import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../utils/formatters.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final String senderName;
  final DateTime timestamp;
  final bool isFromCurrentUser;

  const MessageBubble({
    required this.message,
    required this.senderName,
    required this.timestamp,
    required this.isFromCurrentUser,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isFromCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          crossAxisAlignment:
              isFromCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isFromCurrentUser)
              Text(
                senderName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.grey,
                ),
              ),
            SizedBox(height: 4),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isFromCurrentUser ? AppColors.primary : AppColors.greyLight,
                borderRadius: BorderRadius.circular(12),
              ),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 14,
                      color: isFromCurrentUser ? Colors.white : AppColors.black,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    Formatters.formatTime(timestamp),
                    style: TextStyle(
                      fontSize: 11,
                      color: isFromCurrentUser
                          ? Colors.white70
                          : AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
