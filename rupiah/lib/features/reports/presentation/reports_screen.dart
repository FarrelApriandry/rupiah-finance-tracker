import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'report_controller.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(expenseByCategoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Analisis Pengeluaran")),
      body: data.isEmpty
          ? const Center(child: Text("Belum ada data pengeluaran."))
          : SingleChildScrollView(
              // Biar aman di Tablet/HP kecil
              child: Column(
                children: [
                  const SizedBox(height: 24),

                  // 1. PIE CHART SECTION
                  SizedBox(
                    height: 250, // Tinggi Chart
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 50, // Jadi bentuk Donat
                        sections: data.map((item) {
                          return PieChartSectionData(
                            color: item.color,
                            value: item.totalAmount,
                            title: "${item.percentage.toStringAsFixed(1)}%",
                            radius: 60,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 2. LEGEND / DETAIL LIST
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final item = data[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: item.color,
                            radius: 16,
                          ),
                          title: Text(
                            item.categoryName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: LinearProgressIndicator(
                            value: item.percentage / 100,
                            backgroundColor: item.color.withOpacity(0.1),
                            color: item.color,
                            minHeight: 4,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                NumberFormat.currency(
                                  locale: 'id',
                                  symbol: 'Rp ',
                                  decimalDigits: 0,
                                ).format(item.totalAmount),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "${item.percentage.toStringAsFixed(1)}%",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}
