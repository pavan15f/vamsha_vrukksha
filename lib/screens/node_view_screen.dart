import 'package:flutter/material.dart';
import '../models/graph_node.dart';
import '../widgets/graph_painter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NodeViewScreen extends StatefulWidget {
  final GraphNode graphNode;

  const NodeViewScreen({required this.graphNode});

  @override
  _NodeViewScreenState createState() => _NodeViewScreenState();
}

class _NodeViewScreenState extends State<NodeViewScreen> {
  late GraphNode graphNode;

  final _fatherNameController = TextEditingController();
  final _motherNameController = TextEditingController();
  final _spouseNameController = TextEditingController();
  final _childNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    graphNode = widget.graphNode;
  }

  @override
  void dispose() {
    _fatherNameController.dispose();
    _motherNameController.dispose();
    _spouseNameController.dispose();
    _childNameController.dispose();
    super.dispose();
  }

  // Save the updated GraphNode to SharedPreferences
  Future<void> _saveNode(GraphNode node) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? nodeList = prefs.getStringList('graph_nodes') ?? [];

    // Remove the existing node
    nodeList.removeWhere((nodeJson) =>
    jsonDecode(nodeJson)['nodeName'] == node.nodeName);

    // Add the updated node
    nodeList.add(jsonEncode(node.toJson()));

    // Save the updated list to SharedPreferences
    await prefs.setStringList('graph_nodes', nodeList);
  }

  // Add Parent Dialog
  Future<void> _addParentDialog() async {
    if (graphNode.fatherName != null && graphNode.motherName != null) {
      return;
    }

    // Show a dialog to input Father and Mother names
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Parent'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _fatherNameController,
                decoration: InputDecoration(labelText: 'Father Name'),
              ),
              TextField(
                controller: _motherNameController,
                decoration: InputDecoration(labelText: 'Mother Name'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Validate input and update GraphNode
                if (_fatherNameController.text.isNotEmpty &&
                    _motherNameController.text.isNotEmpty) {
                  setState(() {
                    graphNode.fatherName = _fatherNameController.text;
                    graphNode.motherName = _motherNameController.text;
                  });
                  _fatherNameController.clear();
                  _motherNameController.clear();
                  _saveNode(graphNode);  // Save the updated node in SharedPreferences
                  Navigator.pop(context);
                }
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);  // Close dialog without saving
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Add Wife Dialog
  Future<void> _addWifeDialog() async {
    if (graphNode.spouseName != null) {
      return;
    }

    // Show a dialog to input Spouse name
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Wife'),
          content: TextField(
            controller: _spouseNameController,
            decoration: InputDecoration(labelText: 'Spouse Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Validate input and update GraphNode
                if (_spouseNameController.text.isNotEmpty) {
                  setState(() {
                    graphNode.spouseName = _spouseNameController.text;
                  });
                  _spouseNameController.clear();
                  _saveNode(graphNode);  // Save the updated node in SharedPreferences
                  Navigator.pop(context);
                }
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);  // Close dialog without saving
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Add Children Dialog
  Future<void> _addChildrenDialog() async {
    // Show a dialog to input a child's name
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Child'),
          content: TextField(
            controller: _childNameController,
            decoration: InputDecoration(labelText: 'Child Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Add the child to the children list and save
                final childName = _childNameController.text;
                if (childName.isNotEmpty) {
                  setState(() {
                    graphNode.children.add(childName);
                  });
                  _childNameController.clear();
                  _saveNode(graphNode);  // Save the updated node in SharedPreferences
                  Navigator.pop(context);
                }
              },
              child: Text('Save Child'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);  // Close dialog without saving
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${graphNode.nodeName} Tree'),
        actions: [
          // Add Parent Button
          IconButton(
            onPressed: (graphNode.fatherName != null && graphNode.motherName != null)
                ? null // Disable if both parent names are set
                : _addParentDialog,
            icon: const Icon(Icons.person_add),
            tooltip: 'Add Parent',
          ),
          // Add Wife Button
          IconButton(
            onPressed: (graphNode.spouseName != null)
                ? null // Disable if spouse name is set
                : _addWifeDialog,
            icon: const Icon(Icons.favorite),
            tooltip: 'Add Wife',
          ),
          // Add Child Button
          IconButton(
            onPressed: _addChildrenDialog,
            icon: const Icon(Icons.child_care),
            tooltip: 'Add Child',
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          boundaryMargin: const EdgeInsets.all(100),
          minScale: 0.5,
          maxScale: 5.0,
          constrained: false,
          child: CustomPaint(
            size: const Size(500, 500), // Arbitrary canvas size
            painter: GraphPainter(node: graphNode),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Return to Home Screen
            },
            child: const Text('Go to Home'),
          ),
        ),
      ),
    );
  }
}
