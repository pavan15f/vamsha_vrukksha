import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/graph_node.dart';

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

  bool _isSaveButtonEnabled = false;

  void _addChildField() {
    setState(() {
      _childControllers.add(TextEditingController());
    });
  }

  void _validateNodeName() {
    setState(() {
      _isSaveButtonEnabled = _nodeNameController.text.trim().isNotEmpty;
    });
  }

  @override
  void initState() {
    super.initState();
    _nodeNameController.addListener(_validateNodeName);
  }

  @override
  void dispose() {
    _nodeNameController.removeListener(_validateNodeName);
    _nodeNameController.dispose();
    _spouseNameController.dispose();
    _fatherNameController.dispose();
    _motherNameController.dispose();
    for (var controller in _childControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _saveToSharedPreferences(GraphNode newNode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Retrieve existing nodes from SharedPreferences
    List<String>? nodeList = prefs.getStringList('graph_nodes') ?? [];

    // Convert GraphNode to JSON and ensure the NodeName is unique
    List<GraphNode> existingNodes = nodeList
        .map((nodeJson) => GraphNode.fromJson(jsonDecode(nodeJson)))
        .toList();

    // Prevent duplicate NodeNames
    if (existingNodes.any((node) => node.nodeName == newNode.nodeName)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Node with this name already exists!')),
      );
      return;
    }

    // Add the new node
    existingNodes.add(newNode);

    // Save back to SharedPreferences
    List<String> updatedNodeList =
    existingNodes.map((node) => jsonEncode(node.toJson())).toList();
    await prefs.setStringList('graph_nodes', updatedNodeList);

    // Save additional nodes for relationships if they don't already exist
    await _saveRelatedNodesToSharedPreferences(existingNodes, prefs);

    // Return to the previous screen
    Navigator.pop(context, newNode);
  }

  Future<void> _saveRelatedNodesToSharedPreferences(
      List<GraphNode> existingNodes, SharedPreferences prefs) async {
    // Helper to check if a node already exists
    bool nodeExists(String nodeName) =>
        existingNodes.any((node) => node.nodeName == nodeName);

    List<String> updatedNodeList = existingNodes.map((node) => jsonEncode(node.toJson())).toList();

    // Add Father, Mother, Spouse, and Children as individual nodes if they don't exist
    final relatedNodes = [
      _fatherNameController.text.trim(),
      _motherNameController.text.trim(),
      _spouseNameController.text.trim(),
      ..._childControllers.map((controller) => controller.text.trim()),
    ].where((name) => name.isNotEmpty).toSet();

    for (final nodeName in relatedNodes) {
      if (!nodeExists(nodeName)) {
        GraphNode newRelatedNode = GraphNode(nodeName: nodeName);
        updatedNodeList.add(jsonEncode(newRelatedNode.toJson()));
      }
    }

    // Save all nodes back to SharedPreferences
    await prefs.setStringList('graph_nodes', updatedNodeList);
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
              decoration: InputDecoration(labelText: 'Node Name *'),
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
                  onPressed: _isSaveButtonEnabled
                      ? () {
                    final children = _childControllers
                        .map((controller) => controller.text.trim())
                        .where((name) => name.isNotEmpty)
                        .toList();

                    final newNode = GraphNode(
                      nodeName: _nodeNameController.text.trim(),
                      spouseName: _spouseNameController.text.trim().isNotEmpty
                          ? _spouseNameController.text.trim()
                          : null,
                      fatherName: _fatherNameController.text.trim().isNotEmpty
                          ? _fatherNameController.text.trim()
                          : null,
                      motherName: _motherNameController.text.trim().isNotEmpty
                          ? _motherNameController.text.trim()
                          : null,
                      children: children,
                    );

                    _saveToSharedPreferences(newNode);
                  }
                      : null,
                  child: Text('Save'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
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
