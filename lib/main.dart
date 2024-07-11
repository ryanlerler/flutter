import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class Sensor {
  final String id;
  final String name;
  final String status;
  final int uptime;

  Sensor({
    required this.id,
    required this.name,
    required this.status,
    required this.uptime,
  });

  factory Sensor.fromJson(Map<String, dynamic> json) {
    return Sensor(
      id: json['id'],
      name: json['name'],
      status: json['status'],
      uptime: json['uptime'],
    );
  }
}

class SensorStatusProvider extends ChangeNotifier {
  List<Sensor> sensors = [];

  SensorStatusProvider() {
    loadSensorData();
  }

  Future<void> loadSensorData() async {
    final String response =
        await rootBundle.loadString('assets/mock_data.json');
    final data = await json.decode(response);
    sensors = (data['sensors'] as List).map((i) => Sensor.fromJson(i)).toList();
    notifyListeners();
  }

  void updateStatus(int index, bool status) {
    sensors[index] = Sensor(
      id: sensors[index].id,
      name: sensors[index].name,
      status: status ? 'online' : 'offline',
      uptime: sensors[index].uptime,
    );
    notifyListeners();
  }

  void refreshSensors() {
    final random = Random();
    int numSensorsToUpdate = random.nextInt(3) + 1; // Update 1-3 sensors
    for (int i = 0; i < numSensorsToUpdate; i++) {
      int index = random.nextInt(sensors.length);
      bool newStatus = random.nextBool();
      updateStatus(index, newStatus);
    }
  }

  int get onlineSensorCount =>
      sensors.where((sensor) => sensor.status == 'online').length;
  int get totalSensorCount => sensors.length;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SensorStatusProvider(),
      child: MaterialApp(
        title: 'Sensor Status App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const SensorStatusScreen(),
      ),
    );
  }
}

class SensorStatusScreen extends StatelessWidget {
  const SensorStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor Status'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<SensorStatusProvider>(context, listen: false)
                  .refreshSensors();
            },
          ),
        ],
      ),
      body: Consumer<SensorStatusProvider>(
        builder: (context, provider, child) {
          if (provider.sensors.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          int onlineCount = provider.onlineSensorCount;
          int totalCount = provider.totalSensorCount;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  '$onlineCount/$totalCount sensors online',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 200,
                child: SensorUptimeChart(sensors: provider.sensors),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: provider.sensors.length,
                  itemBuilder: (context, index) {
                    final sensor = provider.sensors[index];
                    return ListTile(
                      title: Text(sensor.name),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            sensor.status == 'online'
                                ? Icons.wifi
                                : Icons.wifi_off,
                            color: sensor.status == 'online'
                                ? Colors.green
                                : Colors.red,
                          ),
                          const SizedBox(width: 10),
                          Text('${sensor.uptime}%'),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Provider.of<SensorStatusProvider>(context, listen: false)
              .refreshSensors();
        },
        child: const Icon(Icons.refresh),
        tooltip: 'Refresh Sensors',
      ),
    );
  }
}

class SensorUptimeChart extends StatelessWidget {
  final List<Sensor> sensors;

  const SensorUptimeChart({Key? key, required this.sensors}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100,
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    sensors[value.toInt()].name,
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 20,
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: sensors.asMap().entries.map((entry) {
          int index = entry.key;
          Sensor sensor = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: sensor.uptime.toDouble(),
                color: sensor.status == 'online' ? Colors.green : Colors.red,
                width: 16,
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
