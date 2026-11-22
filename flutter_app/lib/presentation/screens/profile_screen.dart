import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../presentation/viewmodels/auth_viewmodel.dart';
import '../routes/app_routes.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';

/// Profile screen displaying the authenticated user's account details.
///
/// Responsibilities:
/// - Shows the current user's name, email, and ID.
/// - Allows the user to update their name and/or email.
/// - Provides a logout button that clears the session.
/// - Observes [AuthViewModel] for loading and error states.
class ProfileScreen extends StatefulWidget {
  /// Creates a [ProfileScreen] with an optional [key].
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  /// Controller for the name input field (pre-filled with current name).
  final _nameController = TextEditingController();

  /// Controller for the email input field (pre-filled with current email).
  final _emailController = TextEditingController();

  /// Whether the edit form is currently visible.
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill controllers with the current user profile.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthViewModel>().user;
      if (user != null && mounted) {
        _nameController.text = user.name;
        _emailController.text = user.email;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  /// Updates the profile with the edited name and email.
  Future<void> _saveProfile() async {
    final viewModel = context.read<AuthViewModel>();
    final success = await viewModel.updateProfile(
      name: _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
    );
    if (success && mounted) {
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    }
  }

  /// Logs the user out and redirects to the login screen.
  Future<void> _logout() async {
    await context.read<AuthViewModel>().logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        final user = authViewModel.user;

        // Show a spinner while the profile is being loaded or updated.
        if (authViewModel.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Show an error banner if an operation failed.
        if (authViewModel.error != null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Profile')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    authViewModel.error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  CustomButton(
                    text: 'Retry',
                    onPressed: () => authViewModel.refreshProfile(),
                  ),
                ],
              ),
            ),
          );
        }

        if (user == null) {
          return const Scaffold(
            body: Center(child: Text('No user profile available')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            centerTitle: true,
            actions: [
              if (!_isEditing)
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => setState(() => _isEditing = true),
                  tooltip: 'Edit profile',
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 24),
                // Profile avatar placeholder.
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.indigo,
                  child: Icon(Icons.person, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 24),
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  user.email,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 24),
                // User ID card.
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Account Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _DetailRow(label: 'User ID', value: user.id),
                        const SizedBox(height: 12),
                        _DetailRow(label: 'Name', value: user.name),
                        const SizedBox(height: 12),
                        _DetailRow(label: 'Email', value: user.email),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Edit form (animated in when editing).
                if (_isEditing) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Edit Profile',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _nameController,
                            label: 'Full Name',
                            hint: 'John Doe',
                            icon: Icons.person_outline,
                          ),
                          const SizedBox(height: 20),
                          CustomTextField(
                            controller: _emailController,
                            label: 'Email',
                            hint: 'you@example.com',
                            keyboardType: TextInputType.emailAddress,
                            icon: Icons.email_outlined,
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: CustomButton(
                                  text: 'Save',
                                  isLoading: authViewModel.isLoading,
                                  onPressed: _saveProfile,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () =>
                                      setState(() => _isEditing = false),
                                  child: const Text('Cancel'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                // Logout button.
                CustomButton(
                  text: 'Logout',
                  onPressed: _logout,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// A read-only row showing a [label] and its corresponding [value].
class _DetailRow extends StatelessWidget {
  /// The label text (e.g. "User ID").
  final String label;

  /// The value text (e.g. the actual ID).
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
