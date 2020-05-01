import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart' as ord;

class OrderItem extends StatefulWidget {
  final ord.OrderItem orders;

  OrderItem(this.orders);

  @override
  _OrderItemState createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  var _isExpanded = false;

  Future<bool> showRemoveOrderDialog() {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Remove Order'),
        content: Text('Are you sure to remove order?'),
        actions: <Widget>[
          FlatButton(
            child: Text('No'),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          FlatButton(
            child: Text('Yes'),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      child: Card(
        margin: EdgeInsets.all(5),
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text('\$${widget.orders.amount.toStringAsFixed(2)}'),
              subtitle: Text(
                DateFormat('dd MM yyyy hh:mm').format(widget.orders.date),
              ),
              trailing: IconButton(
                icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
              ),
            ),
            if (_isExpanded)
              Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                height: min(widget.orders.products.length * 20.0 + 20, 100),
                child: ListView.builder(
                  itemCount: widget.orders.products.length,
                  itemBuilder: (ctx, i) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        widget.orders.products[i].title,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                          '${widget.orders.products[i].quantity}x ${widget.orders.products[i].price}')
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      direction: DismissDirection.endToStart,
      key: ValueKey(widget.orders.id),
      background: Container(
        margin: EdgeInsets.all(10),
        color: Theme.of(context).errorColor,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Icon(          
            Icons.delete,
            color: Colors.white,
            size: 40,
          ),
        ),
        alignment: Alignment.centerRight,        
      ),
      onDismissed: (direction) {
        Provider.of<ord.Orders>(context, listen: false).remove(widget.orders.id);
      },
      confirmDismiss: (direction) {
        return showRemoveOrderDialog();
      },
    );
  }
}
