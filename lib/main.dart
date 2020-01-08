import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(MaterialApp(
      home: TaskApp(),
    ));

class TaskApp extends StatefulWidget {
  @override
  _TaskAppState createState() => _TaskAppState();
}

class _TaskAppState extends State<TaskApp> {
  final taskController = TextEditingController();
  List _ToDoList = [];
  Map<String, dynamic> removedItens = Map();
  int positionOfItemRemoved;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("TaskApp"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 8.0, right: 8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: taskController,
                    decoration: InputDecoration(
                        labelText: "Task",
                        labelStyle: TextStyle(
                            color: Colors.deepPurple, fontSize: 20.0)),
                    style: TextStyle(color: Colors.black, fontSize: 25.0),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20.0, left: 10.0),
                  child: RaisedButton(
                    onPressed: addTask,
                    color: Colors.deepPurple,
                    textColor: Colors.white,
                    child: Text("Adicionar"),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
                padding: EdgeInsets.only(top: 20.0),
                child: RefreshIndicator(
                  onRefresh: refreshTasks,
                  child: ListView.builder(
                    itemCount: _ToDoList.length,
                    itemBuilder: buildListItem,
                  ),
                )),
          )
        ],
      ),
    );
  }

  Future<File> getAndroidOriOSDirectory() async {
    final getdirectory = await getApplicationDocumentsDirectory();

    return File("${getdirectory.path}/data.json");
  }

  Future<File> savedata() async {
    String data = json.encode(_ToDoList);
    final file = await getAndroidOriOSDirectory();

    return file.writeAsString(data);
  }

  Future<String> getSavedData() async {
    try {
      final file = await getAndroidOriOSDirectory();

      return file.readAsString();
    } catch (e) {
      return "a";
    }
  }

  Future<Null> refreshTasks() async {
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      _ToDoList.sort((first, second) {
        if (first["checked"] && !second["checked"])
          return 1;
        else if (!first["checked"] && second["checked"])
          return -1;
        else
          return 0;
      });

      savedata();
    });
  }

  Widget buildListItem(context, index) {
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(-0.9, 0.0),
          child: Icon(Icons.delete, color: Colors.white),
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        onChanged: (value) {
          setState(() {
            _ToDoList[index]["checked"] = value;
            savedata();
          });
        },
        title: Text(_ToDoList[index]["title"]),
        value: _ToDoList[index]["checked"],
        secondary: CircleAvatar(
          child: Icon(_ToDoList[index]["checked"] ? Icons.check : Icons.error),
        ),
      ),
      onDismissed: (direction) {
        setState(() {
          removedItens = Map.from(_ToDoList[index]);
          positionOfItemRemoved = index;
          _ToDoList.removeAt(index);

          savedata();

          final snack = SnackBar(
            content: Text("Item \"${removedItens["title"]}\" removido!"),
            action: SnackBarAction(
              label: "Desfazer",
              onPressed: () {
                setState(() {
                  _ToDoList.insert(positionOfItemRemoved, removedItens);
                  savedata();
                });
              },
            ),
            duration: Duration(seconds: 2),
          );
          Scaffold.of(context).showSnackBar(snack);
        });
      },
    );
  }

  void addTask() {
    setState(() {
      Map<String, dynamic> newtask = Map();
      newtask["title"] = taskController.text;
      newtask["checked"] = false;
      taskController.text = "";
      _ToDoList.add(newtask);
      savedata();
    });
  }

  @override
  void initState() {
    super.initState();
    getSavedData().then((data) {
      setState(() {
        _ToDoList = json.decode(data);
      });
    });
  }
}
