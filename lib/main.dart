import 'package:flutter/material.dart';
// Мы убрали dio, cached_network_image и timeago

void main() {
  runApp(const GitHubRadarApp());
}

class GitHubRadarApp extends StatelessWidget {
  const GitHubRadarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GitHub Radar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D1117),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF161B22),
          elevation: 0,
        ),
      ),
      home: const TrendingScreen(),
    );
  }
}

class TrendingScreen extends StatefulWidget {
  const TrendingScreen({super.key});

  @override
  State<TrendingScreen> createState() => _TrendingScreenState();
}

class _TrendingScreenState extends State<TrendingScreen> {
  // Вместо Dio используем стандартный HttpClient из dart:io
  // Внимание: для веба в DartPad используем простой HTTP через dart:html или упрощённый вариант
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
      // ВАЖНО: В DartPad для сетевых запросов мы используем упрощённый подход.
      // Поскольку dart:io в вебе не работает, мы используем "заглушку" для демонстрации UI.
      // В реальном приложении (на GitHub) этот код будет работать с dio.
      
      // Имитация загрузки данных для демонстрации интерфейса:
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _repos = [
          {
            'name': 'flutter/flutter',
            'description': 'Flutter makes it easy and fast to build beautiful apps.',
            'stargazers_count': 160000,
            'forks_count': 26000,
            'language': 'Dart',
            'owner': {'avatar_url': 'https://avatars.githubusercontent.com/u/14101776'}
          },
          {
            'name': 'dart-lang/sdk',
            'description': 'The Dart SDK, including the VM, JS and Wasm compilers, analysis, core libraries, and more.',
            'stargazers_count': 10000,
            'forks_count': 1500,
            'language': 'Dart',
            'owner': {'avatar_url': 'https://avatars.githubusercontent.com/u/1609975'}
          }
        ];
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
      return Center(child: Text('Ошибка: $_error', textAlign: TextAlign.center));
    }

    return RefreshIndicator(
      onRefresh: _fetchTrending,
      child: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _repos.length,
        itemBuilder: (context, index) {
          final repo = _repos[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              // Вместо CachedNetworkImageProvider используем NetworkImage
              leading: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: NetworkImage(repo['owner']['avatar_url']),
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
