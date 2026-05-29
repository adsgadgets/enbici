import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

/// Pantalla 1 — Login con número de teléfono colombiano
/// El usuario ingresa su celular y recibe un SMS con código de 6 dígitos
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    FocusScope.of(context).unfocus();

    await ref
        .read(authNotifierProvider.notifier)
        .sendOtp(_phoneController.text.trim());

    if (!mounted) return;
    setState(() => _loading = false);

    final authState = ref.read(authNotifierProvider);
    authState.whenOrNull(
      data: (state) {
        if (state is _CodeSent) {
          context.push(
            '/otp',
            extra: _phoneController.text.trim(),
          );
        }
      },
      error: (err, _) => _showError(err.toString()),
    );
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
    // Escuchar cambios del estado de auth
    ref.listen(authNotifierProvider, (_, next) {
      next.whenOrNull(
        error: (err, _) => _showError(err.toString()),
      );
    });

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(flex: 2),

                // Logo / icono
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.directions_bike_rounded,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                ),

                const SizedBox(height: AppSizes.paddingL),

                // Título
                const Center(
                  child: Text(
                    'EnBici',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: AppColors.onBackground,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'Tu acompañante de seguridad en ruta',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),

                const Spacer(flex: 2),

                // Campo teléfono
                Text(
                  'Número de celular',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onBackground.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: AppSizes.paddingS),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.5,
                  ),
                  decoration: InputDecoration(
                    hintText: '300 000 0000',
                    hintStyle: TextStyle(
                      color: AppColors.textSecondary.withOpacity(0.5),
                      letterSpacing: 1.5,
                    ),
                    prefixIcon: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 14),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🇨🇴', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 8),
                          Text(
                            '+57',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onBackground.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 1,
                            height: 20,
                            color: AppColors.surfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa tu número de celular';
                    }
                    if (value.length != 10) {
                      return 'El número debe tener 10 dígitos';
                    }
                    if (!value.startsWith('3')) {
                      return 'Los celulares colombianos empiezan con 3';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSizes.paddingL),

                // Botón enviar OTP
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _sendOtp,
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Continuar'),
                  ),
                ),

                const SizedBox(height: AppSizes.paddingM),

                // Nota de privacidad
                Center(
                  child: Text(
                    'Te enviaremos un código SMS para verificar tu número.\n'
                    'Tus datos están protegidos bajo la Ley 1581/2012.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary.withOpacity(0.7),
                      height: 1.5,
                    ),
                  ),
                ),

                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
