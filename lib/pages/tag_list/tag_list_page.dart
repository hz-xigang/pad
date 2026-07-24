import 'package:flutter/material.dart';

import '../home/components/custom_app_bar.dart';
import 'layouts/tag_filter_section.dart';
import 'layouts/tag_list_table.dart';
import 'state/tag_list_state.dart';

class TagListPage extends StatefulWidget {
  const TagListPage({super.key});

  static const routeName = '/tagList';

  @override
  State<TagListPage> createState() => _TagListPageState();
}

class _TagListPageState extends State<TagListPage> {
  late final TagListState _state;

  @override
  void initState() {
    super.initState();
    _state = TagListState();
    _state.addListener(_onStateChanged);
    _state.search();
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
        child: Column(
          children: [
            TagFilterSection(
              state: _state,
              onBack: () => Navigator.pop(context),
            ),
            const SizedBox(height: 12),
            Expanded(child: TagListTable(state: _state)),
          ],
        ),
      ),
    );
  }
}

