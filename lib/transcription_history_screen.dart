import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For date formatting

class TranscriptionHistoryScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transcription History'),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('transcriptions').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var transcriptions = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.all(10),
            itemCount: transcriptions.length,
            itemBuilder: (context, index) {
              var transcription = transcriptions[index];
              var recognizedText = transcription['recognizedText'];
              var translatedText = transcription['translatedText'];
              var timestamp = (transcription['timestamp'] as Timestamp).toDate();

              return Dismissible(
                key: Key(transcription.id),
                onDismissed: (direction) {
                  _firestore.collection('transcriptions').doc(transcription.id).delete();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Transcription deleted')),
                  );
                },
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 20),
                  child: Icon(Icons.delete, color: Colors.white),
                ),
                child: Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(15),
                    title: Text(
                      recognizedText,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 5),
                        Text(
                          translatedText,
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                        SizedBox(height: 5),
                        Text(
                          DateFormat.yMMMd().add_jm().format(timestamp),
                          style: TextStyle(fontSize: 14, color: Colors.black45),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
