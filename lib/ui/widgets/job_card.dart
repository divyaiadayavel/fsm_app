import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class JobCard extends StatelessWidget {
  final String title;
  final String company;
  final String location;
  final String technician;
  final String priority;
  final String status;
  final Color sideColor;

  const JobCard({
    super.key,
    required this.title,
    required this.company,
    required this.location,
    required this.technician,
    required this.priority,
    required this.status,
    required this.sideColor,
  });

  Color tagColor(String value) {
    switch (value.toLowerCase()) {
      case "high":
        return Colors.redAccent;
      case "medium":
        return Colors.blueAccent;
      case "low":
        return Colors.grey;
      case "pending":
        return Colors.orange;
      case "in progress":
        return Colors.blue;
      case "completed":
        return Colors.green;
      default:
        return Colors.black54;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 230,
            decoration: BoxDecoration(
              color: sideColor,
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(24),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      badge(priority.toUpperCase(), tagColor(priority)),
                      const SizedBox(width: 8),
                      badge(status.toUpperCase(), tagColor(status)),
                      const Spacer(),
                      const Icon(Icons.more_vert, color: Colors.black54),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  Text(
                    company,
                    style: const TextStyle(fontSize: 20, color: Colors.black87),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: Colors.black54,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          location,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Divider(color: Color(0xFFE5E7EB), height: 30),

                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: const Color(0xFFEDE9FE),
                        child: Icon(Icons.person, color: AppColors.primary),
                      ),
                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              technician,
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Text(
                              "FIELD TECH",
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        height: 52,
                        width: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.chevron_right,
                          color: Colors.black,
                          size: 34,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }
}
