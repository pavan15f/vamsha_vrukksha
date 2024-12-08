import 'dart:convert';

class GraphNode {
  String nodeName;
  String? spouseName;
  String? fatherName;
  String? motherName;
  List<String> children;

  GraphNode({
    required this.nodeName,
    this.spouseName,
    this.fatherName,
    this.motherName,
    this.children = const [],
  });

  // Convert GraphNode to a Map for storage
  Map<String, dynamic> toMap() {
    return {
      'nodeName': nodeName,
      'spouseName': spouseName,
      'fatherName': fatherName,
      'motherName': motherName,
      'children': children,
    };
  }

  // Create a GraphNode from a Map
  factory GraphNode.fromMap(Map<String, dynamic> map) {
    return GraphNode(
      nodeName: map['nodeName'],
      spouseName: map['spouseName'],
      fatherName: map['fatherName'],
      motherName: map['motherName'],
      children: List<String>.from(map['children']),
    );
  }


  // Convert GraphNode to a JSON-compatible map
  Map<String, dynamic> toJson() {
    return {
      'nodeName': nodeName,
      'spouseName': spouseName,
      'fatherName': fatherName,
      'motherName': motherName,
      'children': children,
    };
  }

  // Factory constructor to create a GraphNode from JSON
  factory GraphNode.fromJson(Map<String, dynamic> json) {
    return GraphNode(
      nodeName: json['nodeName'],
      spouseName: json['spouseName'],
      fatherName: json['fatherName'],
      motherName: json['motherName'],
      children: List<String>.from(json['children']),
    );
  }
}
