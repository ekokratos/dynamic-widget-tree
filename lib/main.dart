import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dynamic_page_demo.dart';
import 'dart:convert';
import 'attributes.dart';
import 'package:flutter/foundation.dart';

main() async {
  runApp(RetroDemo());
}

List<Attributes> _parseJSON(var jsonParsed) {
  final parsed = jsonParsed.cast<Map<String, dynamic>>();
  return parsed.map<Attributes>((json) => Attributes.fromJson(json)).toList();
}

class RetroDemo extends StatelessWidget {
  Future<List<Attributes>> _jsonList() async {
    final dio = Dio();
    final client = RestClient(dio);
    var jsonParsed;
    final res = await client.profile();
    jsonParsed = json.decode(res.toString());
    //final parsed = jsonParsed.cast<Map<String, dynamic>>();
    //return parsed.map<Attributes>((json) => Attributes.fromJson(json)).toList();
    return compute(_parseJSON, jsonParsed);
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
  String selectedValue;
  List<String> jsonValues = [];
  final Set<String> _selectedTools = <String>{};
  final Set<String> _tools = <String>{};

  void _removeTool(String name) {
    _tools.remove(name);
    _selectedTools.remove(name);
  }

  void set(i) {
    _tools.addAll(widget.data[i].values.cast<String>());
  }

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
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ListView.builder(
            itemCount: widget.data == null ? 0 : widget.data.length,
            itemBuilder: (BuildContext context, i) {
              if (widget.data[i].type == 'Text')
                return Row(
                  children: <Widget>[
                    Expanded(
                      flex: 4,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10, top: 20),
                        child: TextFormField(
//                maxLength: 10,
                          decoration: InputDecoration(
                              hintText: widget.data[i].isMandatory == 'Yes'
                                  ? widget.data[i].hint + ' *'
                                  : widget.data[i].hint),
                          validator: (value) {
                            Pattern numPattern = widget.data[i].regex == null
                                ? ''
                                : widget.data[i].regex;
                            RegExp regex = RegExp(numPattern);
                            if (!regex.hasMatch(value))
                              return 'Enter Valid ${widget.data[i].hint}';
                            else
                              return null;
                          },
                          onSaved: (value) {
                            jsonValues.add("{${widget.data[i].hint} : $value}");
                            print(jsonValues);
                          },
                        ),
                      ),
                    ),
                    if (widget.data[i].dropdown == "Yes")
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              canvasColor: Colors.grey[350],
                              dividerColor: Colors.red,
                            ),
                            child: DropdownButton<String>(
                              isExpanded: true,
                              hint: Text(
                                widget.data[i].values[0],
                                style: TextStyle(fontSize: 18),
                              ),
                              value: selectedValue,
                              icon: Icon(Icons.keyboard_arrow_down),
                              onChanged: (String newValue) {
                                setState(() {
                                  selectedValue = newValue;
                                });
                              },
                              items: widget.data[i].values
                                  .cast<String>()
                                  .map<DropdownMenuItem<String>>(
                                      (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              if (widget.data[i].type == 'Image')
                return Container(
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
                  padding: const EdgeInsets.only(top: 20.0),
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
              if (widget.data[i].type == 'multi_value') {
                set(i);
                final List<Widget> filterChips = widget.data[i].values
                    .cast<String>()
                    .map<Widget>((String name) {
                  return FilterChip(
                    key: ValueKey<String>(name),
                    label: Text(name),
                    selected:
                        _tools.contains(name) && _selectedTools.contains(name),
                    onSelected: !_tools.contains(name)
                        ? null
                        : (bool value) {
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
                return _ChipsTile(
                    label: 'Choose Tools (FilterChip)', children: filterChips);
              }
              return Center(child: Text(''));
            },
          ),
        ),
      ),
    );
  }
}

class _ChipsTile extends StatelessWidget {
  const _ChipsTile({
    Key key,
    this.label,
    this.children,
  }) : super(key: key);

  final String label;
  final List<Widget> children;

  // Wraps a list of chips into a ListTile for display as a section in the demo.
  @override
  Widget build(BuildContext context) {
    final List<Widget> cardChildren = <Widget>[
      Container(
        padding: const EdgeInsets.only(top: 16.0, bottom: 4.0),
        alignment: Alignment.center,
        child: Text(label, textAlign: TextAlign.start),
      ),
    ];
    if (children.isNotEmpty) {
      cardChildren.add(Wrap(
          children: children.map<Widget>((Widget chip) {
        return Padding(
          padding: const EdgeInsets.all(2.0),
          child: chip,
        );
      }).toList()));
    } else {
      final TextStyle textStyle = Theme.of(context)
          .textTheme
          .caption
          .copyWith(fontStyle: FontStyle.italic);
      cardChildren.add(Semantics(
        container: true,
        child: Container(
          alignment: Alignment.center,
          constraints: const BoxConstraints(minWidth: 48.0, minHeight: 48.0),
          padding: const EdgeInsets.all(8.0),
          child: Text('None', style: textStyle),
        ),
      ));
    }

    return Card(
      semanticContainer: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: cardChildren,
      ),
    );
  }
}
