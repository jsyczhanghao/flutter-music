import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './views/home.dart';
import './views/user.dart';
import './routes/routes.dart';

class AppFramework extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '大饼音乐',
      home: AppFrameworkView(),
      routes: initializeRoutes(),
    );
  }
}

class AppFrameworkView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AppFrameworkViewState();
  }
}

class AppFrameworkViewState extends State<AppFrameworkView>
    with SingleTickerProviderStateMixin {
  int _navigatorIndex = 0;
  TabController controller;
  List<Widget> views;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]);
    controller = TabController(length: 2, vsync: this);
    views = [HomeView(), UserView()];
  }

  switchTab(int index) {
    setState(() {
      _navigatorIndex = index;
    });

    controller.animateTo(index);
  }

  @override
  void dispose() async {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: controller,
        children: views,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), title: Text('首页')),
          BottomNavigationBarItem(icon: Icon(Icons.person), title: Text('我的音乐'))
        ],
        currentIndex: _navigatorIndex,
        onTap: switchTab,
      ),
    );
  }
}
