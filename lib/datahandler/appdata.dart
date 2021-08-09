import 'package:app_usage/app_usage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:real_app_usage/main.dart';
import 'package:real_app_usage/screens/homepage.dart';

class AppData extends ChangeNotifier {
  // String percenttext = "";
  List percentusage = [];
  List<AppUsageInfo> infos = [];
  int item = 0;

  Duration sum1 = Duration();

  bool dir = true;

  List<ApplicationWithIcon> listofapps = [];

  List<int> percentinint = [];

  ThemeMode themeMode = ThemeMode.system;

  List<ChartData> chartData = [
    ChartData('app1', 25, Color.fromRGBO(255, 0, 0, 1)),
    ChartData('app2', 25, Color.fromRGBO(136, 24, 191, 1)),
    ChartData('app3', 25, Color.fromRGBO(0, 255, 251, 1)),
    ChartData('Others', 25, Color.fromRGBO(177, 177, 177, 1)),
  ];

  void changechartData() {
    double rest = 100 -
        (double.parse(percentinint[0].toString()) +
            double.parse(percentinint[1].toString()) +
            double.parse(percentinint[2].toString()));
    chartData = [
      ChartData('app1', double.parse(percentinint[0].toString()),
          Color.fromRGBO(255, 0, 0, 1)),
      ChartData('app2', double.parse(percentinint[1].toString()),
          Color.fromRGBO(136, 24, 191, 1)),
      ChartData('app3', double.parse(percentinint[2].toString()),
          Color.fromRGBO(0, 255, 251, 1)),
      ChartData('Others', rest, Color.fromRGBO(177, 177, 177, 1)),
    ];
    notifyListeners();
  }

  void dynamictointlist() {
    List<int> intList =
        percentusage.map((s) => int.parse(s.toString())).toList();
    percentinint = intList;
    changechartData();
    notifyListeners();
  }

  void tofirestore(List<AppUsageInfo> li) {
    List<String> appnamelist = [];
    List<String> timespentlist = [];
    for (int i = 0; i < 10; i++) {
      appnamelist.add(li[i].appName.toString());
      timespentlist.add(li[i].usage.toString());
    }
    firestoreInstance.collection("apps").doc("list").set({
      "app name": FieldValue.arrayUnion(appnamelist),
      "time spent": FieldValue.arrayUnion(timespentlist),
    });
    notifyListeners();
  }

  void getUsageStats(context) async {
    sum1 = Duration();
    // getapps();
    try {
      DateTime endDate = new DateTime.now();
      DateTime startDate = endDate.subtract(Duration(days: 1));
      List<AppUsageInfo> infoList =
          await AppUsage.getAppUsage(startDate, endDate);

      infoList.sort((a, b) => b.usage.compareTo(a.usage));

      infos = infoList;

      for (var info in infoList) {
        item++;
        // print("app usage ${info.usage}");
        sum1 += info.usage;
        
        ApplicationWithIcon? appli =
            await DeviceApps.getApp(info.packageName, true)
                as ApplicationWithIcon;
                
        listofapps.add(appli);

        // print(appli.toString());
      }
      print("sum1 is $sum1");
      print("${int.parse("5")}");
      print("test ${infoList[0].usage.inSeconds / sum1.inSeconds}");
      tofirestore(infoList);
      for (int i = 0; i < 3; i++) {
        percentusage.add(((infoList[i].usage.inSeconds / sum1.inSeconds) * 100)
            .truncate()
            .toString());
      }
      dynamictointlist();
    } on AppUsageException catch (exception) {
      print(exception);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("$exception"),
      ));
    }
    notifyListeners();
  }
  

  bool get isDarkMode {
    if (themeMode == ThemeMode.system) {
      final brightness = SchedulerBinding.instance!.window.platformBrightness;
      return brightness == Brightness.dark;
    } else {
      return themeMode == ThemeMode.dark;
    }
  }

  void toggleTheme(bool isOn) {
    themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
