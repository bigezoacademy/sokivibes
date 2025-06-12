import 'package:flutter/material.dart';

class CommentBox extends StatelessWidget {
  final String userName;
  final String comment;
  final String date;
  final VoidCallback? onDelete;
  final bool isAdmin;

  const CommentBox({
    super.key,
    required this.userName,
    required this.comment,
    required this.date,
    this.onDelete,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        title: Text(userName, style: Theme.of(context).textTheme.labelMedium),
        subtitle: Text(comment),
        trailing: isAdmin && onDelete != null
            ? IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: onDelete,
              )
            : null,
        dense: true,
      ),
    );
  }
}
