part of 'bluetooth_bloc.dart';

@immutable
abstract class BluetoothState {}

class BluetoothInitial extends BluetoothState {}

class BluetoothNotAvailable extends BluetoothState {}

class BluetoothNotAccess extends BluetoothState {}

class BluetoothNotConnected extends BluetoothState {
  final Stream<List<ScanResult>> stream;
  final List<BluetoothDevice> devices;
  BluetoothNotConnected(
    this.stream,
    this.devices,
  );
}

class BluetoothConnected extends BluetoothState {
  final BluetoothDevice device;
  final List<BluetoothService> services;
  BluetoothConnected(this.device, this.services);
}
