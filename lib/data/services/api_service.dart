import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      "https://www.catalystack.com/fsm_backend_php/api";

  // =========================
  // SAFE PARSER (NEW)
  // =========================
  static dynamic _safeParse(dynamic value) {
    if (value is String && int.tryParse(value) != null) {
      return int.parse(value);
    }
    return value;
  }

  static Map<String, dynamic> _normalizeMap(Map<String, dynamic> map) {
    final newMap = <String, dynamic>{};

    map.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        newMap[key] = _normalizeMap(value);
      } else if (value is List) {
        newMap[key] = value.map((e) {
          if (e is Map<String, dynamic>) {
            return _normalizeMap(e);
          }
          return _safeParse(e);
        }).toList();
      } else {
        newMap[key] = _safeParse(value);
      }
    });

    return newMap;
  }

  // =========================
  // COMMON REQUEST HANDLER (FIXED++)
  // =========================
  static Future<Map<String, dynamic>> _handleResponse(http.Response res) async {
    try {
      print("STATUS CODE: ${res.statusCode}");
      print("RAW RESPONSE: ${res.body}");

      if (res.body.isEmpty) {
        return {"status": false, "message": "Empty response from server"};
      }

      final decoded = jsonDecode(res.body);

      // ❗ HANDLE STRING RESPONSE
      if (decoded is String) {
        return {"status": false, "message": decoded};
      }

      // ❗ HANDLE NON-MAP RESPONSE
      if (decoded is! Map<String, dynamic>) {
        return {"status": false, "message": "Invalid server format"};
      }

      final data = _normalizeMap(decoded);

      if (res.statusCode == 200) {
        return data;
      } else {
        return {
          "status": false,
          "message": data["message"] ?? "Server error (${res.statusCode})",
        };
      }
    } catch (e) {
      print("JSON ERROR: $e");
      print("RAW RESPONSE (ERROR): ${res.body}");

      return {"status": false, "message": "Invalid server response"};
    }
  }

  // =========================
  // LOGIN
  // =========================
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final res = await http
          .post(
            Uri.parse("$baseUrl/auth/login.php"),
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
            body: jsonEncode({"email": email, "password": password}),
          )
          .timeout(const Duration(seconds: 15));

      return await _handleResponse(res);
    } catch (e) {
      return {"status": false, "message": "Network error"};
    }
  }

  // =========================
  // GET JOBS
  // =========================
  static Future<Map<String, dynamic>> getJobs() async {
    try {
      final res = await http
          .get(
            Uri.parse("$baseUrl/jobs/get_jobs.php"),
            headers: {"Accept": "application/json"},
          )
          .timeout(const Duration(seconds: 15));

      return await _handleResponse(res);
    } catch (e) {
      return {"status": false, "message": "Network error"};
    }
  }

  // =========================
  // CREATE JOB
  // =========================
  static Future<Map<String, dynamic>> createJob(Map data) async {
    try {
      final res = await http
          .post(
            Uri.parse("$baseUrl/jobs/create_job.php"),
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 15));

      return await _handleResponse(res);
    } catch (e) {
      return {"status": false, "message": "Network error"};
    }
  }

  // =========================
  // UPDATE JOB
  // =========================
  static Future<Map<String, dynamic>> updateJob(Map data) async {
    try {
      final res = await http
          .post(
            Uri.parse("$baseUrl/jobs/update_job.php"),
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 15));

      return await _handleResponse(res);
    } catch (e) {
      return {"status": false, "message": "Network error"};
    }
  }

  // =========================
  // DELETE JOB
  // =========================
  static Future<Map<String, dynamic>> deleteJob(int id) async {
    try {
      final res = await http
          .post(
            Uri.parse("$baseUrl/jobs/delete_job.php"),
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
            body: jsonEncode({"id": id}),
          )
          .timeout(const Duration(seconds: 15));

      return await _handleResponse(res);
    } catch (e) {
      return {"status": false, "message": "Network error"};
    }
  }

  // =========================
  // GET TECHNICIANS
  // =========================
  static Future<Map<String, dynamic>> getTechnicians() async {
    try {
      final res = await http
          .get(
            Uri.parse("$baseUrl/technicians/get_technicians.php"),
            headers: {"Accept": "application/json"},
          )
          .timeout(const Duration(seconds: 15));

      return await _handleResponse(res);
    } catch (e) {
      return {"status": false, "message": "Network error"};
    }
  }

  // =========================
  // CREATE TECHNICIAN
  // =========================
  static Future<Map<String, dynamic>> createTechnician(Map data) async {
    try {
      final res = await http
          .post(
            Uri.parse("$baseUrl/technicians/create_technician.php"),
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 15));

      return await _handleResponse(res);
    } catch (e) {
      return {"status": false, "message": "Network error"};
    }
  }

  // =========================
  // DELETE TECHNICIAN
  // =========================
  static Future<Map<String, dynamic>> deleteTechnician(int id) async {
    try {
      final res = await http
          .post(
            Uri.parse("$baseUrl/technicians/delete_technician.php"),
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
            body: jsonEncode({"id": id}),
          )
          .timeout(const Duration(seconds: 15));

      return await _handleResponse(res);
    } catch (e) {
      return {"status": false, "message": "Network error"};
    }
  }
}
