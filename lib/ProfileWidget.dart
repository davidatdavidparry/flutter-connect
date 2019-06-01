import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:github/server.dart';

class ProfileWidget extends StatelessWidget {
  GitHub github;

  ProfileWidget();

  GitHub createClient() {
    if (github == null) {
      try {
        github = GitHub(
            auth: Authentication.withToken(
                "317ec63f8e11acca1f9ddf36eebaa3d97e3b208b"));
      } catch (exception, stackTrace) {
        print("Excpetion occured ${exception}");
      }
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
    List<String> users = snapshot.data;
    List<Widget> widgets = new List();
    print('usrsCnt : $users');
    if(users != null) {
      widgets = <Widget>[
        Image.network(
          users
              .elementAt(0),
        )
      ];
    } else {
      widgets = <Widget>[
        Text('List null')
      ];
    }
    return widgets;
  }

  Future<List<String>> search(_) async {
    List<String> users = new List();
    List<String> searchItems = new List();
    var github = createClient();
    if(github != null) {
      Stream<CodeSearchResults> resultsStream = createClient().search.code(
        'github',
        language: 'flutter',
        perPage: 10,
        pages: 1,
      );

      await for (var results in resultsStream) {
        print('results: $results ');
        for (CodeSearchItem item in results.items) {
          var login = item.repository.owner.login;
          var id = item.repository.owner.id.toString();
          print('item: $item ');
          print("adding user login id $login");
          searchItems.add(login);
        }
      }
    }

    if(searchItems.isNotEmpty) {
      var github = createClient();
      if(github != null) {
        Stream<User> usersStreams = await createClient().users.getUsers(
            searchItems);
        await for (var resultUser in usersStreams) {
          print("adding user to the list $resultUser ");
          users.add(resultUser.avatarUrl);
        }
      }
    }

    return users;
  }
}
