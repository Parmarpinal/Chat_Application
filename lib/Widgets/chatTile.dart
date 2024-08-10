import 'package:chat_application/Model/user_profile.dart';
import 'package:flutter/material.dart';

class ChatTile extends StatelessWidget {
  const ChatTile({super.key, required this.user, required this.onTapUser});

  final UserProfile user;
  final Function onTapUser;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: (){
        onTapUser();
      },
      leading: CircleAvatar(
        foregroundImage: NetworkImage(user.imgUrl!),
        radius: 40,
      ),
      title: Text(
        user.name!,
        style: TextStyle(
          fontSize: 22,
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
