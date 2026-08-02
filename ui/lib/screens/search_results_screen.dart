import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:orbit/services/api_service.dart';
import 'package:orbit/theme/app_colors.dart';
import 'package:orbit/theme/app_text_styles.dart';

class SearchResultsScreen extends StatefulWidget {
  final String query;

  const SearchResultsScreen({
    super.key,
    required this.query,
  });

  @override
  State<SearchResultsScreen> createState() =>
      _SearchResultsScreenState();
}

class _SearchResultsScreenState
    extends State<SearchResultsScreen> {

  final ApiService _apiService = ApiService();

  bool _loading = true;

  List<dynamic> _results = [];

  final Set<String> _sentRequests = {};

  @override
  void initState() {
    super.initState();
    _search();
  }

  Future<void> _search() async {
    try {

      final response =
          await _apiService.semanticSearch(
        widget.query,
      );

      setState(() {
        _results = response["results"] ?? [];
        _loading = false;
      });

    } catch (e) {

      setState(() {
        _loading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _requestChat(
      String alumniId) async {

    try {

      final response =
          await _apiService.createOrGetChatRoom(
        alumniId,
      );

      if (!mounted) return;

      setState(() {
        _sentRequests.add(alumniId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response["message"] ??
                "Chat request sent!",
          ),
          backgroundColor: AppColors.success,
        ),
      );

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _launchLink(String url) async {

    if (url.trim().isEmpty) return;

    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
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
        title: Text(
          "✨ Alumni Search",
          style: AppTextStyles.title,
        ),
      ),

      body: _loading

          ? const Center(
              child: CircularProgressIndicator(),
            )

          : _results.isEmpty

              ? Center(
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [

                      const Text(
                        "🔍",
                        style: TextStyle(
                          fontSize: 60,
                        ),
                      ),

                      const SizedBox(height: 20),

                      Text(
                        "No Alumni Found",
                        style:
                            AppTextStyles.heading,
                      ),

                      const SizedBox(height: 10),

                      Text(
                        "Try searching with another company,\nskill or role 😊",
                        textAlign:
                            TextAlign.center,
                        style:
                            AppTextStyles.subtitle,
                      ),
                    ],
                  ),
                )

              : ListView.builder(
                  padding:
                      const EdgeInsets.all(16),
                  itemCount:
                      _results.length,
                  itemBuilder:
                      (context, index) {

                    return _buildAlumniCard(
                      _results[index],
                    );
                  },
                ),
    );
  }
  Widget _buildAlumniCard(
  Map<String, dynamic> alumni,
) {

  final alumniId =
      alumni["Alumni_ID"]?.toString();

  final name =
      alumni["Full_Name"] ?? "Unknown";

  final company =
      alumni["Current_Company"] ?? "";

  final designation =
      alumni["Designation"] ?? "";

  final experience =
      alumni["Years_of_Experience"] ?? "";

  final industry =
      alumni["Industry"] ?? "";

  final department =
      alumni["Department"] ?? "";

  final degree =
      alumni["Degree"] ?? "";

  final university =
      alumni["University_Name"] ?? "";

  final graduation =
      alumni["Graduation_Year"] ?? "";

  final email =
      alumni["Email"] ?? "";

  final location =
      "${alumni["City"] ?? ""}, "
      "${alumni["State"] ?? ""}, "
      "${alumni["Country"] ?? ""}";

  final linkedIn =
      alumni["LinkedIn_URL"] ?? "";

  final mentorship =
      alumni["Mentorship_Area"] ?? "";

  final projects =
      alumni["Notable_Projects"] ?? "";

  final awards =
      alumni["Awards_Publications"] ?? "";

  final previousCompanies =
      alumni["Previous_Companies"] ?? "";

  final technicalSkills =
      (alumni["Technical_Skills"] ?? "")
          .toString()
          .split(",");

  final softSkills =
      (alumni["Soft_Skills"] ?? "")
          .toString()
          .split(",");

  final interests =
      (alumni["Interests"] ?? "")
          .toString()
          .split(",");

  final isRequestSent =
      alumniId != null &&
          _sentRequests.contains(
            alumniId,
          );

  return Card(

    color: AppColors.card,

    elevation: 4,

    margin:
        const EdgeInsets.only(
      bottom: 22,
    ),

    shape:
        RoundedRectangleBorder(
      borderRadius:
          BorderRadius.circular(22),
    ),

    child: Padding(

      padding:
          const EdgeInsets.all(22),

      child: Column(

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          /// 👤 HEADER

          Row(

            children: [

              CircleAvatar(

                radius: 34,

                backgroundColor:
                    AppColors.primary,

                child: Text(

                  name[0]
                      .toUpperCase(),

                  style:
                      const TextStyle(

                    color: Colors.white,

                    fontWeight:
                        FontWeight.bold,

                    fontSize: 28,
                  ),
                ),
              ),

              const SizedBox(width: 18),

              Expanded(

                child: Column(

                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [

                    Text(
                      "👤 $name",
                      style:
                          AppTextStyles
                              .heading,
                    ),

                    const SizedBox(
                        height: 5),

                    Text(
                      "💼 $designation",
                      style:
                          AppTextStyles
                              .subtitle,
                    ),

                    const SizedBox(
                        height: 5),

                    Container(

                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),

                      decoration:
                          BoxDecoration(

                        color:
                            AppColors
                                .primary
                                .withOpacity(
                                    .12),

                        borderRadius:
                            BorderRadius
                                .circular(
                                    20),
                      ),

                      child: Text(
                        "🏢 $company",
                        style:
                            AppTextStyles
                                .body,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          _sectionTitle(
            "🎓 Education",
          ),

          _infoTile(
            Icons.school,
            "$degree • $department",
            "$university\nGraduated: $graduation",
          ),

          const SizedBox(height: 18),

          _sectionTitle(
            "⭐ Experience",
          ),

          _infoTile(
            Icons.workspace_premium,
            "$experience Years",
            industry,
          ),

          const SizedBox(height: 18),

          _sectionTitle(
            "💻 Technical Skills",
          ),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                technicalSkills
                    .where(
                      (e) =>
                          e.trim().isNotEmpty,
                    )
                    .map(
                      (skill) => Chip(
                        label: Text(
                          skill.trim(),
                        ),
                        backgroundColor:
                            AppColors
                                .primary
                                .withOpacity(
                                    .10),
                      ),
                    )
                    .toList(),
          ),

          const SizedBox(height: 18),

          _sectionTitle(
            "🤝 Soft Skills",
          ),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                softSkills
                    .where(
                      (e) =>
                          e.trim().isNotEmpty,
                    )
                    .map(
                      (skill) => Chip(
                        label: Text(
                          skill.trim(),
                        ),
                      ),
                    )
                    .toList(),
          ),
                    const SizedBox(height: 18),

          _sectionTitle(
            "🚀 Notable Projects",
          ),

          _infoTile(
            Icons.rocket_launch,
            "Project",
            projects.isEmpty
                ? "Not Available"
                : projects,
          ),

          const SizedBox(height: 18),

          _sectionTitle(
            "🎯 Mentorship Areas",
          ),

          _infoTile(
            Icons.groups,
            "Areas",
            mentorship.isEmpty
                ? "Not Available"
                : mentorship,
          ),

          const SizedBox(height: 18),

          _sectionTitle(
            "❤️ Interests",
          ),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: interests
                .where(
                  (e) =>
                      e.trim().isNotEmpty,
                )
                .map(
                  (interest) => Chip(
                    avatar: const Text("❤️"),
                    label: Text(
                      interest.trim(),
                    ),
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: 18),

          _sectionTitle(
            "📍 Location",
          ),

          _infoTile(
            Icons.location_on,
            "Location",
            location.replaceAll(
              ", ,",
              "",
            ),
          ),

          const SizedBox(height: 18),

          _sectionTitle(
            "📧 Contact",
          ),

          _infoTile(
            Icons.email,
            "Email",
            email,
          ),

          if (linkedIn
              .toString()
              .trim()
              .isNotEmpty) ...[

            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,

              child: OutlinedButton.icon(

                icon: const Icon(
                  Icons.link,
                ),

                label: const Text(
                  "🔗 Open LinkedIn",
                ),

                onPressed: () =>
                    _launchLink(
                  linkedIn,
                ),
              ),
            ),
          ],

          const SizedBox(height: 18),

          _sectionTitle(
            "🏆 Awards",
          ),

          _infoTile(
            Icons.workspace_premium,
            "Achievements",
            awards.isEmpty
                ? "Not Available"
                : awards,
          ),

          const SizedBox(height: 18),

          _sectionTitle(
            "🏢 Previous Companies",
          ),

          _infoTile(
            Icons.business_center,
            "Worked At",
            previousCompanies.isEmpty
                ? "Not Available"
                : previousCompanies,
          ),

          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,

            child: FilledButton.icon(

              style: FilledButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 16,
                ),
              ),

              icon: Icon(
                isRequestSent
                    ? Icons.check_circle
                    : Icons.chat,
              ),

              label: Text(
                isRequestSent
                    ? "✅ Chat Request Sent"
                    : "💬 Request Chat",
              ),

              onPressed:
                  alumniId == null ||
                          isRequestSent
                      ? null
                      : () => _requestChat(
                            alumniId,
                          ),
            ),
          ),

        ],
      ),
    ),
  );
}
Widget _sectionTitle(String title) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      title,
      style: AppTextStyles.heading.copyWith(
        fontSize: 18,
      ),
    ),
  );
}

Widget _infoTile(
  IconData icon,
  String title,
  String value,
) {
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.card.withOpacity(.6),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: Colors.grey.shade300,
      ),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Icon(
          icon,
          color: AppColors.primary,
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [

              Text(
                title,
                style: AppTextStyles.title.copyWith(
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                value,
                style: AppTextStyles.body,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
}