import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:logger/logger.dart';
import 'package:meta/meta.dart';

part 'bluetooth_state.dart';

class BluetoothCubit extends Cubit<BluetoothState> {
  final FlutterBluePlus bluePlus;

  BluetoothCubit({required this.bluePlus}) : super(BluetoothLoading());

  Future<void> initScan() async {
    await Future.delayed(const Duration(seconds: 2));
    bool available = await bluePlus.isAvailable;
    bool blueTooth = await bluePlus.isOn;
    Logger().w("available >> $available | blueTooth >> $blueTooth");
    List<BluetoothDevice> devices = await connectedDevices();
    emit(BluetoothMain(
        available: available, blueTooth: blueTooth, devices: devices));
  }

  Future scanDevices() async {
    bluePlus.startScan(timeout: const Duration(seconds: 10));
    bluePlus.stopScan();
  }

  Stream<List<ScanResult>> scanResults() {
    return bluePlus.scanResults;
  }

  Future<List<BluetoothDevice>> connectedDevices() async {
    List<BluetoothDevice> connectDevices = await bluePlus.connectedDevices;
    return connectDevices;
  }

  Future<void> disconnect({BluetoothDevice? device}) async {
    if (device != null) {
      await device.disconnect();
    }
    if (state is BluetoothConnectDevice) {
      await (state as BluetoothConnectDevice).device.disconnect();
    }
    emit(BluetoothLoading());
    initScan();
  }

  Future<void> read(BluetoothCharacteristic c) async {
    var sub = c.value.listen((value) {
      print("Value >> ${utf8.decode(value)}");
    });
    await c.read();
    sub.cancel();
  }

  Future<void> write(BluetoothCharacteristic c) async {
    var result = await c.write(utf8.encode("Mamad"));
    print(result);
  }

  Future deviceInfo(BluetoothDevice device) async {
    if (state is BluetoothConnectDevice) {
      List<BluetoothService> services = await device.discoverServices();
      emit(BluetoothInfoDevice(
          services: services, device: device, characteristics: []));
    } else {
      emit(BluetoothLoading());
      initScan();
    }
  }

  Future loadService(BluetoothService service) async {
    if (state is BluetoothInfoDevice) {
      BluetoothInfoDevice newState = state as BluetoothInfoDevice;
      List<BluetoothCharacteristic> characteristics = service.characteristics;
      for (BluetoothCharacteristic c in characteristics) {
        if (c.properties.read) {
          c.value.listen((value) {
            Logger().w(utf8.decode(value));
          });
          await c.read();
        }
      }
      emit(BluetoothInfoDevice(
          services: newState.services,
          device: newState.device,
          characteristics: characteristics));
    } else {
      emit(BluetoothLoading());
      initScan();
    }
  }

  Future connect(BluetoothDevice device) async {
    if (state is BluetoothMain) {
      var newState = state as BluetoothMain;

      try {
        print(device);
        await device.connect().timeout(const Duration(seconds: 10));
        print("after connect");
        emit(BluetoothConnectDevice(device: device));
        await Future.delayed(const Duration(seconds: 2));
        deviceInfo(device);
      } catch (e) {
        print("error >> $e");
        emit(BluetoothMain(
            available: newState.available,
            blueTooth: newState.blueTooth,
            devices: newState.devices));
      }
    } else {
      emit(BluetoothLoading());
      initScan();
    }

//     Logger().w("connected");
//     List<BluetoothService> services = await device.discoverServices();
//     Logger().w("service size >> ${services.length}");
//
//     var characteristics = services.last.characteristics;
//     for (BluetoothCharacteristic c in characteristics) {
//       Logger().i(c);
//     }
//     Logger().w("befor disconnect");
//     await Future.delayed(
//       const Duration(seconds: 5),
//       () async {
//         await device.disconnect();
//       },
//     );
//     Logger().w("disconnected");
// // // Disconnect from device
// //     device.disconnect();
  }
}
