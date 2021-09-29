import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:band_names/services/socket_service.dart';

class StatusPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);
    final emit = socketService.emit;
    final socket = socketService.socket;
   

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              alignment: Alignment.center,
              child: Text('Server Starus: ${socketService.serverStatus}'))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          emit('emitir-mensaje',
              {'nombre': 'Flutter', 'mensaje': 'Hola desde Flutter'});
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
