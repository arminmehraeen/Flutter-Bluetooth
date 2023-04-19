import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as blue;

import '../cubit/bluetooth_cubit.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    BlocProvider.of<BluetoothCubit>(context).initScan();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Flutter Bluetooth"),
        ),
        body: BlocBuilder<BluetoothCubit, BluetoothState>(
          builder: (context, state) {
            print(state);
            if (state is BluetoothLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is BluetoothMain) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 15,
                    ),
                    if (state.available == false) ...[
                      ElevatedButton(
                          onPressed: () =>
                              BlocProvider.of<BluetoothCubit>(context)
                                  .initScan(),
                          child: const Text("Check")),
                      const SizedBox(
                        height: 15,
                      ),
                      Center(
                        child: Text("Not available blueTooth"),
                      ),
                    ],
                    if (state.blueTooth == false) ...[
                      ElevatedButton(
                          onPressed: () =>
                              BlocProvider.of<BluetoothCubit>(context)
                                  .initScan(),
                          child: const Text("Check")),
                      const SizedBox(
                        height: 15,
                      ),
                      Center(
                        child: Text("BlueTooth off"),
                      ),
                    ],
                    if (state.available && state.blueTooth) ...[
                      ElevatedButton(
                          onPressed: () =>
                              BlocProvider.of<BluetoothCubit>(context)
                                  .scanDevices(),
                          child: const Text("Scan")),
                      Column(
                        children: List.generate(state.devices.length, (index) {
                          var data = state.devices[index];
                          return Card(
                            elevation: 3,
                            child: ListTile(
                              title: Text(data.name),
                              subtitle: Text(data.id.toString()),
                              trailing: IconButton(
                                  onPressed: () {
                                    BlocProvider.of<BluetoothCubit>(context)
                                        .disconnect(
                                            device: state.devices[index]);
                                  },
                                  icon: Icon(
                                    Icons.close,
                                    color: Colors.red,
                                  )),
                            ),
                          );
                        }),
                      ),
                      Divider(),
                      const SizedBox(
                        height: 15,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: StreamBuilder<List<blue.ScanResult>>(
                          stream: BlocProvider.of<BluetoothCubit>(context)
                              .scanResults(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, index) {
                                  var data = snapshot.data![index];
                                  return Card(
                                    elevation: 3,
                                    child: ListTile(
                                      onTap: () {
                                        BlocProvider.of<BluetoothCubit>(context)
                                            .connect(data.device);
                                      },
                                      title: Text(data.device.name),
                                      subtitle: Text(data.device.id.id),
                                      trailing: Text(data.rssi.toString()),
                                    ),
                                  );
                                },
                              );
                            } else {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: Text("No devices found"),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ]
                  ],
                ),
              );
            }

            if (state is BluetoothConnectDevice) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      elevation: 3,
                      child: ListTile(
                        title: Text(state.device.name),
                        subtitle: const Text("Connected"),
                        trailing: IconButton(
                            onPressed: () {
                              BlocProvider.of<BluetoothCubit>(context)
                                  .disconnect();
                            },
                            icon: Icon(
                              Icons.close,
                              color: Colors.red,
                            )),
                      ),
                    ),
                  )
                ],
              );
            }

            if (state is BluetoothInfoDevice) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      elevation: 3,
                      child: ListTile(
                        title: Text(state.device.name),
                        subtitle: const Text("Connected"),
                        trailing: IconButton(
                            onPressed: () {
                              BlocProvider.of<BluetoothCubit>(context)
                                  .disconnect();
                            },
                            icon: Icon(
                              Icons.close,
                              color: Colors.red,
                            )),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  ...List.generate(
                    state.services.length,
                    (index) => Card(
                      elevation: 3,
                      child: ListTile(
                        onTap: () {
                          BlocProvider.of<BluetoothCubit>(context)
                              .loadService(state.services[index]);
                        },
                        title: Text(state.services[index].uuid.toString()),
                        subtitle: Text(
                            "${state.services[index].characteristics.length} // ${state.services[index].includedServices.length}"),
                      ),
                    ),
                  ),
                  Divider(),
                  ...List.generate(
                    state.characteristics.length,
                    (index) => Card(
                      elevation: 3,
                      child: ListTile(
                        onTap: () {
                          bool read =
                              state.characteristics[index].properties.read;
                          bool write =
                              state.characteristics[index].properties.write;
                          if (read) {
                            BlocProvider.of<BluetoothCubit>(context)
                                .read(state.characteristics[index]);
                          }

                          if (write) {
                            BlocProvider.of<BluetoothCubit>(context)
                                .write(state.characteristics[index]);
                          }
                        },
                        title:
                            Text(state.characteristics[index].uuid.toString()),
                        subtitle: Text(
                            (state.characteristics[index].properties.read
                                    ? "Read"
                                    : "") +
                                " | " +
                                (state.characteristics[index].properties.write
                                    ? "Write"
                                    : "")),
                      ),
                    ),
                  ),
                ],
              );
            }

            return Container(
              child: Text("Container"),
            );
          },
        ),
      ),
    );
  }
}
