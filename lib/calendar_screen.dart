import 'package:flutter/material.dart';
import 'calendar_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> with SingleTickerProviderStateMixin {
  List<String> eventList = [];
  bool isLoading = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void fetchEvents() async {
    if (kIsWeb) return; // Jangan lakukan apapun di web
    setState(() => isLoading = true);
    try {
      final service = CalendarService();
      final events = await service.getUpcomingEvents();
      setState(() {
        eventList = events.map((event) {
          final summary = event.summary ?? 'Tanpa Judul';
          final dateTime = event.start?.dateTime?.toLocal().toString() ??
                           event.start?.date?.toLocal().toString() ??
                           'Tanpa Tanggal';
          return '$summary ($dateTime)';
        }).toList();
        isLoading = false;
      });
      _controller.forward(from: 0);
    } catch (e) {
      setState(() => isLoading = false);
      // Tampilkan dialog error
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Error"),
          content: Text("Gagal mengambil event: $e"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Tutup"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Google Calendar',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 26,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFe0c3fc), Color(0xFF8ec5fc)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8),
            child: kIsWeb
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.deepOrange, size: 60),
                        const SizedBox(height: 24),
                        Text(
                          'Fitur Google Calendar hanya tersedia di aplikasi Android/iOS/Windows.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(fontSize: 20, color: Colors.black54, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: Image.network(
                          'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?auto=format&fit=crop&w=800&q=80',
                          height: 170,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 18),
                      ElevatedButton.icon(
                        onPressed: fetchEvents,
                        icon: const Icon(Icons.refresh, size: 22),
                        label: Text(
                          'Ambil Event Kalender',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7f53ac),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                          elevation: 6,
                          shadowColor: Colors.deepPurple.withOpacity(0.2),
                        ),
                      ),
                      const SizedBox(height: 22),
                      if (isLoading)
                        const CircularProgressIndicator(),
                      if (!isLoading && eventList.isEmpty)
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 32),
                              Image.network(
                                'https://cdn.pixabay.com/photo/2017/01/31/13/14/calendar-2025844_1280.png',
                                height: 120,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(height: 18),
                              Text(
                                'Belum ada event diambil.\nKlik tombol di atas untuk mulai! 😊',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(fontSize: 18, color: Colors.black54, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      if (!isLoading && eventList.isNotEmpty)
                        Expanded(
                          child: FadeTransition(
                            opacity: _fadeAnim,
                            child: ListView.separated(
                              itemCount: eventList.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 16),
                              itemBuilder: (context, index) {
                                return Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.deepPurple.withOpacity(0.10),
                                        blurRadius: 18,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Card(
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    color: Colors.white.withOpacity(0.35),
                                    child: ListTile(
                                      leading: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: const LinearGradient(
                                            colors: [Color(0xFF7f53ac), Color(0xFF647dee)],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(10),
                                        child: const Icon(Icons.event, color: Colors.white, size: 28),
                                      ),
                                      title: Text(
                                        eventList[index],
                                        style: GoogleFonts.poppins(
                                          color: Colors.black87,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}