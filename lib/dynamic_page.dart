import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'json_response_attributes.dart';
import 'package:flutter/foundation.dart';
import 'chips.dart';
import 'dynamic_widgets.dart';
import 'dart:async';
import 'package:connectivity/connectivity.dart';
import 'generate_api.dart';

// --------------------------------------------------------------------------------------------------------------
/// An [isolate] to parse the JSON in the background to avoid jank.
/// You can read more about isolates here [https://api.dartlang.org/stable/2.4.0/dart-isolate/Isolate-class.html]
/// The following isolate parses the JSON and returns the list of responses.
///
/// [Attributes] class is in [json_response_attributes.dart] file
// --------------------------------------------------------------------------------------------------------------
List<Attributes> _parseJSON(var jsonParsed) {
  final parsed = jsonParsed.cast<Map<String, dynamic>>();
  return parsed.map<Attributes>((json) => Attributes.fromJson(json)).toList();
}

class DynamicPage extends StatefulWidget {
  @override
  _DynamicPageState createState() => _DynamicPageState();
}

class _DynamicPageState extends State<DynamicPage> {
  bool isLoaded = false;
  Connectivity _connectivity;
  StreamSubscription<ConnectivityResult> _subscription;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Future<List<Attributes>> future;

  // -------------------------------------------------------------------------------------
  /// [Connectivity] package is created by Flutter to check for active network connection.
  /// It provides a listener to check for the network changes which calls the callback
  /// function [onConnectivityChange] when network status is changed.
  // -------------------------------------------------------------------------------------
  @override
  void initState() {
    future = _jsonList();
    _connectivity = Connectivity();
    _subscription =
        _connectivity.onConnectivityChanged.listen(onConnectivityChange);
    super.initState();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Future<List<Attributes>> _jsonList() async {
    final dio = Dio();
    try {
      await dio.get("http://www.google.com");
    } catch (e) {
      return null;
    }
    final client = RestClient(dio);
    var jsonParsed;
    final res = await client.profile();
    jsonParsed = json.decode(res.toString());
    return compute(_parseJSON, jsonParsed);
  }

  void onConnectivityChange(ConnectivityResult result) async {
    if (result != ConnectivityResult.wifi &&
        result != ConnectivityResult.mobile) {
      final snackBar = SnackBar(
        content: Text('No internet connection'),
      );
      _scaffoldKey.currentState.showSnackBar(snackBar);
    } else {
      try {
        await Dio().get("http://www.google.com");
        if (!isLoaded)
          setState(() {
            future = _jsonList();
            build(_scaffoldKey.currentContext);
          });
      } catch (e) {
        final snackBar = SnackBar(
          content: Text('No internet connection'),
        );
        _scaffoldKey.currentState.showSnackBar(snackBar);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          key: _scaffoldKey,
          body: FutureBuilder<List<Attributes>>(
            future: future, // a previously-obtained Future<String> or null
            builder: (BuildContext context,
                AsyncSnapshot<List<Attributes>> snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return Center(child: Text('Oops! Something Went Wrong'));
                case ConnectionState.active:
                case ConnectionState.waiting:
                  return Center(child: CircularProgressIndicator());
                case ConnectionState.done:
                  if (snapshot.hasError)
                    return Text('Error: ${snapshot.error}');
                  if (!snapshot.hasData) {
                    print('lol');
                    return ListView(
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(Icons.signal_wifi_off, size: 100),
                              RaisedButton(
                                child: Text('Retry'),
                                onPressed: () async {
                                  try {
                                    await Dio().get("http://www.google.com");
                                    setState(() {
                                      future = _jsonList();
                                      build(context);
                                    });
                                  } catch (e) {
                                    final snackBar = SnackBar(
                                      content: Text('No internet connection'),
                                    );
                                    Scaffold.of(context).showSnackBar(snackBar);
                                  }
                                },
                              )
                            ],
                          ),
                        )
                      ],
                    );
                  }
                  isLoaded = true;
                  return DynamicWidgetBuilder(
                    data: snapshot.data,
                    scaffoldKey: _scaffoldKey,
                  );
              }
              return null; // unreachable
            },
          )),
    );
  }
}

