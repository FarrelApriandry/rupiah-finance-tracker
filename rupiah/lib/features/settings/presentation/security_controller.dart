import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/biometric_service.dart';

// 1. Notifier untuk Status Locked
final isAppLockedProvider = NotifierProvider<AppLockNotifier, bool>(() {
  return AppLockNotifier();
});

class AppLockNotifier extends Notifier<bool> {
  @override
  bool build() => false; // Default: Tidak terkunci

  void setLocked(bool value) => state = value;
}

// 2. Notifier untuk Setting Biometric Enabled
final isBiometricEnabledProvider =
    NotifierProvider<BiometricEnabledNotifier, bool>(() {
      return BiometricEnabledNotifier();
    });

class BiometricEnabledNotifier extends Notifier<bool> {
  @override
  bool build() => false; // Default: Fitur mati

  void setEnabled(bool value) => state = value;
}

final securityControllerProvider = Provider((ref) => SecurityController(ref));

class SecurityController {
  final Ref _ref;

  SecurityController(this._ref);

  Future<void> requireAuth() async {
    final isEnabled = _ref.read(isBiometricEnabledProvider);

    if (!isEnabled) return;

    // Kunci App
    _ref.read(isAppLockedProvider.notifier).setLocked(true);

    // Authenticate
    final success = await _ref.read(biometricServiceProvider).authenticate();

    if (success) {
      // Buka Kunci
      _ref.read(isAppLockedProvider.notifier).setLocked(false);
    }
  }

  void toggleBiometric(bool value) {
    _ref.read(isBiometricEnabledProvider.notifier).setEnabled(value);
  }
}
