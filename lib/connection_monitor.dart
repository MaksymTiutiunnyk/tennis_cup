import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectionMonitor extends StatefulWidget {
  final Widget child;

  const ConnectionMonitor({required this.child, super.key});

  @override
  State<ConnectionMonitor> createState() => _ConnectionMonitorState();
}

class _ConnectionMonitorState extends State<ConnectionMonitor> {
  late Stream<ConnectivityResult> _connectivityStream;
  late Connectivity _connectivity;
  bool _isDisconnected = false;

  @override
  void initState() {
    super.initState();
    _connectivity = Connectivity();

    _connectivityStream = _connectivity.onConnectivityChanged
        .map((connectivityList) => connectivityList.first);
  }

  void _showNoConnectionModal(BuildContext context) {
    if (!_isDisconnected) {
      _isDisconnected = true;
      showModalBottomSheet(
        context: context,
        isDismissible: false,
        enableDrag: false,
        isScrollControlled: true,
        backgroundColor: Colors.red[400],
        builder: (context) {
          return PopScope(
            canPop: false,
            child: SizedBox(
              height: 100,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off, size: 32, color: Colors.white),
                    const SizedBox(height: 8),
                    Text(
                      'No Internet Connection',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }
  }

  void _closeNoConnectionModal(BuildContext context) {
    if (_isDisconnected) {
      _isDisconnected = false;
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ConnectivityResult>(
      stream: _connectivityStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final connectivityResult = snapshot.data;

          final hasInternet = connectivityResult == ConnectivityResult.mobile ||
              connectivityResult == ConnectivityResult.wifi;

          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            if (!hasInternet) {
              _showNoConnectionModal(context);
            } else {
              _closeNoConnectionModal(context);
            }
          });
        }

        return widget.child;
      },
    );
  }
}
