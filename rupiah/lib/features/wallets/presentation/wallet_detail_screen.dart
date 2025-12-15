import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../transactions/presentation/transaction_controller.dart';
import '../../transactions/presentation/widgets/transaction_item.dart';
import 'balance_provider.dart';
import 'wallet_controller.dart';

class WalletDetailScreen extends ConsumerWidget {
  final String walletId;

  const WalletDetailScreen({super.key, required this.walletId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Ambil Data Dompet & Saldo Realtime
    final wallets = ref.watch(walletListProvider).value ?? [];
    final wallet = wallets.firstWhere(
      (w) => w.id == walletId,
      orElse: () => throw Exception("Dompet tidak ditemukan"),
    );
    final currentBalance = ref.watch(walletBalanceProvider(walletId));

    // 2. Ambil Transaksi & Filter khusus dompet ini
    final allTransactions = ref.watch(transactionListProvider).value ?? [];
    final walletTransactions = allTransactions
        .where((t) => t.walletId == walletId)
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(wallet.name),
        backgroundColor: Color(wallet.color),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Nanti tambahin fitur Edit Wallet di sini
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Fitur Edit Dompet coming soon!")),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // HEADER SALDO
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Color(wallet.color),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                const Text(
                  "Saldo Saat Ini",
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Text(
                  NumberFormat.currency(
                    locale: 'id_ID',
                    symbol: 'Rp ',
                    decimalDigits: 0,
                  ).format(currentBalance),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Modal Awal: ${NumberFormat.compactSimpleCurrency(locale: 'id_ID').format(wallet.initialBalance)}",
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),

          // LIST TRANSAKSI
          Expanded(
            child: walletTransactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          size: 64,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Belum ada transaksi di ${wallet.name}",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: walletTransactions.length,
                    itemBuilder: (context, index) {
                      return TransactionItem(
                        transaction: walletTransactions[index],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
