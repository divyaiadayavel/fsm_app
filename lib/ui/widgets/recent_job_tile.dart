import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_ui.dart';

class RecentJobTile extends StatelessWidget {
  final String title;
  final String location;
  final String status;
  final String time;
  final IconData icon;

  const RecentJobTile({
    super.key,
    required this.title,
    required this.location,
    required this.status,
    required this.time,
    required this.icon,
  });

  Color getStatusColor() {
    switch (status) {
      case "Pending":
        return Colors.orange;
      case "Completed":
        return Colors.green;
      case "In Progress":
        return Colors.blue;
      case "Cancelled":
        return Colors.red;
      default:
        return Colors.white54;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppUI.gapSm),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppUI.radiusMd),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white10,
            child: Icon(icon, color: Colors.white, size: AppUI.body),
          ),

          const SizedBox(width: AppUI.gapSm),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  "$location • $time",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                ),
              ],
            ),
          ),

          const SizedBox(width: AppUI.gapXs),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: getStatusColor().withOpacity(.15),
              borderRadius: BorderRadius.circular(AppUI.radiusLg),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: getStatusColor(),
                fontWeight: FontWeight.w600,
                fontSize: AppUI.caption,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
