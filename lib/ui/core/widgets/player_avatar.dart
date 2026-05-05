import 'package:flutter/material.dart';

class PlayerAvatar extends StatelessWidget {
  final String imageUrl;
  final double radius;

  const PlayerAvatar({super.key, required this.imageUrl, required this.radius});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      child: ClipOval(
        child: imageUrl.isEmpty
            ? Image.asset('assets/default_avatar.jpg', fit: BoxFit.cover)
            : FadeInImage.assetNetwork(
                placeholder: 'assets/default_avatar.jpg',
                image: imageUrl,
                fit: BoxFit.cover,
                imageErrorBuilder: (context, error, stackTrace) => Image.asset(
                  'assets/default_avatar.jpg',
                  fit: BoxFit.cover,
                ),
              ),
      ),
    );
  }
}
