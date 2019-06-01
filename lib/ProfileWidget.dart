import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:github/server.dart';

class ProfileWidget extends StatelessWidget {
  GitHub github;

  ProfileWidget();

  GitHub createClient(String token) {
    return GitHub(auth: Authentication.withToken(token));
  }

  Widget build(context) {
    return new Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(3.0),
        child: new FutureBuilder(
            future: createClient("7886861c4a62930064773d6093770fc3e1cf766d")
                .users.getCurrentUser(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data != null) {
                  return new Column(
                    children: <Widget>[
                      new Expanded(
                          child: new ListView(
                        children: _getData(snapshot),
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

  List<Widget> _getData(AsyncSnapshot snapshot) {

    var v = snapshot.data.bio;

    List<Widget> widgets = <Widget>[
      Text(
        'Hello my BIO is, $v !',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold),
      )
    ];
    return widgets;
  }
}
