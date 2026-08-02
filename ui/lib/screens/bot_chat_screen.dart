// lib/screens/bot_chat_screen.dart

import 'package:flutter/material.dart';
import 'package:orbit/services/api_service.dart';
import 'package:orbit/theme/app_colors.dart';
import 'package:orbit/theme/app_text_styles.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final ApiService _apiService = ApiService();

  bool _loading = true;
  bool _waiting = false;

  String _menuTitle = "";
  String _assistantReply = "";

  List<dynamic> _options = [];

  @override
  void initState() {
    super.initState();
    _loadMenu();
  }

  Future<void> _loadMenu() async {
    try {
      final response = await _apiService.getAssistantMenu();

      setState(() {
        _menuTitle = response["menu_text"];
        _options = response["options"];
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _menuTitle = "Unable to load Orbit Guide.";
      });
    }
  }

  Future<void> _selectOption(
    String optionId,
    String label,
  ) async {
    setState(() {
      _waiting = true;
    });

    try {
      final response = await _apiService.askAssistant(optionId);

      setState(() {
        _assistantReply =
            response["response"] ?? "No response available.";
      });
    } catch (e) {
      setState(() {
        _assistantReply =
            "Unable to contact Orbit Guide.";
      });
    }

    setState(() {
      _waiting = false;
    });
  }

  Widget _buildMenuCard(
    IconData icon,
    String label,
    String id,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: _waiting
          ? null
          : () => _selectOption(id, label),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: Offset(0, 3),
            )
          ],
        ),
        child: Row(
          children: [

            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primary,
              child: Icon(
                icon,
                color: AppColors.white,
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Text(
                label,
                style: AppTextStyles.title,
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textSecondary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(String key) {
    switch (key) {
      case "search_alumni":
        return Icons.search;

      case "send_chat_request":
        return Icons.chat_bubble_outline;

      case "view_chats":
        return Icons.forum_outlined;

      case "notifications":
        return Icons.notifications_none;

      case "profile":
        return Icons.person_outline;

      case "signup_login":
        return Icons.login;

      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: AppColors.textPrimary,
        ),
        title: Text(
          "Orbit Guide",
          style: AppTextStyles.title,
        ),
      ),

      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
          : AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _assistantReply.isEmpty
                  ? _buildMenuPage()
                  : _buildResponsePage(),
            ),
    );
  }

  Widget _buildMenuPage() {
    return SingleChildScrollView(
      key: const ValueKey("menu"),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const Icon(
                  Icons.smart_toy_outlined,
                  color: AppColors.primary,
                  size: 44,
                ),

                const SizedBox(height: 14),

                Text(
                  "Orbit Guide",
                  style: AppTextStyles.heading,
                ),

                const SizedBox(height: 10),

                Text(
                  _menuTitle,
                  style: AppTextStyles.subtitle,
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          Text(
            "Quick Help",
            style: AppTextStyles.subHeading,
          ),

          const SizedBox(height: 12),

          ..._options.map((option) {
            return _buildMenuCard(
              _getIcon(option["key"]),
              option["label"],
              option["id"].toString(),
            );
          }).toList(),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
    Widget _buildResponsePage() {
    return Padding(
      key: const ValueKey("response"),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                )
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary,
                  child: Icon(
                    Icons.smart_toy_outlined,
                    color: AppColors.white,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Text(
                    _assistantReply,
                    style: AppTextStyles.body.copyWith(
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              icon: const Icon(Icons.arrow_back),
              label: const Text("Back to Guide"),
              onPressed: _waiting
                  ? null
                  : () {
                      setState(() {
                        _assistantReply = "";
                      });
                    },
            ),
          ),

          if (_waiting)
            const Padding(
              padding: EdgeInsets.only(top: 20),
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}