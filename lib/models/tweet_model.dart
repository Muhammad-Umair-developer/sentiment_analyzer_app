// Tweet Model
class Tweet {
  final String tweetId;
  final String query;
  final String date;
  final String username;
  final String content;
  final String cleanText;
  final String? vaderLabel;
  final double? vaderScore;
  final String? distilLabel;
  final double? distilScore;
  final String? insertedAt;

  Tweet({
    required this.tweetId,
    required this.query,
    required this.date,
    required this.username,
    required this.content,
    required this.cleanText,
    this.vaderLabel,
    this.vaderScore,
    this.distilLabel,
    this.distilScore,
    this.insertedAt,
  });

  factory Tweet.fromJson(Map<String, dynamic> json) {
    return Tweet(
      tweetId: json['tweet_id'] ?? '',
      query: json['query'] ?? '',
      date: json['date'] ?? '',
      username: json['username'] ?? '',
      content: json['content'] ?? '',
      cleanText: json['clean_text'] ?? '',
      vaderLabel: json['vader_label'],
      vaderScore: json['vader_score']?.toDouble(),
      distilLabel: json['distil_label'],
      distilScore: json['distil_score']?.toDouble(),
      insertedAt: json['inserted_at'],
    );
  }

  // Get sentiment color based on VADER label
  SentimentInfo get sentimentInfo {
    if (vaderLabel == null) {
      return SentimentInfo(label: 'Unknown', color: 'grey', emoji: '❓');
    }

    switch (vaderLabel!.toUpperCase()) {
      case 'POSITIVE':
        return SentimentInfo(label: 'Positive', color: 'green', emoji: '😊');
      case 'NEGATIVE':
        return SentimentInfo(label: 'Negative', color: 'red', emoji: '😞');
      case 'NEUTRAL':
        return SentimentInfo(label: 'Neutral', color: 'orange', emoji: '😐');
      default:
        return SentimentInfo(label: 'Unknown', color: 'grey', emoji: '❓');
    }
  }
}

class SentimentInfo {
  final String label;
  final String color;
  final String emoji;

  SentimentInfo({
    required this.label,
    required this.color,
    required this.emoji,
  });
}
