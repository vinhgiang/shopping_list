import 'package:flutter/material.dart';

import 'package:shopping_list/models/grocery_item.dart' as grocery_item;

class GroceryItem extends StatelessWidget {
  final grocery_item.GroceryItem groceryItem;

  const GroceryItem({
    super.key,
    required this.groceryItem,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(groceryItem.name),
      leading: Container(
        width: 24,
        height: 24,
        color: groceryItem.category.color,
      ),
      trailing: Text(
        groceryItem.quantity.toString(),
      ),
    );
  }
}
