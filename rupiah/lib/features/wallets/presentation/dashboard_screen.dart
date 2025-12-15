import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../auth/data/auth_repository.dart';
import '../../transactions/presentation/widgets/add_transaction_sheet.dart';
import '../../transactions/presentation/transaction_controller.dart'; // Import Provider Transaksi
import '../../transactions/presentation/transaction_history_screen.dart'; // Import Screen History
import '../../transactions/presentation/widgets/transaction_item.dart'; // Import Widget Item
import '../../../core/utils/currency_formatter.dart';
import '../../wallets/presentation/wallet_detail_screen.dart';
import 'wallet_controller.dart';
import 'balance_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authRepositoryProvider).currentUser;
    final walletListAsync = ref.watch(walletListProvider);
    final transactionListAsync = ref.watch(
      transactionListProvider,
    ); // Ambil data transaksi
    final netWorth = ref.watch(netWorthProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Dashboard",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              "Hi, ${user?.displayName?.split(' ').first ?? 'User'}",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_card, color: Colors.black),
            onPressed: () => _showAddWalletDialog(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () =>
                ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => const AddTransactionSheet(),
          );
        },
        label: const Text("Transaksi"),
        icon: const Icon(Icons.edit_note), // Icon baru
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. TOTAL NET WORTH CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black, // Gaya modern dark
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Total Kekayaan Bersih",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      NumberFormat.currency(
                        locale: 'id_ID',
                        symbol: 'Rp ',
                        decimalDigits: 0,
                      ).format(netWorth),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 2. LIST DOMPET (Horizontal Scroll)
              const Text(
                "Dompet Saya",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 140, // Tinggi area scroll
                child: walletListAsync.when(
                  data: (wallets) {
                    if (wallets.isEmpty) return const Text("Belum ada dompet.");
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: wallets.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: SizedBox(
                            width: 160,
                            child: _WalletCard(walletId: wallets[index].id),
                          ),
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text("Err: $e"),
                ),
              ),

              const SizedBox(height: 24),

              // 3. RECENT TRANSACTIONS HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Transaksi Terakhir",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigasi ke Halaman Full History
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const TransactionHistoryScreen(),
                        ),
                      );
                    },
                    child: const Text("Lihat Semua"),
                  ),
                ],
              ),

              // 4. LIST TRANSAKSI (Top 5)
              transactionListAsync.when(
                data: (transactions) {
                  if (transactions.isEmpty)
                    return const Text("Belum ada transaksi.");
                  // Ambil 5 teratas saja
                  final recent = transactions.take(5).toList();

                  return ListView.builder(
                    shrinkWrap:
                        true, // Biar gak conflict sama SingleChildScrollView
                    physics:
                        const NeverScrollableScrollPhysics(), // Scroll ikut parent
                    itemCount: recent.length,
                    itemBuilder: (context, index) {
                      return TransactionItem(transaction: recent[index]);
                    },
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text("Err: $e"),
              ),

              const SizedBox(height: 80), // Padding bawah biar gak ketutup FAB
            ],
          ),
        ),
      ),
    );
  }

  void _showAddWalletDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final balanceController = TextEditingController();
    int selectedColor = 0xFF2196F3; // Default Blue

    // List warna yang bisa dipilih
    final List<int> colors = [
      0xFF2196F3, // Blue
      0xFF4CAF50, // Green
      0xFFF44336, // Red
      0xFFFFC107, // Amber
      0xFF9C27B0, // Purple
      0xFF607D8B, // Blue Grey
      0xFF795548, // Brown
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Buat Dompet Baru",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Input Nama
              TextField(
                controller: nameController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: "Nama Dompet",
                  hintText: "Contoh: BCA, GoPay, Tunai",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
                ),
              ),
              const SizedBox(height: 16),

              // Input Saldo
              TextField(
                controller: balanceController,
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyInputFormatter()],
                decoration: InputDecoration(
                  labelText: "Saldo Awal",
                  prefixText: "Rp ",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.attach_money),
                ),
              ),
              const SizedBox(height: 24),

              // Pilihan Warna
              const Text(
                "Pilih Warna Kartu",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: colors.length,
                  itemBuilder: (context, index) {
                    final color = colors[index];
                    final isSelected = selectedColor == color;
                    return GestureDetector(
                      onTap: () => setState(() => selectedColor = color),
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color(color),
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.black, width: 2)
                              : null,
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: Color(color).withOpacity(0.4),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                          ],
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 20,
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 32),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    final balance = CurrencyInputFormatter.parse(
                      balanceController.text,
                    );

                    if (name.isNotEmpty) {
                      ref
                          .read(walletControllerProvider.notifier)
                          .addWallet(
                            name: name,
                            initialBalance: balance,
                            color: selectedColor,
                            icon: 'wallet',
                          );
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "SIMPAN DOMPET",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _WalletCard extends ConsumerWidget {
  final String walletId;
  const _WalletCard({required this.walletId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallets = ref.watch(walletListProvider).value ?? [];

    // Safety check kalau wallet baru dihapus tapi UI belum rebuild
    if (!wallets.any((w) => w.id == walletId)) return const SizedBox();

    final wallet = wallets.firstWhere((w) => w.id == walletId);
    final currentBalance = ref.watch(walletBalanceProvider(walletId));

    return Card(
      elevation: 4,
      shadowColor: Color(wallet.color).withOpacity(0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        // <--- INTERAKSI CLICK DIMULAI DI SINI
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WalletDetailScreen(walletId: walletId),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16), // Padding digedein dikit biar lega
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(wallet.color).withOpacity(0.8),
                Color(wallet.color),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white54,
                    size: 14,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    wallet.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    NumberFormat.currency(
                      locale: 'id_ID',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ).format(currentBalance),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
