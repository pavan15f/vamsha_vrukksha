import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'screens/add_node_screen.dart';
import 'screens/node_view_screen.dart';
import 'models/graph_node.dart';

void main() {
  runApp(GraphNodeApp());
}

class GraphNodeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<GraphNode> nodes = [];

  @override
  void initState() {
    super.initState();
    _loadNodes();
  }

  // Load nodes from SharedPreferences
  Future<void> _loadNodes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? nodeList = prefs.getStringList('graph_nodes');
    if (nodeList != null) {
      setState(() {
        nodes = nodeList.map((nodeJson) => GraphNode.fromJson(jsonDecode(nodeJson))).toList();
      });
    }
  }

  // Navigate to AddNodeScreen and reload nodes after returning
  Future<void> _navigateToAddNodeScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddNodeScreen()),
    );
    _loadNodes(); // Reload nodes after returning from AddNodeScreen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: nodes.isEmpty
          ? Center(
        child: ElevatedButton(
          onPressed: _navigateToAddNodeScreen,
          child: Text('Add Primary Node'),
        ),
      )
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: nodes.length,
              itemBuilder: (context, index) {
                final node = nodes[index];
                return ListTile(
                  title: Text(node.nodeName),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NodeViewScreen(graphNode: node),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _navigateToAddNodeScreen,
              child: Text('Add Primary Node'),
            ),
          ),
        ],
      ),
    );
  }
}
