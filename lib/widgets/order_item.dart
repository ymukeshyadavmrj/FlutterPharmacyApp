import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/providers/products.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart' as ord;

class OrderItem extends StatefulWidget {
  final ord.OrderItem order;

  OrderItem(this.order);

  @override
  _OrderItemState createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  var _expanded = false;

Widget func(int val)
{
    if(val==0)
    return Text(
                'Ordered',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.red,
                ));
    if(val==1)
    return Text(
                'Your package is on the way!',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.yellow,
                ));
                if(val==2)
    return Text(
                'Delivered',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.green,
                ));

}


  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Products>(context, listen: false)
        .findById(widget.order.id);
    return Card(
      margin: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                product.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${widget.order.quantity}x \$${product.price}',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              )
            ],
          ),
          Divider(),
          Row(
            children: [
              func(widget.order.order_status)
            ],
          )
        ],
      ),
    );
  }
}
