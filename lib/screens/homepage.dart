// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
// import 'package:app_usage/app_usage.dart';
import 'package:provider/provider.dart';
import 'package:real_app_usage/datahandler/appdata.dart';
import 'package:real_app_usage/widget/change_theme_button_widget.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
// import 'package:real_app_usage/main.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class ChartData {
  ChartData(this.x, this.y, this.color);
  final String x;
  final double y;
  final Color color;
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  // List<AppUsageInfo> _infos = [];

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    Provider.of<AppData>(context, listen: false).getUsageStats(context);
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _animation = Tween<double>(
            begin: Provider.of<AppData>(context, listen: false).dir ? 0 : 0.5,
            end: Provider.of<AppData>(context, listen: false).dir ? 0.5 : 1)
        .animate(_controller);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset("assets/logoimage.png", height: 40.0, width: 40.0),
            Text(
              "Ekam",
              // style: TextStyle(color: Colors.black),
            ),
          ],
        ),
        elevation: 0.0,
        // backgroundColor: Colors.white,
        actions: [
          ChangeThemeButtonWidget(),
        ],
      ),
      body: Consumer<AppData>(builder: (context, provider, child) {
        return Center(
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Total Time Spent on Mobile",
                      // textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    RotationTransition(
                      turns: _animation,
                      child: IconButton(
                        onPressed: () {
                          _controller.forward(
                            from: 0,
                          );
                          provider.dir = !provider.dir;
                          provider.getUsageStats(context);
                        },
                        icon: Image.asset("assets/reloadicon.png"),
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child: Container(
                  height: 175,
                  width: 175,
                  child: SfCircularChart(
                    annotations: <CircularChartAnnotation>[
                      CircularChartAnnotation(
                        widget: Container(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "${provider.sum1.inHours} Hours \n${provider.sum1.inMinutes - provider.sum1.inHours * 60} mins",
                              style: TextStyle(
                                fontSize: 25.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                    series: <CircularSeries>[
                      DoughnutSeries<ChartData, String>(
                        dataSource: provider.chartData,
                        pointColorMapper: (ChartData data, _) => data.color,
                        xValueMapper: (ChartData data, _) => data.x,
                        yValueMapper: (ChartData data, _) => data.y,
                        explode: true,
                        explodeAll: true,
                        radius: '96%',
                        innerRadius: '84%',
                        // Corner style of doughnut segment
                        cornerStyle: CornerStyle.bothCurve,
                      ),
                    ],
                  ),
                ),
              ),
              Text(
                "Top 3 Apps killing your time:",
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: Container(
                  child: ListView.separated(
                    itemCount: provider.item >= 3 ? 3 : 0,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Column(
                          children: [
                            Row(
                              children: [
                                Image.memory(
                                  provider.listofapps[index].icon,
                                  height: 60.0,
                                  width: 60.0,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(provider.listofapps[index].appName),
                                      Text(
                                        provider.infos[index].usage.inHours >= 1
                                            ? provider
                                                    .infos[index].usage.inHours
                                                    .toString() +
                                                " hour " +
                                                (provider.infos[index].usage
                                                            .inMinutes -
                                                        provider.infos[index]
                                                                .usage.inHours *
                                                            60)
                                                    .toString() +
                                                " mins"
                                            : provider.infos[index].usage
                                                    .inMinutes
                                                    .toString() +
                                                " mins",
                                        style: TextStyle(
                                          fontSize: 12.0,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Text(
                          provider.percentusage[index].toString() + "%",
                          style: TextStyle(
                            fontSize: 28.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (_, index) => Divider(),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
