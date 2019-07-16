import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dynamic_page_demo.dart';
import 'dart:convert';
import 'attributes.dart';

main() async {
  runApp(RetroDemo());
}

class RetroDemo extends StatelessWidget {
  Future<List<Attributes>> _jsonList() async {
    final dio = Dio();
    final client = RestClient(dio);
    var jsonParsed;
    final res = await client.profile();
    jsonParsed = json.decode(res.toString());
    final parsed = jsonParsed.cast<Map<String, dynamic>>();
    print(jsonParsed[4]);
    return parsed.map<Attributes>((json) => Attributes.fromJson(json)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(
        child: Scaffold(
            body: FutureBuilder<List<Attributes>>(
          future: _jsonList(), // a previously-obtained Future<String> or null
          builder:
              (BuildContext context, AsyncSnapshot<List<Attributes>> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return Text('Press button to start.');
              case ConnectionState.active:
              case ConnectionState.waiting:
                return Center(child: CircularProgressIndicator());
              case ConnectionState.done:
                if (snapshot.hasError) return Text('Error: ${snapshot.error}');
                return RetroDemoWidget(data: snapshot.data);
            }
            return null; // unreachable
          },
        )),
      ),
    );
  }
}

class RetroDemoWidget extends StatefulWidget {
  final List<Attributes> data;
  RetroDemoWidget({this.data});

  @override
  _RetroDemoWidgetState createState() => _RetroDemoWidgetState();
}

class _RetroDemoWidgetState extends State<RetroDemoWidget> {
  bool _autoValidate = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String updatedValue;
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
    return SafeArea(
      child: Form(
        key: _formKey,
        autovalidate: _autoValidate,
        child: ListView.builder(
          itemCount: widget.data == null ? 0 : widget.data.length,
          itemBuilder: (BuildContext context, i) {
            if (widget.data[i].type == 'Text')
              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: TextFormField(
//                maxLength: 10,
                    decoration: InputDecoration(hintText: widget.data[i].type),
                    validator: (value) {
                      Pattern numPattern = widget.data[i].regex;
                      RegExp regex = RegExp(numPattern);
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
              );
            if (widget.data[i].type == 'Image')
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(widget.data[i].imageUrl),
                    fit: BoxFit.fill,
                  ),
                ),
              );
            if (widget.data[i].type == 'button')
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: FlatButton(
                  color: Color(0xFFFFAA01),
                  child: Center(
                    child: Text(
                      'Submit',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onPressed: _validateInputs,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.0)),
                ),
              );
            if (widget.data[i].type == 'Dropdown')
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    canvasColor: Colors.grey[350],
                    dividerColor: Colors.red,
                  ),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    hint: Text(
                      widget.data[i].defaultVal,
                      style: TextStyle(fontSize: 18),
                    ),
                    value: updatedValue,
                    icon: Icon(Icons.keyboard_arrow_down),
                    onChanged: (String newValue) {
                      setState(() {
                        updatedValue = newValue;
                      });
                    },
                    items: widget.data[i].values
                        .cast<String>()
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              );
            return Center(child: Text('Done'));
          },
        ),
      ),
    );
  }
}
