import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final result = await _initializeFirebase();
  runApp(MyApp(initResult: result));
}

class FirebaseInitResult {
  const FirebaseInitResult({required this.success, required this.message});

  final bool success;
  final String message;
}

Future<FirebaseInitResult> _initializeFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    return const FirebaseInitResult(
      success: true,
      message: 'Firebase initialized. You can now use Auth and Database.',
    );
  } on UnsupportedError catch (e) {
    return FirebaseInitResult(
      success: false,
      message: 'Firebase not configured for this platform: ${e.message}',
    );
  } catch (e) {
    if (kDebugMode) {
      return FirebaseInitResult(
        success: false,
        message: 'Firebase initialization failed: $e',
      );
    }

    return const FirebaseInitResult(
      success: false,
      message: 'Firebase initialization failed.',
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.initResult});

  final FirebaseInitResult initResult;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Forms Hub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A73E8)),
        scaffoldBackgroundColor: const Color(0xFFF4F6FA),
        useMaterial3: true,
      ),
      home: FormsHubPage(initResult: initResult),
    );
  }
}

class FormsHubPage extends StatelessWidget {
  const FormsHubPage({super.key, required this.initResult});

  final FirebaseInitResult initResult;

  @override
  Widget build(BuildContext context) {
    if (!initResult.success) {
      return _InitFailurePage(message: initResult.message);
    }

    return const _AuthGate();
  }
}

class _InitFailurePage extends StatelessWidget {
  const _InitFailurePage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firebase setup required')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.warning_amber_rounded, size: 42),
                  const SizedBox(height: 12),
                  const Text(
                    'Firebase initialization status',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(message, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  const Text(
                    'Update your Firebase credentials in lib/firebase_options.dart, then restart.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          return const _SignInPage();
        }

        return _FormsHomePage(user: user);
      },
    );
  }
}

class _SignInPage extends StatefulWidget {
  const _SignInPage();

  @override
  State<_SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<_SignInPage> {
  bool _isLoading = false;
  String? _error;

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        await FirebaseAuth.instance.signInWithPopup(provider);
      } else {
        final googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) {
          setState(() => _error = 'Sign in canceled.');
          return;
        }

        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        await FirebaseAuth.instance.signInWithCredential(credential);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'configuration-not-found') {
        setState(() {
          _error =
              'Google Sign-In is not enabled in Firebase Authentication for this project. '
              'Open Firebase Console -> Authentication -> Get started -> Sign-in method -> enable Google.';
        });
      } else {
        setState(
          () =>
              _error = 'Google sign in failed: [${e.code}] ${e.message ?? ''}',
        );
      }
    } catch (e) {
      setState(() => _error = 'Google sign in failed: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8F0FE), Color(0xFFF4F6FA)],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Card(
              elevation: 2,
              margin: const EdgeInsets.all(24),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Forms Hub',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create and share forms like Microsoft Forms. Sign in to continue.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _isLoading ? null : _handleGoogleSignIn,
                        icon: const Icon(Icons.login),
                        label: Text(
                          _isLoading ? 'Signing in...' : 'Sign in with Google',
                        ),
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _error!,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FormsHomePage extends StatefulWidget {
  const _FormsHomePage({required this.user});

  final User user;

  @override
  State<_FormsHomePage> createState() => _FormsHomePageState();
}

class _FormsHomePageState extends State<_FormsHomePage> {
  final _departmentController = TextEditingController();
  final _satisfactionController = TextEditingController();
  final _improvementController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _departmentController.dispose();
    _satisfactionController.dispose();
    _improvementController.dispose();
    super.dispose();
  }

  Future<void> _submitResponse() async {
    final department = _departmentController.text.trim();
    final satisfaction = _satisfactionController.text.trim();
    final improvement = _improvementController.text.trim();

    if (department.isEmpty || satisfaction.isEmpty || improvement.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please answer all questions.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final doc = await FirebaseFirestore.instance
          .collection('formResponses')
          .add({
            'formId': 'quarterly_team_pulse',
            'department': department,
            'satisfaction': satisfaction,
            'improvement': improvement,
            'submittedByUid': widget.user.uid,
            'submittedByEmail': widget.user.email,
            'submittedAt': FieldValue.serverTimestamp(),
          });

      _departmentController.clear();
      _satisfactionController.clear();
      _improvementController.clear();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Saved to Firebase: ${doc.id}')));
    } on FirebaseException catch (e) {
      if (!mounted) {
        return;
      }

      final message = e.code == 'permission-denied'
          ? 'Write blocked by Firestore rules. Allow create on formResponses for authenticated users.'
          : 'Failed to save to Firebase: ${e.message ?? e.code}';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save to Firebase: $e')));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (!kIsWeb) {
      await GoogleSignIn().signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forms Hub'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Text(
                  widget.user.displayName ?? widget.user.email ?? 'Signed in',
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: _signOut,
                  child: const Text('Sign out'),
                ),
              ],
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const _HeroCard(),
          const SizedBox(height: 16),
          const _FormsPreviewCard(),
          const SizedBox(height: 16),
          _QuestionCard(
            number: 1,
            title: 'What is your department?',
            subtitle: 'Short answer',
            controller: _departmentController,
          ),
          const SizedBox(height: 12),
          _QuestionCard(
            number: 2,
            title: 'How satisfied are you with your current tooling?',
            subtitle: 'Choice',
            controller: _satisfactionController,
          ),
          const SizedBox(height: 12),
          _QuestionCard(
            number: 3,
            title: 'What should we improve first?',
            subtitle: 'Paragraph',
            controller: _improvementController,
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          Text(
            'Responses are stored in Firestore collection formResponses.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSubmitting ? null : _submitResponse,
        icon: const Icon(Icons.send_outlined),
        label: Text(_isSubmitting ? 'Saving...' : 'Submit response'),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quarterly Team Pulse',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'A Microsoft Forms-style template with clean sections and simple response fields.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _FormsPreviewCard extends StatelessWidget {
  const _FormsPreviewCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.description_outlined),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Response settings',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const _OptionRow(title: 'Collect respondent email', enabled: true),
            const _OptionRow(title: 'One response per person', enabled: true),
            const _OptionRow(title: 'Show progress bar', enabled: false),
          ],
        ),
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({required this.title, required this.enabled});

  final String title;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(title)),
          Switch(value: enabled, onChanged: (_) {}),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.controller,
    this.maxLines = 1,
  });

  final int number;
  final String title;
  final String subtitle;
  final TextEditingController controller;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question $number',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(subtitle),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: maxLines,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Type your answer',
              ),
            ),
          ],
        ),
      ),
    );
  }
}