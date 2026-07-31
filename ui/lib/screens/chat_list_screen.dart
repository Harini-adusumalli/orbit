// lib/screens/chat_list_screen.dart
import 'package:flutter/material.dart';
import 'package:orbit/services/api_service.dart';
import 'package:orbit/screens/chat_screen.dart';

// Models for clarity
class ChatRoom {
  final String id;
  final String name;
  ChatRoom({required this.id, required this.name});
}

class PendingRequest {
  final String id;
  final String senderName;
  PendingRequest({required this.id, required this.senderName});
}

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ApiService _apiService = ApiService();
  List<ChatRoom> _activeChats = [];
  List<PendingRequest> _pendingRequests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.getChatRooms();
      final activeChatsData = List<Map<String, dynamic>>.from(response['active_chats'] ?? []);
      final pendingRequestsData = List<Map<String, dynamic>>.from(response['pending_requests'] ?? []);
      
      if (mounted) {
        setState(() {
          _activeChats = activeChatsData.map((data) => ChatRoom(id: data['id'], name: data['name'])).toList();
          _pendingRequests = pendingRequestsData.map((data) => PendingRequest(id: data['id'], senderName: data['sender_name'])).toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching chats: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _respondToRequest(String requestId, String action) async {
    try {
      await _apiService.respondToChatRequest(requestId, action);
      _fetchData(); // Refresh the list after responding
    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchData,
              child: ListView(
                padding: const EdgeInsets.all(8.0),
                children: [
                  // --- PENDING REQUESTS SECTION ---
                  if (_pendingRequests.isNotEmpty) ...[
                    _buildSectionHeader('Pending Requests'),
                    ..._pendingRequests.map((req) => _buildRequestTile(req)),
                    const Divider(height: 32),
                  ],

                  // --- ACTIVE CHATS SECTION ---
                  _buildSectionHeader('Active Conversations'),
                  if (_activeChats.isEmpty && _pendingRequests.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text('You have no active or pending chats.'),
                      ),
                    ),
                  ..._activeChats.map((chat) => _buildChatTile(chat)),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(title, style: Theme.of(context).textTheme.headlineSmall),
    );
  }

  Widget _buildRequestTile(PendingRequest request) {
    return Card(
      // FIX 1: Set the card background color
      color: const Color(0xFF96583E),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.white24,
          // FIX 2: Changed icon color to be visible
          child: Icon(Icons.person_add_alt_1, color: Colors.white),
        ),
        // FIX 3: Changed text colors to be visible
        title: Text(request.senderName, style: const TextStyle(color: Colors.white)),
        subtitle: const Text('Wants to connect with you', style: TextStyle(color: Colors.white70)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Accept',
              // FIX 4: Changed icon color to be visible
              icon: const Icon(Icons.check_circle, color: Colors.lightGreenAccent),
              onPressed: () => _respondToRequest(request.id, 'accept'),
            ),
            IconButton(
              tooltip: 'Reject',
              // FIX 5: Changed icon color to be visible
              icon: const Icon(Icons.cancel, color: Colors.redAccent),
              onPressed: () => _respondToRequest(request.id, 'reject'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatTile(ChatRoom chat) {
    return Card(
      // FIX 6: Set the card background color
      color: const Color(0xFF96583E),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.white24,
          child: Text(
            chat.name.isNotEmpty ? chat.name.substring(0, 1) : '?',
            // FIX 7: Changed text color to be visible
            style: const TextStyle(color: Colors.white),
          ),
        ),
        // FIX 8: Changed text colors to be visible
        title: Text(chat.name, style: const TextStyle(color: Colors.white)),
        trailing: const Icon(Icons.chevron_right, color: Colors.white70),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ChatScreen(
              recipientId: chat.id,
              recipientName: chat.name,
            ),
          )).then((_) => _fetchData());
        },
      ),
    );
  }
}