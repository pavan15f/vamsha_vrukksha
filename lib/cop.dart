import 'package:flutter/material.dart';
import '../models/graph_node.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AddNodeScreen extends StatefulWidget {
  @override
  _AddNodeScreenState createState() => _AddNodeScreenState();
}

class _AddNodeScreenState extends State<AddNodeScreen> {
  final _nodeNameController = TextEditingController();
  final _spouseNameController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _motherNameController = TextEditingController();
  final List<TextEditingController> _childControllers = [];

  void _addChildField() {
    setState(() {
      _childControllers.add(TextEditingController());
    });
  }

  @override
  void dispose() {
    _nodeNameController.dispose();
    _spouseNameController.dispose();
    _fatherNameController.dispose();
    _motherNameController.dispose();
    for (var controller in _childControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // Save node and other related nodes to SharedPreferences
  Future<void> _saveNode() async {
    final nodeName = _nodeNameController.text;
    final spouseName = _spouseNameController.text;
    final fatherName = _fatherNameController.text;
    final motherName = _motherNameController.text;
    final childrenNames = _childControllers
        .map((controller) => controller.text)
        .where((name) => name.isNotEmpty)
        .toList();

    // Create a new GraphNode
    final newNode = GraphNode(
      nodeName: nodeName,
      spouseName: spouseName,
      fatherName: fatherName,
      motherName: motherName,
      children: childrenNames,
    );

    final prefs = await SharedPreferences.getInstance();
    List<String> storedNodes = prefs.getStringList('graph_nodes') ?? [];

    // Ensure unique node name
    if (storedNodes.any((node) {
      var existingNode = GraphNode.fromJson(jsonDecode(node));
      return existingNode.nodeName == newNode.nodeName;
    })) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Node Name must be unique!'), backgroundColor: Colors.red),
      );
      return;
    }

    // Add current node and related nodes
    List<GraphNode> allNodes = [newNode];

    if (fatherName.isNotEmpty) allNodes.add(GraphNode(nodeName: fatherName));
    if (motherName.isNotEmpty) allNodes.add(GraphNode(nodeName: motherName));
    if (spouseName.isNotEmpty) allNodes.add(GraphNode(nodeName: spouseName));
    for (var child in childrenNames) {
      if (child.isNotEmpty) allNodes.add(GraphNode(nodeName: child));
    }

    // Convert nodes to JSON and store them
    List<String> nodeJsonList = allNodes.map((node) => jsonEncode(node.toJson())).toList();
    storedNodes.addAll(nodeJsonList);

    await prefs.setStringList('graph_nodes', storedNodes);

    // Pop screen after saving
    Navigator.pop(context, newNode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Primary Node'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _nodeNameController,
              decoration: InputDecoration(labelText: 'Node Name'),
            ),
            TextField(
              controller: _spouseNameController,
              decoration: InputDecoration(labelText: 'Spouse Name'),
            ),
            TextField(
              controller: _fatherNameController,
              decoration: InputDecoration(labelText: 'Father Name'),
            ),
            TextField(
              controller: _motherNameController,
              decoration: InputDecoration(labelText: 'Mother Name'),
            ),
            SizedBox(height: 16),
            Text(
              'Children:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ..._childControllers.map((controller) {
              return TextField(
                controller: controller,
                decoration: InputDecoration(labelText: 'Child Name'),
              );
            }).toList(),
            ElevatedButton(
              onPressed: _addChildField,
              child: Text('Add Child'),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _saveNode,
                  child: Text('Save'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Cancel
                  },
                  child: Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
