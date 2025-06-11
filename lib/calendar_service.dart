import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

class CalendarService {
  final _googleSignIn = GoogleSignIn(
    // ClientId web dari user
    clientId: kIsWeb ? '694484782416-rf2dihcro97ca5qcipu7kihnhehhje1j.apps.googleusercontent.com' : null,
    scopes: [calendar.CalendarApi.calendarReadonlyScope],
  );

  Future<List<calendar.Event>> getUpcomingEvents() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User belum login.');

      // Jika Web, gunakan accessToken dari OAuthCredential
      if (kIsWeb) {
        // Pakai signInWithPopup untuk dapat OAuthCredential
        final provider = GoogleAuthProvider()
          ..addScope('https://www.googleapis.com/auth/calendar.readonly');

        final userCredential = await FirebaseAuth.instance.signInWithPopup(provider);
        final oauthCred = userCredential.credential as OAuthCredential?;
        final accessToken = oauthCred?.accessToken;

        if (accessToken == null) {
          throw Exception("Access token tidak tersedia.");
        }

        final client = _AuthenticatedClient(accessToken);
        final calendarApi = calendar.CalendarApi(client);

        final events = await calendarApi.events.list(
          "primary",
          maxResults: 10,
          orderBy: "startTime",
          singleEvents: true,
          timeMin: DateTime.now().toUtc(),
        );

        return events.items ?? [];
      } else {
        // Untuk Android/iOS, pakai google_sign_in (seperti sebelumnya)
        throw Exception("Gunakan versi mobile untuk non-Web");
      }
    } catch (e) {
      print('Gagal ambil event: $e');
      return [];
    }
  }
}

class _AuthenticatedClient extends http.BaseClient {
  final String _accessToken;
  final http.Client _inner = http.Client();

  _AuthenticatedClient(this._accessToken);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Authorization'] = 'Bearer $_accessToken';
    return _inner.send(request);
  }
}
