import 'package:flutter/material.dart';

void openDialog (context, String title, String message){
  showDialog(
    context: context,
    
    builder: (BuildContext context){
      return AlertDialog(
        content: Text(message),
        title: Text(title),
        surfaceTintColor: Theme.of(context).colorScheme.background,
        actions: <Widget>[
          TextButton(
            onPressed: (){
              Navigator.pop(context);
            }, 
            child: const Text('OK'))
        ],

      );
    }
    
    );
}
