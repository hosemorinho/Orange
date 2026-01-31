# 板岩紫 Tonal 主题实现说明

## 概述

已成功实现板岩紫（Slate Purple）作为主题色，使用 Material 3 的 **Tonal Spot** 方案衍生浅色和深色模式的色板。

## 修改内容

### 1. 默认方案变体更改

**文件**: `lib/models/config.dart`

将 `ThemeProps` 的默认 `schemeVariant` 从 `DynamicSchemeVariant.content` 改为 `DynamicSchemeVariant.tonalSpot`：

```dart
@Default(DynamicSchemeVariant.tonalSpot) DynamicSchemeVariant schemeVariant,
```

### 2. 主题色保持不变

**文件**: `lib/common/constant.dart`

默认主题色已经是板岩紫：
```dart
const defaultPrimaryColor = 0xFF66558E;  // 板岩紫
```

这个颜色对应：
- **Hex**: `#66558E`
- **RGB**: (102, 85, 142)
- **名称**: Slate Purple / 板岩紫

## Material 3 Tonal Spot 方案说明

### 什么是 Tonal Spot？

`DynamicSchemeVariant.tonalSpot` 是 Material 3 的一种配色方案，特点：

1. **中性色调 (Medium chroma)** - 既不过于鲜艳，也不过于暗淡
2. **均衡的色调分布** - 在整个界面上创建和谐的色彩平衡
3. **自动生成浅色/深色模式** - 从种子色自动衍生出完整的色板

### 浅色模式色板衍生

从板岩紫 `#66558E` 自动生成：

| 角色 | 用途 | 说明 |
|------|------|------|
| `primary` | 主要交互元素 | 板岩紫的主色调 |
| `onPrimary` | 主色上的文本 | 自动计算的对比色（通常为白色） |
| `primaryContainer` | 主色容器背景 | 更浅的板岩紫 |
| `onPrimaryContainer` | 容器上的文本 | 深紫色，保证对比度 |
| `secondary` | 次要交互元素 | 色调相近的互补色 |
| `tertiary` | 第三级元素 | 中性衍生色 |
| `surface` | 表面背景 | 浅色，带有微妙的紫色调 |
| `background` | 整体背景 | 近白色，带有微妙的暖色调 |
| `error` | 错误提示 | 红色系，独立于主题色 |

### 深色模式色板衍生

从同一种子色 `#66558E` 自动生成深色版本：

| 角色 | 用途 | 说明 |
|------|------|------|
| `primary` | 主要交互元素 | 较亮的板岩紫 |
| `onPrimary` | 主色上的文本 | 深色，保证对比度 |
| `primaryContainer` | 主色容器背景 | 暗紫色容器 |
| `onPrimaryContainer` | 容器上的文本 | 浅色，保证可读性 |
| `surface` | 表面背景 | 深灰色，带有微妙的紫色调 |
| `background` | 整体背景 | 更深的背景色 |

### Tonal vs Content vs Vibrant

| 方案 | 色度 | 特点 | 适用场景 |
|------|------|------|---------|
| `tonalSpot` | 中等 | 平衡、和谐、专业 | **默认选择**，适合大多数应用 |
| `content` | 低 | 中性、低饱和度 | 内容为主的应用（阅读器、文档） |
| `vibrant` | 高 | 鲜艳、高饱和度 | 娱乐、创意类应用 |

## 代码实现细节

### 色板生成（lib/providers/state.dart:597-630）

```dart
@riverpod
ColorScheme genColorScheme(
  Ref ref,
  Brightness brightness, {
  Color? color,
  bool ignoreConfig = false,
}) {
  final vm2 = ref.watch(
    themeSettingProvider.select(
      (state) => VM2(
        a: state.primaryColor,
        b: state.schemeVariant,  // 使用配置的 schemeVariant
      ),
    ),
  );

  // 优先级：传入color > 用户配置 > 环境变量 > 系统色 > 默认色
  if (color == null && (ignoreConfig == true || vm2.a == null)) {
    final hasExplicitThemeColor = configuredPrimaryColor != defaultPrimaryColor;
    return ColorScheme.fromSeed(
      seedColor: hasExplicitThemeColor
          ? Color(configuredPrimaryColor)
          : (globalState.corePalette?.toColorScheme(brightness: brightness).primary
             ?? globalState.accentColor),
      brightness: brightness,
      dynamicSchemeVariant: vm2.b,  // ✅ 使用 tonalSpot
    );
  }

  return ColorScheme.fromSeed(
    seedColor: color ?? Color(vm2.a!),
    brightness: brightness,
    dynamicSchemeVariant: vm2.b,  // ✅ 使用 tonalSpot
  );
}
```

