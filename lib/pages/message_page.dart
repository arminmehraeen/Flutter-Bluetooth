import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_bluetooth/bloc/bluetooth_bloc.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({Key? key, required this.characteristics})
      : super(key: key);
  final List<BluetoothCharacteristic> characteristics;
  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter Bluetooth Message"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            const SizedBox(
              height: 15,
            ),
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: "Your Text"),
            ),
            const SizedBox(
              height: 15,
            ),
            ElevatedButton(
                onPressed: () {
                  context.read<BluetoothBloc>().add(
                      SendMessage(controller.text, widget.characteristics));
                  controller.clear();
                },
                child: const Text("send"))
          ],
        ),
      ),
    );
  }
}
