import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/users_repository.dart';
import '../theme/app_theme.dart';
import '../utils/input_validators.dart';
import '../widgets/app_snackbar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usersRepo = UsersRepository();

  /// Typical auth form width; fields and buttons share one column width.
  static const double _authColumnMaxWidth = 400;
  /// Material-aligned minimum height for fields and primary actions (touch target).
  static const double _controlHeight = 48;
  static const EdgeInsets _fieldContentPadding =
      EdgeInsets.symmetric(horizontal: 16, vertical: 16);

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _trySyncUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await _usersRepo.syncUserDocument(user);
    } catch (e) {
      if (mounted) {
        showAppSnackBar(context, 'Could not sync profile to Firestore: $e', isError: true);
      }
    }
  }

  String _authMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      default:
        return e.message ?? e.code;
    }
  }

  Future<void> _signInWithEmail() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      await _trySyncUserProfile();
      if (!mounted) return;
      context.go('/vault');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      showAppSnackBar(context, _authMessage(e), isError: true);
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(context, 'Sign-in failed: $e', isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _performRegistration() async {
    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      await _trySyncUserProfile();
      if (!mounted) return;
      context.go('/vault');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      showAppSnackBar(context, e.message ?? e.code, isError: true);
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(context, 'Registration failed: $e', isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _authColumnMaxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 48),
                    Icon(Icons.lock_outline_rounded, size: 56, color: AppTheme.accentTeal),
                    const SizedBox(height: 24),
                    Text(
                      'CBS Vault',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in with your email to open the vault.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      autofillHints: const [AutofillHints.email],
                      textInputAction: TextInputAction.next,
                      validator: InputValidators.email,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        contentPadding: _fieldContentPadding,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscure,
                      autofillHints: const [AutofillHints.password],
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _signInWithEmail(),
                      validator: (v) {
                        return InputValidators.passwordSignIn(v);
                      },
                      decoration: InputDecoration(
                        labelText: 'Password',
                        contentPadding: _fieldContentPadding,
                        suffixIcon: IconButton(
                          icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _loading ? null : _signInWithEmail,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, _controlHeight),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _loading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Sign in'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _loading ? null : _createAccountWithValidation,
                      child: const Text('Create account'),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Coursework lab: enable Email/Password in Firebase Authentication.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45),
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _createAccountWithValidation() async {
    final emailErr = InputValidators.email(_emailController.text);
    final passErr = InputValidators.passwordRegister(_passwordController.text);
    _formKey.currentState?.validate();
    if (emailErr != null) {
      showAppSnackBar(context, emailErr, isError: true);
      return;
    }
    if (passErr != null) {
      showAppSnackBar(context, passErr, isError: true);
      return;
    }
    await _performRegistration();
  }
}
