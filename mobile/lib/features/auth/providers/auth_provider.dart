import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../models/user_model.dart';
import '../../../shared/services/api_service.dart';

// ──────────────────────────────────────
// Estado de autenticación Firebase
// Escucha el stream de Firebase Auth en tiempo real
// ──────────────────────────────────────
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// ──────────────────────────────────────
// Perfil del usuario actual (desde backend)
// ──────────────────────────────────────
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final firebaseUser = ref.watch(authStateProvider).valueOrNull;
  if (firebaseUser == null) return null;

  final api = ref.read(apiServiceProvider);
  return api.getMe();
});

// ──────────────────────────────────────
// Notifier para el flujo de login OTP
// ──────────────────────────────────────
final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, AuthFlowState>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<AuthFlowState> {
  @override
  Future<AuthFlowState> build() async => const AuthFlowState.idle();

  /// Paso 1: Enviar SMS con Firebase Auth
  Future<void> sendOtp(String phoneNumber) async {
    state = const AsyncLoading();

    await FirebaseAuth.instance.verifyPhoneNumber(
      // Colombia: +57 + número sin el 0 inicial
      phoneNumber: phoneNumber.startsWith('+') ? phoneNumber : '+57$phoneNumber',
      timeout: const Duration(seconds: 60),

      // Verificación automática (Android con SIM card y Google Play)
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _signInWithCredential(credential);
      },

      // Error al enviar el SMS
      verificationFailed: (FirebaseAuthException e) {
        state = AsyncError(
          _mapFirebaseError(e.code),
          StackTrace.current,
        );
      },

      // SMS enviado → pasar el verificationId a la siguiente pantalla
      codeSent: (String verificationId, int? resendToken) {
        state = AsyncData(
          AuthFlowState.codeSent(
            verificationId: verificationId,
            phoneNumber: phoneNumber,
          ),
        );
      },

      codeAutoRetrievalTimeout: (_) {},
    );
  }

  /// Paso 2: Verificar código de 6 dígitos
  Future<void> verifyCode({
    required String verificationId,
    required String smsCode,
  }) async {
    state = const AsyncLoading();

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      await _signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      state = AsyncError(_mapFirebaseError(e.code), StackTrace.current);
    }
  }

  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final firebaseToken = await userCredential.user!.getIdToken();

      // Intercambiar token Firebase por JWT del backend
      final api = ref.read(apiServiceProvider);
      final result = await api.verifyFirebaseToken(firebaseToken!);

      // Guardar JWT de forma segura
      const storage = FlutterSecureStorage();
      await storage.write(key: 'jwt_token', value: result.jwt);

      state = AsyncData(
        AuthFlowState.authenticated(user: result.user),
      );
    } catch (e, st) {
      state = AsyncError('Error al autenticar. Inténtalo de nuevo.', st);
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    const FlutterSecureStorage().delete(key: 'jwt_token');
    state = const AsyncData(AuthFlowState.idle());
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'invalid-phone-number':
        return 'Número de teléfono inválido. Incluye el código de área.';
      case 'too-many-requests':
        return 'Demasiados intentos. Espera unos minutos.';
      case 'invalid-verification-code':
        return 'Código incorrecto. Revisa el SMS e inténtalo de nuevo.';
      case 'session-expired':
        return 'El código expiró. Solicita uno nuevo.';
      default:
        return 'Error inesperado ($code). Inténtalo de nuevo.';
    }
  }
}

// ──────────────────────────────────────
// Estado del flujo de autenticación
// ──────────────────────────────────────
sealed class AuthFlowState {
  const AuthFlowState();

  const factory AuthFlowState.idle() = _Idle;
  const factory AuthFlowState.codeSent({
    required String verificationId,
    required String phoneNumber,
  }) = _CodeSent;
  const factory AuthFlowState.authenticated({required UserModel user}) =
      _Authenticated;
}

class _Idle extends AuthFlowState {
  const _Idle();
}

class _CodeSent extends AuthFlowState {
  const _CodeSent({required this.verificationId, required this.phoneNumber});
  final String verificationId;
  final String phoneNumber;
}

class _Authenticated extends AuthFlowState {
  const _Authenticated({required this.user});
  final UserModel user;
}
