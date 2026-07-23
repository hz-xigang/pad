import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'components/custom_app_bar.dart';
import 'layouts/action_buttons.dart';
import 'layouts/form_header.dart';
import 'layouts/info_section.dart';
import 'layouts/weight_section.dart';
import 'state/home_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static const routeName = '/home';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();
  late final HomeState _state;
  final FocusNode _keyboardFocusNode = FocusNode();

  // 扫描枪输入缓冲区
  String _scanBuffer = '';
  Timer? _scanTimer;

  @override
  void initState() {
    super.initState();
    _state = HomeState();
    _state.addListener(_onStateChanged);

    // 设置焦点恢复回调（只在关键时机触发）
    _state.setOnNeedFocusCallback(_restoreFocus);
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    _state.removeListener(_onStateChanged);
    _state.dispose();
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    setState(() {});
  }

  void _restoreFocus() {
    // 延迟恢复焦点，确保其他操作完成
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted && !_keyboardFocusNode.hasFocus) {
        _keyboardFocusNode.requestFocus();
      }
    });
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    // 检查是否有输入框获得焦点（排除 _keyboardFocusNode）
    final currentFocus = FocusScope.of(context).focusedChild;
    final isInputFieldFocused = currentFocus != null &&
                                 currentFocus != _keyboardFocusNode &&
                                 currentFocus.context?.widget is Focus;

    // 如果有输入框获得焦点，清空缓冲区并忽略按键
    if (isInputFieldFocused) {
      _scanBuffer = '';
      return;
    }

    // 回车键：完成扫描，执行查询
    if (event.logicalKey == LogicalKeyboardKey.enter) {
      if (_scanBuffer.isNotEmpty) {
        _state.setProductionNo(_scanBuffer);
        _state.searchProductionOrder();
        _scanBuffer = '';
      }
      // 重新隐藏状态栏
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      return;
    }

    // 累积字符到缓冲区
    final char = event.character;
    if (char != null && char.isNotEmpty) {
      _scanBuffer += char;

      // 设置超时清空缓冲区（扫描枪通常在 100ms 内完成，设置 500ms 超时）
      _scanTimer?.cancel();
      _scanTimer = Timer(const Duration(milliseconds: 500), () {
        _scanBuffer = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;

    return KeyboardListener(
      focusNode: _keyboardFocusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        backgroundColor: const Color(0xFFE8EBF0),
        appBar: const PreferredSize(
          preferredSize: Size.fromHeight(56),
          child: CustomAppBar(),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
                padding: EdgeInsets.only(bottom: keyboardInset),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 表单头部
                    const FormHeader(),
                    const SizedBox(height: 20),
                    // 标签信息区域（生产单信息）
                    InfoSection(state: _state, keyboardFocusNode: _keyboardFocusNode),
                    const SizedBox(height: 16),
                    // 重量信息区域
                    WeightSection(state: _state),
                    const SizedBox(height: 24),
                    // 操作按钮
                    ActionButtons(state: _state),
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
