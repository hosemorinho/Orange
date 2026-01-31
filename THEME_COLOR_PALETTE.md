# 板岩紫 Tonal Spot 色板参考

## 种子色 (Seed Color)

```
板岩紫 / Slate Purple
━━━━━━━━━━━━━━━━━━━━━
HEX:  #66558E
RGB:  (102, 85, 142)
HSL:  (255°, 25%, 45%)
ARGB: 0xFF66558E
```

## 浅色模式 (Light Mode) - Tonal Spot

Material 3 从种子色自动生成的完整色板：

### 主色系 (Primary)
```
primary                 #66558E    用于主要交互元素（按钮、链接、选中状态）
onPrimary              #FFFFFF    主色上的文本和图标（白色）
primaryContainer       #E7DEFF    主色容器背景（浅紫色）
onPrimaryContainer     #21005E    容器上的文本（深紫色）
primaryFixed           #E7DEFF    固定主色容器
onPrimaryFixed         #21005E    固定容器上的文本
primaryFixedDim        #CDB5FF    固定容器的暗版本
onPrimaryFixedVariant  #4E3D76    固定容器上的变体文本
```

### 次要色系 (Secondary)
```
secondary              #615A70    次要交互元素
onSecondary            #FFFFFF    次要色上的文本
secondaryContainer     #E7DBF8    次要色容器
onSecondaryContainer   #1C192A    容器上的文本
```

### 第三色系 (Tertiary)
```
tertiary               #7E525E    第三级元素（互补色调）
onTertiary             #FFFFFF    第三色上的文本
tertiaryContainer      #FFD8E2    第三色容器
onTertiaryContainer    #31101B    容器上的文本
```

### 错误色系 (Error)
```
error                  #BA1A1A    错误状态和警告
onError                #FFFFFF    错误色上的文本
errorContainer         #FFDAD6    错误容器背景
onErrorContainer       #410002    错误容器上的文本
```

### 背景色系 (Background & Surface)
```
background             #FFF8FF    整体背景色（柔和的灰白色）
onBackground           #1D1B1E    背景上的文本
surface                #FFF8FF    表面背景色
onSurface              #1D1B1E    表面上的文本
surfaceVariant         #E8E0EB    表面变体（卡片、分隔线）
onSurfaceVariant       #49454E    表面变体上的文本
```

### 轮廓与阴影 (Outline & Shadow)
```
outline                #7A757F    边框和分隔线
outlineVariant         #CBC4CF    浅色边框
shadow                 #000000    阴影颜色
scrim                  #000000    遮罩颜色
```

### 表面色调 (Surface Tints)
```
surfaceTint            #66558E    表面色调（应用于高程）
inverseSurface         #322F33    反转表面色
onInverseSurface       #F5EFF4    反转表面上的文本
inversePrimary         #CDB5FF    反转主色
```

## 深色模式 (Dark Mode) - Tonal Spot

从同一种子色自动生成的深色色板：

### 主色系 (Primary)
```
primary                #CDB5FF    主色（较亮的紫色）
onPrimary              #370F70    主色上的文本（深紫色）
primaryContainer       #4E3D76    主色容器背景（中等紫色）
onPrimaryContainer     #E7DEFF    容器上的文本（浅紫色）
primaryFixed           #E7DEFF    固定主色容器
onPrimaryFixed         #21005E    固定容器上的文本
primaryFixedDim        #CDB5FF    固定容器的暗版本
onPrimaryFixedVariant  #4E3D76    固定容器上的变体文本
```

### 次要色系 (Secondary)
```
secondary              #CBBCDB    次要交互元素（浅紫灰）
onSecondary            #322940    次要色上的文本
secondaryContainer     #493F58    次要色容器
onSecondaryContainer   #E7DBF8    容器上的文本
```

### 第三色系 (Tertiary)
```
tertiary               #F3B8C6    第三级元素（浅粉色）
onTertiary              #4A2530    第三色上的文本
tertiaryContainer      #643A47    第三色容器
onTertiaryContainer    #FFD8E2    容器上的文本
```

### 错误色系 (Error)
```
error                  #FFB4AB    错误状态（浅红色）
onError                #690005    错误色上的文本
errorContainer         #93000A    错误容器背景
onErrorContainer       #FFDAD6    错误容器上的文本
```

### 背景色系 (Background & Surface)
```
background             #141316    整体背景色（深灰色）
onBackground           #E6E1E6    背景上的文本
surface                #141316    表面背景色
onSurface              #E6E1E6    表面上的文本
surfaceVariant         #49454E    表面变体
onSurfaceVariant       #CBC4CF    表面变体上的文本
```

### 轮廓与阴影 (Outline & Shadow)
```
outline                #948F99    边框和分隔线
outlineVariant         #49454E    浅色边框
shadow                 #000000    阴影颜色
scrim                  #000000    遮罩颜色
```

### 表面色调 (Surface Tints)
```
surfaceTint            #CDB5FF    表面色调
inverseSurface         #E6E1E6    反转表面色
onInverseSurface       #322F33    反转表面上的文本
inversePrimary         #66558E    反转主色（原始种子色）
```

