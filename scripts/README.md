# Android Package Refactoring Scripts

这些脚本用于将 Android 项目的包名从 `com.follow.clash` 重构为可配置的包名。

## 脚本说明

### 1. `refactor_package_name.sh`
**交互式包名重构脚本**

完整的包名重构工具，包含备份、验证和详细输出。

**用法:**
```bash
# 交互式重构（会要求确认）
bash scripts/refactor_package_name.sh com.example.newapp

# 查看帮助
bash scripts/refactor_package_name.sh
```

**功能:**
- ✓ 自动创建备份到 `/tmp/android_backup_*`
- ✓ 更新所有 Kotlin/Java/AIDL 文件
- ✓ 更新 build.gradle.kts 和 AndroidManifest.xml
- ✓ 重命名包目录结构
- ✓ 验证更改完成度
- ✓ 彩色输出和进度提示

### 2. `apply_package_name.sh`
**从环境变量应用包名**

智能读取配置并调用重构脚本。

**用法:**
```bash
# 从环境变量
export APP_PACKAGE_NAME="com.example.app"
bash scripts/apply_package_name.sh

# 从命令行参数
bash scripts/apply_package_name.sh com.example.app

# 从 env.json（需要 jq）
echo '{"APP_PACKAGE_NAME":"com.example.app"}' > env.json
bash scripts/apply_package_name.sh
```

**读取顺序:**
1. `$APP_PACKAGE_NAME` 环境变量
2. `env.json` 文件中的 `APP_PACKAGE_NAME`
3. 命令行参数
4. 默认值 `com.follow.clash`

### 3. `setup_android_config.sh`
**CI/CD 自动化配置脚本**

非交互式，用于 CI/CD 环境自动应用配置。

**用法:**
```bash
# 在 CI 中使用
export APP_NAME="MyApp"
export APP_PACKAGE_NAME="com.example.myapp"
bash scripts/setup_android_config.sh
```

**功能:**
- ✓ 非交互式执行
- ✓ 自动更新 `strings.xml` 中的 app_name
- ✓ 自动重构包名（如果changed）
- ✓ 适合 GitHub Actions 等 CI 环境

## 使用示例

### 场景 1: 本地开发环境更改包名

```bash
# 1. 运行交互式脚本
bash scripts/refactor_package_name.sh com.mycompany.vpn

# 2. 检查更改
git diff

# 3. 测试编译
flutter build apk

# 4. 如果成功，提交
git add -A
git commit -m "refactor: change package name to com.mycompany.vpn"

# 5. 如果失败，恢复备份
# （脚本会提示备份位置）
```

### 场景 2: 在 CI/CD 中自动应用

在 `.github/workflows/build.yaml` 中添加：

```yaml
- name: Setup Android Configuration
  shell: bash
  env:
    APP_NAME: ${{ secrets.APP_NAME }}
    APP_PACKAGE_NAME: ${{ secrets.APP_PACKAGE_NAME }}
  run: |
    chmod +x scripts/setup_android_config.sh
    bash scripts/setup_android_config.sh
```

### 场景 3: 测试多个包名

```bash
# 测试不同的包名
for pkg in "com.example.app1" "com.test.app2"; do
    echo "Testing $pkg..."
    bash scripts/refactor_package_name.sh "$pkg" <<< "y"
    flutter build apk --debug
    # 恢复原状
    git reset --hard HEAD
done
```

## 包名格式要求

✅ **有效的包名:**
- `com.example.app`
- `com.mycompany.vpnclient`
- `io.github.username.project`

❌ **无效的包名:**
- `Com.Example.App` （大写字母）
- `com.example` （少于 3 段）
- `com.123app` （以数字开头）
- `com.my-app` （包含连字符）

## 修改的文件类型

脚本会修改以下类型的文件：

1. **源代码文件:**
   - `*.kt` - Kotlin 文件
   - `*.java` - Java 文件
   - `*.aidl` - AIDL 接口文件

2. **配置文件:**
   - `*.gradle.kts` - Gradle 构建脚本
   - `AndroidManifest.xml` - Android 清单文件
   - `strings.xml` - 字符串资源
   - `google-services.json` - Firebase 配置

3. **目录结构:**
   - `src/main/java/com/follow/clash/` → `src/main/java/新/包/路径/`
   - `src/main/kotlin/com/follow/clash/` → `src/main/kotlin/新/包/路径/`
   - `src/main/aidl/com/follow/clash/` → `src/main/aidl/新/包/路径/`

## 注意事项

⚠️ **重要提醒:**

1. **备份**: 交互式脚本会自动创建备份，CI 脚本不会
2. **测试**: 重构后务必测试编译：`flutter build apk`
3. **Git**: 在提交前检查 `git diff` 确保更改正确
4. **一次性**: 包名重构应该只做一次，之后使用新包名
5. **Firebase**: 如果使用 Firebase，需要手动更新 `google-services.json`

## 故障排除

### 问题: 脚本没有执行权限
```bash
chmod +x scripts/*.sh
```

### 问题: 仍有旧包名残留
```bash
# 手动检查
grep -r "com.follow.clash" android/

# 手动替换
find android/ -type f -exec sed -i 's/com\.follow\.clash/new.package.name/g' {} +
```

### 问题: 编译失败
```bash
# 清理构建缓存
cd android && ./gradlew clean
cd .. && flutter clean && flutter pub get

# 恢复备份
rm -rf android
cp -r /tmp/android_backup_* android
```

## 技术细节

### sed 替换规则

- 包名点号需要转义: `com\.follow\.clash`
- 路径中的点号替换为斜杠: `com/follow/clash`
- 使用 `-i` 原地修改文件

### 目录移动逻辑

1. 创建新目录结构
2. 移动整个包目录
3. 清理空的父目录

## 许可

这些脚本是 Orange 项目的一部分，使用与主项目相同的许可证。
