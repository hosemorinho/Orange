import 'package:flutter/material.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/xboard/domain/domain.dart';
import 'package:fl_clash/widgets/dialog.dart';

/// Shows a payment method selection dialog using FlClash's CommonDialog.
///
/// Usage:
/// ```dart
/// final method = await showPaymentMethodSelector(
///   context,
///   paymentMethods: methods,
///   selectedMethod: currentMethod,
/// );
/// ```
Future<DomainPaymentMethod?> showPaymentMethodSelector(
  BuildContext context, {
  required List<DomainPaymentMethod> paymentMethods,
  DomainPaymentMethod? selectedMethod,
}) async {
  return await showDialog<DomainPaymentMethod>(
    context: context,
    builder: (context) => _PaymentMethodSelectorDialog(
      paymentMethods: paymentMethods,
      selectedMethod: selectedMethod,
    ),
  );
}

class _PaymentMethodSelectorDialog extends StatefulWidget {
  final List<DomainPaymentMethod> paymentMethods;
  final DomainPaymentMethod? selectedMethod;

  const _PaymentMethodSelectorDialog({
    required this.paymentMethods,
    this.selectedMethod,
  });

  @override
  State<_PaymentMethodSelectorDialog> createState() => _PaymentMethodSelectorDialogState();
}

class _PaymentMethodSelectorDialogState extends State<PaymentMethodSelectorDialog> {
  DomainPaymentMethod? _selectedMethod;

  @override
  void initState() {
    super.initState();
    _selectedMethod = widget.selectedMethod;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CommonDialog(
      title: appLocalizations.xboardSelectPaymentMethod,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(appLocalizations.cancel),
        ),
        FilledButton(
          onPressed: _selectedMethod == null
              ? null
              : () => Navigator.of(context).pop(_selectedMethod),
          child: Text(appLocalizations.confirm),
        ),
      ],
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: widget.paymentMethods.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final method = widget.paymentMethods[index];
          final isSelected = _selectedMethod?.id == method.id;

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            leading: method.iconUrl != null && method.iconUrl!.isNotEmpty
                ? Image.network(
                    method.iconUrl!,
                    width: 32,
                    height: 32,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.payment, size: 32);
                    },
                  )
                : const Icon(Icons.payment, size: 32),
            title: Text(
              method.name,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? colorScheme.primary : null,
              ),
            ),
            subtitle: method.feePercentage > 0
                ? Text(
                    '${appLocalizations.xboardHandlingFee}: ${method.feePercentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  )
                : null,
            trailing: Radio<int>(
              value: method.id,
              groupValue: _selectedMethod?.id,
              onChanged: (value) {
                setState(() {
                  _selectedMethod = method;
                });
              },
            ),
            onTap: () {
              setState(() {
                _selectedMethod = method;
              });
            },
          );
        },
      ),
    );
  }
}
