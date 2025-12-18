import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final biometricServiceProvider = Provider((ref) => BiometricService());

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> isDeviceSupported() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool isDeviceSupported = await _auth.isDeviceSupported();
      return canAuthenticateWithBiometrics || isDeviceSupported;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> authenticate() async {
    try {
      // FIX FINAL: Berdasarkan dokumentasi package kamu:
      // 1. Jangan pakai 'options'.
      // 2. Ganti 'stickyAuth' jadi 'persistAcrossBackgrounding'.
      return await _auth.authenticate(
        localizedReason: 'Scan sidik jari untuk membuka Rupiah',
        biometricOnly: true,
        persistAcrossBackgrounding: true, // Pengganti stickyAuth
      );
    } on PlatformException {
      return false;
    }
  }
}
