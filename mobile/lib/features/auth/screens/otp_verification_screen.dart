import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

/// Pantalla 2 — Verificación del código OTP de 6 dígitos
/// El usuario escribe el código que llegó por SMS
class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({super.key, required this.phoneNumber});

  final String phoneNumber;

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState
    extends ConsumerState<OtpVerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  int _secondsLeft = 60;
  Timer? _timer;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    // Auto-focus al primer campo
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _focusNodes[0].requestFocus());
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _secondsLeft = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 0) {
        t.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  String get _otpCode =>
      _controllers.map((c) => c.text).join();

  Future<void> _verify() async {
    final code = _otpCode;
    if (code.length != 6) return;

    setState(() => _loading = true);
    FocusScope.of(context).unfocus();

    final authState = ref.read(authNotifierProvider);
    final verificationId = authState.valueOrNull;

    if (verificationId is _CodeSent) {
      await ref.read(authNotifierProvider.notifier).verifyCode(
            verificationId: verificationId.verificationId,
            smsCode: code,
          );
    }

    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<void> _resendCode() async {
    if (_secondsLeft > 0) return;
    _startCountdown();
    // Limpiar campos
    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes[0].requestFocus();
    await ref
        .read(authNotifierProvider.notifier)
        .sendOtp(widget.phoneNumber);
  }

  void _onDigitChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    // Auto-verificar cuando se completan los 6 dígitos
    if (_otpCode.length == 6) {
      _verify();
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Navegar cuando la autenticación sea exitosa
    ref.listen(authNotifierProvider, (_, next) {
      next.whenOrNull(
        data: (state) {
          if (state is _Authenticated) {
            // Si es nuevo usuario → selección de rol
            // Si ya tiene perfil → dashboard del ciclista
            context.go('/cyclist/dashboard');
          }
        },
        error: (err, _) {
          _showError(err.toString());
          // Limpiar campos al error
          for (final c in _controllers) {
            c.clear();
          }
          _focusNodes[0].requestFocus();
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Verificar número'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSizes.paddingL),

              Text(
                'Código de verificación',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(text: 'Enviamos un código SMS al '),
                    TextSpan(
                      text: '+57 ${widget.phoneNumber}',
                      style: const TextStyle(
                        color: AppColors.onBackground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.paddingXL),

              // Campos OTP — 6 dígitos
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 48,
                    height: 60,
                    child: TextFormField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        contentPadding: EdgeInsets.zero,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.surfaceVariant,
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (v) => _onDigitChanged(v, index),
                    ),
                  );
                }),
              ),

              const SizedBox(height: AppSizes.paddingXL),

              // Botón verificar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_loading || _otpCode.length != 6) ? null : _verify,
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Verificar'),
                ),
              ),

              const SizedBox(height: AppSizes.paddingL),

              // Reenviar código
              Center(
                child: _secondsLeft > 0
                    ? Text(
                        'Reenviar código en ${_secondsLeft}s',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      )
                    : TextButton(
                        onPressed: _resendCode,
                        child: const Text(
                          'Reenviar código',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
