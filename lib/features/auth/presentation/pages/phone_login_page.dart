import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/aura_background.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../providers/auth_notifier.dart';
import '../providers/auth_ui_state.dart';

/// Phone number + SMS OTP sign-in screen.
class PhoneLoginPage extends StatefulWidget {
  const PhoneLoginPage({super.key});

  @override
  State<PhoneLoginPage> createState() => _PhoneLoginPageState();
}

class _PhoneLoginPageState extends State<PhoneLoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AuthUiState authState = context.watch<AuthUiState>();
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool isAwaitingOtp = authState.status == AuthStatus.awaitingOtp;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          const AuraBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const _BrandMark(),
                    const SizedBox(height: 16),
                    Text(
                      l10n.appTitle,
                      style: textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 28),
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                            l10n.phoneLoginTitle,
                            style: textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            l10n.appTagline,
                            style: textTheme.bodyMedium
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 24),
                          if (!isAwaitingOtp) ...<Widget>[
                            TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              autofocus: true,
                              decoration: InputDecoration(
                                labelText: l10n.phoneLabel,
                                hintText: '+90 5XX XXX XX XX',
                              ),
                            ),
                            const SizedBox(height: 16),
                            FilledButton(
                              onPressed: authState.isLoading ? null : _submitPhone,
                              child: Text(l10n.sendOtp),
                            ),
                          ] else ...<Widget>[
                            TextField(
                              controller: _otpController,
                              keyboardType: TextInputType.number,
                              autofocus: true,
                              maxLength: 6,
                              decoration: InputDecoration(
                                labelText: l10n.otpLabel,
                                counterText: '',
                              ),
                            ),
                            const SizedBox(height: 16),
                            FilledButton(
                              onPressed: authState.isLoading ? null : _submitOtp,
                              child: Text(l10n.verify),
                            ),
                            TextButton(
                              onPressed: authState.isLoading
                                  ? null
                                  : () => context.read<AuthNotifier>().reset(),
                              child: Text(l10n.changeNumber),
                            ),
                          ],
                          if (authState.isLoading) ...<Widget>[
                            const SizedBox(height: 16),
                            const LinearProgressIndicator(),
                          ],
                          if (authState.error != null) ...<Widget>[
                            const SizedBox(height: 16),
                            Text(
                              authState.error!,
                              style: const TextStyle(color: Color(0xFFF87171)),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submitPhone() {
    final String phone = _phoneController.text.trim();
    if (phone.isEmpty) return;
    context.read<AuthNotifier>().signInWithPhone(phone);
  }

  void _submitOtp() {
    final String code = _otpController.text.trim();
    if (code.isEmpty) return;
    context.read<AuthNotifier>().verifyOtp(code);
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Icon(Icons.auto_awesome, color: Colors.white, size: 34),
    );
  }
}
