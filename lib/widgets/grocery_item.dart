import 'package:flutter/material.dart';

import 'package:shopping_list/models/grocery_item.dart' as grocery_item;

class GroceryItem extends StatelessWidget {
  final grocery_item.GroceryItem groceryItem;
  final Function(grocery_item.GroceryItem) removeItem;

  const GroceryItem({
    super.key,
    required this.groceryItem,
    required this.removeItem,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(groceryItem.id),
      onDismissed: (direction) {
        removeItem(groceryItem);
      },
      child: ListTile(
        title: Text(groceryItem.name),
        leading: Container(
          width: 24,
          height: 24,
          color: groceryItem.category.color,
        ),
        trailing: Text(
          groceryItem.quantity.toString(),
        ),
      ),
    );
  }
}
