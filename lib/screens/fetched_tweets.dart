import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/tweet_model.dart';

class FetchedTweetsPage extends StatefulWidget {
  final String query;
  final List<Tweet> tweets;

  const FetchedTweetsPage({
    super.key,
    required this.query,
    required this.tweets,
  });

  @override
  State<FetchedTweetsPage> createState() => _FetchedTweetsPageState();
}

class _FetchedTweetsPageState extends State<FetchedTweetsPage> {
  Map<String, int> _sentimentCounts = {};

  @override
  void initState() {
    super.initState();
    _calculateSentimentCounts();
  }

  void _calculateSentimentCounts() {
    int positive = 0;
    int negative = 0;
    int neutral = 0;

    for (var tweet in widget.tweets) {
      switch (tweet.vaderLabel?.toUpperCase()) {
        case 'POSITIVE':
          positive++;
          break;
        case 'NEGATIVE':
          negative++;
          break;
        case 'NEUTRAL':
          neutral++;
          break;
      }
    }

    setState(() {
      _sentimentCounts = {
        'positive': positive,
        'negative': negative,
        'neutral': neutral,
        'total': widget.tweets.length,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDEEF1),
      appBar: AppBar(
        title: Text(
          'Results for "${widget.query}"',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Sentiment Summary
          _buildSentimentSummary(),
          const SizedBox(height: 10),
          // Tweets List
          Expanded(
            child: widget.tweets.isEmpty
                ? _buildEmptyState()
                : _buildTweetsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSentimentSummary() {
    return Container(
      margin: const EdgeInsets.all(20),
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
            'Sentiment Analysis Summary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1967B2),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                '😊',
                'Positive',
                _sentimentCounts['positive'] ?? 0,
                Colors.green,
              ),
              _buildSummaryItem(
                '😐',
                'Neutral',
                _sentimentCounts['neutral'] ?? 0,
                Colors.orange,
              ),
              _buildSummaryItem(
                '😞',
                'Negative',
                _sentimentCounts['negative'] ?? 0,
                Colors.red,
              ),
            ],
          ),
          const Divider(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.poll, color: Color(0xFF1967B2), size: 20),
              const SizedBox(width: 8),
              Text(
                'Total: ${_sentimentCounts['total'] ?? 0} tweets',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String emoji, String label, int count, Color color) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 32)),
        const SizedBox(height: 5),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildTweetsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: widget.tweets.length,
      itemBuilder: (context, index) {
        final tweet = widget.tweets[index];
        return _buildTweetCard(tweet);
      },
    );
  }

  Widget _buildTweetCard(Tweet tweet) {
    final sentimentInfo = tweet.sentimentInfo;
    Color sentimentColor;

    switch (sentimentInfo.color) {
      case 'green':
        sentimentColor = Colors.green;
        break;
      case 'red':
        sentimentColor = Colors.red;
        break;
      case 'orange':
        sentimentColor = Colors.orange;
        break;
      default:
        sentimentColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: sentimentColor.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with username and sentiment
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1967B2).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.person,
                  color: Color(0xFF1967B2),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '@${tweet.username.isNotEmpty ? tweet.username : 'anonymous'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      _formatDate(tweet.date),
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              // Sentiment Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: sentimentColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: sentimentColor.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      sentimentInfo.emoji,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      sentimentInfo.label,
                      style: TextStyle(
                        color: sentimentColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Tweet Content
          Text(
            tweet.content,
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 10),
          // Sentiment Scores
          Row(
            children: [
              if (tweet.vaderScore != null) ...[
                const Icon(
                  Icons.analytics_outlined,
                  size: 14,
                  color: Colors.grey,
                ),
                const SizedBox(width: 5),
                Text(
                  'VADER: ${tweet.vaderScore!.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
              if (tweet.distilLabel != null) ...[
                const SizedBox(width: 15),
                const Icon(
                  Icons.psychology_outlined,
                  size: 14,
                  color: Colors.grey,
                ),
                const SizedBox(width: 5),
                Text(
                  'DistilBERT: ${tweet.distilLabel}',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(
            'No tweets found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Try searching with different keywords',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return dateStr;
    }
  }
}
