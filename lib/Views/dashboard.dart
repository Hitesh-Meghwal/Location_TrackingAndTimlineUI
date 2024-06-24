import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sampleapp/Views/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timelines/timelines.dart';
import '../Models/user_model.dart';
import '../Services/Database/database_service.dart';

class Dashboard extends StatefulWidget {

  final String username;
  const Dashboard({super.key, required this.username});

  @override
  State<StatefulWidget> createState() {
    return _DashboardState();
  }
}

class _DashboardState extends State<Dashboard> {

  final DatabaseService _DatabaseService = DatabaseService.instance;

  late String _locationName = "";
  late String _userName = "";
  late String _timestamp = "";
  late double _deviceWidth, _deviceHeight;
  List<User> _userTimeline = [];

  @override
  void initState() {
    super.initState();
    _getUserData();
    // _getLocationNames();
  }

  @override
  Widget build(BuildContext context) {
    _deviceWidth = MediaQuery.of(context).size.width;
    _deviceHeight = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Welcome, $_userName'),
          actions: [
            IconButton(onPressed: ()  async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> Login()));
            },
                icon: const Icon(Icons.logout))
          ],
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              _timeLineUI(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _getUserData() async {
    final users = await _DatabaseService.getUserByUsername(widget.username);
    if (users.isNotEmpty) {
      setState(() {
        _userName = users.first.userName;
        _userTimeline = users;
      });
    }
  }

  Widget _timeLineUI() {
    return FixedTimeline.tileBuilder(
      builder: TimelineTileBuilder.connectedFromStyle(
        contentsAlign: ContentsAlign.alternating,
        oppositeContentsBuilder: (context, index) => Padding(
          padding: const EdgeInsets.all(28.0),
          child: Text('${_userTimeline[index].userName}\n ${_userTimeline[index].userTimestamp}'),
        ),
        contentsBuilder: (context, index) => Card(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Text(_userTimeline[index].userLocation ?? 'Loading...'),
          ),
        ),
        connectorStyleBuilder: (context, index) => ConnectorStyle.solidLine,
        indicatorStyleBuilder: (context, index) => IndicatorStyle.dot,
        itemCount: _userTimeline.length,
      ),
    );
  }
}
