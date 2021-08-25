import 'package:driver_app/widgets/HistoryItem.dart';
import 'package:driver_app/DataHandler/appData.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/src/public_ext.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('trip_history'.tr()),
        backgroundColor: Colors.black87,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.keyboard_arrow_left),
        ),
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(0),
        itemBuilder: (context, index) {
          return HistoryItem(
            history: Provider.of<AppData>(context, listen: false)
                .tripHistoryDataList[index],
          );
        },
        separatorBuilder: (BuildContext context, int index) => Divider(
          thickness: 3.0,
          height: 3.0,
        ),
        itemCount: Provider.of<AppData>(context, listen: false)
            .tripHistoryDataList
            .length,
        physics: ClampingScrollPhysics(),
        shrinkWrap: true,
      ),
    );
  }
}
