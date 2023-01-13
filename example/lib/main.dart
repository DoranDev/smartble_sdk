import 'package:flutter/material.dart';
import 'package:smartble_sdk/smartble_sdk.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final smartble = SmartbleSdk();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            shrinkWrap: true,
            children: [
              TextButton(
                  onPressed: () {
                    smartble.scan(isScan: true);
                  },
                  child: const Text("Scan")),
              StreamBuilder<dynamic>(
                stream: SmartbleSdk.getDeviceListStream,
                builder: (
                  BuildContext context,
                  AsyncSnapshot<dynamic> snapshot,
                ) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container();
                  } else if (snapshot.connectionState ==
                          ConnectionState.active ||
                      snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasError) {
                      return const Text(
                        'Error',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.normal),
                        textAlign: TextAlign.center,
                      );
                    } else if (snapshot.hasData) {
                      List listdata = snapshot.data ?? [];
                      return ListView.builder(
                          itemCount: listdata.length,
                          shrinkWrap: true,
                          itemBuilder: (context, i) {
                            return Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: InkWell(
                                onTap: () {
                                  smartble.setAddress(
                                      bname: "${listdata[i]['deviceName']}",
                                      bmac:
                                          "${listdata[i]['deviceMacAddress']}");
                                  smartble.connect();
                                },
                                child: Text(
                                  "${listdata[i]['deviceName']} ${listdata[i]['deviceMacAddress']}",
                                  style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.start,
                                ),
                              ),
                            );
                          });
                    } else {
                      return const Text(
                        'Empty Data',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.normal),
                        textAlign: TextAlign.center,
                      );
                    }
                  } else {
                    return Text(
                      'State: ${snapshot.connectionState}',
                      style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.normal),
                      textAlign: TextAlign.center,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
