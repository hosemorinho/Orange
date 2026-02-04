import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_clash/xboard/utils/xboard_notification.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fl_clash/xboard/features/notice/notice.dart';
import 'package:fl_clash/xboard/services/services.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/xboard/domain/domain.dart';
import '../styles/markdown_styles.dart';
import '../styles/html_styles.dart';

/// 通知内容渲染类型
enum NoticeRenderType {
  /// Markdown 渲染
  markdown,
  /// HTML 渲染
  html,
}

/// 全局配置：选择通知内容的渲染方式
/// 
/// 可选值：
/// - null: 自动检测内容格式（默认，推荐）
/// - NoticeRenderType.markdown: 强制使用 Markdown 渲染
/// - NoticeRenderType.html: 强制使用 HTML 渲染
/// 
/// 设置为 null 时，程序会自动判断内容是 HTML 还是 Markdown
const NoticeRenderType? kNoticeRenderType = null;

class NoticeBanner extends ConsumerStatefulWidget {
  const NoticeBanner({super.key});
  @override
  ConsumerState<NoticeBanner> createState() => _NoticeBannerState();
}
class _NoticeBannerState extends ConsumerState<NoticeBanner>
    with TickerProviderStateMixin {
  late PageController _pageController;
  Timer? _autoScrollTimer;
  int _currentIndex = 0;
  bool _hasCheckedDialogNotices = false;
  bool _isDismissed = false;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(noticeProvider.notifier).fetchNotices();
      await _checkDismissalStatus();
    });

    // Listen for notices loaded, then check for popup dialog notices
    ref.listenManual(noticeProvider, (previous, next) {
      if (!_hasCheckedDialogNotices && !next.isLoading && next.notices.isNotEmpty) {
        _hasCheckedDialogNotices = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _checkAndShowDialogNotices(next.notices);
        });
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  /// Check if banner was dismissed within the last hour
  Future<void> _checkDismissalStatus() async {
    final storageService = ref.read(storageServiceProvider);
    final result = await storageService.getDismissalTimestamp();

    if (result.isSuccess) {
      final timestamp = result.dataOrNull;
      if (timestamp != null) {
        final dismissedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        final now = DateTime.now();
        final difference = now.difference(dismissedTime);

        if (difference.inMinutes < 60) {
          setState(() {
            _isDismissed = true;
          });
        }
      }
    }
  }

  void _startAutoScroll(int noticeCount) {
    if (noticeCount <= 1 || _isPaused) return;

    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted && !_isPaused) {
        final nextPage = (_currentIndex + 1) % noticeCount;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _handleDismiss() async {
    final storageService = ref.read(storageServiceProvider);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    await storageService.saveDismissalTimestamp(timestamp);

    setState(() {
      _isDismissed = true;
    });
    _autoScrollTimer?.cancel();
  }
  @override
  Widget build(BuildContext context) {
    final noticeState = ref.watch(noticeProvider);

    // Don't show if dismissed or no notices
    if (_isDismissed || noticeState.isLoading) {
      return const SizedBox.shrink();
    }

    // Filter notices with '顶部' tag
    final topNotices = noticeState.visibleNotices
        .where((notice) => notice.tags.contains('顶部'))
        .toList();

    if (topNotices.isEmpty) {
      return const SizedBox.shrink();
    }

    // Start auto-scroll
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll(topNotices.length);
    });

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _isPaused = true),
      onExit: (_) {
        setState(() => _isPaused = false);
        _startAutoScroll(topNotices.length);
      },
      child: Container(
        height: 44,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              colorScheme.primary,
              colorScheme.primary.withValues(alpha: 0.85),
            ],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 12),
              child: Icon(
                Icons.campaign_rounded,
                size: 18,
                color: colorScheme.onPrimary,
              ),
            ),

            // Previous button
            if (topNotices.length > 1)
              _buildNavButton(
                icon: Icons.chevron_left_rounded,
                onTap: () {
                  final prevPage = (_currentIndex - 1 + topNotices.length) % topNotices.length;
                  _pageController.animateToPage(
                    prevPage,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),

            // Notice content
            Expanded(
              child: GestureDetector(
                onTap: () => _showNoticeDialog(topNotices),
                child: SizedBox(
                  height: 44,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    itemCount: topNotices.length,
                    itemBuilder: (context, index) {
                      final notice = topNotices[index];
                      final content = _truncateContent(notice.content, 100);
                      return Center(
                        child: Text(
                          '${notice.title}${content.isNotEmpty ? ' · $content' : ''}',
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Next button
            if (topNotices.length > 1)
              _buildNavButton(
                icon: Icons.chevron_right_rounded,
                onTap: () {
                  final nextPage = (_currentIndex + 1) % topNotices.length;
                  _pageController.animateToPage(
                    nextPage,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),

            // Counter
            if (topNotices.length > 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '${_currentIndex + 1}/${topNotices.length}',
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onPrimary.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

            // Close button
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _handleDismiss,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: colorScheme.onPrimary.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            size: 18,
            color: colorScheme.onPrimary.withValues(alpha: 0.9),
          ),
        ),
      ),
    );
  }

  String _truncateContent(String content, int maxLength) {
    // Remove HTML tags and excessive newlines
    String cleaned = content
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll(RegExp(r'\n{2,}'), ' ')
        .replaceAll('\n', ' ')
        .trim();

    if (cleaned.length <= maxLength) {
      return cleaned;
    }

    return '${cleaned.substring(0, maxLength)}...';
  }

  /// 检查并显示需要弹窗的公告
  Future<void> _checkAndShowDialogNotices(List<DomainNotice> notices) async {
    if (!mounted) return;

    // 找到所有标签包含"弹窗"的公告
    final dialogNotices = notices.where((notice) {
      return notice.tags.any((tag) =>
        tag.toString().toLowerCase() == '弹窗' ||
        tag.toString().toLowerCase() == 'popup' ||
        tag.toString().toLowerCase() == 'dialog'
      );
    }).toList();

    if (dialogNotices.isEmpty) return;

    // 获取存储服务
    final storageService = ref.read(storageServiceProvider);

    // 找到需要显示的公告（24小时内未显示过的）
    for (final notice in dialogNotices) {
      final shouldShow = await storageService.shouldShowNoticeDialog(notice.id);

      if (shouldShow && mounted) {
        // 显示弹窗
        await _showNoticePopupDialog(notice, storageService);
        // 只显示一个弹窗，然后退出
        break;
      }
    }
  }

  /// 显示公告弹窗对话框
  Future<void> _showNoticePopupDialog(dynamic notice, XBoardStorageService storageService) async {
    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false, // 不允许点击外部关闭
      builder: (context) => NoticePopupDialog(
        notice: notice,
        onConfirm: () async {
          // 保存已读时间戳
          await storageService.saveNoticeDialogReadTime(notice.id);
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }

  void _showNoticeDialog(List<DomainNotice> notices) {
    if (notices.isEmpty) return;

    // Remove focus before opening dialog
    FocusScope.of(context).unfocus();

    showDialog(
      context: context,
      builder: (context) => NoticeDetailDialog(
        notices: notices,
        initialIndex: _currentIndex,
        onPageChanged: (index) {
          // Update current index
        },
      ),
    ).then((_) {
      // Remove focus after closing dialog
      if (mounted) {
        FocusScope.of(context).unfocus();
      }
    });
  }
}
class NoticeDetailDialog extends StatefulWidget {
  final List<dynamic> notices; // 使用 Notice 类型的列表
  final int initialIndex;
  final ValueChanged<int>? onPageChanged;
  
  const NoticeDetailDialog({
    super.key,
    required this.notices,
    this.initialIndex = 0,
    this.onPageChanged,
  });
  @override
  State<NoticeDetailDialog> createState() => _NoticeDetailDialogState();
}
class _NoticeDetailDialogState extends State<NoticeDetailDialog> 
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late int _currentIndex;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.notices.length - 1);
    _pageController = PageController(initialPage: _currentIndex);
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        // 当对话框关闭时（无论通过什么方式），移除焦点
        if (didPop) {
          Future.microtask(() {
            if (context.mounted) {
              FocusScope.of(context).unfocus();
            }
          });
        }
      },
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: screenWidth > 600 ? 600 : double.infinity,
            maxHeight: screenHeight * 0.85,
          ),
          decoration: BoxDecoration(
            // 在暗色主题下使用稍亮的背景色以区分弹窗
            color: isDark 
                ? Theme.of(context).colorScheme.surfaceContainerHighest
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            // 添加明显的边框
            border: Border.all(
              color: isDark
                  ? Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)
                  : Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
              width: isDark ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              Flexible(
                child: widget.notices.length == 1
                    ? _buildSingleNotice()
                    : _buildMultipleNotices(),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    final currentNotice = widget.notices[_currentIndex];
    final title = currentNotice.title ?? '无标题';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
      decoration: BoxDecoration(
        // 在暗色主题下头部使用更亮的背景色
        color: isDark
            ? Theme.of(context).colorScheme.surfaceContainer
            : Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: isDark ? 0.2 : 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (widget.notices.length > 1) ...[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Text(
                '${_currentIndex + 1}/${widget.notices.length}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(width: 6),
          ],
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                // 在关闭对话框前移除焦点，避免键盘弹出
                FocusScope.of(context).unfocus();
                Navigator.of(context).pop();
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Icon(
                  Icons.close_rounded,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildSingleNotice() {
    final notice = widget.notices[0];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      physics: const BouncingScrollPhysics(),
      child: _buildNoticeContent(notice),
    );
  }
  Widget _buildMultipleNotices() {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
              widget.onPageChanged?.call(index);
            },
            itemCount: widget.notices.length,
            itemBuilder: (context, index) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                physics: const BouncingScrollPhysics(),
                child: _buildNoticeContent(widget.notices[index]),
              );
            },
          ),
        ),
        _buildNavigationBar(),
      ],
    );
  }
  
  Widget _buildNavigationBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        // 在暗色主题下底部导航栏使用更亮的背景色
        color: isDark
            ? Theme.of(context).colorScheme.surfaceContainer
            : Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(24),
        ),
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: isDark ? 0.2 : 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavButton(
            icon: Icons.chevron_left_rounded,
            label: '上一条',
            enabled: _currentIndex > 0,
            onPressed: () => _pageController.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ),
          ),
          _buildPageIndicator(),
          _buildNavButton(
            icon: Icons.chevron_right_rounded,
            label: '下一条',
            enabled: _currentIndex < widget.notices.length - 1,
            isReversed: true,
            onPressed: () => _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNavButton({
    required IconData icon,
    required String label,
    required bool enabled,
    required VoidCallback onPressed,
    bool isReversed = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: enabled 
                ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: enabled 
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
                  : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: isReversed ? [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: enabled 
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                icon,
                size: 20,
                color: enabled 
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline,
              ),
            ] : [
              Icon(
                icon,
                size: 20,
                color: enabled 
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: enabled 
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildPageIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        widget.notices.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: index == _currentIndex ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: index == _currentIndex
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
  Widget _buildNoticeContent(dynamic notice) {
    String formatTime(dynamic timeValue) {
      if (timeValue == null) return '未知时间';
      try {
        DateTime dateTime;
        if (timeValue is int) {
          final timestamp = timeValue > 1000000000000 ? timeValue : timeValue * 1000;
          dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        } else if (timeValue is String) {
          dateTime = DateTime.parse(timeValue);
        } else {
          return timeValue.toString();
        }
        return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
      } catch (e) {
        return timeValue.toString();
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 时间信息
        if (notice.createdAt != null || notice.updatedAt != null) ...[
          Text(
            formatTime(notice.createdAt),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 12),
        ],
        
        // 内容区域 - 根据配置选择渲染方式
        _buildContentWidget(notice),
      ],
    );
  }
  /// 根据配置构建内容Widget（Markdown或HTML）
  Widget _buildContentWidget(dynamic notice) {
    final content = notice.content ?? '暂无内容';
    
    // 如果配置为 null，自动检测内容格式
    final renderType = kNoticeRenderType ?? _detectContentType(content);
    
    switch (renderType) {
      case NoticeRenderType.markdown:
        return _buildMarkdownContent(content);
      case NoticeRenderType.html:
        return _buildHtmlContent(content);
    }
  }
  
  /// 自动检测内容类型
  /// 
  /// 通过检查内容中是否包含 HTML 标签来判断：
  /// - 如果包含常见的 HTML 标签，认为是 HTML
  /// - 否则认为是 Markdown
  NoticeRenderType _detectContentType(String content) {
    // 去除首尾空白
    final trimmedContent = content.trim();
    
    // 如果内容为空，默认使用 Markdown
    if (trimmedContent.isEmpty) {
      return NoticeRenderType.markdown;
    }
    
    // 常见的 HTML 标签模式
    final htmlTagPattern = RegExp(
      r'<(p|div|span|h[1-6]|ul|ol|li|br|hr|strong|em|a|img|table|tr|td|th|blockquote|pre|code)[>\s]',
      caseSensitive: false,
    );
    
    // 如果匹配到 HTML 标签，使用 HTML 渲染
    if (htmlTagPattern.hasMatch(trimmedContent)) {
      return NoticeRenderType.html;
    }
    
    // 默认使用 Markdown 渲染
    return NoticeRenderType.markdown;
  }
  
  /// 构建Markdown内容
  Widget _buildMarkdownContent(String content) {
    return MarkdownBody(
      data: _processMarkdownForDialog(content),
      styleSheet: NoticeMarkdownStyles.getNoticeContentStyle(context),
      onTapLink: (text, href, title) => _handleLinkTap(href),
    );
  }
  
  /// 构建HTML内容
  Widget _buildHtmlContent(String content) {
    return NoticeHtmlStyles.buildNoticeHtml(
      context: context,
      htmlContent: _processHtmlForDialog(content),
      onTapUrl: (url) => _handleLinkTap(url),
    );
  }
  
  String _processMarkdownForDialog(String markdownText) {
    return markdownText.trim();
  }
  
  String _processHtmlForDialog(String htmlText) {
    return htmlText.trim();
  }
  
  /// 处理Markdown/HTML中的链接点击
  void _handleLinkTap(String? href) async {
    if (href == null || href.isEmpty) return;
    
    try {
      final uri = Uri.parse(href);
      
      // 检查是否可以启动该链接
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication, // 在外部浏览器打开
        );
      } else {
        // 如果无法打开，显示提示
        if (mounted) {
          XBoardNotification.showError('无法打开链接: $href');
        }
      }
    } catch (e) {
      // 处理无效URL或其他错误
      if (mounted) {
        XBoardNotification.showError('链接格式错误: $href');
      }
    }
  }
}

/// 公告弹窗对话框（用于标签包含"弹窗"的公告）
class NoticePopupDialog extends StatelessWidget {
  final dynamic notice;
  final VoidCallback onConfirm;

  const NoticePopupDialog({
    super.key,
    required this.notice,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false, // 禁止返回键关闭
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: isDark
                ? Theme.of(context).colorScheme.surfaceContainerHighest
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isDark
                  ? Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)
                  : Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
              width: isDark ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 头部：图标和标题
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark
                      ? Theme.of(context).colorScheme.surfaceContainer
                      : Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.campaign_rounded,
                        size: 32,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      notice.title ?? '重要通知',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // 内容区域
              Container(
                constraints: const BoxConstraints(maxHeight: 400),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  physics: const BouncingScrollPhysics(),
                  child: _buildNoticeContent(context, notice),
                ),
              ),

              // 底部按钮
              Container(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: onConfirm,
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      AppLocalizations.of(context).xboardNoticeDialogGotIt,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoticeContent(BuildContext context, dynamic notice) {
    final content = notice.content ?? '暂无内容';

    // 自动检测内容类型
    final isHtml = _isHtmlContent(content);

    if (isHtml) {
      return NoticeHtmlStyles.buildNoticeHtml(
        context: context,
        htmlContent: content,
        onTapUrl: (url) => _handleLinkTap(context, url),
      );
    } else {
      return MarkdownBody(
        data: content,
        styleSheet: NoticeMarkdownStyles.getNoticeContentStyle(context),
        onTapLink: (text, href, title) => _handleLinkTap(context, href),
      );
    }
  }

  bool _isHtmlContent(String content) {
    final htmlTagPattern = RegExp(
      r'<(p|div|span|h[1-6]|ul|ol|li|br|hr|strong|em|a|img|table|tr|td|th|blockquote|pre|code)[>\s]',
      caseSensitive: false,
    );
    return htmlTagPattern.hasMatch(content.trim());
  }

  void _handleLinkTap(BuildContext context, String? href) async {
    if (href == null || href.isEmpty) return;

    try {
      final uri = Uri.parse(href);

      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (context.mounted) {
          XBoardNotification.showError('无法打开链接: $href');
        }
      }
    } catch (e) {
      if (context.mounted) {
        XBoardNotification.showError('链接格式错误: $href');
      }
    }
  }
}