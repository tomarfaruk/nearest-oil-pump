import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'nearest_oil_pump.dart';

/* PermissionHandler()
                  .requestPermissions([PermissionGroup.location]).then((value) {
                if (value.containsValue(PermissionStatus.granted)) {
                  Navigator.of(context).push(CupertinoPageRoute(
                      builder: (context) => NearestOilPump()));
                } else {
                  print("Please allow gps permission");
                }
              });*/


void main() {
  runApp(MaterialApp(
    title: 'Navigation Basics',
    home: FirstRoute(),
  ));
}


class FirstRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('First Route'),
      ),
      body: Center(
        child: RaisedButton(
          child: Text('Open route'),
          onPressed: () {

             PermissionHandler()
                  .requestPermissions([PermissionGroup.location]).then((value) {
                if (value.containsValue(PermissionStatus.granted)) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NearestOilPump()),
                  );
                } else {
                  print("Please allow gps permission");
                }
              });




          },
        ),
      ),
    );
  }
}
