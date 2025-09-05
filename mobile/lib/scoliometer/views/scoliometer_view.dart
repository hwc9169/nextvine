// lib/scoliometer/views/scoliometer_view.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../view_model/scoliometer_view_model.dart';
import '../widgets/angle_gauge.dart';
import '../widgets/chart_painter.dart';
import '../models/reading.dart';
import '../models/mount_mode.dart';

class ScoliometerView extends StatefulWidget {
  const ScoliometerView({super.key});

  @override
  State<ScoliometerView> createState() => _ScoliometerViewState();
}

class _ScoliometerViewState extends State<ScoliometerView> {
  int _tab = 0; // 0=Measure,1=History,2=Chart
  final GlobalKey _chartRepaintKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Set orientation to landscapeLeft when ScoliometerView is active
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
    ]);
  }

  @override
  void dispose() {
    // Restore original orientation when leaving ScoliometerView
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ScoliometerViewModel(),
      child: Consumer<ScoliometerViewModel>(
        builder: (context, vm, child) {
          final body = _tab == 0
              ? _buildMeasure(vm)
              : _tab == 1
                  ? _buildHistory(vm)
                  : _buildChart(vm);

          return Scaffold(
            body: body,
            bottomNavigationBar: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_tab == 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade100,
                      boxShadow: const [
                        BoxShadow(
                            blurRadius: 8,
                            offset: Offset(0, -2),
                            color: Color(0x1F000000))
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: vm.calibrateZero,
                            icon: const Icon(Icons.center_focus_strong),
                            label: const Text('Calibrate 0°'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: vm.record,
                            icon: const Icon(Icons.bookmark_add_rounded),
                            label: const Text('Record'),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                NavigationBar(
                  height: 50.0,
                  selectedIndex: _tab,
                  onDestinationSelected: (i) {
                    setState(() => _tab = i);
                  },
                  destinations: const [
                    NavigationDestination(
                        icon: Icon(Icons.speed), label: 'Measure'),
                    NavigationDestination(
                        icon: Icon(Icons.table_chart), label: 'History'),
                    NavigationDestination(
                        icon: Icon(Icons.show_chart), label: 'Chart'),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ---------------------- Measure ----------------------
  Widget _buildMeasure(ScoliometerViewModel vm) {
    return SafeArea(
      child: Column(
        children: [
          if (vm.showSimHint && !vm.sensorSeen)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(top: 8, left: 12, right: 12),
              decoration: BoxDecoration(
                color: Colors.teal.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.teal.shade300),
              ),
              child: const Text(
                'No motion sensors detected. Enable Simulation or use a mobile device.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.teal),
              ),
            ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: AngleGauge(
                        angleDeg: vm.displayDeg,
                        peakAbs: vm.peakAbs,
                        maxHeight: 320,
                        deviceCmWidth: vm.desiredDeviceWidthCm,
                        arcLiftFactor: 0.14,
                        convexUp: false,
                        uiScale: vm.uiScale,
                      ),
                    ),
                    // Controls (mount/width)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PopupMenuButton<MountMode>(
                            tooltip: 'Mount',
                            onSelected: (m) {
                              vm.setMountMode(m);
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                  value: MountMode.longEdge,
                                  child: Text('Long Edge (Left/Right)')),
                              PopupMenuItem(
                                  value: MountMode.flatBack,
                                  child: Text('Flat (Back/Front)')),
                              PopupMenuItem(
                                  value: MountMode.shortEdge,
                                  child: Text('Short Edge (Top/Bottom)')),
                            ],
                            icon: const Icon(Icons.screen_rotation_alt),
                          ),
                          const SizedBox(width: 6),
                          PopupMenuButton<double>(
                            tooltip: 'Width',
                            onSelected: (v) => vm.setDeviceWidth(v),
                            itemBuilder: (context) => const [
                              PopupMenuItem(value: 15.0, child: Text('15 cm')),
                              PopupMenuItem(value: 18.0, child: Text('18 cm')),
                              PopupMenuItem(value: 20.0, child: Text('20 cm')),
                            ],
                            icon: const Icon(Icons.straighten),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Readings: ${vm.sessionReadingCount(vm.sessionId)}'),
                Text('Peak: ${vm.peakAbs.toStringAsFixed(1)}°'),
              ],
            ),
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  // ---------------------- History ----------------------
  Widget _buildHistory(ScoliometerViewModel vm) {
    final sessions = vm.availableSessionsDesc();
    if (!sessions.contains(vm.selectedSessionForHistory)) {
      vm.setSelectedSessionForHistory(sessions.first);
    }

    final data = vm.log
        .where((r) => r.session == vm.selectedSessionForHistory)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final stats = vm.computeStats(data);

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;

        const double minTime = 200, minAtr = 100, minAct = 100;
        double wTime = w * 0.50;
        double wAtr = w * 0.25;
        double wAct = w * 0.25;

        // Ensure minimum widths but allow horizontal scrolling if needed
        wTime = math.max(minTime, wTime);
        wAtr = math.max(minAtr, wAtr);
        wAct = math.max(minAct, wAct);

        return Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (final s in sessions)
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: _sessionChip(s, vm),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.teal.shade100,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.teal.shade300),
                ),
                child: Row(
                  children: [
                    Expanded(child: Text('Count: ${data.length}')),
                    Expanded(
                        child: Text(
                            'Min: ${stats.min?.toStringAsFixed(1) ?? '-'}°')),
                    Expanded(
                        child: Text(
                            'Max: ${stats.max?.toStringAsFixed(1) ?? '-'}°')),
                    Expanded(
                        child: Text(
                            'Avg: ${stats.avg?.toStringAsFixed(1) ?? '-'}°')),
                  ],
                ),
              ),
              Expanded(
                child: Theme(
                  data: Theme.of(context).copyWith(
                    dataTableTheme: DataTableThemeData(
                      headingRowHeight: 56,
                      dataRowHeight: 56,
                      horizontalMargin: 16,
                      columnSpacing: 0,
                      dividerThickness: 0.6,
                      headingTextStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                      dataTextStyle: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                      headingRowColor:
                          MaterialStateProperty.all(Colors.teal.shade50),
                    ),
                  ),
                  child: Scrollbar(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: DataTable(
                          columns: [
                            DataColumn(
                              label: SizedBox(
                                width: wTime,
                                child: const Text('Time'),
                              ),
                            ),
                            DataColumn(
                              label: SizedBox(
                                width: wAtr,
                                child: const Text('ATR (°)'),
                              ),
                            ),
                            DataColumn(
                              label: SizedBox(
                                width: wAct,
                                child: const Text('Actions'),
                              ),
                            ),
                          ],
                          rows: [
                            for (int i = 0; i < data.length; i++)
                              _historyRowStyled(data[i], i, wTime, wAtr, wAct),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sessionChip(int sessionId, ScoliometerViewModel vm) {
    return InputChip(
      label: Text(vm.sessionDisplay(sessionId)),
      selected: vm.selectedSessionForHistory == sessionId,
      onPressed: () => vm.setSelectedSessionForHistory(sessionId),
      selectedColor: Colors.teal.shade100,
      side: const BorderSide(color: Color(0x22000000)),
    );
  }

  DataRow _historyRowStyled(
      Reading r, int viewRowIndex, double wTime, double wAtr, double wAct) {
    final ts =
        '${r.timestamp.year}-${r.timestamp.month.toString().padLeft(2, '0')}-${r.timestamp.day.toString().padLeft(2, '0')} '
        '${r.timestamp.hour.toString().padLeft(2, '0')}:${r.timestamp.minute.toString().padLeft(2, '0')}:${r.timestamp.second.toString().padLeft(2, '0')}';

    final zebra = viewRowIndex.isOdd ? const Color(0xFFF6F8FA) : Colors.white;

    return DataRow(
      color: MaterialStatePropertyAll<Color>(zebra),
      cells: [
        DataCell(SizedBox(width: wTime, child: Text(ts))),
        DataCell(SizedBox(
          width: wAtr,
          child: Align(
              alignment: Alignment.centerRight,
              child: Text(r.angleDeg.toStringAsFixed(1))),
        )),
        DataCell(SizedBox(
          width: wAct,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Delete row',
                onPressed: () {
                  // TODO: Implement delete functionality
                },
              ),
            ],
          ),
        )),
      ],
    );
  }

  // ---------------------- Chart ----------------------
  Widget _buildChart(ScoliometerViewModel vm) {
    final sessions = vm.availableSessionsDesc();
    if (!sessions.contains(vm.selectedSessionForChart)) {
      vm.setSelectedSessionForChart(
          sessions.isNotEmpty ? sessions.first : vm.sessionId);
    }
    final data = vm.log
        .where((r) => r.session == vm.selectedSessionForChart)
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top controls row
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final s in sessions)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: _sessionChip(s, vm),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Full-bleed chart area
        Expanded(
          child: RepaintBoundary(
            key: _chartRepaintKey,
            child: Container(
              color: Colors.teal.shade50,
              width: double.infinity,
              height: double.infinity,
              child: data.isEmpty
                  ? const Center(child: Text('No data in this session yet.'))
                  : CustomPaint(
                      painter: ChartPainter(data),
                      child: const SizedBox.expand(),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
