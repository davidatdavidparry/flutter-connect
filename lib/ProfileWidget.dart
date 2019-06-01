import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:github/server.dart';

class ProfileWidget extends StatelessWidget {
  GitHub github;

  ProfileWidget();

  GitHub createClient() {
    if (github == null) {
      github = GitHub(auth: Authentication.withToken("3f61d11baf9d4eb00119ba2c7bd4c62bd04de788"));
    }
    return github;
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
                        children: _getDataProjectUsers(snapshot),
                      ))
                    ],
                  );
                } else {
                  return new Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Waiting'));
                }
              }
            }));
  }

  List<Widget> _getDataUser(AsyncSnapshot snapshot) {
    var v = snapshot.data.bio;

    print('bio : $v');

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
   List<User> users = snapshot.data;

    print('usrsCnt : $users');

    List<Widget> wid = <Widget>[
      Text(
        'BIO data is, $users !',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold),
      )
    ];



    List<Widget> widgets = <Widget>[
    Image.network( users.elementAt(0).avatarUrl.toString(),
    )];
    return widgets;
  }

  Future<List<User>> search(_) async {
    print('here: $_');

    List<User> users = new List();

    Map map = new Map<String, User>();
    Stream<CodeSearchResults> resultsStream =
        createClient().search.code(
              'github',
              language: 'flutter',
              perPage: 10,
              pages: 1,
            );

    int count = 0;
    await for (var results in resultsStream) {
      print('results: $results ');
      for (CodeSearchItem item in results.items) {
        var login = item.repository.owner.login;
        var id = item.repository.owner.id.toString() ;
        print('item: $item ');
        //map[id] = item;
        print("calling to a user $login");
        User u =  await createClient().users.getUser(login);
        users.add(u);
      }
    }

    return users;
  }
}
