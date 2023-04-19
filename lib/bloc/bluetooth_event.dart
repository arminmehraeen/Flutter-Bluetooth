part of 'bluetooth_bloc.dart';

@immutable
abstract class BluetoothEvent {}

class BluetoothCheck extends BluetoothEvent {}

class BluetoothScan extends BluetoothEvent {}

class BluetoothConnect extends BluetoothEvent {
  final BluetoothDevice device;
  BluetoothConnect(this.device);
}

class BluetoothDisconnect extends BluetoothEvent {
  final BluetoothDevice device;
  BluetoothDisconnect(this.device);
}

class SendMessage extends BluetoothEvent {
  final List<BluetoothCharacteristic> characteristics;
  final String message;
  SendMessage(this.message, this.characteristics);
}
