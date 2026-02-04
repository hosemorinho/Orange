import 'package:flutter_riverpod/flutter_riverpod.dart';

class LatencyNotifier extends Notifier<Map<String, int?>> {
  @override
  Map<String, int?> build() => {};

  void updateLatencies(Map<String, int?> newLatencies) {
    state = {...state, ...newLatencies};
  }

  void clear() {
    state = {};
  }
}

final latencyProvider = NotifierProvider<LatencyNotifier, Map<String, int?>>(
  LatencyNotifier.new,
);
