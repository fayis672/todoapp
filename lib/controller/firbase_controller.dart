import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:todo_app/model/task.dart';

class FirebaseController extends GetxController {
  final CollectionReference _taskRef =
      FirebaseFirestore.instance.collection('task');
  var taskList = <Task>[].obs;

  @override
  void onInit() {
    taskList.bindStream(getTasks());
    super.onInit();
  }

  Future<void> addTask(Task task) async {
    await _taskRef.add(
        {'id': task.id, 'title': task.title, 'is_complete': task.iscomplte});
  }

  Stream<List<Task>> getTasks() {
    return _taskRef.snapshots().map((snapshot) =>
        snapshot.docs.map((snap) => Task.fromQuerySnapshot(snap)).toList());
  }

  Future<void> deleteTask(String id) async {
    var docId = '';
    await _taskRef.where('id', isEqualTo: id).get().then((snap) {
      for (var element in snap.docs) {
        docId = element.reference.id;
      }
    });
    await _taskRef.doc(docId).delete();
  }

  Future<void> updateTask(String id, String title) async {
    var docId = '';
    await _taskRef.where('id', isEqualTo: id).get().then((snap) {
      for (var element in snap.docs) {
        docId = element.reference.id;
      }
    });
    await _taskRef.doc(docId).update({'title': title});
  }

  Future<void> updateStatus(String id, bool isCompelte) async {
    var docId = '';
    await _taskRef.where('id', isEqualTo: id).get().then((snap) {
      for (var element in snap.docs) {
        docId = element.reference.id;
      }
    });
    await _taskRef.doc(docId).update({'is_complete': isCompelte});
  }
}
