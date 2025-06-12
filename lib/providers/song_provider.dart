import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/song_model.dart';

class SongProvider extends ChangeNotifier {
  List<Song> _songs = [];
  List<Song> get songs => _songs;

  Future<void> fetchSongs({String sortBy = 'latest'}) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'songs_cache';
    try {
      final query = FirebaseFirestore.instance.collection('songs');
      QuerySnapshot snapshot = await query.get();
      _songs = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Song(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          genres: List<String>.from(data['genres'] ?? []),
          originalUrl: data['originalUrl'] ?? '',
          versions: (data['versions'] as List<dynamic>? ?? [])
              .map((v) => SongVersion(
                    genre: v['genre'] ?? '',
                    fileUrl: v['fileUrl'] ?? '',
                    votes: v['votes'] ?? 0,
                    likes: v['likes'] ?? 0,
                  ))
              .toList(),
          timestamp:
              (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
      // Robust JSON cache
      final jsonList = _songs
          .map((s) => jsonEncode({
                'id': s.id,
                'title': s.title,
                'description': s.description,
                'genres': s.genres,
                'originalUrl': s.originalUrl,
                'versions': s.versions
                    .map((v) => {
                          'genre': v.genre,
                          'fileUrl': v.fileUrl,
                          'votes': v.votes,
                          'likes': v.likes,
                        })
                    .toList(),
                'timestamp': s.timestamp.toIso8601String(),
              }))
          .toList();
      prefs.setStringList(cacheKey, jsonList);
    } catch (e) {
      // On error (e.g. offline), try to load from cache
      final cached = prefs.getStringList(cacheKey);
      if (cached != null) {
        _songs = cached.map((s) {
          final data = jsonDecode(s);
          return Song(
            id: data['id'],
            title: data['title'],
            description: data['description'],
            genres: List<String>.from(data['genres']),
            originalUrl: data['originalUrl'],
            versions: (data['versions'] as List<dynamic>)
                .map((v) => SongVersion(
                      genre: v['genre'],
                      fileUrl: v['fileUrl'],
                      votes: v['votes'],
                      likes: v['likes'],
                    ))
                .toList(),
            timestamp: DateTime.parse(data['timestamp']),
          );
        }).toList();
      }
    }
    notifyListeners();
  }

  Future<void> likeSong(String songId, String userId) async {
    // Update Firestore likes for the song
    final doc = FirebaseFirestore.instance.collection('songs').doc(songId);
    await doc.update({
      'likes': FieldValue.increment(1),
    });
    // Optionally update user's likedSongs
    notifyListeners();
  }

  Future<void> voteSong(String songId, String userId) async {
    // Update Firestore votes for the song
    final doc = FirebaseFirestore.instance.collection('songs').doc(songId);
    await doc.update({
      'votes': FieldValue.increment(1),
    });
    // Optionally update user's votedSongs
    notifyListeners();
  }
}
