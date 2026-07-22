import 'package:flutter/material.dart';

import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  static const routeName = '/login';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: 'admin');
    _passwordController = TextEditingController(text: '123456');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF343946),
              Color(0xFFE9EEF8),
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxHeight < 820;
              final outerHorizontal = constraints.maxWidth < 600 ? 20.0 : 32.0;
              final outerVertical = compact ? 12.0 : 20.0;
              final cardHorizontal = compact ? 24.0 : 32.0;
              final cardTop = compact ? 24.0 : 32.0;
              final cardBottom = compact ? 24.0 : 28.0;
              final iconSize = compact ? 72.0 : 88.0;
              final iconRadius = compact ? 22.0 : 24.0;
              final iconInnerSize = compact ? 34.0 : 42.0;
              final titleGap = compact ? 24.0 : 32.0;
              final sectionGap = compact ? 22.0 : 28.0;
              final fieldGap = compact ? 14.0 : 18.0;
              final buttonGap = compact ? 22.0 : 28.0;
              final buttonHeight = compact ? 64.0 : 76.0;
              final cardWidth = constraints.maxWidth < 600
                  ? constraints.maxWidth - (outerHorizontal * 2)
                  : 420.0;

              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: outerHorizontal,
                  vertical: outerVertical,
                ),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: SizedBox(
                      width: cardWidth,
                      child: Container(
                        padding: EdgeInsets.fromLTRB(
                          cardHorizontal,
                          cardTop,
                          cardHorizontal,
                          cardBottom,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(36),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x3318223D),
                              blurRadius: 40,
                              offset: Offset(0, 24),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: iconSize,
                              height: iconSize,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE7EEFF),
                                borderRadius: BorderRadius.circular(iconRadius),
                              ),
                              child: Icon(
                                Icons.factory_outlined,
                                size: iconInnerSize,
                                color: const Color(0xFF3D63F0),
                              ),
                            ),
                            SizedBox(height: titleGap),
                            Text(
                              '仓储作业登录',
                              style: theme.textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF141B2D),
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '请输入用户名和密码后进入系统',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: const Color(0xFF7B8498),
                              ),
                            ),
                            SizedBox(height: sectionGap),
                            Text(
                              '用户名',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: const Color(0xFF41495C),
                              ),
                            ),
                            const SizedBox(height: 10),
                            _LoginInput(
                              controller: _usernameController,
                              icon: Icons.person_outline,
                              compact: compact,
                            ),
                            SizedBox(height: fieldGap),
                            Text(
                              '密码',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: const Color(0xFF41495C),
                              ),
                            ),
                            const SizedBox(height: 10),
                            _LoginInput(
                              controller: _passwordController,
                              icon: Icons.lock_outline,
                              obscureText: true,
                              compact: compact,
                            ),
                            SizedBox(height: buttonGap),
                            SizedBox(
                              width: double.infinity,
                              height: buttonHeight,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    HomePage.routeName,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3D63F0),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                child: const Text('登录'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LoginInput extends StatelessWidget {
  const _LoginInput({
    required this.controller,
    required this.icon,
    this.obscureText = false,
    this.compact = false,
  });

  final TextEditingController controller;
  final IconData icon;
  final bool obscureText;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      obscuringCharacter: '•',
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: Color(0xFF22283A),
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, size: 30, color: const Color(0xFF4D5260)),
        filled: true,
        fillColor: const Color(0xFFF5F7FE),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 0,
        ),
        constraints: BoxConstraints(minHeight: compact ? 80 : 92),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(26),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(26),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(26),
          borderSide: const BorderSide(color: Color(0xFF3D63F0), width: 1.5),
        ),
      ),
    );
  }
}
