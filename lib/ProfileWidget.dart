import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:github/server.dart';
import 'dart:developer';

class ProfileWidget extends StatelessWidget {


  GitHub github;

  ProfileWidget();

  GitHub createClient(String token) {
    return GitHub(auth: Authentication.withToken(token));
  }

  Widget build(context) {
    //search('here is value');

   // createClient("3f4c94454acc3438ac23c7f45c3a92026e7c6d69").users.getCurrentUser()

    return new Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(3.0),
        child: new FutureBuilder(
            future: search(''),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data != null) {
                  return new Column(
                    children: <Widget>[
                      new Expanded(
                          child: new ListView(
                        children:_getDataProjectUsers(snapshot),
                      ))
                    ],
                  );
                } else {
                  return new Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Waiting'
                      ));
                }
              }
            }));
  }

  List<Widget> _getDataUser(AsyncSnapshot snapshot) {

    var v = snapshot.data.bio;

    debugPrint('bio : $v');

    List<Widget> widgets = <Widget>[
      Text(
        'BIO data is, $v !',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold),
      )
    ];
    return widgets;
  }

  List<Widget> _getDataProjectUsers(AsyncSnapshot snapshot) {
    var v = snapshot.data;

    debugPrint('bio : $v');

    List<Widget> widgets = <Widget>[
      Text(
        'BIO data is, $v !',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold),
      )
    ];
    return widgets;
  }





  Future<String> search(_) async {
    debugPrint('here: $_');


    Stream<CodeSearchResults> resultsStream = createClient("84f0906d2e9912da328bf65bfec40cfe0a7f9267").search.code(
      'github',
      language: 'dart,flutter',
        perPage: 5, pages: 5,
    );

    int count = 0;
    await for (var results in resultsStream) {
      debugPrint('results: $results ');
      for (CodeSearchItem item in results.items) {
        debugPrint('item: $item ');

      }
    }

    return 'here';
  }



}
