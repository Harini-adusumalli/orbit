// lib/screens/search_results_screen.dart
import 'package:flutter/material.dart';
import 'package:orbit/services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class SearchResultsScreen extends StatefulWidget {
  final String query;
  const SearchResultsScreen({super.key, required this.query});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _error;
  List<dynamic> _results = [];
  final Set<String> _sentRequests = {};

  @override
  void initState() {
    super.initState();
    _search();
  }

  Future<void> _search() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final response = await _apiService.semanticSearch(widget.query);
      setState(() { _results = response['results'] ?? []; });
    } catch (e) {
      setState(() { _error = 'Error searching: $e'; });
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open link: $url'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _requestChat(String alumniId, String alumniName) async {
    try {
      final response = await _apiService.createOrGetChatRoom(alumniId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Request sent successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _sentRequests.add(alumniId);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search: "${widget.query}"')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : _results.isEmpty
                  ? const Center(child: Text('No results found.'))
                  : ListView.builder(
                      itemCount: _results.length,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemBuilder: (context, index) {
                        final item = _results[index];
                        final meta = item['metadata'] ?? {};
                        
                        // Extract all data fields that might exist
                        final alumniId = meta['Alumni_ID'] as String?;
                        final alumniName = meta['Full_Name'] as String?;
                        final skills = meta['Technical_Skills'] as String?;
                        final linkedInUrl = meta['LinkedIn_URL'] as String?;
                        final projects = meta['Notable_Projects'] as String?;
                        final mentorshipArea = meta['Mentorship_Area'] as String?;

                        final isRequestSent = alumniId != null && _sentRequests.contains(alumniId);

                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          color: const Color(0xFF212121), // Dark card color
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(alumniName ?? 'Name not available', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                                const SizedBox(height: 8),
                                _buildInfoRow('Company', meta['Current_Company']),
                                _buildInfoRow('Designation', meta['Designation']),
                                _buildInfoRow('Industry', meta['Industry']),
                                _buildInfoRow('Mentorship', mentorshipArea),
                                
                                // This will only show if 'Notable_Projects' exists in your data
                                if (projects != null && projects.isNotEmpty)
                                  _buildInfoRow('Projects', projects),

                                // This will only show if 'Technical_Skills' exists in your data
                                if (skills != null && skills.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Text('Skills:', style: TextStyle(color: Colors.white.withOpacity(0.9))),
                                  const SizedBox(height: 4),
                                  Wrap(
                                    spacing: 6.0,
                                    runSpacing: 6.0,
                                    children: skills.split(',').map((skill) => Chip(label: Text(skill.trim()))).toList(),
                                  ),
                                ],
                                
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: (alumniId == null || isRequestSent)
                                            ? null
                                            : () => _requestChat(alumniId, alumniName ?? 'Alumni'),
                                        icon: Icon(isRequestSent ? Icons.check : Icons.send_outlined),
                                        label: Text(isRequestSent ? 'Request Sent' : 'Request Chat'),
                                      ),
                                    ),
                                    // This will only show if 'LinkedIn_URL' exists in your data
                                    if (linkedInUrl != null && linkedInUrl.isNotEmpty) ...[
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.link),
                                        tooltip: 'View LinkedIn Profile',
                                        onPressed: () => _launchURL(linkedInUrl),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }

  // Helper widget that only builds the row if the value is not null or empty
  Widget _buildInfoRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink(); 
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Text('$label: $value', style: const TextStyle(color: Colors.white70)),
    );
  }
}