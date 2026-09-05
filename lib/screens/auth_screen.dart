import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/supabase_service.dart';
import 'main_shell.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  bool _otpSent = false;
  bool _loading = false;
  String? _error;

  Future<void> _sendOtp() async {
    if (_nameCtrl.text.trim().isEmpty || _phoneCtrl.text.trim().length < 8) {
      setState(() => _error = 'عبّي الاسم ورقم الهاتف بشكل صحيح');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await SupabaseService.signInWithPhone(_phoneCtrl.text.trim());
      setState(() { _otpSent = true; _loading = false; });
    } catch (e) {
      setState(() { _error = 'تعذر إرسال الرمز — تأكد إن مزوّد SMS مفعّل بمشروع Supabase.\n$e'; _loading = false; });
    }
  }

  Future<void> _verify() async {
    setState(() { _loading = true; _error = null; });
    try {
      await SupabaseService.verifyPhoneOtp(_phoneCtrl.text.trim(), _otpCtrl.text.trim());
      await SupabaseService.upsertProfile(fullName: _nameCtrl.text.trim(), phone: _phoneCtrl.text.trim());
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainShell()));
    } catch (e) {
      setState(() { _error = 'رمز غير صحيح، حاول مرة ثانية'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 30),
              const Icon(Icons.vpn_key_rounded, color: AppColors.orange, size: 40),
              const SizedBox(height: 10),
              Text('أهلاً فيك 👋', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              const Text('أدخل اسمك ورقم هاتفك للمتابعة', style: TextStyle(color: AppColors.muted)),
              const SizedBox(height: 20),
              if (!_otpSent) ...[
                TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'الاسم الكامل')),
                const SizedBox(height: 12),
                TextField(controller: _phoneCtrl, keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'رقم الهاتف (بصيغة دولية مثل +9627...)')),
                const SizedBox(height: 16),
                if (_error != null) Padding(padding: const EdgeInsets.only(bottom: 10), child: Text(_error!, style: const TextStyle(color: AppColors.danger))),
                ElevatedButton(onPressed: _loading ? null : _sendOtp, child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('إرسال رمز التحقق')),
              ] else ...[
                Text('أدخل الرمز المرسل لـ ${_phoneCtrl.text}', style: const TextStyle(color: AppColors.muted)),
                const SizedBox(height: 12),
                TextField(controller: _otpCtrl, keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'رمز التحقق')),
                const SizedBox(height: 16),
                if (_error != null) Padding(padding: const EdgeInsets.only(bottom: 10), child: Text(_error!, style: const TextStyle(color: AppColors.danger))),
                ElevatedButton(onPressed: _loading ? null : _verify, child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('تأكيد')),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
