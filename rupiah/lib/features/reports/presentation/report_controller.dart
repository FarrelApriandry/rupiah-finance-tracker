import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart'; // Buat grouping
import '../../transactions/presentation/transaction_controller.dart';
import '../../categories/presentation/category_controller.dart';
import '../../transactions/domain/transaction_model.dart';

class CategoryExpense {
  final String categoryName;
  final double totalAmount;
  final Color color;
  final double percentage;

  CategoryExpense({
    required this.categoryName,
    required this.totalAmount,
    required this.color,
    required this.percentage,
  });
}

// Provider untuk menghitung Pengeluaran per Kategori bulan ini
final expenseByCategoryProvider = Provider<List<CategoryExpense>>((ref) {
  final transactions = ref.watch(transactionListProvider).value ?? [];
  final categories = ref.watch(categoryListProvider).value ?? [];

  // 1. Filter cuma Pengeluaran (Expense) & Bulan Ini (Opsional, sementara All Time dulu biar datanya banyak)
  // Kalau mau bulan ini aja, uncomment baris bawah:
  // final now = DateTime.now();
  final expenses = transactions
      .where((t) => t.amount < 0 /* && t.date.month == now.month */)
      .toList();

  if (expenses.isEmpty) return [];

  // 2. Hitung Total Pengeluaran
  final totalExpense = expenses.fold(0.0, (sum, t) => sum + t.amount.abs());

  // 3. Grouping by Category Name
  final grouped = groupBy<TransactionModel, String>(
    expenses,
    (t) => t.category,
  );

  // 4. Map ke object CategoryExpense
  final result = grouped.entries.map((entry) {
    final catName = entry.key;
    final totalPerCat = entry.value.fold(0.0, (sum, t) => sum + t.amount.abs());

    // Cari warna dari daftar kategori custom
    // Kalau gak ketemu (kategori default/manual), kasih warna random/hash
    final customCat = categories.firstWhereOrNull((c) => c.name == catName);

    Color color;
    if (customCat != null) {
      color = Color(customCat.color);
    } else {
      // Fallback colors buat kategori default/manual
      color = _getFallbackColor(catName);
    }

    return CategoryExpense(
      categoryName: catName,
      totalAmount: totalPerCat,
      color: color,
      percentage: (totalPerCat / totalExpense) * 100,
    );
  }).toList();

  // Sort dari yang pengeluarannya paling gede
  result.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

  return result;
});

// Helper buat warna kategori default
Color _getFallbackColor(String name) {
  switch (name) {
    case 'Makan':
      return Colors.orange;
    case 'Transport':
      return Colors.blue;
    case 'Belanja':
      return Colors.purple;
    case 'Gaji':
      return Colors.green; // Jarang dipake di expense
    default:
      // Generate warna konsisten dari string hash
      return Colors.primaries[name.hashCode % Colors.primaries.length];
  }
}
