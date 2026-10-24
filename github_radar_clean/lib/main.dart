import 'dart:async'; import 'dart:convert'; import 'dart:ui';
import 'package:flutter/material.dart'; import 'package:http/http.dart' as http; import 'dart:html' as html;

void main() => runApp(const App());

class T {
  static const Map<String, Map<String, String>> _v = {
    'en': {'t': 'GitHub Radar', 'tr': 'Trending', 'ex': 'Explore', 'rp': 'Repos', 'fv': 'Favorites', 'st': 'Settings', 'dk': 'Dark Mode', 'lg': 'Language', 'ac': 'Account', 'si': 'Sign in', 'lo': 'Logout', 'ss': 'Signed in as', 'nf': 'No favorites yet.', 'nr': 'No repos found.', 'ap': 'Appearance', 'se': 'Search...', 'co': 'Accent Color', 'ui': 'UI Style', 'm3': 'Material 3', 'ios': 'iOS', 'cl': 'Classic', 'pv': 'Python', 'js': 'JavaScript', 'dr': 'Dart', 'rs': 'Rust', 'ai': 'AI/ML', 'gm': 'Games', 'wb': 'Web'},
    'ru': {'t': 'GitHub Radar', 'tr': 'Тренды', 'ex': 'Обзор', 'rp': 'Репозитории', 'fv': 'Избранное', 'st': 'Настройки', 'dk': 'Темная тема', 'lg': 'Язык', 'ac': 'Аккаунт', 'si': 'Войти', 'lo': 'Выйти', 'ss': 'Вы вошли как', 'nf': 'В избранном пусто.', 'nr': 'Репозитории не найдены.', 'ap': 'Внешний вид', 'se': 'Поиск...', 'co': 'Цвет акцента', 'ui': 'Стиль', 'm3': 'Material 3', 'ios': 'iOS', 'cl': 'Классика', 'pv': 'Python', 'js': 'JavaScript', 'dr': 'Dart', 'rs': 'Rust', 'ai': 'AI/ML', 'gm': 'Игры', 'wb': 'Веб'},
  };
  static String get(String l, String k) => _v[l]?[k] ?? k;
}

class S {
  static bool isDark() => html.window.localStorage['theme'] != 'light';
  static void setDark(bool v) => html.window.localStorage['theme'] = v ? 'dark' : 'light';
  static String getLang() => html.window.localStorage['lang'] ?? 'en';
  static void setLang(String v) => html.window.localStorage['lang'] = v;
  static String getColor() => html.window.localStorage['color'] ?? 'blue';
  static void setColor(String v) => html.window.localStorage['color'] = v;
  static String getStyle() => html.window.localStorage['style'] ?? 'material';
  static void setStyle(String v) => html.window.localStorage['style'] = v;
  static Color getColorValue(String n) {
    switch (n) {
      case 'green': return const Color(0xFF2EA043);
      case 'purple': return const Color(0xFF8957E5);
      case 'red': return const Color(0xFFDA3633);
      default: return const Color(0xFF1F6FEB);
    }
  }
}

class App extends StatefulWidget {
  const App({super.key});
  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool _dark = S.isDark();
  String _lang = S.getLang(), _color = S.getColor(), _style = S.getStyle();
  int _idx = 0;
  String? _user, _token;

  @override
  void initState() {
    super.initState();
    final uri = Uri.parse(html.window.location.href);
    if (uri.queryParameters.containsKey('token')) {
      _token = uri.queryParameters['token'];
      _user = uri.queryParameters['user'];
      html.window.localStorage['token'] = _token!;
      html.window.localStorage['user'] = _user!;
      html.window.history.replaceState(null, '', '/');
    } else {
      _token = html.window.localStorage['token'];
      _user = html.window.localStorage['user'];
    }
  }

  void _logout() {
    html.window.localStorage.remove('token');
    html.window.localStorage.remove('user');
    setState(() { _token = null; _user = null; _idx = 0; });
  }

