import 'package:flutter/material.dart';
import '../../data/services/api_service.dart';

class UpdateJobScreen extends StatefulWidget {
  final Map job;
  final VoidCallback onUpdated;

  const UpdateJobScreen({
    super.key,
    required this.job,
    required this.onUpdated,
  });

  @override
  State<UpdateJobScreen> createState() => _UpdateJobScreenState();
}

class _UpdateJobScreenState extends State<UpdateJobScreen> {
  late TextEditingController titleController;
  String status = "Pending";

  @override
  void initState() {
    super.initState();
    titleController =
        TextEditingController(text: widget.job["title"]);
    status = widget.job["status"];
  }

  Future<void> updateJob() async {
    final response = await ApiService.updateJob({
      "id": widget.job["id"],
      "title": titleController.text,
      "status": status,
    });

    if (response['status'] == true) {
      widget.onUpdated();
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'])),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Update Job")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Job Title"),
            ),
            const SizedBox(height: 20),

            DropdownButton<String>(
              value: status,
              isExpanded: true,
              items: [
                "Pending",
                "In Progress",
                "Completed",
                "Cancelled"
              ].map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e),
                  )).toList(),
              onChanged: (value) {
                setState(() {
                  status = value!;
                });
              },
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: updateJob,
              child: const Text("Update Job"),
            ),
          ],
        ),
      ),
    );
  }
}