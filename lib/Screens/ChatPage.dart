import 'dart:io';

import 'package:chat_application/Model/chat.dart';
import 'package:chat_application/Model/message.dart';
import 'package:chat_application/Model/user_profile.dart';
import 'package:chat_application/Services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:image_picker/image_picker.dart';

class ChatPage extends StatefulWidget {
  final UserProfile chatUser;

  const ChatPage({super.key, required this.chatUser});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  ChatUser? currentUser, otherUser;
  DatabaseService _databaseService = DatabaseService();

  @override
  void initState() {
    super.initState();
    currentUser = ChatUser(
        id: FirebaseAuth.instance.currentUser!.uid,
        firstName: FirebaseAuth.instance.currentUser!.displayName);
    otherUser = ChatUser(
        id: widget.chatUser.uid!,
        firstName: widget.chatUser.name,
        profileImage: widget.chatUser.imgUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.chatUser.name!,
            style: TextStyle(
                color: Colors.amber, fontSize: 25, fontWeight: FontWeight.w600),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            color: Colors.amber,
            iconSize: 27,// Change this to your desired color
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          backgroundColor:
              Theme.of(context).colorScheme.primary.withOpacity(0.7),
        ),
        body: StreamBuilder(
          stream: _databaseService.getChatData(currentUser!.id, otherUser!.id),
          builder: (context, snapshot) {
            Chat? chat = snapshot.data?.data();
            List<ChatMessage> msg = [];
            if (chat != null && chat.messages != null) {
              msg = _generateChatMessages(chat.messages!);
            }
            return DashChat(
                messageOptions: MessageOptions(
                    showOtherUsersAvatar: true,
                    showTime: true,
                    containerColor: Color.fromARGB(98, 8, 248, 219),
                    //Color.fromARGB(85, 130, 250, 235),
                    textColor: Color.fromARGB(255, 56, 74, 80),
                    timeTextColor: Colors.orange.shade600,
                    currentUserContainerColor:
                        Theme.of(context).colorScheme.primary,
                    currentUserTextColor: Colors.white,
                    currentUserTimeTextColor: Colors.amber),
                inputOptions: InputOptions(
                  alwaysShowSend: true,
                  autocorrect: true,
                  trailing: [_mediaMessageButton()],
                ),
                currentUser: currentUser!,
                onSend: (message) {
                  _sendMessage(message);
                },
                messages: msg);
          },
        ));
  }

  Future<void> _sendMessage(ChatMessage chatMessage) async {
    if (chatMessage.medias?.isNotEmpty ?? false) {
      if(chatMessage.medias!.first.type == MediaType.image){
        Message msg = Message(senderID: chatMessage.user.id, content: chatMessage.medias!.first.url, messageType: MessageType.Image, sentAt: Timestamp.fromDate(chatMessage.createdAt));
        await _databaseService.sendChatMessage(currentUser!.id, otherUser!.id, msg);
      }
    } else {
      Message message = Message(
        senderID: currentUser!.id,
        content: chatMessage.text,
        messageType: MessageType.Text,
        sentAt: Timestamp.fromDate(chatMessage.createdAt),
      );
      await _databaseService.sendChatMessage(
          currentUser!.id, otherUser!.id, message);
    }
  }

  List<ChatMessage> _generateChatMessages(List<Message> message) {
    List<ChatMessage> chatMessages = message.map((m) {
      if(m.messageType == MessageType.Image){
        return ChatMessage(user: m.senderID == currentUser!.id ? currentUser! : otherUser!, createdAt: m.sentAt!.toDate(), medias: [
          ChatMedia(url: m.content!, fileName: "", type: MediaType.image),
        ]);
      }else{
        return ChatMessage(
            user: m.senderID == currentUser!.id ? currentUser! : otherUser!,
            text: m.content!,
            createdAt: m.sentAt!.toDate());
      }
    }).toList();
    chatMessages.sort((a, b) {
      return b.createdAt.compareTo(a.createdAt);
    });
    return chatMessages;
  }

  Widget _mediaMessageButton() {
    return IconButton(
      onPressed: () async {
        final pickedImage = await ImagePicker().pickImage(
            source: ImageSource.camera, imageQuality: 50, maxWidth: 150);
        File? imageFile = File(pickedImage!.path);
        if (imageFile != null) {
          String chatID = _databaseService.generateChatID(
              uid1: currentUser!.id, uid2: otherUser!.id);
          String? downloadedURL =
              await uploadImageToChat(file: imageFile, chatID: chatID);
          if (downloadedURL != null) {
            ChatMessage chatmsg = ChatMessage(
                user: currentUser!,
                createdAt: DateTime.now(),
                medias: [
                  ChatMedia(
                      url: downloadedURL, fileName: "", type: MediaType.image)
                ]);
            _sendMessage(chatmsg);
          }
        }
      },
      icon: Icon(Icons.image),
      color: Theme.of(context).primaryColor,
    );
  }

  Future<String?> uploadImageToChat(
      {required File file, required String chatID}) async {
    Reference fileRef = FirebaseStorage.instance
        .ref('chats/$chatID')
        .child('${DateTime.now().toIso8601String()}${file.path}');
    await fileRef.putFile(file);
    final downloadUrl = await fileRef.getDownloadURL();
    return downloadUrl;
  }
}
