import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/comment_model.dart';

class CommentProvider extends ChangeNotifier {
  List<Comment> _comments = [];
  List<Comment> get comments => _comments;

  Future<void> fetchComments(String songId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('comments')
        .where('songId', isEqualTo: songId)
        .orderBy('timestamp', descending: true)
        .get();
    _comments = snapshot.docs.map((doc) {
      final data = doc.data();
      return Comment(
        id: doc.id,
        songId: data['songId'],
        userId: data['userId'],
        text: data['text'],
        timestamp: (data['timestamp'] as Timestamp).toDate(),
      );
    }).toList();
    notifyListeners();
  }

  Future<void> addComment(String songId, String userId, String text) async {
    await FirebaseFirestore.instance.collection('comments').add({
      'songId': songId,
      'userId': userId,
      'text': text,
      'timestamp': DateTime.now(),
    });
    await fetchComments(songId);
  }

  Future<void> deleteComment(String commentId, String songId) async {
    await FirebaseFirestore.instance
        .collection('comments')
        .doc(commentId)
        .delete();
    await fetchComments(songId);
  }
}
