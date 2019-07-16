class Attributes {
  String type;
  String isMandatory;
  String regex;
  String imageUrl;
  String defaultVal;
  String hint;
  String dropdown;
  List values;

  Attributes(
      {this.type,
      this.isMandatory,
      this.regex,
      this.imageUrl,
      this.defaultVal,
      this.values,
      this.hint,
      this.dropdown});

  Attributes.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    isMandatory = json['is_mandatory'];
    regex = json['regex'];
    imageUrl = json['url'];
    defaultVal = json['default'];
    values = json['values'];
    hint = json['hint'];
    dropdown = json['dropdown'];
    print(type);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['is_mandatory'] = this.isMandatory;
    data['regex'] = this.regex;
    data['url'] = this.imageUrl;
    return data;
  }
}
