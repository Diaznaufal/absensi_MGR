import 'dart:async';
import 'dart:io';

import 'package:flutter_absensi_app/core/constants/variables.dart';
import 'package:http/http.dart' as http;

class BackendConnectionHelper {
  /// Check if backend is reachable
  /// Returns true if backend is accessible, false otherwise
  static Future<bool> checkBackendConnection() async {
    try {
      final uri = Uri.parse('${Variables.baseUrl}/api/health');

      // Try to connect with a timeout
      final response = await http
          .get(uri)
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              // Return a failed response on timeout
              return http.Response('Connection Timeout', 408);
            },
          );

      // If we get any response (even error), backend is reachable
      // We just want to check if we can connect to it
      return response.statusCode < 500;
    } on SocketException catch (_) {
      // No internet or server not reachable
      return false;
    } on TimeoutException catch (_) {
      // Connection timeout
      return false;
    } catch (e) {
      // Any other error means we can't connect
      return false;
    }
  }

  /// Alternative check using simple socket connection
  /// This is faster but less reliable for HTTP endpoints
  static Future<bool> checkBackendSocket() async {
    try {
      final uri = Uri.parse(Variables.baseUrl);
      final host = uri.host;
      final port = uri.port != 0 ? uri.port : (uri.scheme == 'https' ? 443 : 80);

      final socket = await Socket.connect(
        host,
        port,
        timeout: const Duration(seconds: 3),
      );

      socket.destroy();
      return true;
    } on SocketException catch (_) {
      return false;
    } on TimeoutException catch (_) {
      return false;
    } catch (e) {
      return false;
    }
  }
}
