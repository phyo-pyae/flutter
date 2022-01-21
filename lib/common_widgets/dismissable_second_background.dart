import 'package:flutter/material.dart';

class Dismissable_Second_BackGround extends StatelessWidget {
  const Dismissable_Second_BackGround({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(''),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
