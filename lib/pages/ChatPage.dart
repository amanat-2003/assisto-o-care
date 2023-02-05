// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class ChatPage extends StatefulWidget {
  final BluetoothDevice server;

  const ChatPage({required this.server});

  @override
  _ChatPage createState() => new _ChatPage();
}

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}

class _HandData {
  int? resistanceFirst;
  int? resistanceSecond;
  int? resistanceThird;
  int? resistanceForth;
  int? resistanceThumb;
  int? resistancePalm;

  int? angleFirst;
  int? angleSecond;
  int? angleThird;
  int? angleForth;
  int? angleThumb;
  int? anglePalm;

  _HandData({
    required this.resistanceFirst,
    required this.resistanceSecond,
    required this.resistanceThird,
    required this.resistanceForth,
    required this.resistanceThumb,
    required this.resistancePalm,
    required this.angleFirst,
    required this.angleSecond,
    required this.angleThird,
    required this.angleForth,
    required this.angleThumb,
    required this.anglePalm,
  });

  _HandData.fromMessage(_Message message) {
    final re = RegExp(
        r'(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s*\n*(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)');
    // final regExp = RegExp(r'(\d+)\s+');
    var str = '0 0 0 0 0 0 0 0 0 0 0 0';
    var ifNoMatches = re.firstMatch(str);
    // print(ifNoMatches![0]);
    final matches = re.firstMatch(message.text) ?? ifNoMatches;

    resistanceFirst = int.tryParse(matches![1]!);
    resistanceSecond = int.tryParse(matches[2]!);
    resistanceThird = int.tryParse(matches[3]!);
    resistanceForth = int.tryParse(matches[4]!);
    resistanceThumb = int.tryParse(matches[5]!);
    resistancePalm = int.tryParse(matches[6]!);

    angleFirst = int.tryParse(matches[7]!);
    angleSecond = int.tryParse(matches[8]!);
    angleThird = int.tryParse(matches[9]!);
    angleForth = int.tryParse(matches[10]!);
    angleThumb = int.tryParse(matches[11]!);
    anglePalm = int.tryParse(matches[12]!);
  }
}

class _ChatPage extends State<ChatPage> {
  var isVisible = false;
  static final clientID = 0;
  BluetoothConnection? connection;

  List<_Message> messages = List<_Message>.empty(growable: true);
  String _messageBuffer = '';

  final TextEditingController textEditingController =
      new TextEditingController();
  final ScrollController listScrollController = new ScrollController();

  bool isConnecting = true;
  bool get isConnected => (connection?.isConnected ?? false);

  bool isDisconnecting = false;

