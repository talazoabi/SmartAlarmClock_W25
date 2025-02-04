import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';

class ConnectivityService {
  ConnectivityService._();
  static final ConnectivityService instance = ConnectivityService._();
  factory ConnectivityService() => instance;

  final _connectivity = Connectivity();
  final StreamController<bool> _connectionStatusController =
  StreamController<bool>.broadcast();

  Stream<bool> get connectionStatusStream =>
      _connectionStatusController.stream;

  void initialize() {
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      _connectionStatusController.add(_isConnected(result));
    });
  }

  bool _isConnected(ConnectivityResult result) {
    return result == ConnectivityResult.mobile || result == ConnectivityResult.wifi;
  }

  Future<bool> isConnected() async {
    var connectivityResult = await _connectivity.checkConnectivity();
    return _isConnected(connectivityResult);
  }

  void dispose() {
    _connectionStatusController.close();
  }

  void checkConnectionManually() async {
    final result = await _connectivity.checkConnectivity();
    _connectionStatusController.add(_isConnected(result));
  }
}

class ConnectivityWrapper extends StatelessWidget {
  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;
  ConnectivityWrapper({required this.child, required this.navigatorKey});
  bool _isDialogVisible = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: ConnectivityService().connectionStatusStream,
      initialData: true,
      builder: (context, snapshot) {
        final isConnected = snapshot.data ?? true;
        print('ConnectivityWrapper: isConnected = $isConnected');
        if (!isConnected) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_isDialogVisible) return;
            print('Attempting to show the No Internet dialog...');
            _isDialogVisible = true;

            showDialog(
              context: navigatorKey.currentContext!,
              barrierDismissible: false,
              builder: (dialogContext) => AlertDialog(
                title: Text('No Internet Connection'),
                content: Text('Please check your internet connection and try again.'),
                actions: [
                  TextButton(
                    onPressed: () async {
                      ConnectivityService().checkConnectionManually();

                      if (await ConnectivityService().isConnected()) {
                        Navigator.pop(dialogContext);
                        _isDialogVisible = false;
                      }
                    },
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          });
        }
        return child;
      },
    );
  }
}