import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Ensure these files exist in your lib folder
import 'login.dart';
import 'profile.dart';
import 'settings.dart'; // <--- Make sure this import is here
import 'fetched_tweets.dart';
import 'history.dart';
import '../models/tweet_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _keywordController = TextEditingController();
  double _tweetCount = 50;

  bool _isLoading = false;
  String _loadingMessage = '';
  Map<String, dynamic> _stats = {
    "positive": "0",
    "neutral": "0",
    "negative": "0",
    "total": "0",
  };

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  // Save search history
  Future<void> _saveSearchHistory(String keyword) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> history = prefs.getStringList('search_history') ?? [];

      // Remove if already exists to avoid duplicates
      history.remove(keyword);

      // Add to the end (most recent)
      history.add(keyword);

      // Keep only last 50 searches
      if (history.length > 50) {
        history = history.sublist(history.length - 50);
      }

      await prefs.setStringList('search_history', history);
    } catch (e) {
      debugPrint('Error saving search history: $e');
    }
  }

  // Generate dummy tweets for demonstration
  List<Tweet> _generateDummyTweets(String query, int count) {
    final random = Random();
    final sentiments = ['POSITIVE', 'NEGATIVE', 'NEUTRAL'];

    // More realistic looking usernames
    final firstNames = [
      'alex',
      'sarah',
      'mike',
      'emma',
      'david',
      'lisa',
      'james',
      'maria',
      'chris',
      'anna',
      'tom',
      'julia',
      'kevin',
      'sophia',
      'ryan',
      'olivia',
      'mark',
      'emily',
      'daniel',
      'jessica',
    ];
    final lastNames = [
      'parker',
      'williams',
      'brown',
      'jones',
      'garcia',
      'miller',
      'davis',
      'rodriguez',
      'martinez',
      'wilson',
      'anderson',
      'taylor',
      'thomas',
      'moore',
      'jackson',
      'martin',
      'lee',
      'walker',
      'hall',
      'allen',
    ];
    final suffixes = [
      '',
      '_official',
      'tweets',
      '2024',
      'real',
      'daily',
      'updates',
      'news',
      'x',
      'pro',
    ];

    final positiveContents = [
      'I absolutely love $query! Best thing ever! 😍',
      '$query is amazing, highly recommend it to everyone!',
      'Just tried $query and I\'m blown away by how great it is!',
      'Can\'t get enough of $query, it\'s fantastic!',
      '$query exceeded all my expectations, wonderful!',
    ];
    final negativeContents = [
      'Really disappointed with $query, not what I expected 😞',
      '$query is terrible, waste of time and money',
      'I regret trying $query, it\'s just awful',
      'Worst experience ever with $query',
      '$query failed to deliver, very frustrated',
    ];
    final neutralContents = [
      'Just saw something about $query today',
      '$query is trending right now',
      'People are talking about $query',
      'Here\'s what I found about $query',
      'Read an article about $query earlier',
    ];

    List<Tweet> tweets = [];
    for (int i = 0; i < count; i++) {
      final sentiment = sentiments[i % sentiments.length];
      String content;

      if (sentiment == 'POSITIVE') {
        content = positiveContents[i % positiveContents.length];
      } else if (sentiment == 'NEGATIVE') {
        content = negativeContents[i % negativeContents.length];
      } else {
        content = neutralContents[i % neutralContents.length];
      }

      // Generate random realistic username
      final firstName = firstNames[random.nextInt(firstNames.length)];
      final lastName = lastNames[random.nextInt(lastNames.length)];
      final suffix = suffixes[random.nextInt(suffixes.length)];
      final separator = random.nextBool() ? '_' : '';

      String username;
      final usernameType = random.nextInt(3);
      if (usernameType == 0) {
        // firstname_lastname format
        username = '$firstName$separator$lastName$suffix';
      } else if (usernameType == 1) {
        // firstname + number format
        username = '$firstName${random.nextInt(999)}$suffix';
      } else {
        // lastname + firstname format
        username = '$lastName$separator$firstName$suffix';
      }

      tweets.add(
        Tweet(
          tweetId: 'tweet_${i + 1}',
          query: query,
          date: DateTime.now().subtract(Duration(hours: i)).toString(),
          username: username,
          content: content,
          cleanText: content,
          vaderLabel: sentiment,
          vaderScore: sentiment == 'POSITIVE'
              ? 0.8
              : (sentiment == 'NEGATIVE' ? -0.7 : 0.0),
          distilLabel: sentiment,
          distilScore: sentiment == 'POSITIVE'
              ? 0.85
              : (sentiment == 'NEGATIVE' ? -0.75 : 0.0),
          insertedAt: DateTime.now().toString(),
        ),
      );
    }
    return tweets;
  }

  Future<void> _fetchAndAnalyze() async {
    if (_keywordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a keyword'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Close the keyboard
    FocusManager.instance.primaryFocus?.unfocus();

    // Save search to history
    await _saveSearchHistory(_keywordController.text.trim());

    setState(() {
      _isLoading = true;
      _loadingMessage = 'Fetching tweets...';
    });

    try {
      // Simulate fetching tweets
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;
      setState(() => _loadingMessage = 'Running analysis...');
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;
      setState(() => _loadingMessage = 'Loading results...');
      await Future.delayed(const Duration(seconds: 1));

      // Generate dummy tweets
      final tweets = _generateDummyTweets(
        _keywordController.text.trim(),
        _tweetCount.toInt(),
      );

      if (!mounted) return;

      int pos = tweets.where((t) => t.vaderLabel == 'POSITIVE').length;
      int neg = tweets.where((t) => t.vaderLabel == 'NEGATIVE').length;
      int neu = tweets.length - (pos + neg);

      setState(() {
        _stats = {
          "positive": pos.toString(),
          "neutral": neu.toString(),
          "negative": neg.toString(),
          "total": tweets.length.toString(),
        };
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FetchedTweetsPage(
            query: _keywordController.text.trim(),
            tweets: tweets,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFFDEEF1),
      drawer: _buildSideMenu(context, user),
      appBar: AppBar(
        title: const Text(
          "Tweet Sentiment",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        // backgroundColor: Colors.transparent,
        // elevation: 0,
        // foregroundColor: Colors.black87,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "Search Trends",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  _buildKeywordInput(),
                  const SizedBox(height: 30),
                  const Text(
                    "Recent Analytics",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  _buildSentimentGrid(),
                  const SizedBox(height: 30),
                  _buildInfoCard(),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: Color(0xFF1967B2)),
                      const SizedBox(height: 20),
                      Text(
                        _loadingMessage,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1967B2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildKeywordInput() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
      ],
    ),
    child: Column(
      children: [
        TextField(
          controller: _keywordController,
          decoration: InputDecoration(
            hintText: "e.g., Pakistan Economy",
            prefixIcon: const Icon(Icons.search, color: Color(0xFF1967B2)),
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        Slider(
          value: _tweetCount,
          min: 10,
          max: 100,
          divisions: 9,
          label: _tweetCount.round().toString(),
          activeColor: const Color(0xFF1967B2),
          onChanged: (val) => setState(() => _tweetCount = val),
        ),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _fetchAndAnalyze,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1967B2),
            ),
            child: Text(
              _isLoading ? "ANALYZING..." : "FETCH & ANALYZE",
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildSentimentGrid() => GridView.count(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    crossAxisCount: 2,
    crossAxisSpacing: 15,
    mainAxisSpacing: 15,
    childAspectRatio: 1.6,
    children: [
      _buildStatCard(
        "Positive",
        _stats["positive"],
        Colors.green,
        Icons.sentiment_very_satisfied,
      ),
      _buildStatCard(
        "Neutral",
        _stats["neutral"],
        Colors.orange,
        Icons.sentiment_neutral,
      ),
      _buildStatCard(
        "Negative",
        _stats["negative"],
        Colors.red,
        Icons.sentiment_very_dissatisfied,
      ),
      _buildStatCard("Total", _stats["total"], Colors.blue, Icons.poll),
    ],
  );

  Widget _buildStatCard(
    String title,
    String count,
    Color color,
    IconData icon,
  ) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.3), width: 1.5),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 28),
        Text(
          count,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    ),
  );

  Widget _buildInfoCard() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF1967B2), Color(0xFF3A51E3)],
      ),
      borderRadius: BorderRadius.circular(20),
    ),
    child: const Row(
      children: [
        Icon(Icons.tips_and_updates, color: Colors.white, size: 40),
        SizedBox(width: 15),
        Expanded(
          child: Text(
            "Tip: Search for specific hashtags for better accuracy.",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    ),
  );

  Widget _buildSideMenu(BuildContext context, User? user) {
    return Drawer(
      backgroundColor: const Color(0xFFFDEEF1),
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF1967B2)),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Color(0xFF1967B2), size: 40),
            ),
            accountName: Text(
              user?.displayName ?? "User Name",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(user?.email ?? "user@email.com"),
          ),
          ListTile(
            leading: const Icon(
              Icons.account_circle_outlined,
              color: Color(0xFF1967B2),
            ),
            title: const Text("Profile"),
            onTap: () {
              Navigator.pop(context); // Close Drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.settings_outlined,
              color: Color(0xFF1967B2),
            ),
            title: const Text("Settings"),
            onTap: () {
              Navigator.pop(context); // Close Drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.history, color: Color(0xFF1967B2)),
            title: const Text("History"),
            onTap: () async {
              Navigator.pop(context); // Close Drawer
              final keyword = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryPage()),
              );
              // If a keyword was selected from history, fill the text field
              if (keyword != null && keyword is String) {
                _keywordController.text = keyword;
              }
            },
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text(
              "Logout",
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              }
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
