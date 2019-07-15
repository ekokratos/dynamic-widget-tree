import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dynamic_page_demo.dart';
import 'dart:convert';

main() async {
  runApp(RetroDemo());

//  print(jsonParsed);
//
}

class Attributes {
  String type;
  String isMandatory;
  String regex;

  Attributes({this.type, this.isMandatory, this.regex});

  Attributes.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    isMandatory = json['is_mandatory'];
    regex = json['regex'];
    print(type);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['is_mandatory'] = this.isMandatory;
    data['regex'] = this.regex;
    return data;
  }
}

class RetroDemo extends StatelessWidget {
  Future wait(int seconds) {
    return new Future.delayed(Duration(milliseconds: seconds), () => {});
  }

  Future<Attributes> _jsonList() async {
    String jsonObj;
    final dio = Dio();
    final client = RestClient(dio);
//    return client.profile();
    var jsonParsed;
    client.profile().then((it) async {
      jsonObj = it.toString();
//    print(jsonObj);
      jsonParsed = await json.decode(jsonObj.toString());
    });
    await wait(2000);
    print(jsonParsed[0]);
    return Attributes.fromJson(jsonParsed[0]);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(
        child: Scaffold(
            body: FutureBuilder<Attributes>(
          future: _jsonList(), // a previously-obtained Future<String> or null
          builder: (BuildContext context, AsyncSnapshot<Attributes> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return Text('Press button to start.');
              case ConnectionState.active:
              case ConnectionState.waiting:
                return Text('Awaiting result...');
              case ConnectionState.done:
                if (snapshot.hasError) return Text('Error: ${snapshot.error}');
                return RetroDemoWidget(snapshot: snapshot);
            }
            return null; // unreachable
          },
        )),
      ),
    );
  }
}

class RetroDemoWidget extends StatefulWidget {
  final AsyncSnapshot snapshot;
  RetroDemoWidget({this.snapshot});
  @override
  _RetroDemoWidgetState createState() => _RetroDemoWidgetState();
}

class _RetroDemoWidgetState extends State<RetroDemoWidget> {
  bool _autoValidate = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  void _validateInputs() {
    if (_formKey.currentState.validate()) {
      //If all data are correct then save data to out variables
      _formKey.currentState.save();
    } else {
      //If all data are not valid then start auto validation.
      setState(() {
        _autoValidate = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidate: _autoValidate,
      child: ListView(
        children: <Widget>[
          if (widget.snapshot.data.type == 'Text')
            Center(
              child: TextFormField(
//                maxLength: 10,
                decoration:
                    InputDecoration(labelText: widget.snapshot.data.type),
                validator: (value) {
                  Pattern numPattern = r'^[0-9]{10}$';
                  RegExp regex = new RegExp(numPattern);
                  if (!regex.hasMatch(value))
                    return 'Enter Valid Phone Number';
                  else
                    return null;
                },
                onSaved: (value) {
                  print(value);
                },
              ),
            ),
          FlatButton(
            child: Text('Submit'),
            onPressed: _validateInputs,
          )
        ],
      ),
    );
  }
}