  @override
  Widget build(BuildContext context) {
    final accent = S.getColorValue(_color);
    final isLogged = _token != null;
    final t = (String k) => T.get(_lang, k);

    final screens = [
      TrendingScreen(lang: _lang),
      if (isLogged) ExploreScreen(lang: _lang),
      if (isLogged) MyReposScreen(lang: _lang),
      FavoritesScreen(lang: _lang),
      SettingsScreen(dark: _dark, lang: _lang, color: _color, style: _style, user: _user, 
        onTheme: (v) => setState(() { _dark = v; S.setDark(v); }),
        onLang: (v) => setState(() { _lang = v; S.setLang(v); }),
        onColor: (v) => setState(() { _color = v; S.setColor(v); }),
        onStyle: (v) => setState(() { _style = v; S.setStyle(v); }),
        onLogin: () => html.window.location.href = '/api/auth/github',
        onLogout: _logout,
      ),
    ];
    if (_idx >= screens.length) _idx = 0;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: _dark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData.light(useMaterial3: _style == 'material').copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: accent),
        scaffoldBackgroundColor: Colors.transparent,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0),
      ),
      darkTheme: ThemeData.dark(useMaterial3: _style == 'material').copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: accent, brightness: Brightness.dark),
        scaffoldBackgroundColor: Colors.transparent,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0),
      ),
      home: Scaffold(
        extendBody: true,
        body: Stack(children: [
          AmbientBackground(color: _color, style: _style),
          SafeArea(child: screens[_idx]),
        ]),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _idx,
          onDestinationSelected: (i) => setState(() => _idx = i),
          backgroundColor: _dark ? const Color(0xFF161B22).withOpacity(0.9) : Colors.white.withOpacity(0.9),
          indicatorColor: accent.withOpacity(0.2),
          destinations: [
            NavigationDestination(icon: const Icon(Icons.trending_up), label: t('tr')),
            if (isLogged) NavigationDestination(icon: const Icon(Icons.explore), label: t('ex')),
            if (isLogged) NavigationDestination(icon: const Icon(Icons.folder), label: t('rp')),
            NavigationDestination(icon: const Icon(Icons.star), label: t('fv')),
            NavigationDestination(icon: const Icon(Icons.settings), label: t('st')),
          ],
        ),
      ),
    );
  }
}

// --- Фон ---
class AmbientBackground extends StatelessWidget {
  final String color, style;
  const AmbientBackground({super.key, required this.color, required this.style});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = S.getColorValue(color);
    if (style == 'classic') return Container(color: isDark ? const Color(0xFF0D1117) : const Color(0xFFF0F2F5));
    final c1 = accent.withOpacity(isDark ? 0.4 : 0.2);
    final c2 = (style == 'ios' ? Colors.pink : Colors.purple).withOpacity(isDark ? 0.2 : 0.1);
    final c3 = (style == 'ios' ? Colors.amber : Colors.teal).withOpacity(isDark ? 0.2 : 0.1);
    return Stack(children: [
      Container(color: isDark ? const Color(0xFF0D1117) : const Color(0xFFF0F2F5)),
      Positioned(top: -100, right: -100, child: Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, color: c1, boxShadow: [BoxShadow(color: c1, blurRadius: 100, spreadRadius: 50)]))),
      Positioned(bottom: -50, left: -100, child: Container(width: 250, height: 250, decoration: BoxDecoration(shape: BoxShape.circle, color: c2, boxShadow: [BoxShadow(color: c2, blurRadius: 120, spreadRadius: 40)]))),
      Positioned(top: 300, left: 50, child: Container(width: 200, height: 200, decoration: BoxDecoration(shape: BoxShape.circle, color: c3, boxShadow: [BoxShadow(color: c3, blurRadius: 90, spreadRadius: 30)]))),
      BackdropFilter(filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40), child: Container(color: Colors.transparent)),
    ]);
  }
}

// --- Поиск/Тренды ---
class TrendingScreen extends StatefulWidget {
  final String lang;
  const TrendingScreen({super.key, required this.lang});
  @override
  State<TrendingScreen> createState() => _TrendState();
}

