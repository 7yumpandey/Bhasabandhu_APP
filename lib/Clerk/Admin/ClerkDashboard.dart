import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../transcription_history_screen.dart';

class ClerkDashboard extends StatefulWidget {
  @override
  _ClerkDashboardState createState() => _ClerkDashboardState();
}

class _ClerkDashboardState extends State<ClerkDashboard> {
  final TextEditingController _searchController = TextEditingController();
  String _searchField = 'name';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Clerk Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: _search,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                DropdownButton<String>(
                  value: _searchField,
                  items: ['name', 'caseNumber'].map((field) {
                    return DropdownMenuItem(
                      value: field,
                      child: Text(field),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _searchField = value!;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final users = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final searchValue = _searchController.text.toLowerCase();

                    if (_searchField == 'name') {
                      return data['name'] != null &&
                          data['name'].toString().toLowerCase().contains(searchValue);
                    } else {
                      return data['caseNumber'] != null &&
                          data['caseNumber'].toString().toLowerCase().contains(searchValue);
                    }
                  }).toList();

                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index].data() as Map<String, dynamic>;

                      return ListTile(
                        title: Text(user['name'] ?? 'No Name'),
                        subtitle: Text('Case Number: ${user['caseNumber'] ?? 'No Case Number'}'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TranscriptionHistoryScreen(),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _search() {
    setState(() {}); // Trigger a rebuild to apply the search filter
  }
}
