import 'package:chat_application/Model/user_profile.dart';
import 'package:chat_application/Screens/ChatPage.dart';
import 'package:chat_application/Services/database_service.dart';
import 'package:chat_application/Widgets/chatTile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final DatabaseService _databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Messages",
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w600,
              color: Colors.amber,
            ),
          ),
          actions: [
            IconButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                },
                icon: Icon(Icons.exit_to_app,color: Colors.amber,))
          ],
          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.7),
        ),
        body: FutureBuilder(
          future: DatabaseService().getUserProfiles(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                  child: (Text(
                      'Unable to load data with this error = ${snapshot.error}')));
            }
            if (snapshot.hasData && snapshot.data != null) {
              final users = snapshot.data!;
              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  UserProfile user = UserProfile(
                      uid: users[index]['uid'],
                      name: users[index]['name'],
                      imgUrl: users[index]['imgUrl']);
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ChatTile(
                        user: user,
                        onTapUser: () async {
                          final chatExist =
                              await _databaseService.checkChatExists(
                                  FirebaseAuth.instance.currentUser!.uid,
                                  user.uid!);
                          if (!chatExist) {
                            await _databaseService.createNewChat(
                                FirebaseAuth.instance.currentUser!.uid,
                                user.uid!);
                          }
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ChatPage(chatUser: user),
                          ));
                        }),
                  );
                },
              );
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ));
  }
}
