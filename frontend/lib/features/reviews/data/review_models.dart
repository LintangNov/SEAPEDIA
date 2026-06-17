class Review {
  final String id;
  final String username;
  final int rating;
  final String comment;

  Review({
    required this.id,
    required this.username,
    required this.rating,
    required this.comment,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String? ?? '',
      username: json['username'] as String? ?? 'Anonymous',
      rating: json['rating'] as int? ?? 0,
      comment: json['comment'] as String? ?? '',
    );
  }
}