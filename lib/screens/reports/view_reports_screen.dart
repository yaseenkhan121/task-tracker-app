import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reports")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("tasks").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final tasks = snapshot.data!.docs;
          final total = tasks.length;
          final completed = tasks.where((t) => t["isCompleted"] == true).length;
          final pending = total - completed;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildStat("Total Tasks", total, Colors.blue),
                _buildStat("Completed", completed, Colors.green),
                _buildStat("Pending", pending, Colors.orange),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStat(String title, int count, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color, child: Text(count.toString())),
        title: Text(title),
      ),
    );
  }
}
