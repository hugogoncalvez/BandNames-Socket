import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:pie_chart/pie_chart.dart';

import 'package:band_names/helpers/size.dart';
import 'package:band_names/models/band.dart';
import 'package:band_names/services/socket_service.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [];
  Map<String, double> dataMap = {};

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on('active-bands', _handleActiveBands);
    super.initState();
  }

  _handleActiveBands(dynamic payload) {
    print(payload);
    bands = (payload as List).map((band) => Band.fromMap(band)).toList();
    setState(() {});
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);
    final serverStatus = socketService.serverStatus;

    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        actions: [
          Container(
              margin: EdgeInsets.only(right: context.height * 0.012),
              child: (serverStatus == ServerStatus.onLine)
                  ? Icon(Icons.check_circle, color: Colors.blue[300])
                  : Icon(Icons.offline_bolt, color: Colors.red[300]))
        ],
        title: const Text(
          'Band Names',
          style: TextStyle(color: Colors.black87),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // SizedBox(height: context.height * 0.05),
          Padding(
              padding: EdgeInsets.all(context.height * 0.03),
              child: _ShowGraph()),
          Expanded(
            child: ListView.builder(
                itemCount: bands.length,
                itemBuilder: (context, index) => _bandTile(bands[index])),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNewBand,
        child: const Icon(Icons.add),
        elevation: 1,
      ),
    );
  }

  Widget _bandTile(Band band) {
    final socketService = Provider.of<SocketService>(context, listen: false);
    return Dismissible(
      onDismissed: (_) => socketService.socket.emit('borrar', {'id': band.id}),

      background: Container(
        padding: EdgeInsets.only(left: context.height * 0.015),
        color: Colors.red,
        child: const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Borrar Banda',
              style: TextStyle(color: Colors.white),
            )),
      ),
      direction: DismissDirection.startToEnd,
      key: UniqueKey(), // Key(band.id),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Text(band.name.substring(0, 2)),
        ),
        title: Text(band.name),
        trailing: Text('${band.votes}',
            style: TextStyle(fontSize: context.height * 0.0243)),
        onTap: () => socketService.socket.emit('voto', {'id': band.id}),
      ),
    );
  }

  addNewBand() {
    final textController = TextEditingController();

    if (Platform.isAndroid) {
      return showDialog(
          context: context,
          builder: (_) => AlertDialog(
                title: const Text('New Band Name'),
                content: TextField(
                  controller: textController,
                ),
                actions: [
                  MaterialButton(
                    elevation: 5,
                    textColor: Colors.blue,
                    onPressed: () => addBandToList(textController.text),
                    child: const Text('Agregar'),
                  )
                ],
              ));
    }
    showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
              title: const Text('New Band Name'),
              content: CupertinoTextField(
                controller: textController,
              ),
              actions: [
                CupertinoDialogAction(
                  child: const Text('Agregar'),
                  isDefaultAction: true,
                  onPressed: () => addBandToList(textController.text),
                ),
                CupertinoDialogAction(
                  child: const Text('Dismiss'),
                  isDestructiveAction: true,
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ));
  }

  void addBandToList(String name) {
    final socketService = Provider.of<SocketService>(context, listen: false);
    if (name.length > 1) {
      socketService.socket.emit('nueva', {'name': name});
    }

    Navigator.pop(context);
  }

  Widget _ShowGraph() {
    Map<String, double> dataMap = {};
    for (var band in bands) {
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
    }
    final List<Color> colorList = [
      Colors.blue.withOpacity(0.5),
      Colors.blue.withOpacity(0.8),
      Colors.pink.withOpacity(0.5),
      Colors.pink.withOpacity(0.8),
      Colors.red.withOpacity(0.5),
      Colors.red.withOpacity(0.8),
      Colors.yellow.withOpacity(0.5),
      Colors.yellow.withOpacity(0.8),
    ];
    return PieChart(
      dataMap: dataMap,
      animationDuration: const Duration(milliseconds: 800),
      chartLegendSpacing: 32,
      chartRadius: context.height * 0.3,
      colorList: colorList,
      initialAngleInDegree: 0,
      chartType: ChartType.disc,
      ringStrokeWidth: 32,
      // centerText: "HYBRID",
      legendOptions: const LegendOptions(
        showLegendsInRow: false,
        legendPosition: LegendPosition.right,
        showLegends: true,
        legendShape: BoxShape.circle,
        legendTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      chartValuesOptions: const ChartValuesOptions(
        showChartValueBackground: true,
        showChartValues: true,
        showChartValuesInPercentage: false,
        showChartValuesOutside: false,
        decimalPlaces: 0,
      ),
    );
  }
}
