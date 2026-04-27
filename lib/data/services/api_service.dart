import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      "http://192.168.1.5/fsm_backend_php/api";

  // =========================
  // LOGIN
  // =========================
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final res = await http.post(
      Uri.parse("$baseUrl/auth/login.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    return jsonDecode(res.body);
  }

  // =========================
  // GET JOBS
  // =========================
  static Future<Map<String, dynamic>> getJobs() async {
    final res = await http.get(
      Uri.parse("$baseUrl/jobs/get_jobs.php"),
    );

    return jsonDecode(res.body);
  }

  // =========================
  // CREATE JOB ❗ FIXED
  // =========================
  static Future<Map<String, dynamic>> createJob(Map data) async {
    final res = await http.post(
      Uri.parse("$baseUrl/jobs/create_job.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    return jsonDecode(res.body);
  }

  // =========================
  // UPDATE JOB
  // =========================
  static Future<Map<String, dynamic>> updateJob(Map data) async {
    final res = await http.post(
      Uri.parse("$baseUrl/jobs/update_job.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    return jsonDecode(res.body);
  }

  // =========================
  // DELETE JOB
  // =========================
  static Future<Map<String, dynamic>> deleteJob(int id) async {
    final res = await http.post(
      Uri.parse("$baseUrl/jobs/delete_job.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"id": id}),
    );

    return jsonDecode(res.body);
  }

  // =========================
  // GET TECHNICIANS ❗ FIXED
  // =========================
  static Future<Map<String, dynamic>> getTechnicians() async {
    final res = await http.get(
      Uri.parse("$baseUrl/technicians/get_technicians.php"),
    );

    return jsonDecode(res.body);
  }
}