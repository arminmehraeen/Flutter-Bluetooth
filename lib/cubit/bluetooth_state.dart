part of 'bluetooth_cubit.dart';

@immutable
abstract class BluetoothState {}

class BluetoothLoading extends BluetoothState {
  BluetoothLoading();
}

class BluetoothMain extends BluetoothState {
  final bool available;
  final bool blueTooth;
  final List<BluetoothDevice> devices;
  BluetoothMain(
      {required this.available,
      required this.blueTooth,
      required this.devices});
}

class BluetoothConnectDevice extends BluetoothState {
  final BluetoothDevice device;
  BluetoothConnectDevice({required this.device});
}

class BluetoothInfoDevice extends BluetoothState {
  final List<BluetoothService> services;
  final List<BluetoothCharacteristic> characteristics;
  final BluetoothDevice device;
  BluetoothInfoDevice(
      {required this.services,
      required this.device,
      required this.characteristics});
}
