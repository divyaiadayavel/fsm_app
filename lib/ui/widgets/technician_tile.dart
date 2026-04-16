import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_ui.dart';

class TechnicianTile extends StatelessWidget {
  final String name;
  final String email;
  final String phone;
  final int jobs;
  final bool online;

  const TechnicianTile({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
    required this.jobs,
    this.online = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppUI.gapSm),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppUI.radiusLg),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white12,
                child: Icon(Icons.person, color: Colors.white, size: 30),
              ),
              Positioned(
                right: 2,
                bottom: 2,
                child: Container(
                  height: 12,
                  width: 12,
                  decoration: BoxDecoration(
                    color: online ? Colors.green : Colors.grey,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.card, width: 2),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: AppUI.gapSm),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: AppUI.caption,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  phone,
                  style: const TextStyle(color: Colors.white38, fontSize: 13),
                ),
              ],
            ),
          ),

          const SizedBox(width: AppUI.gapXs),

          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(AppUI.radiusSm),
                ),
                child: Text(
                  "$jobs Jobs",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: AppUI.caption,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: AppUI.gapXs),

              const Icon(Icons.chevron_right, color: Colors.white54),
            ],
          ),
        ],
      ),
    );
  }
}