class _TrendState extends State<TrendingScreen> {
  List<dynamic> _repos = [];
  bool _loading = true;
  String _query = '', _period = 'week', _filterLang = '';
  final _ctrl = TextEditingController();
  Timer? _debounce;

  @override
  void initState() { super.initState(); _fetch(); }
  @override
  void dispose() { _debounce?.cancel(); _ctrl.dispose(); super.dispose(); }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    String url;
    if (_query.isNotEmpty) url = '/api/search?q=${Uri.encodeComponent(_query)}';
    else {
      String q = 'created:>';
      final now = DateTime.now();
      if (_period == 'week') q += now.subtract(const Duration(days: 7)).toIso8601String().split('T')[0];
      else if (_period == 'month') q += now.subtract(const Duration(days: 30)).toIso8601String().split('T')[0];
      else q += now.subtract(const Duration(days: 365)).toIso8601String().split('T')[0];
      if (_filterLang.isNotEmpty) q += ' language:$_filterLang';
      url = '/api/trending?q=${Uri.encodeComponent(q)}';
    }
    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) setState(() { _repos = json.decode(res.body)['items'] ?? []; _loading = false; });
      else setState(() => _loading = false);
    } catch (e) { setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    final t = (String k) => T.get(widget.lang, k);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final style = S.getStyle();
    return Column(children: [
      Padding(padding: const EdgeInsets.all(16), child: Text(t('t'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: TextField(controller: _ctrl, decoration: InputDecoration(hintText: t('se'), prefixIcon: const Icon(Icons.search), filled: true, fillColor: isDark ? const Color(0xFF161B22).withOpacity(0.8) : Colors.white.withOpacity(0.8), border: OutlineInputBorder(borderRadius: BorderRadius.circular(style == 'ios' ? 30 : 16), borderSide: BorderSide.none)), onChanged: (v) { if (_debounce?.isActive ?? false) _debounce!.cancel(); _debounce = Timer(const Duration(milliseconds: 500), () { setState(() => _query = v); _fetch(); }); })),
      const SizedBox(height: 12),
      if (_query.isEmpty) SingleChildScrollView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(children: [
        FilterChip(label: const Text('Week'), selected: _period == 'week', onSelected: (v) { setState(() => _period = 'week'); _fetch(); }),
        const SizedBox(width: 8),
        FilterChip(label: const Text('Month'), selected: _period == 'month', onSelected: (v) { setState(() => _period = 'month'); _fetch(); }),
        const SizedBox(width: 16),
        FilterChip(label: const Text('Python'), selected: _filterLang == 'Python', onSelected: (v) { setState(() => _filterLang = v ? 'Python' : ''); _fetch(); }),
      ])),
      Expanded(child: _loading ? const Center(child: CircularProgressIndicator()) : ListView.builder(padding: const EdgeInsets.all(16), itemCount: _repos.length, itemBuilder: (context, i) => RepoCard(repo: _repos[i], style: style))),
    ]);
  }
}

// --- Обзор (Категории) ---
class ExploreScreen extends StatefulWidget {
  final String lang;
  const ExploreScreen({super.key, required this.lang});
  @override
  State<ExploreScreen> createState() => _ExploreState();
}

class _ExploreState extends State<ExploreScreen> {
  List<dynamic> _repos = [];
  bool _loading = true;
  String _topic = 'python';

