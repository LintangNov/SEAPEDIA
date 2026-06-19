import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/debug_border.dart';
import '../data/review_repository.dart';
import 'reviews_provider.dart';

class ReviewsScreen extends ConsumerStatefulWidget {
  const ReviewsScreen({super.key});

  @override
  ConsumerState<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends ConsumerState<ReviewsScreen> {
  final _nameController = TextEditingController();
  final _commentController = TextEditingController();
  int _selectedRating = 5; 
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final reviewerName = _nameController.text.trim();
    final comment = _commentController.text.trim();
    
    if (reviewerName.isEmpty || reviewerName.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name must be at least 3 characters')),
      );
      return;
    }

    if (_selectedRating < 1 || _selectedRating > 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rating must be strictly between 1 and 5')),
      );
      return;
    }
    if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment cannot be empty')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await ref.read(reviewRepositoryProvider).submitReview(reviewerName, _selectedRating, comment);
      _commentController.clear();
      _nameController.clear();
      setState(() => _selectedRating = 5);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review submitted successfully')),
      );
      ref.invalidate(reviewsListProvider);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reviewsAsync = ref.watch(reviewsListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Application Reviews')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DebugBorder(
              color: Colors.purple,
              label: 'Review Form',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Rating (1-5):', style: TextStyle(fontWeight: FontWeight.bold)),
                      DropdownButton<int>(
                        value: _selectedRating,
                        items: [1, 2, 3, 4, 5].map((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text('$value Star${value > 1 ? 's' : ''}'),
                          );
                        }).toList(),
                        onChanged: (int? newValue) {
                          if (newValue != null) {
                            setState(() => _selectedRating = newValue);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _commentController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Write your review here...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _handleSubmit,
                    child: _isSubmitting 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Submit Review'),
                  ),
                ],
              ),
            ),
          ),
          
          const Divider(thickness: 2),

          Expanded(
            child: reviewsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
              data: (reviews) {
                if (reviews.isEmpty) {
                  return const Center(child: Text('No reviews yet. Be the first!'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    final review = reviews[index];
                    return DebugBorder(
                      color: Colors.blue,
                      label: 'Review Item',
                      child: ListTile(
                        leading: CircleAvatar(child: Text(review.rating.toString())),
                        title: Text(review.reviewerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(review.comment),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}