import 'dart:async';

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'package:orbit/config.dart';
import 'package:orbit/main.dart';
import 'package:orbit/services/api_service.dart';
import 'package:orbit/theme/app_colors.dart';
import 'package:orbit/theme/app_text_styles.dart';

class ChatMessage {
  final String senderId;
  final String text;
  final bool isMe;

  ChatMessage({
    required this.senderId,
    required this.text,
    required this.isMe,
  });
}

class ChatScreen extends StatefulWidget {
  final String recipientId;
  final String recipientName;

  const ChatScreen({
    super.key,
    required this.recipientId,
    required this.recipientName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  IO.Socket? socket;

  final TextEditingController _controller =
      TextEditingController();

  final ScrollController _scrollController =
      ScrollController();

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
    Timer(
      const Duration(milliseconds: 100),
      () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration:
                const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      },
    );
  }

  Future<void> _fetchMessageHistory() async {
    try {
      final messagesData =
          await _apiService.getMessages(
        widget.recipientId,
      );

      final history =
          (messagesData["messages"] as List)
              .map(
                (e) => ChatMessage(
                  senderId: e["sender_id"],
                  text: e["text"],
                  isMe:
                      e["sender_id"] ==
                          authManager.rollNumber,
                ),
              )
              .toList();

      if (mounted) {
        setState(() {
          _messages.addAll(history);
          _isLoading = false;
        });

        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _connectToSocket() {
    if (socket != null) return;

    socket = IO.io(
      apiBaseUrl,
      {
        "transports": ["websocket"],
        "autoConnect": false,
        "reconnection": true,
        "forceNew": true,
      },
    );

socket!.connect();

    socket!.onConnect((_) {

      if (!mounted) return;

      setState(() {
        _isSocketConnected = true;
      });

      socket!.emit(
        "join_chat_room",
        {
          "token": authManager.token,
          "room_id": widget.recipientId,
        },
      );
    });

    socket!.onDisconnect((_) {

      if (!mounted) return;

      setState(() {
        _isSocketConnected = false;
      });
    });

    socket!.onConnectError((_) {

      if (!mounted) return;

      setState(() {
        _isSocketConnected = false;
      });
    });

    socket!.on(
      "new_message",
      (data) {

        if (!mounted) return;

        if (data is Map<String, dynamic>) {

          if (data["sender_id"] != authManager.rollNumber) {

            setState(() {
              _messages.add(
                ChatMessage(
                  senderId: data["sender_id"],
                  text: data["text"],
                  isMe: false,
                ),
              );
            });

            _scrollToBottom();
          }
        }
      },
    );
  }

  @override
  void dispose() {

    socket?.off("connect");
    socket?.off("disconnect");
    socket?.off("connect_error");
    socket?.off("new_message");

    socket?.disconnect();
    socket?.dispose();

    _controller.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();

    if (text.isEmpty ||
        !_isSocketConnected) return;

    setState(() {
      _messages.add(
        ChatMessage(
          senderId: authManager.rollNumber!,
          text: text,
          isMe: true,
        ),
      );
    });

    socket!.emit(
      "send_message",
      {
        "token": authManager.token,
        "room_id": widget.recipientId,
        "message": text,
      },
    );

    _controller.clear();

    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColors.background,

      appBar: AppBar(
        backgroundColor:
            AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.recipientName,
          style: AppTextStyles.title,
        ),
      ),

      body: _isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(
                color:
                    AppColors.primary,
              ),
            )
          : Column(
              children: [

                Expanded(
                  child:
                      ListView.builder(
                    controller:
                        _scrollController,

                    padding:
                        const EdgeInsets.all(
                            16),

                    itemCount:
                        _messages.length,

                    itemBuilder:
                        (context, index) {
                      final msg =
                          _messages[index];

                      return Align(
                        alignment: msg.isMe
                            ? Alignment
                                .centerRight
                            : Alignment
                                .centerLeft,

                        child: Container(
                          margin:
                              const EdgeInsets.symmetric(
                            vertical: 5,
                          ),

                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),

                          decoration:
                              BoxDecoration(
                            color: msg.isMe
                                ? AppColors.primary
                                : AppColors.card,

                            borderRadius:
                                BorderRadius.circular(
                                    18),
                          ),

                          child: Text(
                            msg.text,

                            style: TextStyle(
                              color: msg.isMe
                                  ? Colors.white
                                  : AppColors
                                      .textPrimary,
                            ),
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
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border(
          top: BorderSide(
            color: AppColors.divider,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [

            Expanded(
              child: TextField(
                controller: _controller,
                enabled: _isSocketConnected,
                onSubmitted: (_) => _sendMessage(),

                style: AppTextStyles.body,

                decoration: InputDecoration(
                  hintText: _isSocketConnected
                      ? "Type a message..."
                      : "Connecting...",

                  hintStyle:
                      AppTextStyles.subtitle,

                  filled: true,
                  fillColor: Colors.white,

                  contentPadding:
                      const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),

                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),

                  enabledBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(30),
                    borderSide:
                        BorderSide.none,
                  ),

                  focusedBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(30),
                    borderSide:
                        const BorderSide(
                      color:
                          AppColors.primary,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 10),

            CircleAvatar(
              radius: 26,
              backgroundColor:
                  _isSocketConnected
                      ? AppColors.primary
                      : Colors.grey,

              child: IconButton(
                onPressed: _isSocketConnected
                    ? _sendMessage
                    : null,

                icon: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}