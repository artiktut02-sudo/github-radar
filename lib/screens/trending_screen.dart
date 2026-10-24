import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;

class TrendingScreen extends StatefulWidget {
  const TrendingScreen({super.key});

  @override
  State<TrendingScreen> createState() => _TrendingScreenState();
}

class _TrendingScreenState extends State<TrendingScreen> {
  final Dio _dio = Dio();
  List<dynamic> _repos = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchTrending();
  }

  Future<void> _fetchTrending() async {
    try {
      // Получаем репозитории, созданные за последнюю неделю, отсортированные по звездам
      final response = await _dio.get(
        'https://api.github.com/search/repositories',
        queryParameters: {
          'q': 'created:>2024-05-01', // В реальном приложении дату лучше считать динамически
          'sort': 'stars',
          'order': 'desc',
        },
      );
      
      setState(() {
        _repos = response.data['items'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GitHub Radar 🔥'),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text('Ошибка: $_error'));
    }

    return RefreshIndicator(
      onRefresh: _fetchTrending,
      child: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _repos.length,
        itemBuilder: (context, index) {
          final repo = _repos[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(repo['owner']['avatar_url']),
              ),
              title: Text(
                repo['name'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (repo['description'] != null)
                    Text(
                      repo['description'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text('${repo['stargazers_count']}'),
                      const SizedBox(width: 16),
                      const Icon(Icons.fork_right, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('${repo['forks_count']}'),
                      const SizedBox(width: 16),
                      if (repo['language'] != null)
                        Text(
                          repo['language'],
                          style: const TextStyle(color: Colors.blue),
                        ),
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
}
