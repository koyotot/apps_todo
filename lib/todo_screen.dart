import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';
import 'signin_screen.dart';
import 'services/todo_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({Key? key}) : super(key: key);

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> with TickerProviderStateMixin {
  final TodoService _todoService = TodoService();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<DocumentSnapshot> _todos = [];
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;
  String _filter = 'Semua';
  String _search = '';
  bool _showCelebration = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _logout() async {
    await AuthService().signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const SignInScreen()),
      (route) => false,
    );
  }

  Future<void> _showAddOrEditTodoDialog({String? initial, String? id}) async {
    final controller = TextEditingController(text: initial ?? '');
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Center(
          child: FadeTransition(
            opacity: CurvedAnimation(
              parent: ModalRoute.of(context)!.animation!,
              curve: Curves.easeInOut,
            ),
            child: Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.10),
                      blurRadius: 32,
                      offset: Offset(0, 16),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Icon(
                        id == null ? Icons.add_task_rounded : Icons.edit,
                        color: Colors.orange.shade700,
                        size: 38,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      id == null ? 'Tambah Tugas' : 'Edit Tugas',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Colors.deepPurple,
                      ),
        ),
                    const SizedBox(height: 18),
                    TextField(
          controller: controller,
          autofocus: true,
                      style: GoogleFonts.poppins(fontSize: 16, color: Colors.deepPurple),
          decoration: InputDecoration(
                        hintText: 'Tulis tugas...'
                          ,hintStyle: GoogleFonts.poppins(color: Colors.deepPurple.shade200),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.orange.shade100, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.orange.shade700, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        fillColor: Colors.orange.shade50,
                        filled: true,
          ),
          onSubmitted: (val) => Navigator.of(context).pop(val),
        ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
          TextButton(
                          child: Text('Batal', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.deepPurple)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
                          child: Text(id == null ? 'Tambah Tugas' : 'Simpan', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
                            backgroundColor: id == null ? Colors.orange.shade700 : Colors.blueAccent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                            elevation: 4,
            ),
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
          ),
        ],
      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
    if (result != null && result.isNotEmpty) {
      if (id == null) {
      await _todoService.addTodo(result);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tugas berhasil ditambahkan!', style: GoogleFonts.poppins()), backgroundColor: Colors.green.shade600),
      );
      } else {
        await _todoService.updateTodoText(id, result);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tugas berhasil diubah!', style: GoogleFonts.poppins()), backgroundColor: Colors.blue.shade600),
        );
      }
    }
  }

  Future<void> _deleteTodo(String id) async {
    await _todoService.deleteTodo(id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: const Text('Tugas dihapus!'), backgroundColor: Colors.red.shade400),
    );
  }

  Future<void> _toggleDone(String id, bool done) async {
    await _todoService.updateTodoDone(id, done);
  }

  void _showCelebrationEffect() {
    setState(() => _showCelebration = true);
    Future.delayed(const Duration(seconds: 2), () => setState(() => _showCelebration = false));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 12, top: 4, bottom: 4),
          child: GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (context) {
                  final hour = DateTime.now().hour;
                  String greeting;
                  if (hour >= 4 && hour < 11) {
                    greeting = 'Selamat Pagi!';
                  } else if (hour >= 11 && hour < 15) {
                    greeting = 'Selamat Siang!';
                  } else if (hour >= 15 && hour < 18) {
                    greeting = 'Selamat Sore!';
                  } else {
                    greeting = 'Selamat Malam!';
                  }
                  return Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.10),
                          blurRadius: 32,
                          offset: Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFD580), Color(0xFFFFA726)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(6),
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 44,
                            child: Icon(Icons.person, color: Colors.deepPurple, size: 54),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          '👋 $greeting',
                          style: GoogleFonts.montserrat(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Semangat mengerjakan tugas hari ini! 🚀',
                          style: GoogleFonts.poppins(
                            color: Colors.deepPurple.shade300,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 18),
                        ElevatedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                          label: Text('Tutup', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade700,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD580), Color(0xFFFFA726)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.18),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(3),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 24,
                child: Icon(Icons.person, color: Colors.deepPurple, size: 28),
              ),
            ),
          ),
        ),
        title: null,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            tooltip: 'Google Calendar',
            onPressed: () {
              Navigator.pushNamed(context, '/calendar');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOrEditTodoDialog(),
        backgroundColor: Colors.orange.shade700,
        child: const Icon(Icons.add, size: 32),
        tooltip: 'Tambah Tugas',
        elevation: 8,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade700, Colors.blueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
          child: Column(
            children: [
              const SizedBox(height: 24),
                // Logo dan judul utama
                Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 32,
                            offset: Offset(0, 16),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'web/icons/logo_ilustration.png',
                        width: 130,
                        height: 130,
                      ),
                    ),
              const SizedBox(height: 10),
                    Text(
                      'Tugas Kuliahku',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                  shadows: [Shadow(color: Colors.black26, blurRadius: 8)],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                // Filter buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (final f in ['Semua', 'Belum Selesai', 'Selesai'])
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: _filter == f ? Colors.orange.shade200 : Colors.white.withOpacity(0.13),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: _filter == f
                                ? [BoxShadow(color: Colors.orange.withOpacity(0.18), blurRadius: 8, offset: Offset(0, 4))]
                                : [],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => setState(() => _filter = f),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                                child: Text(
                                  f,
                                  style: GoogleFonts.poppins(
                                    color: _filter == f ? Colors.deepPurple : Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _todoService.getTodosStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.13),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.deepPurple.withOpacity(0.18),
                                      blurRadius: 24,
                                      offset: Offset(0, 8),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(32),
                                child: Icon(Icons.check_circle_outline_rounded, color: Colors.orange.shade200, size: 72),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Belum ada tugas, yuk mulai catat tugasmu! ✨',
                                style: GoogleFonts.poppins(
                                  color: Colors.white70,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                        ),
                      );
                    }
                      var docs = snapshot.data!.docs;
                      // Filter logic
                      if (_filter == 'Selesai') {
                        docs = docs.where((d) => d['done'] == true).toList();
                      } else if (_filter == 'Belum Selesai') {
                        docs = docs.where((d) => d['done'] != true).toList();
                      }
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      itemCount: docs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                          final data = doc.data() as Map<String, dynamic>;
                          final text = data['text'] ?? '';
                          final done = data['done'] ?? false;
                          final created = data.containsKey('createdAt') && data['createdAt'] != null
                              ? DateFormat('dd MMM yyyy, HH:mm').format((data['createdAt'] as Timestamp).toDate())
                              : '';
                        return AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                          child: Card(
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                              color: done
                                  ? Colors.greenAccent.withOpacity(0.18)
                                  : Colors.white.withOpacity(0.18),
                              shadowColor: done
                                  ? Colors.greenAccent.withOpacity(0.2)
                                  : Colors.deepPurple.withOpacity(0.2),
                            child: ListTile(
                                leading: Checkbox(
                                  value: done,
                                  onChanged: (_) => _toggleDone(doc.id, !done),
                                  activeColor: Colors.deepPurple,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              ),
                              title: Text(
                                text,
                                  style: GoogleFonts.poppins(
                                  color: done ? Colors.grey.shade400 : Colors.white,
                                  fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  decoration: done ? TextDecoration.lineThrough : null,
                                  letterSpacing: 0.5,
                                ),
                              ),
                                subtitle: created.isNotEmpty ? Text('Dibuat: $created', style: GoogleFonts.poppins(fontSize: 12, color: Colors.white54)) : null,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.deepPurple, size: 24),
                                      tooltip: 'Edit',
                                      onPressed: () => _showAddOrEditTodoDialog(initial: text, id: doc.id),
                                    ),
                                    IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 28),
                                tooltip: 'Hapus',
                                onPressed: () => _deleteTodo(doc.id),
                              ),
                                  ],
                                ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
            ),
          ),
        ),
      ),
    );
  }
}
