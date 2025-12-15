import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'transaction_controller.dart';
import 'widgets/transaction_item.dart';

class TransactionHistoryScreen extends ConsumerStatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  ConsumerState<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState
    extends ConsumerState<TransactionHistoryScreen> {
  String _searchQuery = '';
  DateTime _selectedMonth = DateTime.now(); // Default bulan ini

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Riwayat Transaksi"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SearchBar(
              hintText: "Cari transaksi...",
              leading: const Icon(Icons.search, color: Colors.grey),
              elevation: MaterialStateProperty.all(0),
              backgroundColor: MaterialStateProperty.all(Colors.grey.shade100),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
            ),
          ),
        ),
        actions: [
          // FILTER BULAN
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: _showMonthPicker,
            tooltip: "Pilih Bulan",
          ),
        ],
      ),
      body: transactionsAsync.when(
        data: (transactions) {
          // 1. FILTER BERDASARKAN BULAN & TAHUN
          var filtered = transactions.where((t) {
            return t.date.year == _selectedMonth.year &&
                t.date.month == _selectedMonth.month;
          }).toList();

          // 2. FILTER BERDASARKAN SEARCH QUERY
          if (_searchQuery.isNotEmpty) {
            filtered = filtered.where((t) {
              final query = _searchQuery.toLowerCase();
              return t.category.toLowerCase().contains(query) ||
                  (t.note?.toLowerCase().contains(query) ?? false);
            }).toList();
          }

          if (filtered.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    "Tidak ada transaksi di ${DateFormat('MMMM yyyy').format(_selectedMonth)}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // Hitung Total Pemasukan & Pengeluaran di Bulan Terpilih
          double income = 0;
          double expense = 0;
          for (var t in filtered) {
            if (t.amount > 0)
              income += t.amount;
            else
              expense += t.amount;
          }

          return Column(
            children: [
              // Summary Strip
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                color: Colors.grey.shade50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('MMMM yyyy').format(_selectedMonth),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Icon(Icons.arrow_downward, size: 14, color: Colors.red),
                        Text(
                          NumberFormat.compact().format(expense.abs()),
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.arrow_upward, size: 14, color: Colors.green),
                        Text(
                          NumberFormat.compact().format(income),
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    return TransactionItem(transaction: filtered[index]);
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text("Error: $e")),
      ),
    );
  }

  void _showMonthPicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      // Trik biar cuma pilih bulan (di beberapa device masih muncul tanggal, tapi gpp)
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null && picked != _selectedMonth) {
      setState(() {
        _selectedMonth = picked;
      });
    }
  }
}
