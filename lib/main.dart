import 'package:data/sql.dart';
import 'package:flutter/material.dart';
import 'Notestodo.dart';

Future main() async{
  WidgetsFlutterBinding.ensureInitialized();
  SqlHelper().getDatabase();
  runApp(const Note());
}

class Note extends StatelessWidget {
  const Note({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: NotesTodo(),
    );
  }
}
