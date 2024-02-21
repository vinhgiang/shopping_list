import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/widgets/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';
import 'package:shopping_list/models/grocery_item.dart' as GroceryItemModel;
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItemModel.GroceryItem> _groceryItems = [];

  void _loadItems() async {
    final url = Uri.https('shopping-list-39ea4-default-rtdb.firebaseio.com',
        'shopping-list.json');
    final response = await http.get(url);
    final Map<String, dynamic> data = json.decode(response.body);
    final List<GroceryItemModel.GroceryItem> items = [];
    for (final item in data.entries) {
      final category = categories.entries
          .firstWhere((cat) => cat.value.name == item.value['category'])
          .value;
      items.add(
        GroceryItemModel.GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category,
        ),
      );
    }

    setState(() {
      _groceryItems = items;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _addItem() async {
    // final recentlyAddedItem = await Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (ctx) => const NewItem(),
    //   ),
    // );

    // if (recentlyAddedItem != null) {
    //   setState(() {
    //     _groceryItems.add(recentlyAddedItem);
    //   });
    // }

    final recentlyAddedItem = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(),
      ),
    );

    if (recentlyAddedItem != null) {
      setState(() {
        _groceryItems.add(recentlyAddedItem);
      });
    }
  }

  void _removeItem(GroceryItemModel.GroceryItem item) {
    setState(() {
      _groceryItems.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text('Your list is empty!'),
    );

    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (ctx, index) => GroceryItem(
          groceryItem: _groceryItems[index],
          removeItem: _removeItem,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grocery List'),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: content,
    );
  }
}
