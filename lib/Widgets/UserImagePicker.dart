import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({super.key, required this.onPickImage});

  final void Function(File? f) onPickImage;

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? pickedImageFile;

  void pickImage() async {
    final pickedImage = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 50, maxWidth: 150);

    if (pickedImage == null) {
      return;
    }

    setState(() {
      pickedImageFile = File(pickedImage.path);
    });

    widget.onPickImage(pickedImageFile);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: pickImage,
          child: CircleAvatar(
            radius: MediaQuery.of(context).size.height  * 0.05,
            backgroundColor: Color.fromARGB(100, 113, 203, 195),
            foregroundImage:
                pickedImageFile != null ? FileImage(pickedImageFile!) : null,
          ),
        ),
        TextButton.icon(
          onPressed: pickImage,
          icon: Icon(Icons.camera_alt,size: 15,color: Color.fromARGB(255, 79, 168, 162),),
          label: Text("Add Image",style: TextStyle(
            fontSize: 17,
            color: Color.fromARGB(255, 79, 168, 162),
          ),),
        ),
      ],
    );
  }
}