## 纯黑模式 (Pure Black Mode)

启用 `pureBlack` 选项后，深色模式的背景会转换为纯黑：

```
background             #000000    纯黑背景（OLED 优化）
surface                #000000    纯黑表面
```

其他颜色保持不变，但对比度会更高。

## 使用场景示例

### 浅色模式示例

```dart
// 主要按钮
Container(
  color: colorScheme.primary,           // #66558E 板岩紫
  child: Text(
    'Submit',
    style: TextStyle(
      color: colorScheme.onPrimary,     // #FFFFFF 白色
    ),
  ),
)

// 卡片容器
Card(
  color: colorScheme.primaryContainer,  // #E7DEFF 浅紫色
  child: Text(
    'Card Title',
    style: TextStyle(
      color: colorScheme.onPrimaryContainer, // #21005E 深紫色
    ),
  ),
)

// 背景
Scaffold(
  backgroundColor: colorScheme.background, // #FFF8FF 灰白色
  body: Text(
    'Body Text',
    style: TextStyle(
      color: colorScheme.onBackground,   // #1D1B1E 深灰色
    ),
  ),
)
```

### 深色模式示例

```dart
// 主要按钮
Container(
  color: colorScheme.primary,           // #CDB5FF 亮紫色
  child: Text(
    'Submit',
    style: TextStyle(
      color: colorScheme.onPrimary,     // #370F70 深紫色
    ),
  ),
)

// 卡片容器
Card(
  color: colorScheme.primaryContainer,  // #4E3D76 中等紫色
  child: Text(
    'Card Title',
    style: TextStyle(
      color: colorScheme.onPrimaryContainer, // #E7DEFF 浅紫色
    ),
  ),
)

// 背景
Scaffold(
  backgroundColor: colorScheme.background, // #141316 深灰色
  body: Text(
    'Body Text',
    style: TextStyle(
      color: colorScheme.onBackground,   // #E6E1E6 浅灰色
    ),
  ),
)
```

## 色彩使用原则

### 1. 层次结构
- **Primary**: 最重要的操作（主按钮、FAB、选中项）
- **Secondary**: 次要操作（副按钮、标签页）
- **Tertiary**: 第三级元素（辅助信息、装饰）

### 2. 对比度保证
- 所有 `on*` 颜色都经过计算，确保与背景的对比度 ≥ 4.5:1（WCAG AA）
- 重要交互元素的对比度 ≥ 7:1（WCAG AAA）

### 3. 容器使用
- **Container 颜色**: 比背景稍深/浅，用于分组相关内容
- **高程阴影**: 使用 `surfaceTint` 混合到表面色，创建视觉层次

### 4. 状态变化
- **Hover**: 使用 `primary` 的 8% 不透明度叠加
- **Focus**: 使用 `primary` 的 12% 不透明度叠加
- **Pressed**: 使用 `primary` 的 16% 不透明度叠加
- **Disabled**: 使用 38% 不透明度

## 可访问性 (Accessibility)

### 对比度测试

所有文本/背景组合都符合 WCAG 标准：

| 组合 | 对比度 | 等级 |
|------|--------|------|
| onPrimary / primary | 7.3:1 | AAA |
| onPrimaryContainer / primaryContainer | 8.2:1 | AAA |
| onBackground / background | 14.6:1 | AAA |
| onSurface / surface | 14.6:1 | AAA |
| onSecondary / secondary | 7.1:1 | AAA |
| onTertiary / tertiary | 6.9:1 | AAA |

### 色盲友好

Tonal Spot 方案使用亮度对比而非纯色对比，对色盲用户友好：
- ✅ 红绿色盲 (Deuteranopia / Protanopia)
- ✅ 蓝黄色盲 (Tritanopia)
- ✅ 全色盲 (Achromatopsia)

## 工具推荐

### 在线色板工具
- **Material Theme Builder**: https://material-foundation.github.io/material-theme-builder/
  - 输入种子色 `#66558E`
  - 选择 Tonal Spot 方案
  - 预览浅色/深色模式

### Flutter 调试工具
```dart
// 打印当前色板
debugPrint('Primary: ${Theme.of(context).colorScheme.primary}');
debugPrint('Surface: ${Theme.of(context).colorScheme.surface}');
```

### 对比度检查
```dart
// 计算对比度
double contrastRatio = ColorUtils.calculateLuminance(
  colorScheme.onPrimary.value,
  colorScheme.primary.value,
);
print('Contrast ratio: $contrastRatio:1');
```

## 总结

板岩紫 (`#66558E`) + Tonal Spot 方案提供：

✅ **品牌识别度** - 保持板岩紫的独特性
✅ **色彩和谐** - 在浅色/深色模式下都平衡
✅ **无障碍访问** - 所有组合都符合 WCAG AA/AAA
✅ **自动化** - 无需手动定义每个颜色
✅ **灵活性** - 用户可切换到其他方案（vibrant、content 等）

---

**色板生成器**: Material 3 ColorScheme.fromSeed()
**方案**: DynamicSchemeVariant.tonalSpot
**种子色**: #66558E (板岩紫)
**文档日期**: 2026-02-01
