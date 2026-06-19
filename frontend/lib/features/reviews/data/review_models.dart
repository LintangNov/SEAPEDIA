class Review {
  final String id;
  final String reviewerName;
  final int rating;
  final String comment;

  Review({
    required this.id,
    required this.reviewerName,
    required this.rating,
    required this.comment,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id']?.toString() ?? '',
      reviewerName: json['reviewerName']?.toString() ?? 'Anonymous', 
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      comment: json['comment']?.toString() ?? '',
    );
  }
}