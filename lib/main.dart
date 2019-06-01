import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Stack Overflow',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Stack Overflow Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //var searchResults;
  //int radioValue;

  var _futureGet;

  @override
  initState() {
    super.initState();
    _futureGet = getSearch(null);
  }
  TextEditingController textController = TextEditingController();
  
  Future<List<Question>> getSearch(String searchTerms) async {
    List<Question> list;
    String url =
        "https://api.stackexchange.com/2.2/search/advanced?pagesize=10&order=desc&sort=activity&tagged=flutter&site=stackoverflow";
    if (searchTerms != null) {
      url =
          "https://api.stackexchange.com/2.2/search/advanced?pagesize=10&order=desc&sort=activity&tagged=flutter&site=stackoverflow&title=" + searchTerms;
    }

    final response = await http.get(url);

    if (response.statusCode == 200 && response.body != null) {
      final jsonResult = json.decode(utf8.decode(response.bodyBytes));
      //var data = json.decode(response.body);
      var rest = jsonResult["items"] as List;
      list = rest.map<Question>((json) => Question.fromJson(json)).toList();
      return list;
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(child:TextField(
                    decoration: InputDecoration(
                        hintText: 'Please enter a search term'),
                  controller: textController,)),
          RaisedButton(child: Icon(Icons.search), onPressed: () {
            setState(() {
              
              _futureGet = getSearch(textController.value.text);
            });
              

          }),
                ],
              ),
          FutureBuilder<List<Question>>(
              future:
                  _futureGet,
              builder: (BuildContext context,
                  AsyncSnapshot<List<Question>> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                    return Text('Press button to start.');
                  case ConnectionState.active:
                  case ConnectionState.waiting:
                    return Text("Please wait.");
                  case ConnectionState.done:
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return ListView(
                        shrinkWrap: true,
                        children: snapshot.data.map(getQuestionItem).toList(),
                      );
                    }
                }
                return null; // unreachable
              })
        ],
      ),
    );
  }

  Widget getQuestionItem(Question question) {
    return ListTile(
      title: Text(question.title),
      trailing: RaisedButton(
          child: Icon(Icons.keyboard_arrow_right),
          onPressed: () {
            _launchUrl('https://stackoverflow.com/questions/' +
                question.question_id.toString());
          }),
      /*onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(question_id: question.question_id),
          ),
        );
                  },*/
    );
  }

  _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Não foi possível abrir: $url';
    }
  }
}

class Question {
  final int question_id;
  final String title;

  Question({
    this.question_id,
    this.title,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      question_id: json['question_id'],
      title: json['title'],
    );
  }
}
