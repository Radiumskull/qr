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
  String contact = '';
  String eventType = '';
  String eventName = '';
  Color colorb = Colors.red;

  final database = FirebaseDatabase.instance.reference();
  Future qscan() async {
    try {
      String qresult = await BarcodeScanner.scan();
      setState(() async {
        result = qresult;
        print(result);
        print(result.split('\n').length);

        contact = result.split(' ')[2];
        eventType = result.split(' ')[0];
        eventName = result.split(' ')[1];          
        
        String path = eventType  + '/' +   eventName + '/' + contact;
        print(path);
        setState(() {
          colorb = Colors.yellow;
        });
          await database.reference().child(path).once().then((DataSnapshot dataSnapshot)  {
              setState(() {
                received = dataSnapshot.value.toString();
              });

          if(dataSnapshot.value == null){
            received = 'Not Registered';
          }
          else{
            received = dataSnapshot.value.toString();
          }
          setState(() {
            colorb = Colors.red;
          });
        });  
        
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
  String received = '';
  Widget build(BuildContext context) {
    
    return MaterialApp(
        title: 'TechStorm2020 QR',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
          appBar: AppBar(
              ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(received),
              Center(child: Text("Hey there....\nclick on payment recieved button\n only after scanning the QR CODE")),
              RaisedButton(
                color : colorb,
                onPressed: (){

                 String path = eventType  + '/' +   eventName + '/' + contact;
                setState(() {
                  print(path);
                    setState(() {
                      colorb = Colors.yellow;
                    });
                  database.reference().child(path).once().then((DataSnapshot dataSnapshot) async {
                  if(dataSnapshot.value == null){
                    received = 'Not Registered';

                  }
                  else{
                                        setState(() {
                      colorb = Colors.yellow;
                    });
 
                      await database.reference().child(eventType  + '/' +   eventName + '/' + contact).update({
                        'payment' : 'true'
                      });
                  await database.reference().child(path).once().then((DataSnapshot dataSnapshot) async {
                    
                    setState(() {
                      colorb = Colors.red;
                      received = dataSnapshot.value.toString();

                    });
                  });

            
                  }
                  print(received);
                });  
                });


              },child: Text("Payment Recieved"),)
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
