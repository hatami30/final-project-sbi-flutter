class RateLimiter {
  final int maxRequestsPerMinute;
  final int maxTokensPerMinute;
  final int maxRequestsPerDay;

  final List<DateTime> _requests = [];
  final List<int> _tokens = [];
  DateTime _startOfDay;

  RateLimiter({
    required this.maxRequestsPerMinute,
    required this.maxTokensPerMinute,
    required this.maxRequestsPerDay,
  }) : _startOfDay = DateTime.now();

  bool _isRateLimited(List<DateTime> requests, DateTime now, int maxRequests) {
    requests
        .removeWhere((timestamp) => now.difference(timestamp).inMinutes >= 1);
    return requests.length >= maxRequests;
  }

  bool _isTokenLimited(List<int> tokens, DateTime now, int maxTokens) {
    tokens.removeWhere((timestamp) =>
        now
            .difference(DateTime.fromMillisecondsSinceEpoch(timestamp))
            .inMinutes >=
        1);
    return tokens.length >= maxTokens;
  }

  bool _isDailyRequestLimited(DateTime now, int maxRequests) {
    if (now.difference(_startOfDay).inDays >= 1) {
      _startOfDay = now;
      _requests.clear();
    }
    return _requests.length >= maxRequests;
  }

  bool checkLimits(int tokenCount) {
    final now = DateTime.now();
    final isRateLimited = _isRateLimited(_requests, now, maxRequestsPerMinute);
    final isTokenLimited = _isTokenLimited(_tokens, now, maxTokensPerMinute);
    final isDailyRequestLimited =
        _isDailyRequestLimited(now, maxRequestsPerDay);

    if (isRateLimited || isTokenLimited || isDailyRequestLimited) {
      return false;
    }

    _requests.add(now);
    _tokens.add(now.millisecondsSinceEpoch);

    return true;
  }
}
