import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../utils/utils.dart';
import '../utils/constants.dart';

class IapDialogItem extends StatelessWidget {
  final ProductDetails product;

  const IapDialogItem({this.product});

  @override
  Widget build(BuildContext context) {
    final boostProduct = Constants.boostProductData[product.id];
    if (boostProduct == null) {
      print("Error: Boost product ID not found: ${product.id}");
      return Container();
    }

    final title = tr('product.title', args: ['${boostProduct.totalCount}']);
    final subtitle = 'product.subtitle'.plural(boostProduct.freeCount);

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