### 应用主题（lib/application.dart:267-283）

```dart
theme: ThemeData(
  useMaterial3: true,
  pageTransitionsTheme: _pageTransitionsTheme,
  colorScheme: _getAppColorScheme(
    brightness: Brightness.light,  // 浅色模式
    primaryColor: themeProps.primaryColor,
  ),
),
darkTheme: ThemeData(
  useMaterial3: true,
  pageTransitionsTheme: _pageTransitionsTheme,
  colorScheme: _getAppColorScheme(
    brightness: Brightness.dark,  // 深色模式
    primaryColor: themeProps.primaryColor,
  ).toPureBlack(themeProps.pureBlack),  // 可选纯黑模式
),
```

## 构建时自定义

可通过 `--dart-define` 覆盖默认主题色（无需修改代码）：

```bash
# 使用默认板岩紫
flutter build apk

# 自定义主题色（例如：使用深紫色）
flutter build apk --dart-define=THEME_COLOR=7C4DFF

# 完整构建示例（setup.dart）
dart setup.dart android \
  --arch arm64 \
  --theme-color 66558E \
  --api-url https://panel.example.com
```

## 色彩对比度保证

Material 3 的 `ColorScheme.fromSeed` 自动保证：

- **WCAG AA 级别** - 文本对比度 ≥ 4.5:1
- **自动调整** - 根据背景自动选择深色或浅色文本
- **动态色调** - 在不同亮度下保持品牌识别度

## 用户可选方案

用户可在设置中切换不同方案（lib/views/theme.dart:267-288）：

```dart
final value = await globalState.showCommonDialog<DynamicSchemeVariant>(
  child: OptionsDialog<DynamicSchemeVariant>(
    title: appLocalizations.scheme,
    options: DynamicSchemeVariant.values,  // 所有可用方案
    value: schemeVariant,  // 当前选中方案
  ),
);
```

可选方案：
- `tonalSpot` (默认) - 平衡的色调
- `content` - 低饱和度
- `vibrant` - 高饱和度
- `expressive` - 表现力强
- `fidelity` - 高保真
- `monochrome` - 单色
- `neutral` - 中性

## 验证步骤

1. **重新生成代码**（必需）：
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

2. **清理并构建**：
   ```bash
   flutter clean
   flutter pub get
   flutter build apk
   ```

3. **运行应用**：
   ```bash
   flutter run
   ```

4. **测试主题切换**：
   - 打开设置 → 外观
   - 切换浅色/深色模式
   - 观察板岩紫色调在不同模式下的变化

## 效果预览

### 浅色模式
- **背景**: 柔和的灰白色，带有微妙的紫色调
- **卡片**: 浅紫色容器，边缘圆润
- **按钮**: 板岩紫主色，白色文本
- **文本**: 深灰色到黑色，对比度充足

### 深色模式
- **背景**: 深灰色，带有微妙的紫色调
- **卡片**: 暗紫色容器，提升视觉层次
- **按钮**: 较亮的板岩紫，深色文本
- **文本**: 浅灰色到白色，对比度充足

## 常见问题

### Q: 为什么选择 tonalSpot 而不是 content？

**A**: `tonalSpot` 在浅色和深色模式下都能提供更好的视觉平衡，同时保持品牌色的识别度。`content` 适合内容为主的应用，但色彩表现力较弱。

### Q: 如何调整主题色的饱和度？

**A**: 用户可在设置中切换到 `vibrant`（更鲜艳）或 `content`（更中性）方案。开发者也可修改 `defaultPrimaryColor` 来调整种子色。

### Q: 深色模式是否支持纯黑背景？

**A**: 是的，在 `ThemeProps` 中有 `pureBlack` 选项，启用后会将深色模式的 `surface` 和 `background` 转换为纯黑色（#000000），适合 OLED 屏幕。

### Q: 如何添加自定义色板？

**A**: 修改 `lib/common/constant.dart` 中的 `defaultPrimaryColors` 数组，添加新的颜色值（int 格式，0xFF 前缀）。

## 总结

通过将默认 `schemeVariant` 改为 `DynamicSchemeVariant.tonalSpot`，结合现有的板岩紫种子色 `#66558E`，应用现在使用 Material 3 的 Tonal Spot 方案自动生成浅色和深色模式的完整色板。这种方案在保持品牌识别度的同时，确保了出色的可读性和无障碍访问性。

---

**实现日期**: 2026-02-01
**修改文件**:
- `lib/models/config.dart` (1 行修改)
- 无需修改其他文件，色板生成逻辑已自动适配
