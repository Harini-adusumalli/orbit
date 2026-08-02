import 'package:flutter/material.dart';
import 'package:orbit/services/api_service.dart';
import 'package:orbit/screens/chat_screen.dart';
import 'package:orbit/theme/app_colors.dart';
import 'package:orbit/theme/app_text_styles.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() =>
      _ChatListScreenState();
}

class _ChatListScreenState
    extends State<ChatListScreen> {

  final ApiService _apiService = ApiService();

  bool _loading = true;

  List<dynamic> _activeChats = [];
  List<dynamic> _pendingRequests = [];

@override
void initState() {
  super.initState();
  _loadChats();
}

Future<void> _loadChats() async {
  try {
    final response =
        await _apiService.getChatRooms();

    debugPrint(response.toString());

    if (!mounted) return;

    setState(() {
      _activeChats =
          response["active_chats"] ?? [];

      _pendingRequests =
          response["pending_requests"] ?? [];

      _loading = false;
    });
  } catch (e) {
    if (!mounted) return;

    setState(() {
      _loading = false;
    });

    debugPrint(e.toString());
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
          : _activeChats.isEmpty &&
_pendingRequests.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [

                      Icon(
                        Icons.chat_bubble_outline,
                        size: 70,
                        color: AppColors.primary,
                      ),

                      const SizedBox(height: 20),

                      Text(
                        "No Chats Yet",
                        style:
                            AppTextStyles.heading,
                      ),

                      const SizedBox(height: 8),

                      Text(
                        "Start a conversation with an alumnus to see it here.",
                        textAlign: TextAlign.center,
                        style:
                            AppTextStyles.subtitle,
                      ),
                    ],
                  ),
                )
              : ListView(
  padding: const EdgeInsets.all(16),
  children: [

    //-------------------------------------------------
    // Pending Requests
    //-------------------------------------------------

    if (_pendingRequests.isNotEmpty) ...[

      Text(
        "📩 Pending Requests",
        style: AppTextStyles.heading,
      ),

      const SizedBox(height: 16),

      ..._pendingRequests.map((request) {

        return Card(
          margin:
              const EdgeInsets.only(
                  bottom: 16),

          child: Padding(
            padding:
                const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  request["sender_name"],
                  style:
                      AppTextStyles.title,
                ),

                const SizedBox(height: 14),

                Row(
                  children: [

                    Expanded(
                      child:
                          ElevatedButton.icon(
                        icon: const Icon(
                            Icons.check),
                        label:
                            const Text(
                                "Accept"),
                        onPressed: () async {

                          await _apiService
                              .respondToChatRequest(
                            request["id"],
                            "accept",
                          );

                          _loadChats();
                        },
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child:
                          OutlinedButton.icon(
                        icon: const Icon(
                            Icons.close),
                        label:
                            const Text(
                                "Reject"),
                        onPressed: () async {

                          await _apiService
                              .respondToChatRequest(
                            request["id"],
                            "reject",
                          );

                          _loadChats();
                        },
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      }),

      const SizedBox(height: 24),
    ],

    //-------------------------------------------------
    // Active Chats
    //-------------------------------------------------

    if (_activeChats.isNotEmpty)

      Text(
        "💬 Active Chats",
        style: AppTextStyles.heading,
      ),

    const SizedBox(height: 14),

    ..._activeChats.map((room) {

      return Card(
        margin:
            const EdgeInsets.only(
                bottom: 14),

        child: ListTile(

          leading: CircleAvatar(
            backgroundColor:
                AppColors.primary,
            child: Text(
              room["recipient_name"][0],
            ),
          ),

          title: Text(
            room["recipient_name"],
            style:
                AppTextStyles.title,
          ),

          subtitle: Text(
            room["last_message"],
          ),

          trailing:
              const Icon(Icons.chevron_right),

          onTap: () {

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatScreen(
                  recipientId:
                      room["room_id"],
                  recipientName:
                      room["recipient_name"],
                ),
              ),
            ).then((_) {
              _loadChats();
            });
          },
        ),
      );
    }),
  ],
)
    );
  }
}