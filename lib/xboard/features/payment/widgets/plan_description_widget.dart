import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:markdown/markdown.dart' as md;

class PlanDescriptionWidget extends StatelessWidget {
  final String content;
  const PlanDescriptionWidget({
    super.key,
    required this.content,
  });

  /// 检测内容是否为 HTML
  bool _isHtml(String text) {
    final htmlPattern = RegExp(r'<[^>]+>', multiLine: true);
    return htmlPattern.hasMatch(text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: _isHtml(content)
          ? _buildHtmlContent(colorScheme)
          : _buildMarkdownContent(colorScheme),
    );
  }

  /// 渲染 HTML 内容
  Widget _buildHtmlContent(ColorScheme colorScheme) {
    return HtmlWidget(
      content,
      textStyle: TextStyle(
        color: colorScheme.onSurfaceVariant,
        fontSize: 14,
        height: 1.5,
      ),
      customStylesBuilder: (element) {
        if (element.localName == 'a') {
          return {
            'color': '#${colorScheme.primary.value.toRadixString(16).substring(2)}',
            'text-decoration': 'underline',
          };
        }
        if (element.localName == 'code') {
          return {
            'background-color': '#${colorScheme.surfaceContainerLow.value.toRadixString(16).substring(2)}',
            'color': '#${colorScheme.onSurfaceVariant.value.toRadixString(16).substring(2)}',
            'font-family': 'monospace',
            'font-size': '13px',
            'padding': '2px 4px',
          };
        }
        if (element.localName == 'pre') {
          return {
            'background-color': '#${colorScheme.surfaceContainerLow.value.toRadixString(16).substring(2)}',
            'padding': '12px',
            'border-radius': '8px',
          };
        }
        if (element.localName == 'blockquote') {
          return {
            'border-left': '4px solid #${colorScheme.primary.value.toRadixString(16).substring(2)}',
            'padding-left': '12px',
            'margin-left': '8px',
          };
        }
        if (element.localName?.startsWith('h') == true) {
          return {
            'color': '#${colorScheme.onSurface.value.toRadixString(16).substring(2)}',
            'font-weight': 'bold',
          };
        }
        return null;
      },
    );
  }

  /// 渲染 Markdown 内容
  Widget _buildMarkdownContent(ColorScheme colorScheme) {
    return MarkdownBody(
      data: content,
      styleSheet: MarkdownStyleSheet(
        p: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: 14,
          height: 1.5,
        ),
        h1: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        h2: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        h3: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        h4: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        listBullet: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: 14,
        ),
        code: TextStyle(
          backgroundColor: colorScheme.surfaceContainerLow,
          color: colorScheme.onSurfaceVariant,
          fontFamily: 'monospace',
          fontSize: 13,
        ),
        codeblockDecoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
        ),
        blockquoteDecoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          border: Border(
            left: BorderSide(color: colorScheme.primary, width: 4),
          ),
        ),
        a: TextStyle(
          color: colorScheme.primary,
          decoration: TextDecoration.underline,
        ),
        strong: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
        em: const TextStyle(
          fontStyle: FontStyle.italic,
        ),
      ),
      extensionSet: md.ExtensionSet.gitHubFlavored,
    );
  }
}