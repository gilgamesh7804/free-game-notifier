import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/epic_games_service.dart';
import 'widgets/gamecard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const FreeGameNotifierApp());
}

class FreeGameNotifierApp extends StatelessWidget {
  const FreeGameNotifierApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Free Game Notifier',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.white,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),
        cardColor: const Color(0xFF2C2C2E),
      ),
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Game>> _games;

  @override
  void initState() {
    super.initState();
    _games = fetchEpicFreeGames();
  }

  Future<void> _refreshGames() async {
    setState(() {
      _games = fetchEpicFreeGames();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Free Games')),
      body: RefreshIndicator(
        onRefresh: _refreshGames,
        child: FutureBuilder<List<Game>>(
          future: _games,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Error fetching games'));
            } else if (snapshot.data!.isEmpty) {
              return const Center(child: Text('No free games available.'));
            } else {
              return ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(), // required to allow pull even if list is short
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return GameCard(game: snapshot.data![index]);
                },
              );
            }
          },
        ),
      ),
    );
  }
}
