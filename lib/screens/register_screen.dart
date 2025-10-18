import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/app_theme.dart';
import '../widgets/main_navigation.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  UserRole _selectedRole = UserRole.kasir;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() => setState(() {}));
    _emailController.addListener(() => setState(() {}));
    _passwordController.addListener(() => setState(() {}));
    _confirmPasswordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama wajib diisi';
    }
    if (value.length < 2) {
      return 'Nama minimal 2 karakter';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email wajib diisi';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password wajib diisi';
    }
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password wajib diisi';
    }
    if (value != _passwordController.text) {
      return 'Password tidak cocok';
    }
    return null;
  }

  bool _isFormValid() {
    return _nameController.text.isNotEmpty &&
           _emailController.text.isNotEmpty && 
           _passwordController.text.isNotEmpty &&
           _confirmPasswordController.text.isNotEmpty &&
           _validateName(_nameController.text) == null &&
           _validateEmail(_emailController.text) == null &&
           _validatePassword(_passwordController.text) == null &&
           _validateConfirmPassword(_confirmPasswordController.text) == null;
  }

  Future<void> _handleRegister(AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await authProvider.register(
        _emailController.text,
        _passwordController.text,
        _nameController.text,
        _selectedRole,
      );
      
      if (success && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigation()),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary,
                  AppColors.primary.withOpacity(0.8),
                  Colors.white,
                ],
                stops: const [0.0, 0.3, 1.0],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.lg),
                    
                    // Back button and Logo
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.savings,
                            size: 30,
                            color: AppColors.primary,
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(width: 48), // Balance the back button
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    
                    const Text(
                      'Create New Account',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const Text(
                      'Join Flutter Savings Bank today',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    
                    // Registration Card
                    Card(
                      elevation: 20,
                      shadowColor: Colors.black.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Create Your Bank Account',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              
                              // Error message display
                              if (authProvider.errorMessage != null) ...[
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  decoration: BoxDecoration(
                                    color: AppColors.errorLight,
                                    borderRadius: BorderRadius.circular(AppRadius.lg),
                                    border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.warning, color: AppColors.error),
                                      const SizedBox(width: AppSpacing.sm),
                                      Expanded(
                                        child: Text(
                                          authProvider.errorMessage!,
                                          style: const TextStyle(color: AppColors.error),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.lg),
                              ],

                              // Name field
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.grey50,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: TextFormField(
                                  controller: _nameController,
                                  validator: _validateName,
                                  decoration: const InputDecoration(
                                    hintText: 'Nama Lengkap',
                                    prefixIcon: Icon(Icons.person, color: AppColors.primary),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),

                              // Role selector
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.grey50,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: DropdownButtonFormField<UserRole>(
                                  value: _selectedRole,
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(Icons.work, color: AppColors.primary),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                  ),
                                  items: UserRole.values.map((UserRole role) {
                                    return DropdownMenuItem<UserRole>(
                                      value: role,
                                      child: Text(role == UserRole.admin ? 'Admin' : 'Kasir'),
                                    );
                                  }).toList(),
                                  onChanged: (UserRole? newValue) {
                                    setState(() {
                                      _selectedRole = newValue ?? UserRole.kasir;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),

                              // Email field
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.grey50,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: TextFormField(
                                  controller: _emailController,
                                  validator: _validateEmail,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: const InputDecoration(
                                    hintText: 'Email',
                                    prefixIcon: Icon(Icons.email, color: AppColors.primary),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),

                              // Password field
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.grey50,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: TextFormField(
                                  controller: _passwordController,
                                  validator: _validatePassword,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                    hintText: 'Password',
                                    prefixIcon: Icon(Icons.lock, color: AppColors.primary),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),

                              // Confirm Password field
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.grey50,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: TextFormField(
                                  controller: _confirmPasswordController,
                                  validator: _validateConfirmPassword,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                    hintText: 'Confirm Password',
                                    prefixIcon: Icon(Icons.lock, color: AppColors.primary),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xl),

                              // Register button
                              Container(
                                width: double.infinity,
                                height: 56,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  gradient: LinearGradient(
                                    colors: _isLoading || !_isFormValid() 
                                        ? [AppColors.grey300, AppColors.grey300]
                                        : [AppColors.primary, AppColors.primaryDark],
                                  ),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(50),
                                    onTap: _isLoading || !_isFormValid() 
                                        ? null 
                                        : () => _handleRegister(authProvider),
                                    child: Center(
                                      child: _isLoading
                                          ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Text(
                                              'Register',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),

                              // Login link
                              Center(
                                child: TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text(
                                    'Already have an account? Sign in',
                                    style: TextStyle(color: AppColors.primary),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}