import 'package:flutter/material.dart';

class DynamicWidgets {
  TextFormField textField(
      {String isMandatory,
      String hint,
      String regEx,
      List<String> jsonValues}) {
    return TextFormField(
//                maxLength: 10,
      decoration:
          InputDecoration(hintText: isMandatory == 'Yes' ? hint + ' *' : hint),
      validator: (value) {
        Pattern numPattern = regEx == null ? '' : regEx;
        RegExp regex = RegExp(numPattern);
        if (!regex.hasMatch(value))
          return 'Enter Valid $hint';
        else
          return null;
      },
      onSaved: (value) {
        jsonValues.add("{$hint : $value}");
      },
    );
  }

  Theme dropDown(
      {BuildContext context,
      List<dynamic> values,
      String defaultVal,
      String selectedValue,
      Function onChanged}) {
    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: Colors.grey[350],
        dividerColor: Colors.red,
      ),
      child: DropdownButton<String>(
        isExpanded: true,
        hint: Text(
          defaultVal,
          style: TextStyle(fontSize: 18),
        ),
        value: selectedValue,
        icon: Icon(Icons.keyboard_arrow_down),
        onChanged: onChanged,
        items:
            values.cast<String>().map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }

  Container image({String url}) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(url),
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
