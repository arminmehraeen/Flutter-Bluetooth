import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:logger/logger.dart';
import 'package:meta/meta.dart';

part 'bluetooth_event.dart';
part 'bluetooth_state.dart';

class BluetoothBloc extends Bloc<BluetoothEvent, BluetoothState> {
  final FlutterBluePlus bluePlus;

  BluetoothBloc(this.bluePlus) : super(BluetoothInitial()) {
    on<BluetoothCheck>((event, emit) async {
      emit(BluetoothInitial());

      await Future.delayed(const Duration(seconds: 1));

      bool isAvailable = await bluePlus.isAvailable;
      if (!isAvailable) {
        emit(BluetoothNotAvailable());
      }

      bool isOn = await bluePlus.isOn;
      if (!isOn) {
        emit(BluetoothNotAccess());
      }

      if (isOn && isAvailable) {
        List<BluetoothDevice> devices = await bluePlus.connectedDevices;
        print(devices);
        emit(BluetoothNotConnected(bluePlus.scanResults, devices));
      }
    });

    on<BluetoothScan>((event, emit) async {
      bluePlus.startScan(timeout: const Duration(seconds: 10));
      bluePlus.stopScan();
    });

    on<BluetoothConnect>((event, emit) async {
      try {
        await event.device.connect().timeout(const Duration(seconds: 10));
        List<BluetoothService> services = await event.device.discoverServices();
        emit(BluetoothConnected(event.device, services));
      } catch (e) {
        Logger().e("Bluetooth connected error");
      }
    });

    on<BluetoothDisconnect>((event, emit) async {
      try {
        await event.device.disconnect();
        emit(BluetoothInitial());
        await Future.delayed(const Duration(seconds: 1));
        add(BluetoothCheck());
      } catch (e) {
        Logger().e("Bluetooth disconnected error");
      }
    });

    on<SendMessage>((event, emit) async {
      final List<BluetoothCharacteristic> characteristics =
          event.characteristics;
      BluetoothCharacteristic readBlue =
          characteristics.where((element) => element.properties.read).first;
      BluetoothCharacteristic writeBlue =
          characteristics.where((element) => element.properties.write).first;

      await writeBlue.write(utf8.encode(event.message));
      await writeBlue.write(utf8.encode(event.message));

      await Future.delayed(const Duration(seconds: 2));
      // var sub = readBlue.value.listen((value) {
      //   String word = utf8.decode(value);
      //   Logger().w("Value >> ${word}");
      // });
      List<int> value = await readBlue.read();
      String word = utf8.decode(value);
      Logger().w("Value >> $word");
    });
  }
}
