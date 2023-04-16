import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_bluetooth/bluetooth_controller.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Bluetooth',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const Home()
    );
  }
}


class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text("Flutter Bluetooth")),
        body: GetBuilder<BluetoothController>(
            init: BluetoothController(),
            builder: (controller) {
              return  SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [

                    const SizedBox(height: 15,) ,

                    ElevatedButton(onPressed: () => controller.scanDevices() , child: const Text("Scan")) ,

                    const SizedBox(height: 15,) ,

                    StreamBuilder<List<ScanResult>>(
                        stream: controller.scanResults,
                        builder: (context, snapshot) {
                          if(snapshot.hasData) {
                            return ListView.builder(
                              shrinkWrap: true,
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                var data = snapshot.data![index] ;
                                return Card(
                                  elevation: 3,
                                  child: ListTile(
                                    onTap: () {

                                    },
                                    title: Text(data.device.name) ,
                                    subtitle: Text(data.device.id.id) ,
                                    trailing: Text(data.rssi.toString()),
                                  ),
                                ) ;
                              },
                            ) ;
                          }else{
                            return const Center(
                              child: Text("No devices found"),
                            );
                          }
                        },)
                  ],
                ),
              ) ;
            },),
      ),
    );
  }
}


