import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/settings/presentation/security_controller.dart';

class BiometricGate extends ConsumerStatefulWidget {
  final Widget child;
  const BiometricGate({super.key, required this.child});

  @override
  ConsumerState<BiometricGate> createState() => _BiometricGateState();
}

class _BiometricGateState extends ConsumerState<BiometricGate>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Mulai pantau status App
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Stop pantau
    super.dispose();
  }

  // Logic Deteksi Keluar Masuk App
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final isEnabled = ref.read(isBiometricEnabledProvider);

    if (!isEnabled) return; // Kalau fitur mati, cuekin aja

    if (state == AppLifecycleState.paused) {
      // User minimize app / layar mati -> KUNCI LANGSUNG!
      ref.read(isAppLockedProvider.notifier).state = true;
    } else if (state == AppLifecycleState.resumed) {
      // User balik lagi -> Trigger Auth
      ref.read(securityControllerProvider).requireAuth();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLocked = ref.watch(isAppLockedProvider);

    return Stack(
      children: [
        widget.child, // Aplikasi Utama
        // Layar Pengunci (Overlay)
        if (isLocked)
          Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock, size: 80, color: Colors.green),
                  const SizedBox(height: 24),
                  const Text(
                    "Rupiah Terkunci",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      ref.read(securityControllerProvider).requireAuth();
                    },
                    icon: const Icon(Icons.fingerprint),
                    label: const Text("Buka Kunci"),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
