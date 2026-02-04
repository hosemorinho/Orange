import 'package:fl_clash/core/core.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LatencyService {
  LatencyService();
  
  Future<Map<String, int>> testNodes(List<Proxy> nodes) async {
    final Map<String, int> latencies = {};
    if (nodes.isEmpty) {
      return latencies;
    }
    
    const testUrl = 'http://www.gstatic.com/generate_204';
    final List<Future> tasks = [];
    for (final node in nodes) {
      tasks.add(
        coreController.getDelay(testUrl, node.name).then((delay) {
          latencies[node.name] = delay.value ?? -1;
        }).catchError((_) {
          latencies[node.name] = -1;
        }),
      );
    }
    await Future.wait(tasks);
    return latencies;
  }
}
final latencyServiceProvider = Provider<LatencyService>((ref) {
  return LatencyService();
});