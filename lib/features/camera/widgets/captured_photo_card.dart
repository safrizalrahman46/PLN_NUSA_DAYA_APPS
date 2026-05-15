import 'dart:io';

import 'package:flutter/material.dart';

class CapturedPhotoCard extends StatelessWidget {
  const CapturedPhotoCard({super.key, required this.path});

  final String? path;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.2,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: path == null
            ? Container(
                color: Colors.black12,
                child: const Center(
                  child: Icon(Icons.image_outlined, size: 42),
                ),
              )
            : Image.file(File(path!), fit: BoxFit.cover),
      ),
    );
  }
}
