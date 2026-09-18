import 'package:dio/dio.dart';

/// Shared Dio client for the `journaly-backend` FastAPI server.
///
/// `ApiJournalRepository`/`ApiPsychologistRepository` use this to talk to
/// the real backend (see backend.md in this repo for the endpoint
/// contract).
class ApiClient {
  ApiClient._();

  // Points at `localhost` from the app's perspective. Depending on where
  // you're running the app, that resolves differently:
  // - Chrome / Windows desktop: works as-is, same machine as the backend.
  // - Physical Android device (USB): run `adb reverse tcp:8000 tcp:8000`
  //   once so the phone's 127.0.0.1:8000 forwards to your PC.
  // - Android emulator: use `http://10.0.2.2:8000` instead.
  // - Physical device over Wi-Fi (no adb reverse): use your PC's LAN IP,
  //   e.g. `http://192.168.1.23:8000`.
  static const String baseUrl = 'http://127.0.0.1:8000';

  static final Dio instance = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
}
