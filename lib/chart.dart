import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartPage extends StatefulWidget {
  @override
  _ChartPageState createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  String _selectedTimeFrame = 'Month';
  late List<_Users> _dataSource;

  @override
  void initState() {
    super.initState();
    _updateDataSource();
  }

  void _updateDataSource() {
    switch (_selectedTimeFrame) {
      case 'Day':
        _dataSource = [
          _Users('12 AM', 5),
          _Users('4 AM', 7),
          _Users('8 AM', 12),
          _Users('12 PM', 15),
          _Users('4 PM', 18),
          _Users('8 PM', 21),
        ];
        break;
      case 'Week':
        _dataSource = [
          _Users('Mon', 150),
          _Users('Tue', 170),
          _Users('Wed', 140),
          _Users('Thu', 200),
          _Users('Fri', 220),
          _Users('Sat', 240),
          _Users('Sun', 260),
        ];
        break;
      case 'Month':
        _dataSource = [
          _Users('1', 3500),
          _Users('2', 3500),
          _Users('3', 2800),
          _Users('4', 3500),
          _Users('5', 3400),
          _Users('6', 3200),
          _Users('7', 4000),
          _Users('8', 6000),
          _Users('9', 5000),
          _Users('10', 1500),
          _Users('11', 3550),
          _Users('12', 5500),
        ];
        break;
      case 'Year':
        _dataSource = [
          _Users('Jan', 35000),
          _Users('Feb', 28000),
          _Users('Mar', 34000),
          _Users('Apr', 32000),
          _Users('May', 40000),
          _Users('Jun', 60000),
          _Users('Jul', 50000),
          _Users('Aug', 45000),
          _Users('Sep', 47000),
          _Users('Oct', 52000),
          _Users('Nov', 53000),
          _Users('Dec', 60000),
        ];
        break;
      default:
        _dataSource = [];
    }
  }

  void _onTimeFrameChanged(String timeFrame) {
    setState(() {
      _selectedTimeFrame = timeFrame;
      _updateDataSource();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Engagement'),
        backgroundColor: Colors.pink,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () => _onTimeFrameChanged('Day'),
                  child: Text('Day'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                          (_) => _selectedTimeFrame == 'Day' ? Colors.pink : Colors.grey,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _onTimeFrameChanged('Week'),
                  child: Text('Week'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                          (_) => _selectedTimeFrame == 'Week' ? Colors.pink : Colors.grey,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _onTimeFrameChanged('Month'),
                  child: Text('Month'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                          (_) => _selectedTimeFrame == 'Month' ? Colors.pink : Colors.grey,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _onTimeFrameChanged('Year'),
                  child: Text('Year'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                          (_) => _selectedTimeFrame == 'Year' ? Colors.pink : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _selectedTimeFrame == 'Year'
                ? SfCircularChart(
              title: ChartTitle(text: 'User Engagement ($_selectedTimeFrame)'),
              legend: Legend(isVisible: true),
              series: <CircularSeries<dynamic, dynamic>>[
                PieSeries<_Users, String>(
                  dataSource: _dataSource,
                  xValueMapper: (_Users users, _) => users.timeFrame,
                  yValueMapper: (_Users users, _) => users.count,
                  dataLabelSettings: DataLabelSettings(isVisible: true),
                ),
              ],
            )
                : SfCartesianChart(
              primaryXAxis: CategoryAxis(),
              title: ChartTitle(text: 'User Engagement ($_selectedTimeFrame)'),
              legend: Legend(isVisible: true),
              tooltipBehavior: TooltipBehavior(enable: true),
              series: <CartesianSeries<dynamic, dynamic>>[
                _selectedTimeFrame == 'Week'
                    ? AreaSeries<_Users, String>(
                  dataSource: _dataSource,
                  xValueMapper: (_Users users, _) => users.timeFrame,
                  yValueMapper: (_Users users, _) => users.count,
                  dataLabelSettings: DataLabelSettings(isVisible: true),
                )
                    : _selectedTimeFrame == 'Month'
                    ? ColumnSeries<_Users, String>(
                  dataSource: _dataSource,
                  xValueMapper: (_Users users, _) => users.timeFrame,
                  yValueMapper: (_Users users, _) => users.count,
                  dataLabelSettings: DataLabelSettings(isVisible: true),
                )
                    : LineSeries<_Users, String>(
                  dataSource: _dataSource,
                  xValueMapper: (_Users users, _) => users.timeFrame,
                  yValueMapper: (_Users users, _) => users.count,
                  dataLabelSettings: DataLabelSettings(isVisible: true),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Users {
  _Users(this.timeFrame, this.count);
  final String timeFrame;
  final double count;
}
