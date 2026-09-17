class SchemaField {
  const SchemaField(this.name, this.type,
      {this.key = '', this.nullable = false, this.note = ''});
  final String name;
  final String type;
  final String key;
  final bool nullable;
  final String note;
}

class SchemaTable {
  const SchemaTable(
      {required this.group,
      required this.name,
      required this.purpose,
      required this.fields,
      this.relations = const []});
  final String group;
  final String name;
  final String purpose;
  final List<SchemaField> fields;
  final List<String> relations;
}
