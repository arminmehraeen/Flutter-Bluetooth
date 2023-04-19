import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../cubit/bluetooth_cubit.dart';

class ConnectedDevicesPage extends StatefulWidget {
  const ConnectedDevicesPage({Key? key, required this.devices})
      : super(key: key);
  final List<BluetoothDevice> devices;
  @override
  State<ConnectedDevicesPage> createState() => _ConnectedDevicesPageState();
}

class _ConnectedDevicesPageState extends State<ConnectedDevicesPage> {
  List<BluetoothDevice> devices = [];
  @override
  void initState() {
    devices = widget.devices;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Flutter Bluetooth")),
      body: Column(
        children: List.generate(devices.length, (index) {
          var data = devices[index];
          return Card(
            elevation: 3,
            child: ListTile(
              title: Text(data.name),
              subtitle: Text(data.id.toString()),
              trailing: IconButton(
                  onPressed: () {
                    BlocProvider.of<BluetoothCubit>(context)
                        .disconnect(device: devices[index]);
                  },
                  icon: Icon(
                    Icons.close,
                    color: Colors.red,
                  )),
            ),
          );
        }),
      ),
    );
  }
}
