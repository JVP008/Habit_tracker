import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/user_profile.dart';
import '../providers/social_provider.dart';

class FriendRequestDialog extends StatelessWidget {
  final FriendRequest request;

  const FriendRequestDialog({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final socialProvider = Provider.of<SocialProvider>(context, listen: false);

    return AlertDialog(
      title: const Text('Friend Request'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: request.fromUserPhotoUrl != null
                ? CachedNetworkImageProvider(request.fromUserPhotoUrl!)
                : null,
            child: request.fromUserPhotoUrl == null
                ? Text(
                    request.fromUserName[0].toUpperCase(),
                    style: const TextStyle(fontSize: 24),
                  )
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            request.fromUserName,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            request.message ?? 'Sent you a friend request',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            socialProvider.respondToFriendRequest(request.id, false);
            Navigator.of(context).pop();
          },
          child: const Text('Reject', style: TextStyle(color: Colors.red)),
        ),
        ElevatedButton(
          onPressed: () {
            socialProvider.respondToFriendRequest(request.id, true);
            Navigator.of(context).pop();
          },
          child: const Text('Accept'),
        ),
      ],
    );
  }
}
