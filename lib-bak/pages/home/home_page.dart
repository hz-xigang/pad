import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    _state = HomeState();
    _state.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _state.removeListener(_onStateChanged);
    _state.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 表单头部
                  const FormHeader(),
                  const SizedBox(height: 20),
                  // 标签信息区域（生产单信息）
                  InfoSection(state: _state),
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
    );
  }
}
