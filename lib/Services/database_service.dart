import 'package:chat_application/Model/chat.dart';
import 'package:chat_application/Model/message.dart';
import 'package:chat_application/Model/user_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference? _userCollection;
  CollectionReference? _chatCollection;

  DatabaseService() {
    setUpCollectionReferences();
  }

  void setUpCollectionReferences() {
    _userCollection = _firestore.collection('users').withConverter<UserProfile>(
      fromFirestore: (snapshot, options) =>
          UserProfile.fromJson(
            snapshot.data()!,
          ),
      toFirestore: (user, options) => user.toJson(),
    );
    _chatCollection = _firestore.collection('chats').withConverter<Chat>(
      fromFirestore: (snapshot, options) => Chat.fromJson(snapshot.data()!),
      toFirestore: (value, options) => value.toJson(),);
  }

  Future<void> createUserProfile({required UserProfile user}) async {
    await _userCollection!.doc(user.uid).set(user);
  }

  Future<List<Map<String, dynamic>>> getUserProfiles() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return [];
    }
    QuerySnapshot snapshot = await _firestore.collection('users').where(
        'uid', isNotEqualTo: currentUser.uid).get();
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  String generateChatID({required String uid1, required String uid2}) {
    List uids = [uid1, uid2];
    uids.sort();
    String chatID = uids.fold("", (id, uid) => "$id$uid");
    return chatID;
  }

  Future<bool> checkChatExists(String id1, String id2) async {
    String chatID = generateChatID(uid1: id1, uid2: id2);
    final result = await _chatCollection?.doc(chatID).get();
    if(result != null){
      return result.exists;
    }
    return false;
  }

  Future<void> createNewChat(String id1, String id2) async {
    String chatID = generateChatID(uid1: id1, uid2: id2);
    final docRef = _chatCollection!.doc(chatID);
    final chat = Chat(id: chatID, participants: [id1, id2], messages: []);
    await docRef.set(chat);
  }

  Future<void> sendChatMessage(String uid1, String uid2, Message message) async {
    String chatID = generateChatID(uid1: uid1, uid2: uid2);
    final docRef = _chatCollection!.doc(chatID);
    await docRef.update({
      "messages" : FieldValue.arrayUnion(
        [
          message.toJson(),
        ]
      )
    });
  }

  Stream<DocumentSnapshot<Chat>> getChatData(String uid1, String uid2) {
    String chatId = generateChatID(uid1: uid1, uid2: uid2);
    return _chatCollection?.doc(chatId).snapshots() as Stream<DocumentSnapshot<Chat>>;
  }
}
