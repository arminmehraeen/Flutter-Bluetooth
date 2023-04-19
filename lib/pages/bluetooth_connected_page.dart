import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bluetooth/bloc/bluetooth_bloc.dart';
import 'package:flutter_bluetooth/pages/message_page.dart';

class BluetoothConnectedPage extends StatefulWidget {
  const BluetoothConnectedPage({Key? key}) : super(key: key);

  @override
  State<BluetoothConnectedPage> createState() => _BluetoothConnectedPageState();
}

class _BluetoothConnectedPageState extends State<BluetoothConnectedPage> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Flutter Bluetooth Connected"),
          leading: null,
        ),
        body: BlocConsumer<BluetoothBloc, BluetoothState>(
          builder: (context, state) {
            if (state is BluetoothConnected) {
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
                              BlocProvider.of<BluetoothBloc>(context)
                                  .add(BluetoothDisconnect(state.device));
                            },
                            icon: const Icon(
                              Icons.close,
                              size: 15,
                              color: Colors.red,
                            )),
                      ),
                    ),
                  ),
                  const Divider(),
                  ...List.generate(
                      state.services.length,
                      (index) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Card(
                              elevation: 3,
                              child: ListTile(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MessagePage(
                                            characteristics: state
                                                .services[index]
                                                .characteristics),
                                      ));
                                },
                                title: Text(state.services[index].uuid.toMac()),
                                subtitle: Text(
                                  state.services[index].uuid
                                          .toMac()
                                          .startsWith("00")
                                      ? "System"
                                      : "Open",
                                  style: TextStyle(
                                      color: state.services[index].uuid
                                              .toMac()
                                              .startsWith("00")
                                          ? Colors.red
                                          : Colors.blue),
                                ),
                              ),
                            ),
                          ))
                ],
              );
            }
            return const Center(child: Text("Default text :)"));
          },
          listener: (context, state) {
            if (state is BluetoothInitial) {
              Navigator.pop(context, true);
            }
          },
        ),
      ),
    );
  }
}
