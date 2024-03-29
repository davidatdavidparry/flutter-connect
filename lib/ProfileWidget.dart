import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:github/server.dart';

class ProfileWidget extends StatelessWidget {
  GitHub github;
  List<Map<String, dynamic>> gitusers = null;

  ProfileWidget();

  GitHub createClient() {
    if (github == null) {
      try {
        github = GitHub(
            auth: Authentication.withToken(
                "1d15249042f07d8849b0cea5d32ee5eba9faadef"));
      } catch (exception, stackTrace) {
        print("Excpetion occured ${exception}");
      }
    }
    return github;
  }

  Widget build(context) {
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

  List<Widget> _getDataProjectUsers(AsyncSnapshot snapshot) {
    List<Map<String, dynamic>> users = snapshot.data;
    List<Widget> widgets = new List();
    print('usrsCnt : $users');
    if (users != null) {
      widgets = <Widget>[
        Image.network(
          users.elementAt(0)['avatar_url'],
        )
      ];
    } else {
      widgets = <Widget>[Text('List null')];
    }
    return widgets;
  }

  Future<List<Map<String, dynamic>>> search(_) async {
    if (gitusers == null) {
      List<Map<String, dynamic>> users = new List();
      List<String> searchItems = new List();
      var github = createClient();
      if (github != null) {
        try {
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
        } catch (exception, stackTrace) {
          print("Excpetion occured ${exception}");
        }

        try {
          if (searchItems.isNotEmpty) {
            var github = createClient();
            if (github != null) {
              Stream<User> usersStreams =
              await createClient().users.getUsers(searchItems);
              await for (var resultUser in usersStreams) {
                print("adding user to the list $resultUser ");
                Map _map = resultUser.toJson();
                _map['user_image'] =  new DecorationImage(
                  image: new NetworkImage(_map['avatar_url']),
                  fit: BoxFit.cover,
                );
                users.add(_map);
              }
            }
          }
        } catch (exception, stackTrace) {
          print("Excpetion occured ${exception}");
        }
      }
      gitusers = users;
      return users;
    } else {
      return gitusers;
    }
  }
}
