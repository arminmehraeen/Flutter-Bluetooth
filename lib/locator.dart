import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_bluetooth/cubit/bluetooth_cubit.dart';
import 'package:get_it/get_it.dart';

GetIt locator = GetIt.instance;

setup() async {
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  locator
      .registerSingleton<BluetoothCubit>(BluetoothCubit(bluePlus: flutterBlue));
}
