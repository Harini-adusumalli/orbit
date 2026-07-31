import 'dart:async';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:orbit/main.dart';
import 'package:orbit/config.dart';
import 'package:orbit/services/api_service.dart';

class ChatMessage {
  final String senderId;
  final String text;
  final bool isMe;
  ChatMessage({required this.senderId, required this.text, required this.isMe});
}

class ChatScreen extends StatefulWidget {
  final String recipientId;
  final String recipientName;
  const ChatScreen({super.key, required this.recipientId, required this.recipientName});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  IO.Socket? socket;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  bool _isSocketConnected = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    await _fetchMessageHistory();
    _connectToSocket();
  }

  void _scrollToBottom() {
    Timer(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _fetchMessageHistory() async {
    try {
      final messagesData = await _apiService.getMessages(widget.recipientId);
      final historicalMessages = (messagesData['messages'] as List).map((data) => ChatMessage(
        senderId: data['sender_id'],
        text: data['text'],
        isMe: data['sender_id'] == authManager.rollNumber,
      )).toList();
      
      if (mounted) {
        setState(() {
          _messages.addAll(historicalMessages);
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      print("Error fetching message history: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _connectToSocket() {
    if (socket != null) return; 

    socket = IO.io(apiBaseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket!.onConnect((_) {
  print("--- WebSocket CONNECTED successfully! ---");

  setState(() {
    _isSocketConnected = true;
  });

  print("Socket state after connect = $_isSocketConnected");

  socket!.emit('join_chat_room', {
    'token': authManager.token,
    'room_id': widget.recipientId,
  });
});

    socket!.onConnectError((data) {
      print("--- ❌ WebSocket Connection ERROR: $data ---");
      if (mounted) {
        setState(() { _isSocketConnected = false; });
      }
    });

    socket!.onDisconnect((_) {
      print("--- WebSocket DISCONNECTED ---");
      if (mounted) {
        setState(() { _isSocketConnected = false; });
      }
    });

    socket!.on('new_message', (data) {
      if (mounted && data is Map<String, dynamic>) {
        final senderId = data['sender_id'];
        if (senderId != authManager.rollNumber) {
          setState(() {
            _messages.add(ChatMessage(
              senderId: senderId,
              text: data['text'],
              isMe: false,
            ));
          });
          _scrollToBottom();
        }
      }
    });
  }

  @override
  void dispose() {
    print("--- Disposing ChatScreen and cleaning up listeners ---");
    socket?.off('connect');
    socket?.off('connect_error');
    socket?.off('disconnect');
    socket?.off('new_message');
    socket?.disconnect();
    socket?.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty || !_isSocketConnected) {
      print("Cannot send message. Connected: $_isSocketConnected");
      return;
    }
    setState(() {
      _messages.add(ChatMessage(
        senderId: authManager.rollNumber!,
        text: text,
        isMe: true,
      ));
    });
    _scrollToBottom();
    print("ROOM ID = ${widget.recipientId}");
    socket!.emit('send_message', {
      'token': authManager.token,
      'room_id': widget.recipientId,
      'message': text,
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    print("BUILD: _isSocketConnected = $_isSocketConnected");
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.recipientName}'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Align(
                  alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: msg.isMe ? const Color(0xFF9FFF90) : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      msg.text,
                      style: TextStyle(color: msg.isMe ? Colors.black87 : Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
          _buildMessageComposer(),
        ],
      ),
    );
  }

  Widget _buildMessageComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      color: const Color(0xFF9FFF90),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                onSubmitted: (_) => _sendMessage(),
                enabled: _isSocketConnected,
                decoration: InputDecoration.collapsed(
                  hintText: _isSocketConnected ? 'Type a message...' : 'Connecting...',
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: _isSocketConnected ? _sendMessage : null,
              color: _isSocketConnected 
                  ? Theme.of(context).colorScheme.primary 
                  : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}