import 'package:data/sql.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

class NotesTodo extends StatefulWidget {
  const NotesTodo({super.key});

  @override
  State<NotesTodo> createState() => _NotesTodoState();
}

class _NotesTodoState extends State<NotesTodo> {
  TextEditingController titlecontroller = TextEditingController();
  TextEditingController contentcontroller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: () {
              SqlHelper().deleteAllNotes();
              SqlHelper().deleteAllTodo().whenComplete(
                    () => setState(
                      () {},
                    ),
                  );
            },
            icon: const Icon(Icons.delete),
          )
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder(
                future: SqlHelper().loadNote(),
                builder:
                    (BuildContext context, AsyncSnapshot<List<Map>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return Dismissible(
                          key: UniqueKey(),
                          onDismissed: (direction) {
                            SqlHelper().deleteNote(snapshot.data![index]['id']);
                          },
                          child: Card(
                            color: Colors.purpleAccent,
                            child: Column(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    showEditNote(
                                      context,
                                      snapshot.data![index]['title'],
                                      snapshot.data![index]['content'],
                                      snapshot.data![index]['id'],
                                    );

                                  },
                                  icon: const Icon(Icons.edit),
                                ),
                                Text(
                                  ("id : ") +
                                      (snapshot.data![index]['id']).toString(),
                                ),
                                Text(
                                  ("title : ") +
                                      (snapshot.data![index]['title'])
                                          .toString(),
                                ),
                                Text(
                                  ("content : ") +
                                      (snapshot.data![index]['content'])
                                          .toString(),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
            Expanded(
              child: FutureBuilder(
                future: SqlHelper().loadTodo(),
                builder:
                    (BuildContext context, AsyncSnapshot<List<Map>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        bool isDone =
                            snapshot.data![index]['value'] == 0 ? false : true;
                        return Card(
                          color: isDone ? Colors.green : Colors.purpleAccent,
                          child: Row(
                            children: [
                              Checkbox(
                                value: isDone,
                                onChanged: (bool? value) {
                                  SqlHelper()
                                      .updatetodo(snapshot.data![index]['id'],
                                          snapshot.data![index]['value'])
                                      .whenComplete(() => setState(() {}));
                                },
                              ),
                              Text(
                                '${(
                                  snapshot.data![index]['title'].toString(),
                                )}',
                                style: TextStyle(
                                  color: isDone ? Colors.white : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            tooltip: 'Increment',
            onPressed: () {
              showinsertNote(context);
            },
            backgroundColor: Colors.purpleAccent,
            child: const Icon(Icons.add),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: FloatingActionButton(
              tooltip: 'Increment',
              onPressed: () {
                showinserttodo(context);
              },
              backgroundColor: Colors.green,
              child: const Icon(Icons.add),
            ),
          )
        ],
      ),
    );
  }

  void showinsertNote(context) {
    showCupertinoDialog(
      context: context,
      builder: (_) {
        return Material(
          color: Colors.white.withOpacity(0.3),
          child: CupertinoAlertDialog(
            title: const Text("Add new note"),
            content: Column(
              children: [
                TextField(
                  controller: titlecontroller,
                ),
                TextField(
                  controller: contentcontroller,
                ),
              ],
            ),
            actions: <CupertinoDialogAction>[
              CupertinoDialogAction(
                child: const Text("No"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              CupertinoDialogAction(
                child: const Text("Yes"),
                onPressed: () {
                  SqlHelper()
                      .insertNote(
                        Note(
                            title: titlecontroller.text,
                            content: contentcontroller.text),
                      )
                      .whenComplete(
                        () => setState(
                          () {
                            titlecontroller.text = '';
                            contentcontroller.text = '';
                          },
                        ),
                      );
                  titlecontroller.clear();
                  contentcontroller.clear();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void showinserttodo(context) {
    showCupertinoDialog(
      context: context,
      builder: (_) {
        return Material(
          color: Colors.white.withOpacity(0.3),
          child: CupertinoAlertDialog(
            title: const Text("Add new todo"),
            content: Column(
              children: [
                TextField(
                  controller: titlecontroller,
                ),
              ],
            ),
            actions: <CupertinoDialogAction>[
              CupertinoDialogAction(
                child: const Text("No"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              CupertinoDialogAction(
                child: const Text("Yes"),
                onPressed: () {
                  SqlHelper()
                      .insertTodo(
                        Todo(
                          title: titlecontroller.text,
                        ),
                      )
                      .whenComplete(
                        () => setState(
                          () {
                            titlecontroller.text = '';
                          },
                        ),
                      );
                  titlecontroller.clear();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void showEditNote(context, String titleInit, String contentInit, int id) {
    showCupertinoDialog(
      context: context,
      builder: (_) {
        return Material(
          color: Colors.white.withOpacity(0.3),
          child: CupertinoAlertDialog(
            title: const Text("Edit note"),
            content: Column(
              children: [
                TextFormField(
                  initialValue: titleInit,
                  onChanged: (value) {
                    titleInit = value;
                  },
                ),
                TextFormField(
                  initialValue: contentInit,
                  onChanged: (value) {
                    contentInit = value;
                  },
                ),
              ],
            ),
            actions: <CupertinoDialogAction>[
              CupertinoDialogAction(
                child: const Text("No"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              CupertinoDialogAction(
                child: const Text("Yes"),
                onPressed: () {
                  SqlHelper()
                      .updateNote(
                        Note(title: titleInit, content: contentInit, id: id),
                      )
                      .whenComplete(
                        () => setState(
                          () {},
                        ),
                      );
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
