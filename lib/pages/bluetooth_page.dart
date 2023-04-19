import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as blue;
import 'package:flutter_bluetooth/bloc/bluetooth_bloc.dart';
import 'package:flutter_bluetooth/pages/bluetooth_connected_page.dart';
import 'package:logger/logger.dart';

class BluetoothPage extends StatefulWidget {
  const BluetoothPage({Key? key}) : super(key: key);

  @override
  State<BluetoothPage> createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  @override
  void initState() {
    onnBlueCheck();
    super.initState();
  }

  onnBlueCheck() {
    context.read<BluetoothBloc>().add(BluetoothCheck());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter Bluetooth"),
      ),
      body: BlocConsumer<BluetoothBloc, BluetoothState>(
        listener: (context, state) async {
          Logger().w(state);
          if (state is BluetoothConnected) {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BluetoothConnectedPage(),
                ));
          }
        },
        builder: (context, state) {
          if (state is BluetoothInitial) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is BluetoothNotAccess) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Bluetooth turn off . please turn on "),
                  const SizedBox(
                    height: 15,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        context.read<BluetoothBloc>().add(BluetoothCheck());
                      },
                      child: const Text("Check"))
                ],
              ),
            );
          }

          if (state is BluetoothNotAvailable) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Bluetooth not available"),
                  const SizedBox(
                    height: 15,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        context.read<BluetoothBloc>().add(BluetoothCheck());
                      },
                      child: const Text("Check"))
                ],
              ),
            );
          }

          if (state is BluetoothNotConnected) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (state.devices.isNotEmpty) ...[
                    const SizedBox(
                      height: 15,
                    ),
                    Column(
                        children: List.generate(
                            state.devices.length,
                            (index) => Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Card(
                                    elevation: 3,
                                    child: ListTile(
                                      title: Text(state.devices[index].name),
                                      subtitle: const Text("Connected"),
                                      trailing: IconButton(
                                          onPressed: () {
                                            BlocProvider.of<BluetoothBloc>(
                                                    context)
                                                .add(BluetoothDisconnect(
                                                    state.devices[index]));
                                          },
                                          icon: const Icon(
                                            Icons.close,
                                            size: 15,
                                            color: Colors.red,
                                          )),
                                    ),
                                  ),
                                )))
                  ],
                  const SizedBox(
                    height: 15,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        context.read<BluetoothBloc>().add(BluetoothScan());
                      },
                      child: const Text("Scan Devices")),
                  const SizedBox(
                    height: 15,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: StreamBuilder<List<blue.ScanResult>>(
                        stream: state.stream,
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return const Center(
                              child: Text("Error while get device"),
                            );
                          }
                          if (snapshot.hasData) {
                            List<blue.ScanResult> work = snapshot.data!
                                .where((element) => (element.device.type !=
                                    blue.BluetoothDeviceType.unknown))
                                .toList();
                            return work.isEmpty
                                ? const Center(
                                    child: Text("No device found"),
                                  )
                                : ListView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: work.length,
                                    itemBuilder: (context, index) {
                                      var data = work[index];
                                      return Card(
                                        elevation: 3,
                                        child: ListTile(
                                          onTap: () {
                                            context.read<BluetoothBloc>().add(
                                                BluetoothConnect(data.device));
                                          },
                                          title: Text(data.device.name),
                                          subtitle: Text(data.device.id.id),
                                          trailing: Text(data.rssi.toString()),
                                        ),
                                      );
                                    },
                                  );
                          }
                          return const Center(
                              child: CircularProgressIndicator());
                        },
                      ),
                    ),
                  )
                ],
              ),
            );
          }

          return const Center(child: Text("Default text :)"));
        },
      ),
    );
  }
}
