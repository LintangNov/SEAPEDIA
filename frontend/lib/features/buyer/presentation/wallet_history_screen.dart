import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seapedia/core/widgets/debug_border.dart';
import 'package:seapedia/features/buyer/data/buyer_repository.dart';

final walletHistoryProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  return ref.watch(buyerRepositoryProvider).getWalletHistory();
});

class WalletHistoryScreen extends ConsumerWidget {
  const WalletHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(walletHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Wallet Transaction History')),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (history) {
          if (history.isEmpty) return const Center(child: Text('No transactions yet.'));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: history.length,
            itemBuilder: (context, index){
              final trx = history[index];
              final isTopUp = trx['type'] == 'TOP_UP' || trx['type'] == 'REFUND';
              return DebugBorder(
                color: isTopUp ? Colors.green : Colors.red, label: trx['type'],
                child: ListTile(
                  leading: Icon(isTopUp ? Icons.arrow_downward : Icons.arrow_upward, color: isTopUp ? Colors.green : Colors.red),
                  title: Text(trx['description'] ?? 'Transaction'),
                  subtitle: Text(DateTime.parse(trx['createdAt']).toLocal().toString().split('.')[0]),
                  trailing: Text(
                    '${isTopUp ? '+' : '-'} Rp ${trx['amount']}',
                    style: TextStyle(color: isTopUp ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              );
            },
          );
        }
      ),
    );
  }
}