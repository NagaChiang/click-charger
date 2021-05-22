import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:easy_localization/easy_localization.dart';

import 'iapDialogItem.dart';

class IapDialog extends StatelessWidget {
  final List<ProductDetails> products;

  const IapDialog({this.products});

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Center(child: Text('store'.tr())),
      children: products
          .map((product) => IapDialogItem(
                product: product,
              ))
          .toList(),
    );
  }
}
