import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_clash/xboard/core/core.dart';
import 'package:fl_clash/xboard/domain/domain.dart';
import 'package:fl_clash/xboard/infrastructure/api/v2board_error_localizer.dart';
import 'package:fl_clash/xboard/adapter/initialization/sdk_provider.dart';
import 'package:fl_clash/xboard/adapter/state/ticket_state.dart';

final _logger = FileLogger('ticket_provider.dart');

class TicketState {
  final List<DomainTicket> tickets;
  final DomainTicket? currentTicket;
  final bool isLoading;
  final bool isSubmitting;
  final bool isSending;
  final String? errorMessage;

  const TicketState({
    this.tickets = const [],
    this.currentTicket,
    this.isLoading = false,
    this.isSubmitting = false,
    this.isSending = false,
    this.errorMessage,
  });

  TicketState copyWith({
    List<DomainTicket>? tickets,
    DomainTicket? currentTicket,
    bool? isLoading,
    bool? isSubmitting,
    bool? isSending,
    String? errorMessage,
    bool clearCurrentTicket = false,
  }) {
    return TicketState(
      tickets: tickets ?? this.tickets,
      currentTicket: clearCurrentTicket ? null : (currentTicket ?? this.currentTicket),
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSending: isSending ?? this.isSending,
      errorMessage: errorMessage,
    );
  }

  bool get hasTickets => tickets.isNotEmpty;
  int get openTicketCount => tickets.where((t) => t.status != TicketStatus.closed).length;
}

class TicketNotifier extends Notifier<TicketState> {
  @override
  TicketState build() {
    return const TicketState();
  }

  Future<void> loadTickets() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      _logger.info('加载工单列表...');
      final tickets = await ref.read(getTicketsProvider.future);

      state = state.copyWith(
        tickets: tickets,
        isLoading: false,
      );
      _logger.info('工单列表加载成功: ${tickets.length} 条');
    } catch (e) {
      _logger.info('加载工单列表失败: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: V2BoardErrorLocalizer.localize(ErrorSanitizer.sanitize(e.toString())),
      );
    }
  }

  Future<void> loadTicketDetail(int id) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      _logger.info('加载工单详情: $id');
      final ticket = await ref.read(getTicketProvider(id).future);

      state = state.copyWith(
        currentTicket: ticket,
        isLoading: false,
      );
      _logger.info('工单详情加载成功');
    } catch (e) {
      _logger.info('加载工单详情失败: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: V2BoardErrorLocalizer.localize(ErrorSanitizer.sanitize(e.toString())),
      );
    }
  }

  Future<bool> createTicket(String subject, int priority, String message) async {
    if (state.isSubmitting) return false;

    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      _logger.info('创建工单: $subject');
      final api = await ref.read(xboardSdkProvider.future);
      await api.saveTicket(subject, priority, message);

      state = state.copyWith(isSubmitting: false);

      // Reload ticket list
      await loadTickets();

      _logger.info('工单创建成功');
      return true;
    } catch (e) {
      _logger.info('创建工单失败: $e');
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: V2BoardErrorLocalizer.localize(ErrorSanitizer.sanitize(e.toString())),
      );
      return false;
    }
  }

  Future<bool> replyTicket(int id, String message) async {
    if (state.isSending) return false;

    state = state.copyWith(isSending: true, errorMessage: null);

    try {
      _logger.info('回复工单: $id');
      final api = await ref.read(xboardSdkProvider.future);
      await api.replyTicket(id, message);

      state = state.copyWith(isSending: false);

      // Reload ticket detail
      await loadTicketDetail(id);

      _logger.info('工单回复成功');
      return true;
    } catch (e) {
      _logger.info('回复工单失败: $e');
      state = state.copyWith(
        isSending: false,
        errorMessage: V2BoardErrorLocalizer.localize(ErrorSanitizer.sanitize(e.toString())),
      );
      return false;
    }
  }

  Future<bool> closeTicket(int id) async {
    if (state.isLoading) return false;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      _logger.info('关闭工单: $id');
      final api = await ref.read(xboardSdkProvider.future);
      await api.closeTicket(id);

      state = state.copyWith(isLoading: false);

      // Reload both list and detail
      await loadTickets();
      await loadTicketDetail(id);

      _logger.info('工单已关闭');
      return true;
    } catch (e) {
      _logger.info('关闭工单失败: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: V2BoardErrorLocalizer.localize(ErrorSanitizer.sanitize(e.toString())),
      );
      return false;
    }
  }

  Future<void> refresh() async {
    ref.invalidate(getTicketsProvider);
    await loadTickets();
  }

  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(errorMessage: null);
    }
  }
}

final ticketProvider = NotifierProvider<TicketNotifier, TicketState>(
  TicketNotifier.new,
);