  @override
  void initState() {
    super.initState();

    BluetoothConnection.toAddress(widget.server.address).then((_connection) {
      print('Connected to the device');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      connection!.input!.listen(_onDataReceived).onDone(() {
        // Example: Detect which side closed the connection
        // There should be `isDisconnecting` flag to show are we are (locally)
        // in middle of disconnecting process, should be set before calling
        // `dispose`, `finish` or `close`, which all causes to disconnect.
        // If we except the disconnection, `onDone` should be fired as result.
        // If we didn't except this (no flag set), it means closing by remote.
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
        if (this.mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
    });
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection?.dispose();
      connection = null;
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<_HandData> dataList = [
      _HandData(
          resistanceFirst: 2323,
          resistanceSecond: 2456,
          resistanceThird: 1890,
          resistanceForth: 2467,
          resistanceThumb: 2654,
          resistancePalm: 0,
          angleFirst: 32,
          angleSecond: 23,
          angleThird: 45,
          angleForth: 78,
          angleThumb: 95,
          anglePalm: 0),
      _HandData.fromMessage(_Message(1,
          '1234 2345 3456 4567 5678 0 \n\n     0 33 44 55 66 0  hi sfdljfdskdjf jgfdkshg')),
      ...messages.map((message) {
        return _HandData.fromMessage(message);
      }).toList()
    ];

    final List<Row> list = messages.map((_message) {
      return Row(
        children: <Widget>[
          Container(
            child: Text(
                (text) {
                  return text == '/shrug' ? '¯\\_(ツ)_/¯' : text;
                }(_message.text.trim()),
                style: TextStyle(color: Colors.white)),
            padding: EdgeInsets.all(12.0),
            margin: EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
            width: 222.0,
            decoration: BoxDecoration(
                color:
                    _message.whom == clientID ? Colors.blueAccent : Colors.grey,
                borderRadius: BorderRadius.circular(7.0)),
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
      );
    }).toList();

    final serverName = widget.server.name ?? "Unknown";
    return Scaffold(
      appBar: AppBar(
        title: (isConnecting
            ? Text('Connecting to ' + serverName)
            : isConnected
                ? Text('Connected to ' + serverName)
                : Text('Disconnected from ' + serverName)),
        actions: [
          FittedBox(
            child: Container(
              margin: new EdgeInsets.symmetric(vertical: 20.0, horizontal: 40),
              child: isConnecting
                  ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    )
                  : Icon(Icons.done),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Flexible(
              child: ListView(
                padding: const EdgeInsets.all(12.0),
                children: [
                  ListTile(
                    title: Text(
                      'Angles',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                          color: Theme.of(context).primaryColor),
                    ),
                    leading: Icon(Icons.back_hand_rounded,
                        color: Theme.of(context).primaryColor, size: 30),
                  ),
                  ListTile(
                    title: Text(
                      'First Finger',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
                    ),
                    leading: Icon(Icons.looks_one_outlined),
                    trailing: Text(
                      '${dataList.last.angleFirst.toString()}°',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      'Second Finger',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
                    ),
                    leading: Icon(Icons.looks_two_outlined),
                    trailing: Text(
                      '${dataList.last.angleSecond.toString()}°',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      'Third Finger',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
                    ),
                    leading: Icon(Icons.looks_3_outlined),
                    trailing: Text(
                      '${dataList.last.angleThird.toString()}°',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      'Forth Finger',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
                    ),
                    leading: Icon(Icons.looks_4_outlined),
                    trailing: Text(
                      '${dataList.last.angleForth.toString()}°',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      'Thumb',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
                    ),
                    leading: Icon(Icons.looks_5_outlined),
                    trailing: Text(
                      '${dataList.last.angleThumb.toString()}°',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      'Palm',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
                    ),
                    leading: Icon(Icons.looks_6_outlined),
                    trailing: Text(
                      '${dataList.last.anglePalm.toString()}°',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      'Resistances',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 23,
                          color: Theme.of(context).primaryColor),
                    ),
                    leading: Icon(Icons.handyman,
                        color: Theme.of(context).primaryColor, size: 23),
                    trailing: Switch(
                      value: isVisible,
                      onChanged: (val) {
                        setState(() {
                          isVisible = val;
                        });
                      },
                      materialTapTargetSize: MaterialTapTargetSize.padded,
                    ),
                  ),
                  Visibility(
                    visible: isVisible,
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(
                            'First Finger',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17),
                          ),
                          leading: Icon(Icons.looks_one_outlined, size: 20),
                          trailing: Text(
                            '${dataList.last.resistanceFirst.toString()} Ω',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                        ),
                        ListTile(
                          title: Text(
                            'Second Finger',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17),
                          ),
                          leading: Icon(Icons.looks_two_outlined, size: 20),
                          trailing: Text(
                            '${dataList.last.resistanceSecond.toString()} Ω',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                        ),
                        ListTile(
                          title: Text(
                            'Third Finger',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17),
                          ),
                          leading: Icon(Icons.looks_3_outlined, size: 20),
                          trailing: Text(
                            '${dataList.last.resistanceThird.toString()} Ω',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                        ),
                        ListTile(
                          title: Text(
                            'Forth Finger',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17),
                          ),
                          leading: Icon(Icons.looks_4_outlined, size: 20),
                          trailing: Text(
                            '${dataList.last.resistanceForth.toString()} Ω',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                        ),
                        ListTile(
                          title: Text(
                            'Thumb',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17),
                          ),
                          leading: Icon(Icons.looks_5_outlined, size: 20),
                          trailing: Text(
                            '${dataList.last.resistanceThumb.toString()} Ω',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                        ),
                        ListTile(
                          title: Text(
                            'Palm',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17),
                          ),
                          leading: Icon(Icons.looks_6_outlined, size: 20),
                          trailing: Text(
                            '${dataList.last.resistancePalm.toString()} Ω',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(13);
    if (~index != 0) {
      setState(() {
        messages.add(
          _Message(
            1,
            backspacesCounter > 0
                ? _messageBuffer.substring(
                    0, _messageBuffer.length - backspacesCounter)
                : _messageBuffer + dataString.substring(0, index),
          ),
        );
        _messageBuffer = dataString.substring(index);
      });
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }
  }

  void _sendMessage(String text) async {
    text = text.trim();
    textEditingController.clear();

    if (text.length > 0) {
      try {
        connection!.output.add(Uint8List.fromList(utf8.encode(text + "\r\n")));
        await connection!.output.allSent;

        setState(() {
          messages.add(_Message(clientID, text));
        });

        Future.delayed(Duration(milliseconds: 500)).then((_) {
          listScrollController.animateTo(
              listScrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 500),
              curve: Curves.easeOut);
        });
      } catch (e) {
        // Ignore error, but notify state
        setState(() {});
      }
    }
  }
}
