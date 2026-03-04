/// XBoard 设计常量 - 统一的设计令牌
///
/// 提供整个 XBoard 模块的设计常量，确保视觉一致性
library;

import 'package:flutter/material.dart';

/// 设计常量命名空间
class XBoardDesignConstants {
  XBoardDesignConstants._();

  // ========== 间距 (Spacing) ==========
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 12.0;
  static const double spacingLg = 16.0;
  static const double spacingXl = 20.0;
  static const double spacing2Xl = 24.0;
  static const double spacing3Xl = 32.0;

  // ========== 圆角 (Border Radius) ==========
  /// 卡片圆角 - 所有卡片统一使用
  static const double cardBorderRadius = 16.0;

  /// 按钮圆角 - 所有按钮统一使用
  static const double buttonBorderRadius = 12.0;

  /// 输入框圆角 - 所有输入框统一使用
  static const double inputBorderRadius = 16.0;

  /// 徽章/标签圆角
  static const double badgeBorderRadius = 14.0;

  // ========== 边框 (Borders) ==========
  /// 边框宽度
  static const double borderWidth = 1.0;

  /// 边框颜色透明度
  /// 使用 outlineVariant 作为基础色，透明度为 0.35
  static const double borderColorAlpha = 0.35;

  /// 悬停边框透明度
  static const double borderColorHoverAlpha = 0.5;

  // ========== 阴影 (Shadows) ==========
  /// 卡片基础阴影
  /// 使用统一的阴影效果，确保层次感
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  /// 悬停阴影 - 增强悬停效果
  static List<BoxShadow> get cardShadowHover => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.12),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];

  /// 深度阴影 - 用于模态框、浮层面板
  static List<BoxShadow> get cardShadowDeep => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.16),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  // ========== 内边距 (Padding) ==========
  /// 卡片内边距 - 统一所有卡片的内边距
  static const EdgeInsets cardPadding = EdgeInsets.all(16.0);

  /// 紧凑卡片内边距
  static const EdgeInsets cardPaddingCompact = EdgeInsets.all(12.0);

  /// 宽松卡片内边距
  static const EdgeInsets cardPaddingLoose = EdgeInsets.all(20.0);

  // ========== 颜色辅助函数 ==========
  /// 获取主题色的渐变
  /// 用于价格标签、重要按钮
  static Gradient get primaryGradient => LinearGradient(
        colors: [
          ThemeColorHelper.primary.withValues(alpha: 1.0),
          ThemeColorHelper.primary.withValues(alpha: 0.7),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// 获取辅助色的渐变
  /// 用于状态标签、次要信息
  static Gradient get secondaryGradient => LinearGradient(
        colors: [
          ThemeColorHelper.secondary.withValues(alpha: 1.0),
          ThemeColorHelper.secondary.withValues(alpha: 0.6),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// 获取强调色的渐变
  /// 用于购买状态、重要提示
  static Gradient get tertiaryGradient => LinearGradient(
        colors: [
          ThemeColorHelper.tertiary.withValues(alpha: 1.0),
          ThemeColorHelper.tertiary.withValues(alpha: 0.7),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
}

/// 主题色辅助类
class ThemeColorHelper {
  ThemeColorHelper._();

  // ========== 主题色 (从 ColorScheme 读取) ==========
  /// 主题主色
  /// 在组件中使用：Theme.of(context).colorScheme.primary
  /// 此处仅为类型提示
  static Color get primary => Colors.purple;

  /// 主题辅色
  static Color get secondary => Colors.blue;

  /// 强调色
  /// 用于购买状态、成功状态
  static Color get tertiary => Colors.pink;

  /// 表面色
  static Color get surface => Colors.white;

  /// 底色
  static Color get background => Colors.grey.shade50;

  /// 错误色
  static Color get error => Colors.red;

  /// 警告色
  static Color get warning => Colors.orange;

  /// 成功色
  static Color get success => Colors.green;
}

/// 文字样式辅助类
class TextStyleHelper {
  TextStyleHelper._();

  // ========== 字体大小 ==========
  /// 大标题 - 24px
  /// 用于页面标题
  static const double fontSizeHeading = 24.0;

  /// 中标题 - 20px
  /// 用于卡片标题、章节标题
  static const double fontSizeTitle = 20.0;

  /// 小标题 - 16px
  /// 用于标签、按钮文本
  static const double fontSizeSubtitle = 16.0;

  /// 正文 - 14px
  /// 用于段落、描述
  static const double fontSizeBody = 14.0;

  /// 小文本 - 12px
  /// 用于辅助信息、注释
  static const double fontSizeCaption = 12.0;

  /// 微小文本 - 10px
  /// 用于徽章、标签
  static const double fontSizeTiny = 10.0;

  // ========== 字重 ==========
  /// 超细 - 100
  static const FontWeight fontWeightThin = FontWeight.w100;

  /// 细 - 200
  static const FontWeight fontWeightExtraLight = FontWeight.w200;

  /// 轻 - 300
  static const FontWeight fontWeightLight = FontWeight.w300;

  /// 常规 - 400
  static const FontWeight fontWeightRegular = FontWeight.w400;

  /// 中等 - 500
  /// 用于标签、辅助文字
  static const FontWeight fontWeightMedium = FontWeight.w500;

  /// 半粗 - 600
  /// 用于按钮、标题
  static const FontWeight fontWeightSemiBold = FontWeight.w600;

  /// 粗体 - 700
  /// 用于重要信息、强调
  static const FontWeight fontWeightBold = FontWeight.w700;

  /// 超粗 - 800
  /// 用于标题、重点
  static const FontWeight fontWeightExtraBold = FontWeight.w800;

  /// 极粗 - 900
  /// 用于超大标题
  static const FontWeight fontWeightBlack = FontWeight.w900;
}
