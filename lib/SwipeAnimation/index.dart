import 'dart:async';
import '../SwipeAnimation/data.dart';
import '../SwipeAnimation/dummyCard.dart';
import '../SwipeAnimation/activeCard.dart';

import 'package:github/server.dart';
//import 'package:animation_exp/PageReveal/page_main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;

class CardDemo extends StatefulWidget {
  @override
  CardDemoState createState() => new CardDemoState();
}

class CardDemoState extends State<CardDemo> with TickerProviderStateMixin {
  AnimationController _buttonController;
  Animation<double> rotate;
  Animation<double> right;
  Animation<double> bottom;
  Animation<double> width;
  int flag = 0;

  List data = imageData;
  List selectedData = [];
  initState() {
    super.initState();

     search('').then((values) {
       for (var it in values){
         DecorationImage img = new DecorationImage(
           image: new NetworkImage(it['avatar_url']),
           fit: BoxFit.cover,
         );

         setState(() {
           data.add(img);
         });
       }

     });




      _buttonController = new AnimationController(
        duration: new Duration(milliseconds: 1000), vsync: this);

    rotate = new Tween<double>(
      begin: -0.0,
      end: -40.0,
    ).animate(
      new CurvedAnimation(
        parent: _buttonController,
        curve: Curves.ease,
      ),
    );
    rotate.addListener(() {
      setState(() {
        if (rotate.isCompleted) {
          var i = data.removeLast();
          data.insert(0, i);

          _buttonController.reset();
        }
      });
    });

    right = new Tween<double>(
      begin: 0.0,
      end: 400.0,
    ).animate(
      new CurvedAnimation(
        parent: _buttonController,
        curve: Curves.ease,
      ),
    );
    bottom = new Tween<double>(
      begin: 15.0,
      end: 100.0,
    ).animate(
      new CurvedAnimation(
        parent: _buttonController,
        curve: Curves.ease,
      ),
    );
    width = new Tween<double>(
      begin: 20.0,
      end: 25.0,
    ).animate(
      new CurvedAnimation(
        parent: _buttonController,
        curve: Curves.bounceOut,
      ),
    );
  }

  @override
  void dispose() {
    _buttonController.dispose();
    super.dispose();
  }

  Future<Null> _swipeAnimation() async {
    try {
      await _buttonController.forward();
    } on TickerCanceled {}
  }

  dismissImg(DecorationImage img) {
    setState(() {
      data.remove(img);
    });
  }

  addImg(DecorationImage img) {
    setState(() {
      data.remove(img);
      selectedData.add(img);
    });
  }

  swipeRight() {
    if (flag == 0)
      setState(() {
        flag = 1;
      });
    _swipeAnimation();
  }

  swipeLeft() {
    if (flag == 1)
      setState(() {
        flag = 0;
      });
    _swipeAnimation();
  }

  @override
  Widget build(BuildContext context) {
    timeDilation = 0.4;

    double initialBottom = 15.0;
    var dataLength = data.length;
    double backCardPosition = initialBottom + (dataLength - 1) * 10 + 10;
    double backCardWidth = -10.0;
    return (new Scaffold(
        appBar: new AppBar(
          elevation: 0.0,
          backgroundColor: new Color.fromRGBO(7,91,154, 1.0),
          centerTitle: true,
          // leading: new Container(
          //   margin: const EdgeInsets.all(15.0),
          //   child: new Icon(
          //     Icons.equalizer,
          //     color: Colors.cyan,
          //     size: 30.0,
          //   ),
          // ),
          actions: <Widget>[
            new GestureDetector(
              onTap: () {
                // Navigator.push(
                //     context,
                //     new MaterialPageRoute(
                //         builder: (context) => new PageMain()));
              },
              child: new Container(
                  margin: const EdgeInsets.all(15.0),
                  child: new Icon(
                    Icons.person_outline,
                    color: Colors.white,
                    size: 30.0,
                  )),
            ),
          ],
          title: new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text(
                "Flutter Connect",
                style: new TextStyle(
                    fontSize: 12.0,
                    letterSpacing: 3.5,
                    fontWeight: FontWeight.bold),
              ),
              new Container(
                width: 15.0,
                height: 15.0,
                margin: new EdgeInsets.only(bottom: 20.0),
                alignment: Alignment.center,
                child: new Text(
                  dataLength.toString(),
                  style: new TextStyle(fontSize: 10.0),
                ),
                decoration: new BoxDecoration(
                    color: Colors.red, shape: BoxShape.circle),
              )
            ],
          ),
        ),
        body: new Container(

          // TO DO: Make this a gradient
          // Main Background
          color: new Color.fromRGBO(7,91,154, 1.0),
          alignment: Alignment.center,
          child: dataLength > 0
              ? new Stack(
                  alignment: AlignmentDirectional.center,
                  children: data.map((item) {
                    if (data.indexOf(item) == dataLength - 1) {
                      return cardDemo(
                          item,
                          bottom.value,
                          right.value,
                          0.0,
                          backCardWidth + 10,
                          rotate.value,
                          rotate.value < -10 ? 0.1 : 0.0,
                          context,
                          dismissImg,
                          flag,
                          addImg,
                          swipeRight,
                          swipeLeft);
                    } else {
                      backCardPosition = backCardPosition - 10;
                      backCardWidth = backCardWidth + 10;

                      return cardDemoDummy(item, backCardPosition, 0.0, 0.0,
                          backCardWidth, 0.0, 0.0, context);
                    }
                  }).toList())
              : new Text("No Event Left",
                  style: new TextStyle(color: Colors.white, fontSize: 50.0)),
        )));
  }



  GitHub github;

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
            perPage: 6,
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
      return gitusers;
    } else {
      print("users already present");
      return gitusers;
    }
  }

}