  @override
  void initState() { super.initState(); _fetch(); }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final res = await http.get(Uri.parse('/api/search?q=topic:$_topic'));
      if (res.statusCode == 200) setState(() { _repos = json.decode(res.body)['items'] ?? []; _loading = false; });
      else setState(() => _loading = false);
    } catch (e) { setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    final t = (String k) => T.get(widget.lang, k);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final style = S.getStyle();
    return Column(children: [
      Padding(padding: const EdgeInsets.all(16), child: Text(t('ex'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
      SingleChildScrollView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(children: [
        _chip('python', '🐍 Python', isDark), _chip('javascript', '🟨 JS', isDark), _chip('dart', '🎯 Dart', isDark), _chip('rust', '🦀 Rust', isDark), _chip('artificial-intelligence', '🤖 AI', isDark), _chip('games', '🎮 Games', isDark),
      ])),
      const SizedBox(height: 12),
      Expanded(child: _loading ? const Center(child: CircularProgressIndicator()) : ListView.builder(padding: const EdgeInsets.all(16), itemCount: _repos.length, itemBuilder: (context, i) => RepoCard(repo: _repos[i], style: style))),
    ]);
  }

  Widget _chip(String topic, String label, bool isDark) {
    final isSel = _topic == topic;
    final accent = Theme.of(context).colorScheme.primary;
    return Padding(padding: const EdgeInsets.only(right: 8), child: FilterChip(
      label: Text(label), selected: isSel,
      onSelected: (v) { if (v) { setState(() => _topic = topic); _fetch(); } },
      selectedColor: accent.withOpacity(0.2), checkmarkColor: accent,
      backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
    ));
  }
}

// --- Мои репозитории ---
class MyReposScreen extends StatefulWidget {
  final String lang;
  const MyReposScreen({super.key, required this.lang});
  @override
  State<MyReposScreen> createState() => _MyReposState();
}

class _MyReposState extends State<MyReposScreen> {
  List<dynamic> _repos = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _fetch(); }

  Future<void> _fetch() async {
    final token = html.window.localStorage['token'];
    if (token == null) return;
    try {
      final res = await http.get(Uri.parse('/api/my-repos'), headers: {'Authorization': 'Bearer $token'});
      if (res.statusCode == 200) setState(() { _repos = json.decode(res.body); _loading = false; });
      else setState(() => _loading = false);
    } catch (e) { setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    final style = S.getStyle();
    return _loading ? const Center(child: CircularProgressIndicator()) : ListView.builder(padding: const EdgeInsets.all(16), itemCount: _repos.length, itemBuilder: (context, i) => RepoCard(repo: _repos[i], style: style));
  }
}

// --- Избранное ---
class FavoritesScreen extends StatefulWidget {
  final String lang;
  const FavoritesScreen({super.key, required this.lang});
  @override
  State<FavoritesScreen> createState() => _FavsState();
}

class _FavsState extends State<FavoritesScreen> {
  List<Map<String, dynamic>> _favs = [];
  @override
  void initState() { super.initState(); _favs = Favs.get(); }

  @override
  Widget build(BuildContext context) {
    final t = (String k) => T.get(widget.lang, k);
    final style = S.getStyle();
    return _favs.isEmpty ? Center(child: Text(t('nf'))) : ListView.builder(padding: const EdgeInsets.all(16), itemCount: _favs.length, itemBuilder: (context, i) => RepoCard(repo: _favs[i], style: style));
  }
}

// --- Настройки ---
class SettingsScreen extends StatelessWidget {
  final bool dark; final String lang, color, style; final String? user;
  final ValueChanged<bool> onTheme; final ValueChanged<String> onLang, onColor, onStyle;
  final VoidCallback onLogin, onLogout;

  const SettingsScreen({super.key, required this.dark, required this.lang, required this.color, required this.style, required this.user, required this.onTheme, required this.onLang, required this.onColor, required this.onStyle, required this.onLogin, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final t = (String k) => T.get(lang, k);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView(padding: const EdgeInsets.all(16), children: [
      Text(t('ap'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      Container(decoration: BoxDecoration(color: isDark ? const Color(0xFF161B22).withOpacity(0.8) : Colors.white.withOpacity(0.8), borderRadius: BorderRadius.circular(16)), child: Column(children: [
        SwitchListTile(title: Text(t('dk')), value: dark, onChanged: onTheme),
        ListTile(title: Text(t('lg')), trailing: DropdownButton<String>(value: lang, underline: const SizedBox(), items: const [DropdownMenuItem(value: 'en', child: Text('EN')), DropdownMenuItem(value: 'ru', child: Text('RU'))], onChanged: (v) { if (v != null) onLang(v); })),
        ListTile(title: Text(t('ui')), trailing: DropdownButton<String>(value: style, underline: const SizedBox(), items: [DropdownMenuItem(value: 'material', child: Text(t('m3'))), DropdownMenuItem(value: 'ios', child: Text(t('ios'))), DropdownMenuItem(value: 'classic', child: Text(t('cl')))], onChanged: (v) { if (v != null) onStyle(v); })),
        ListTile(title: Text(t('co')), trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          _c(context, 'blue', const Color(0xFF1F6FEB)), _c(context, 'green', const Color(0xFF2EA043)), _c(context, 'purple', const Color(0xFF8957E5)), _c(context, 'red', const Color(0xFFDA3633)),
        ])),
      ])),
      const SizedBox(height: 24),
      Text(t('ac'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      Container(decoration: BoxDecoration(color: isDark ? const Color(0xFF161B22).withOpacity(0.8) : Colors.white.withOpacity(0.8), borderRadius: BorderRadius.circular(16)), child: user == null ? ListTile(leading: const Icon(Icons.login), title: Text(t('si')), onTap: onLogin) : Column(children: [
        ListTile(leading: const Icon(Icons.account_circle, size: 40), title: Text('${t('ss')} $user')),
        const Divider(height: 1),
        ListTile(leading: const Icon(Icons.logout, color: Colors.red), title: Text(t('lo'), style: const TextStyle(color: Colors.red)), onTap: onLogout),
      ])),
    ]);
  }
  Widget _c(BuildContext ctx, String n, Color c) => GestureDetector(onTap: () => onColor(n), child: Container(margin: const EdgeInsets.only(left: 8), width: 24, height: 24, decoration: BoxDecoration(color: c, shape: BoxShape.circle, border: color == n ? Border.all(color: Theme.of(ctx).colorScheme.onSurface, width: 2) : null)));
}

// --- Карточка репозитория ---
class RepoCard extends StatelessWidget {
  final Map<String, dynamic> repo;
  final String style;
  const RepoCard({super.key, required this.repo, required this.style});

  @override
  Widget build(BuildContext context) {
    final l = repo['language'] as String?;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = style == 'ios' ? 20.0 : (style == 'classic' ? 4.0 : 16.0);
    final bgColor = isDark ? (style == 'classic' ? const Color(0xFF161B22) : const Color(0xFF161B22).withOpacity(0.7)) : (style == 'classic' ? Colors.white : Colors.white.withOpacity(0.7));
    final isFav = Favs.isFav(repo['id']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(radius), border: style == 'ios' ? Border.all(color: isDark ? Colors.white24 : Colors.black12, width: 1) : null),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(backgroundImage: NetworkImage(repo['owner']['avatar_url'])),
        title: Text(repo['full_name'] ?? repo['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (repo['description'] != null) Text(repo['description'], maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.star, size: 14, color: Colors.amber), const SizedBox(width: 4), Text('${repo['stargazers_count']}'),
            const Spacer(),
            if (l != null) ...[
              Container(width: 10, height: 10, decoration: BoxDecoration(color: l == 'Python' ? Colors.blue : l == 'JavaScript' ? Colors.yellow : Colors.grey, shape: BoxShape.circle)),
              const SizedBox(width: 6), Text(l, style: const TextStyle(fontSize: 12)),
            ],
          ]),
        ]),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(icon: Icon(isFav ? Icons.star : Icons.star_border, color: isFav ? Colors.amber : Colors.grey), onPressed: () => Favs.toggle(repo)),
          IconButton(icon: const Icon(Icons.open_in_new, color: Colors.blue), onPressed: () => html.window.open(repo['html_url'], '_blank')),
        ]),
      ),
    );
  }
}

// --- Избранное утилита ---
class Favs {
  static const _k = 'favs';
  static List<Map<String, dynamic>> get() {
    final d = html.window.localStorage[_k];
    return d == null ? [] : json.decode(d).map((e) => e as Map<String, dynamic>).toList();
  }
  static bool isFav(int id) => get().any((r) => r['id'] == id);
  static void toggle(Map<String, dynamic> repo) {
    final f = get();
    if (isFav(repo['id'])) f.removeWhere((r) => r['id'] == repo['id']);
    else f.add(repo);
    html.window.localStorage[_k] = json.encode(f);
  }
}