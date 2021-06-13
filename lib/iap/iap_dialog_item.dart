import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../utils/utils.dart';

class IapDialogItem extends StatelessWidget {
  static RegExp _titleRegExp = RegExp(r'^(.*) \((.*)\) \(.*\)$');

  final ProductDetails product;

  const IapDialogItem({this.product});

  @override
  Widget build(BuildContext context) {
    final RegExpMatch match = _titleRegExp.firstMatch(product.title);
    if (match == null) {
      print(
        'Error: RegExp can not find match in the product title: ${product.title}.',
      );
      return Container();
    }

    final String title = match.group(1);
    final String subtitle = match.group(2);

    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Text(product.price),
        onTap: () async {
          Utils.showLoadingOverlay(context);

          final PurchaseParam param = PurchaseParam(productDetails: product);
          await InAppPurchase.instance.buyConsumable(purchaseParam: param);

          Navigator.of(context).pop();
        },
      ),
    );
  }
}