class DynamicWidgetBuilder extends StatefulWidget {
  final List<Attributes> data;
  final GlobalKey scaffoldKey;
  DynamicWidgetBuilder({this.data, this.scaffoldKey});

  @override
  _DynamicWidgetBuilderState createState() => _DynamicWidgetBuilderState();
}

class _DynamicWidgetBuilderState extends State<DynamicWidgetBuilder> {
  bool _autoValidate = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String selectedDropdownValue;
  String selectedValue;
  List<String> jsonValues = [];
  final Set<String> _selectedTools = <String>{};

  void _validateInputs() async {
    if (_formKey.currentState.validate()) {
      //If all data are correct then save data to out variables
      try {
        await Dio().get("http://www.google.com");
        //getSession();
        _formKey.currentState.save();
        Navigator.pop(context);
      } catch (e) {
        final snackBar = SnackBar(
          content: Text('No internet connection'),
        );
        Scaffold.of(context).showSnackBar(snackBar);
      }
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: ListView(
            children: <Widget>[
              ListView.builder(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemCount: widget.data == null ? 0 : widget.data.length,
                itemBuilder: (BuildContext context, i) {
                  if (widget.data[i].type == 'Text')
                    return Row(
                      children: <Widget>[
                        Expanded(
                          flex: 4,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10, top: 20),
                            child: DynamicWidgets().textField(
                                isMandatory: widget.data[i].isMandatory,
                                hint: widget.data[i].hint,
                                regEx: widget.data[i].regex,
                                jsonValues: jsonValues),
                          ),
                        ),
                        if (widget.data[i].dropdown == "Yes")
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                              child: DynamicWidgets().dropDown(
                                  context: context,
                                  values: widget.data[i].values,
                                  defaultVal: widget.data[i].values[0],
                                  selectedValue: selectedValue,
                                  onChanged: (String newValue) {
                                    setState(() {
                                      selectedValue = newValue;
                                    });
                                  }),
                            ),
                          ),
                      ],
                    );
                  if (widget.data[i].type == 'Image')
                    return DynamicWidgets().image(url: widget.data[i].imageUrl);
                  if (widget.data[i].type == 'Dropdown')
                    return Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: DynamicWidgets().dropDown(
                          context: context,
                          values: widget.data[i].values,
                          defaultVal: widget.data[i].defaultVal,
                          selectedValue: selectedDropdownValue,
                          onChanged: (String value) {
                            setState(() {
                              selectedDropdownValue = value;
                            });
                          }),
                    );
                  if (widget.data[i].type == 'multi-value') {
                    final Set<String> setValues = <String>{};
                    setValues.addAll(widget.data[i].values.cast<String>());
                    //print(setValues);

                    final List<Widget> filterChips = widget.data[i].values
                        .cast<String>()
                        .map<Widget>((String name) {
                      return FilterChip(
                        key: ValueKey<String>(name),
                        label: Text(name),
                        selected: setValues.contains(name) &&
                            _selectedTools.contains(name),
                        onSelected: !setValues.contains(name)
                            ? null
                            : (bool value) {
                                print(setValues);
                                setState(() {
                                  if (!value) {
                                    _selectedTools.remove(name);
                                  } else {
                                    _selectedTools.add(name);
                                  }
                                });
                              },
                      );
                    }).toList();
                    return ChipsTile(
                        label: 'Select a Color', children: filterChips);
                  }
                  return Center(child: Text(''));
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30.0),
                child: FlatButton(
                  color: Color(0xFFFFAA01),
                  padding: EdgeInsets.symmetric(vertical: 30.0),
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
