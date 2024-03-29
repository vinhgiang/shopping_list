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
  bool _isReady = false;
  String? _error;

  void _loadItems() async {
    try {
      final url = Uri.https('shopping-list-39ea4-default-rtdb.firebaseio.com',
          'shopping-list.json');
      final response = await http.get(url);
      if (response.statusCode != 200) {
        setState(() {
          _error = 'Failed to fetch data. Please try again later.';
        });
        return;
      }

      // 'null' is the specific response from Firebase when the list is empty.'
      // different service or BE might have different response
      if (response.body == 'null') {
        setState(() {
          _isReady = true;
        });
        return;
      }

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
        _isReady = true;
      });
    } catch (err) {
      setState(() {
        _error = 'Something went wrong. Please try again later.\n\n $err';
      });
    }
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

  void _removeItem(GroceryItemModel.GroceryItem item) async {
    final index = _groceryItems.indexOf(item);

    // delete locally first and move on
    // so that we don't need to wait for the deletion to complete
    setState(() {
      _groceryItems.remove(item);
    });

    // then delete on server
    final url = Uri.https('shopping-list-39ea4-default-rtdb.firebaseio.com',
        'shopping-list/${item.id}.json');

    final response = await http.delete(url);
    if (response.statusCode != 200) {
      setState(() {
        _groceryItems.insert(index, item);
      });

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete item. Please try again later.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text('Your list is empty!'),
    );

    if (!_isReady) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (ctx, index) => GroceryItem(
          groceryItem: _groceryItems[index],
          removeItem: _removeItem,
        ),
      );
    }

    if (_error != null) {
      content = Center(
        child: Text(_error!),
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
