import 'dart:io';

import 'package:band_names/helpers/size.dart';
import 'package:band_names/models/band.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [
    Band(id: '1', name: 'Metallica', votes: 5),
    Band(id: '2', name: 'Soda Stereo', votes: 15),
    Band(id: '3', name: 'Virus', votes: 5),
    Band(id: '4', name: 'Depeche Mode', votes: 10),
    Band(id: '5', name: 'U2', votes: 5),
    Band(id: '6', name: 'The Cure', votes: 5),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: const Text(
          'Band Names',
          style: TextStyle(color: Colors.black87),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: ListView.builder(
          itemCount: bands.length,
          itemBuilder: (context, index) => _bandTile(bands[index])),
      floatingActionButton: FloatingActionButton(
        onPressed: addNewBand,
        child: const Icon(Icons.add),
        elevation: 1,
      ),
    );
  }

  Widget _bandTile(Band band) {
    return Dismissible(
      onDismissed: (direction) {
        print('direccion: $direction');

        print('id: ${band.id}');
      },
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
        onTap: () {},
      ),
    );
  }

  addNewBand() {
    final textController = TextEditingController();

    if (Platform.isAndroid) {
      return showDialog(
        context: context,
        builder: (contex) {
          return AlertDialog(
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
          );
        },
      );
    }
    showCupertinoDialog(
        context: context,
        builder: (_) {
          return CupertinoAlertDialog(
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
          );
        });
  }

  void addBandToList(String name) {
    if (name.length > 1) {
      this.bands.add(Band(id: DateTime.now().toString(), name: name, votes: 0));
      setState(() {});
    }

    Navigator.pop(context);
  }
}
