class ApiConstants {
  static const String baseUrl =
      "https://www.catalystack.com/fsm_backend_php/api";

  // AUTH
  static const String login = "$baseUrl/auth/login.php";

  // TECHNICIAN
  static const String createTechnician =
      "$baseUrl/technician/create_technician.php";
  static const String getTechnicians =
      "$baseUrl/technician/get_technicians.php";

  // JOB
  static const String createJob = "$baseUrl/job/create_job.php";
  static const String getJobs = "$baseUrl/job/get_jobs.php";
  static const String updateJob = "$baseUrl/job/update_job.php";
  static const String deleteJob = "$baseUrl/job/delete_job.php";
}