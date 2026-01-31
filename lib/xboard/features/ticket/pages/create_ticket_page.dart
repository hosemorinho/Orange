import 'package:fl_clash/xboard/features/ticket/providers/ticket_provider.dart';
import 'package:fl_clash/xboard/utils/xboard_notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CreateTicketPage extends ConsumerStatefulWidget {
  const CreateTicketPage({super.key});

  @override
  ConsumerState<CreateTicketPage> createState() => _CreateTicketPageState();
}

class _CreateTicketPageState extends ConsumerState<CreateTicketPage> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  int _priority = 1; // 0=低, 1=中, 2=高

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(ticketProvider.notifier).createTicket(
          _subjectController.text.trim(),
          _priority,
          _messageController.text.trim(),
        );

    if (success) {
      XBoardNotification.showSuccess('工单已创建');
      if (mounted) context.pop();
    } else {
      final error = ref.read(ticketProvider).errorMessage;
      XBoardNotification.showError(error ?? '创建失败');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(ticketProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('新建工单'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _subjectController,
              decoration: InputDecoration(
                labelText: '主题',
                hintText: '简要描述您的问题',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请输入主题';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Text(
              '优先级',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('低'), icon: Icon(Icons.arrow_downward, size: 16)),
                ButtonSegment(value: 1, label: Text('中'), icon: Icon(Icons.remove, size: 16)),
                ButtonSegment(value: 2, label: Text('高'), icon: Icon(Icons.arrow_upward, size: 16)),
              ],
              selected: {_priority},
              onSelectionChanged: (selected) {
                setState(() {
                  _priority = selected.first;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: '详细描述',
                hintText: '请详细描述您遇到的问题...',
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 8,
              minLines: 5,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请输入详细描述';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: state.isSubmitting ? null : _submit,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: state.isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('提交工单'),
            ),
          ],
        ),
      ),
    );
  }
}
