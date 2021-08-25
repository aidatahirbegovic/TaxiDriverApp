import 'package:driver_app/helpingMethods/assistantMethods.dart';
import 'package:driver_app/tabPages/earningsTabPage.dart';
import 'package:driver_app/tabPages/homeTabPage.dart';
import 'package:driver_app/tabPages/profileTabPage.dart';
import 'package:driver_app/tabPages/ratingPage.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/src/public_ext.dart';

class MainScreen extends StatefulWidget {
  static const String idScreen = "mainScreen";
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  TabController tabController;
  int selectedIndex = 0;

  void onItemClicked(int index) {
    setState(() {
      selectedIndex = index;
      tabController.index = selectedIndex;
    });
  }

  Future<void> currentOnlineUser() async {
    AssistantMethods.getCurrentOnlineUserInfo();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentOnlineUser();
    tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: tabController,
        children: [
          HomeTabPage(),
          EarningsTabPage(),
          RatingTabPage(),
          ProfileTabPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'home'.tr(),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card),
            label: 'earning'.tr(),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'ratings'.tr(),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'account'.tr(),
          ),
        ],
        unselectedItemColor: Colors.black54,
        selectedItemColor: Colors.yellow,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontSize: 12.0),
        showUnselectedLabels: true,
        currentIndex: selectedIndex,
        onTap: onItemClicked,
      ),
    );
  }
}
