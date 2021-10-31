import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  String? id;
  String? title;
  bool? iscomplte;

  Task(this.id, this.title, this.iscomplte);

  Task.fromQuerySnapshot(QueryDocumentSnapshot snapshot) {
    id = snapshot.get('id');
    title = snapshot.get('title');
    iscomplte = snapshot.get('is_complete');
  }
}
