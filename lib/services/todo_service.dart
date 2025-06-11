import 'package:cloud_firestore/cloud_firestore.dart';

class TodoService {
  final CollectionReference todosCollection =
      FirebaseFirestore.instance.collection('todos');

  Stream<QuerySnapshot> getTodosStream() {
    return todosCollection.orderBy('timestamp', descending: true).snapshots();
  }

  Future<void> addTodo(String text) async {
    await todosCollection.add({
      'text': text,
      'done': false,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateTodoDone(String id, bool done) async {
    await todosCollection.doc(id).update({'done': done});
  }

  Future<void> deleteTodo(String id) async {
    await todosCollection.doc(id).delete();
  }

  Future<void> updateTodoText(String id, String newText) async {
    await todosCollection.doc(id).update({
      'text': newText,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
} 