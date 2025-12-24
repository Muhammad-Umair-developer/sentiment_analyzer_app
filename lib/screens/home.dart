import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Added Firebase Auth
import 'login.dart';
import 'connection.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _keywordController = TextEditingController();
  double _tweetCount = 50;

  // Get the current user from Firebase
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDEEF1),
      drawer: _buildSideMenu(context),
      appBar: AppBar(
        title: const Text(
          "Tweet Sentiment",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => debugPrint("History tapped"),
          ),
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
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
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- KEYWORD INPUT SECTION ---
  Widget _buildKeywordInput() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Enter Topic or Keyword",
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blueGrey),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _keywordController,
          decoration: InputDecoration(
            hintText: "e.g., #ArtificialIntelligence",
            prefixIcon: const Icon(Icons.search, color: Color(0xFF1967B2)),
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Tweets to fetch: ${_tweetCount.toInt()}",
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const Icon(Icons.speed, size: 18, color: Colors.grey),
          ],
        ),
        Slider(
          value: _tweetCount,
          min: 10,
          max: 100,
          divisions: 9,
          activeColor: const Color(0xFF1967B2),
          onChanged: (value) {
            setState(() => _tweetCount = value);
          },
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () {
              String keyword = _keywordController.text;
              if (keyword.isNotEmpty) {
                debugPrint(
                  "Fetching ${_tweetCount.toInt()} tweets for: $keyword",
                );
                // Implement your sentiment analysis API call here
              }
            },
            icon: const Icon(Icons.cloud_download, color: Colors.white),
            label: const Text(
              "FETCH & ANALYZE",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1967B2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  // --- DRAWER SECTION ---
  Widget _buildSideMenu(BuildContext context) {
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
            // DYNAMICALLY LOAD USER INFO
            accountName: Text(
              user?.displayName ?? "User Name",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(user?.email ?? "user@email.com"),
          ),
          _buildMenuTile(Icons.account_circle_outlined, "Profile"),
          _buildMenuTile(Icons.settings_outlined, "Settings"),
          ListTile(
            leading: const Icon(Icons.cloud, color: Color(0xFF1967B2)),
            title: const Text(
              "Firebase Status",
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ConnectionStatusScreen(),
                ),
              );
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
              // LOGOUT FROM FIREBASE
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
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

  Widget _buildMenuTile(IconData icon, String title) => ListTile(
    leading: Icon(icon, color: const Color(0xFF1967B2)),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
    onTap: () => debugPrint("$title tapped"),
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
        "124",
        Colors.green,
        Icons.sentiment_very_satisfied,
      ),
      _buildStatCard("Neutral", "56", Colors.orange, Icons.sentiment_neutral),
      _buildStatCard(
        "Negative",
        "12",
        Colors.red,
        Icons.sentiment_very_dissatisfied,
      ),
      _buildStatCard("Total", "192", Colors.blue, Icons.poll),
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
        const SizedBox(height: 5),
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
            "Tip: Search for specific hashtags to see real-time public sentiment.",
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      ],
    ),
  );
}
