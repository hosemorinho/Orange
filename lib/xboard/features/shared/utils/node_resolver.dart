import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';

/// Resolves the current active proxy node based on groups, selection map, and mode.
///
/// Returns a record with the resolved [Group] and [Proxy], or nulls if unavailable.
({Group? group, Proxy? proxy}) resolveCurrentNode({
  required List<Group> groups,
  required Map<String, String> selectedMap,
  required Mode mode,
}) {
  if (groups.isEmpty) {
    return (group: null, proxy: null);
  }

  Group? currentGroup;

  if (mode == Mode.global) {
    currentGroup = groups.firstWhere(
      (group) => group.name == GroupName.GLOBAL.name,
      orElse: () => groups.first,
    );
  } else if (mode == Mode.rule) {
    for (final group in groups) {
      if (group.hidden == true) continue;
      if (group.name == GroupName.GLOBAL.name) continue;
      final selectedProxyName = selectedMap[group.name];
      if (selectedProxyName != null && selectedProxyName.isNotEmpty) {
        final referencedGroup = groups.firstWhere(
          (g) => g.name == selectedProxyName,
          orElse: () => group,
        );
        if (referencedGroup.name == selectedProxyName &&
            referencedGroup.type == GroupType.URLTest) {
          currentGroup = referencedGroup;
          break;
        } else {
          currentGroup = group;
          break;
        }
      }
    }
    if (currentGroup == null) {
      currentGroup = groups.firstWhere(
        (group) =>
            group.hidden != true && group.name != GroupName.GLOBAL.name,
        orElse: () => groups.first,
      );
      if (currentGroup.now != null && currentGroup.now!.isNotEmpty) {
        final nowValue = currentGroup.now!;
        final referencedGroup = groups.firstWhere(
          (g) => g.name == nowValue,
          orElse: () => currentGroup!,
        );
        if (referencedGroup.name == nowValue &&
            referencedGroup.type == GroupType.URLTest) {
          currentGroup = referencedGroup;
        }
      }
    }
  }

  if (currentGroup == null || currentGroup.all.isEmpty) {
    return (group: null, proxy: null);
  }

  final selectedProxyName = selectedMap[currentGroup.name] ?? "";
  String realNodeName;
  if (currentGroup.type == GroupType.URLTest) {
    realNodeName = currentGroup.now ?? "";
  } else {
    realNodeName = currentGroup.getCurrentSelectedName(selectedProxyName);
  }

  Proxy? currentProxy;
  if (realNodeName.isNotEmpty) {
    currentProxy = currentGroup.all.firstWhere(
      (proxy) => proxy.name == realNodeName,
      orElse: () => currentGroup!.all.first,
    );

    // 如果解析到 DIRECT/REJECT，尝试选择第一个有效节点
    if (currentProxy.name.toUpperCase() == 'DIRECT' ||
        currentProxy.name.toUpperCase() == 'REJECT') {
      final validProxy = currentGroup.all.firstWhere(
        (proxy) =>
            proxy.name.toUpperCase() != 'DIRECT' &&
            proxy.name.toUpperCase() != 'REJECT',
        orElse: () => currentProxy!,
      );
      currentProxy = validProxy;
    }
  } else {
    currentProxy = currentGroup.all.first;
  }

  return (group: currentGroup, proxy: currentProxy);
}
