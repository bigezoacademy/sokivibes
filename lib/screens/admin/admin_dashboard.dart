import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
// For web file picking
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';
import '../../providers/auth_provider.dart';
import 'package:provider/provider.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  Future<int> _getSongCount() async {
    final snapshot = await FirebaseFirestore.instance.collection('songs').get();
    return snapshot.size;
  }

  Future<int> _getUserCount() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    return snapshot.size;
  }

  @override
  Widget build(BuildContext context) {
    // Only show the upload form, not analytics
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _UploadSongForm(),
        ),
      ),
    );
  }
}

class _UploadSongForm extends StatefulWidget {
  @override
  State<_UploadSongForm> createState() => _UploadSongFormState();
}

class _UploadSongFormState extends State<_UploadSongForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _lyricsController = TextEditingController();
  String? _selectedGenre;
  String? _fileName;
  int? _fileSize;
  String? _downloadUrl;
  bool _isUploading = false;
  List<html.File>? _selectedFiles;
  List<String?> _uploadedUrls = List.filled(6, null);
  int _uploadingIndex = -1;
  double _uploadProgress = 0.0;
  static const genres = [
    'Afrobeat',
    'Pop',
    'Jazz',
    'Hip-Hop',
    'R&B',
    'Gospel',
    'Reggae',
    'Rock',
    'Classical',
    'Other'
  ];

  Future<void> _pickFiles() async {
    final uploadInput = html.FileUploadInputElement();
    uploadInput.accept = '.mp3,audio/*';
    uploadInput.multiple = true;
    uploadInput.click();
    await uploadInput.onChange.first;
    final files = uploadInput.files;
    if (files == null || files.isEmpty) return;
    setState(() {
      _selectedFiles = files.take(6).toList();
      _uploadedUrls = List.filled(6, null);
    });
  }

  Future<void> _uploadFiles() async {
    if (_selectedFiles == null || _selectedFiles!.isEmpty) return;
    setState(() {
      _uploadingIndex = 0;
      _uploadProgress = 0.0;
      _isUploading = true;
    });
    for (int i = 0; i < _selectedFiles!.length; i++) {
      final file = _selectedFiles![i];
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      await reader.onLoad.first;
      try {
        dynamic result = reader.result;
        Uint8List bytes;
        if (result is Uint8List) {
          bytes = result;
        } else if (result is ByteBuffer) {
          bytes = Uint8List.view(result);
        } else if (result is List<int>) {
          bytes = Uint8List.fromList(result);
        } else {
          throw Exception(
              'Unsupported file data type: \\${result.runtimeType}');
        }
        final ref = firebase_storage.FirebaseStorage.instance
            .ref('songs/${DateTime.now().millisecondsSinceEpoch}_${file.name}');
        final uploadTask = ref.putData(bytes);
        uploadTask.snapshotEvents.listen((event) {
          if (event.totalBytes > 0 && _uploadingIndex == i) {
            setState(() {
              _uploadProgress = event.bytesTransferred / event.totalBytes;
            });
          }
        });
        final snapshot = await uploadTask.whenComplete(() {});
        final url = await snapshot.ref.getDownloadURL();
        setState(() {
          _uploadedUrls[i] = url;
        });
        print('Upload successful: \\${file.name}');
      } catch (e) {
        print('Upload failed: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
        setState(() {
          _isUploading = false;
          _uploadingIndex = -1;
        });
        return;
      }
      setState(() {
        _uploadingIndex = i + 1;
        _uploadProgress = 0.0;
      });
    }
    setState(() {
      _isUploading = false;
      _uploadingIndex = -1;
      _fileName = _selectedFiles!.first.name;
      _fileSize = _selectedFiles!.first.size;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All files uploaded!')),
    );
    // Automatically submit after upload
    await _submit();
  }

  Future<void> _submit() async {
    if (_uploadedUrls[0] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please upload at least the original song file.')),
      );
      return;
    }
    final title = _titleController.text.trim().isEmpty
        ? _fileName
        : _titleController.text.trim();
    final genre = _selectedGenre ?? genres.first;
    final fileSize = _fileSize ?? 0;
    final description = _descriptionController.text.trim();
    final lyrics = _lyricsController.text.trim();
    // Prepare versions: first file is original, rest are covers with their file names as title
    final List<Map<String, dynamic>> versions = [];
    // Original
    versions.add({
      'type': 'raw',
      'fileUrl': _uploadedUrls[0],
      'genre': genre,
      'title': title,
      'votes': 0,
      'likes': 0,
    });
    // Covers
    for (int i = 1; i < _uploadedUrls.length; i++) {
      if (_uploadedUrls[i] != null &&
          _selectedFiles != null &&
          i < _selectedFiles!.length) {
        versions.add({
          'type': 'ai_cover',
          'fileUrl': _uploadedUrls[i],
          'genre': genre,
          'title': _selectedFiles![i].name,
          'votes': 0,
          'likes': 0,
        });
      }
    }
    await FirebaseFirestore.instance.collection('songs').add({
      'title': title,
      'genres': [genre],
      'originalUrl': _uploadedUrls[0],
      'fileSize': fileSize,
      'description': description,
      'lyrics': lyrics,
      'timestamp': FieldValue.serverTimestamp(),
      'versions': versions,
      'aiCovers': _uploadedUrls.sublist(1),
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Song added to library!')),
    );
    _titleController.clear();
    _descriptionController.clear();
    _lyricsController.clear();
    setState(() {
      _selectedGenre = null;
      _fileName = null;
      _fileSize = null;
      _downloadUrl = null;
      _selectedFiles = null;
      _uploadedUrls = List.filled(6, null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Upload New Song',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Song Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLength: 150,
                decoration: const InputDecoration(
                  labelText: 'Description (max 150 chars)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedGenre,
                items: genres
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedGenre = val),
                decoration: const InputDecoration(
                  labelText: 'Genre',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lyricsController,
                minLines: 3,
                maxLines: 8,
                decoration: const InputDecoration(
                  labelText: 'Lyrics',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),
              // Original song file button
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.upload_file, size: 28),
                      label: Text(
                          _selectedFiles == null || _selectedFiles!.isEmpty
                              ? 'Select original song file'
                              : 'Original: \\${_selectedFiles![0].name}'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 18),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                      onPressed: _isUploading
                          ? null
                          : () async {
                              final uploadInput = html.FileUploadInputElement();
                              uploadInput.accept = '.mp3,audio/*';
                              uploadInput.multiple = false;
                              uploadInput.click();
                              await uploadInput.onChange.first;
                              final files = uploadInput.files;
                              if (files == null || files.isEmpty) return;
                              setState(() {
                                if (_selectedFiles == null) {
                                  _selectedFiles =
                                      List<html.File>.filled(1, files.first);
                                } else if (_selectedFiles!.isEmpty) {
                                  _selectedFiles = [files.first];
                                } else {
                                  // Replace the original file, keep covers if any
                                  if (_selectedFiles!.length == 1) {
                                    _selectedFiles![0] = files.first;
                                  } else {
                                    _selectedFiles![0] = files.first;
                                  }
                                }
                                _uploadedUrls[0] = null;
                              });
                            },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Cover(s) file button
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.library_music, size: 24),
                      label: Text(_selectedFiles == null ||
                              _selectedFiles!.length <= 1
                          ? 'Select cover(s) (up to 5)'
                          : 'Covers: \\${_selectedFiles!.length - 1} selected'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 18),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      onPressed: _isUploading
                          ? null
                          : () async {
                              final uploadInput = html.FileUploadInputElement();
                              uploadInput.accept = '.mp3,audio/*';
                              uploadInput.multiple = true;
                              uploadInput.click();
                              await uploadInput.onChange.first;
                              final files = uploadInput.files;
                              if (files == null || files.isEmpty) return;
                              setState(() {
                                if (_selectedFiles == null ||
                                    _selectedFiles!.isEmpty) {
                                  // No original selected yet, add a placeholder for original
                                  _selectedFiles =
                                      List<html.File>.filled(1, files.first);
                                  _selectedFiles!.addAll(files.take(5));
                                } else {
                                  // Keep the original, replace covers
                                  _selectedFiles = [_selectedFiles![0]];
                                  _selectedFiles!.addAll(files.take(5));
                                }
                                // Reset uploadedUrls for covers
                                for (int i = 1; i < 6; i++) {
                                  _uploadedUrls[i] = null;
                                }
                              });
                            },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isUploading ? null : _uploadFiles,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  minimumSize: const Size.fromHeight(48),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: _isUploading
                    ? const Text('Uploading...')
                    : const Text('Upload'),
              ),
              if (_isUploading)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Column(
                    children: [
                      LinearProgressIndicator(
                        value: _uploadProgress > 0 ? _uploadProgress : null,
                        minHeight: 4,
                        color: Colors.pink,
                        backgroundColor: Colors.pink.shade100,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _uploadProgress > 0
                            ? 'Uploading: ${(100 * _uploadProgress).toStringAsFixed(0)}%'
                            : 'Uploading...',
                        style: const TextStyle(
                            color: Colors.pink, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              if (_fileSize != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                      'File size: \\${(_fileSize! / (1024 * 1024)).toStringAsFixed(2)} MB'),
                ),
            ],
          ),
        ),
      ), // Close Padding
    ); // Close Card
  }
}
