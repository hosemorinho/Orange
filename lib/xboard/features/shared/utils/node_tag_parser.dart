/// 从节点名称中提取 tags 和国旗 emoji
///
/// 节点提供商通常将标签信息编码在节点名称中，例如：
/// - `🇺🇸 US-Premium-01 [IPLC]`
/// - `🇯🇵 Tokyo-Node-5G`
/// - `🇭🇰 香港 IEPL [Premium]`

/// 从节点名称中提取 tags
///
/// 提取策略：
/// 1. 提取方括号 `[...]` 内的所有标签
/// 2. 识别常见的关键词标签（如 Premium, IPLC, 5G 等）
///
/// 示例：
/// ```dart
/// extractNodeTags('🇺🇸 US-Premium [IPLC]'); // ['IPLC', 'Premium']
/// extractNodeTags('🇯🇵 Tokyo 5G Pro'); // ['5G', 'Pro']
/// ```
List<String> extractNodeTags(String nodeName) {
  final tags = <String>[];

  // 提取方括号内的标签 [Premium], [IPLC] 等
  final bracketRegex = RegExp(r'\[([^\]]+)\]');
  final bracketMatches = bracketRegex.allMatches(nodeName);
  for (final match in bracketMatches) {
    final tag = match.group(1)?.trim();
    if (tag != null && tag.isNotEmpty) {
      tags.add(tag);
    }
  }

  // 提取常见关键词标签（仅当不在方括号内时）
  final keywords = [
    'Premium',
    'IPLC',
    'IEPL',
    '5G',
    '4G',
    'Pro',
    'Plus',
    'Lite',
    'Basic',
    'Standard',
    'Ultimate',
    'VIP',
  ];

  // 移除方括号内容后再检测关键词，避免重复
  var cleanName = nodeName.replaceAll(bracketRegex, '');

  for (final keyword in keywords) {
    final regex = RegExp(r'\b' + keyword + r'\b', caseSensitive: false);
    if (regex.hasMatch(cleanName) && !tags.contains(keyword)) {
      tags.add(keyword);
    }
  }

  return tags;
}

/// 从节点名称中提取国旗 emoji
///
/// 国旗 emoji 由两个区域指示符号组成（U+1F1E6 到 U+1F1FF）
///
/// 示例：
/// ```dart
/// extractCountryFlag('🇺🇸 US-Premium'); // '🇺🇸'
/// extractCountryFlag('Tokyo Node'); // null
/// ```
String? extractCountryFlag(String nodeName) {
  final emojiRegex = RegExp(
    r'[\u{1F1E6}-\u{1F1FF}]{2}',
    unicode: true,
  );
  final match = emojiRegex.firstMatch(nodeName);
  return match?.group(0);
}
