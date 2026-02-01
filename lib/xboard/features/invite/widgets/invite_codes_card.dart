import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/xboard/domain/domain.dart';
import 'package:fl_clash/xboard/features/shared/shared.dart';

/// Invite codes management card
///
/// Features:
/// - List of invite codes (max 5)
/// - Create new code button
/// - Copy code and copy link actions
/// - Empty state
class InviteCodesCard extends StatefulWidget {
  final List<DomainInviteCode> codes;
  final VoidCallback onCreateCode;
  final bool isCreating;

  const InviteCodesCard({
    super.key,
    required this.codes,
    required this.onCreateCode,
    this.isCreating = false,
  });

  @override
  State<InviteCodesCard> createState() => _InviteCodesCardState();
}

class _InviteCodesCardState extends State<InviteCodesCard> {
  String? _copiedCode;
  String? _copiedLink;

  Future<void> _copyCode(String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    setState(() => _copiedCode = code);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appLocalizations.xboardCodeCopied),
          duration: const Duration(seconds: 2),
        ),
      );
    }

    // Reset after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _copiedCode = null);
      }
    });
  }

  Future<void> _copyLink(String code) async {
    // Build invite link (matching frontend pattern)
    final inviteLink = '${Uri.base.origin}/#/register?invite=$code';
    await Clipboard.setData(ClipboardData(text: inviteLink));
    setState(() => _copiedLink = code);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appLocalizations.xboardLinkCopied),
          duration: const Duration(seconds: 2),
        ),
      );
    }

    // Reset after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _copiedLink = null);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final canCreateMore = widget.codes.length < 5;

    return XBDashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: XBSectionTitle(
                  title: appLocalizations.xboardInviteCodes,
                  icon: Icons.vpn_key,
                ),
              ),
              if (canCreateMore)
                FilledButton.icon(
                  onPressed: widget.isCreating ? null : widget.onCreateCode,
                  icon: widget.isCreating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.add, size: 18),
                  label: Text(
                    widget.isCreating
                        ? appLocalizations.xboardCreating
                        : appLocalizations.xboardCreateInviteCode,
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Codes list or empty state
          if (widget.codes.isEmpty)
            _buildEmptyState(context)
          else
            _buildCodesList(context),

          // Max limit notice
          if (!canCreateMore) ...[
            const SizedBox(height: 12),
            Center(
              child: Text(
                appLocalizations.xboardMaxInviteCodesReached,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.vpn_key_outlined,
              size: 64,
              color: colorScheme.onSurface.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 16),
            Text(
              appLocalizations.xboardNoInviteCodes,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              appLocalizations.xboardNoInviteCodesDesc,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCodesList(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: widget.codes.map((code) {
        final isCopiedCode = _copiedCode == code.code;
        final isCopiedLink = _copiedLink == code.code;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.2),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Code display
              Expanded(
                child: Text(
                  code.code,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Copy code button
              OutlinedButton.icon(
                onPressed: () => _copyCode(code.code),
                icon: Icon(
                  isCopiedCode ? Icons.check : Icons.content_copy,
                  size: 16,
                  color: isCopiedCode ? Colors.green : null,
                ),
                label: Text(
                  isCopiedCode
                      ? appLocalizations.xboardCopied
                      : appLocalizations.xboardCopyCode,
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isCopiedCode
                      ? Colors.green
                      : colorScheme.onSurface.withValues(alpha: 0.7),
                  side: BorderSide(
                    color: isCopiedCode
                        ? Colors.green
                        : colorScheme.outline.withValues(alpha: 0.3),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Copy link button
              FilledButton.icon(
                onPressed: () => _copyLink(code.code),
                icon: Icon(
                  isCopiedLink ? Icons.check : Icons.link,
                  size: 16,
                  color: isCopiedLink ? Colors.green : colorScheme.onPrimary,
                ),
                label: Text(
                  isCopiedLink
                      ? appLocalizations.xboardLinkCopied
                      : appLocalizations.xboardCopyLink,
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: isCopiedLink
                      ? Colors.green
                      : colorScheme.primaryContainer,
                  foregroundColor: isCopiedLink
                      ? Colors.white
                      : colorScheme.onPrimaryContainer,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
