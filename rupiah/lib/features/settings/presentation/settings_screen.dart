import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // Buat Cek Sinyal
import '../../auth/presentation/auth_controller.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/services/firestore_service.dart';
import 'security_controller.dart'; // Import Controller Security

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    final themeMode = ref.watch(themeModeProvider);
    // Watch status Biometric
    final isBiometricEnabled = ref.watch(isBiometricEnabledProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Pengaturan")),
      body: ListView(
        children: [
          // ... (PROFILE SECTION - SAMA SEPERTI SEBELUMNYA) ...
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(
                    user?.photoURL ?? "https://ui-avatars.com/api/?name=User",
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user?.displayName ?? "User",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user?.email ?? "",
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          const Divider(),

          // 2. KEAMANAN (BARU)
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              "Keamanan & Koneksi",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),

          // Toggle Biometric
          ListTile(
            leading: const Icon(Icons.fingerprint),
            title: const Text("Kunci Aplikasi"),
            subtitle: const Text("Wajibkan sidik jari saat membuka aplikasi"),
            trailing: Switch(
              value: isBiometricEnabled,
              onChanged: (val) {
                ref.read(securityControllerProvider).toggleBiometric(val);
                if (val) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Aplikasi akan terkunci jika diminimize"),
                    ),
                  );
                }
              },
            ),
          ),

          // Indikator Offline (Bonus Day 12 Part B)
          StreamBuilder<List<ConnectivityResult>>(
            stream: Connectivity().onConnectivityChanged,
            builder: (context, snapshot) {
              final results = snapshot.data;
              final isOffline =
                  results != null && results.contains(ConnectivityResult.none);

              return ListTile(
                leading: Icon(
                  isOffline ? Icons.wifi_off : Icons.wifi,
                  color: isOffline ? Colors.red : Colors.green,
                ),
                title: Text(isOffline ? "Mode Offline" : "Terhubung"),
                subtitle: Text(
                  isOffline
                      ? "Data tersimpan lokal, akan sync otomatis nanti."
                      : "Sinkronisasi realtime aktif.",
                ),
              );
            },
          ),

          const Divider(),

          // ... (APPEARANCE & DANGEROUS ZONE - SAMA SEPERTI SEBELUMNYA) ...
          ListTile(
            leading: const Icon(Icons.dark_mode_outlined),
            title: const Text("Mode Gelap"),
            trailing: Switch(
              value: themeMode == ThemeMode.dark,
              onChanged: (val) {
                ref
                    .read(themeModeProvider.notifier)
                    .setTheme(val ? ThemeMode.dark : ThemeMode.light);
              },
            ),
          ),

          // ... (DANGEROUS ZONE) ...
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text(
              "Reset Data Aplikasi",
              style: TextStyle(color: Colors.red),
            ),
            onTap: () async {
              await ref.read(firestoreServiceProvider).deleteAllData();
              if (context.mounted) Navigator.pop(context);
            },
          ),

          const Divider(),

          // LOGOUT
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Keluar"),
            onTap: () async {
              await ref.read(authControllerProvider.notifier).signOut();
              if (context.mounted)
                Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ],
      ),
    );
  }
}
