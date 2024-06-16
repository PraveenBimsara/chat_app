import 'package:chat_app/components/text_field.dart';
import 'package:chat_app/services/auth/auth_service.dart';
import 'package:chat_app/services/chat/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  final String receiverEmail;
  final String receiverID;
  ChatPage({super.key, required this.receiverEmail, required this.receiverID});

  // Text controller
  final TextEditingController _messageController = TextEditingController();

  // Chat & auth service
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  // Send message
  void sendMessage() async {
    // If there is something inside the textfield
    if (_messageController.text.isNotEmpty) {
      // Send message
      await _chatService.sendMessage(receiverID, _messageController.text);

      // Clear text controller
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(receiverEmail),
      ),
      body: Column(
        children: [
          // Display all messages
          Expanded(
            child: _buildMessageList(),
          ),

          // User input
          _buildUserInput(),
        ],
      ),
    );
  }

  // Build message list
  Widget _buildMessageList() {
    String senderID = _authService.getCurrentUser()!.uid;
    return StreamBuilder(
      stream: _chatService.getMessages(senderID, receiverID),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        // Errors
        if (snapshot.hasError) {
          return const Text('Error');
        }
        // Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        // Return list view
        return ListView(
          children:
              snapshot.data!.docs.map((doc) => _buildMessageItem(doc)).toList(),
        );
      },
    );
  }

  // Build message item
  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return ListTile(
      title: Text(data['message']),
      subtitle: Text(data['senderEmail']),
    );
  }

  // Build user input
  Widget _buildUserInput() {
    return Row(
      children: [
        Expanded(
          child: MyTextField(
            hintText: 'Type a message',
            obscurText: false,
            controller: _messageController,
          ),
        ),
        // Send button
        IconButton(onPressed: sendMessage, icon: const Icon(Icons.arrow_upward))
      ],
    );
  }
}
