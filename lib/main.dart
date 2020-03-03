import 'package:flutter/material.dart';
import "package:barcode_scan/barcode_scan.dart";
import "package:flutter/services.dart";
import 'package:firebase_database/firebase_database.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String result = '';
  String contact;
  Future qscan() async {
    try {
      String qresult = await BarcodeScanner.scan();
      setState(() {
        result = qresult;
        print(result);
        print(result.split('\n').length);
        print(result.split('\n')[5].split(':')[1]);
        contact = result.split('\n')[5].split(':')[1].split(',')[0];
      });
    } on PlatformException catch (ex) {
      if (ex.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          result = "camera permisson denied";
        });
      } else {
        setState(() {
          result = "unknown exception $ex";
        });
      }
    }catch(ex)
    {
      setState(() {
          result = "unknown exception $ex";
        });
    }
  }

  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
          appBar: AppBar(
              ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(result),
              Center(child: Text("Hey there....\nclick on payment recieved button\n only after scanning the QR CODE")),
              RaisedButton(onPressed: (){
                final database = FirebaseDatabase.instance.reference();
                database.reference().child('BrainTeasers/' + 'Omegatrix/' + contact).update({
                  'payment' : true
                });
              },child: Text("Payment Recieved"),color: Colors.red,)
            ],
          ),
          

          floatingActionButton: FloatingActionButton.extended(
            onPressed: qscan,
            label: Text("scan"),
            icon: Icon(Icons.camera_alt),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation
              .centerFloat, // This trailing comma makes auto-formatting nicer for build methods.
        ));
  }
}
