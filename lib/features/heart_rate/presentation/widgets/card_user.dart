import 'package:flutter/material.dart';

class CardUser extends StatelessWidget {
  final String name;
  final String email;
  final String avatarUrl;

  const CardUser({
    super.key,
    required this.name,
    required this.email,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.teal[700],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          avatarUrl.isNotEmpty
              ? CircleAvatar(
                  backgroundImage: NetworkImage(avatarUrl),
                  radius: 30,
                )
              : CircleAvatar(child: Icon(Icons.person, size: 40), radius: 30,),
          const SizedBox(width: 16),
          Expanded(
            child: name.isEmpty
                ? const Text(
                    'Vui lòng đăng nhập để sử dụng đầy đủ tính năng',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        softWrap: false,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Email: $email',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
