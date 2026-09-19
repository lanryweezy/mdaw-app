import 'package:flutter_test/flutter_test.dart';
import 'package:studio_wiz/models/automation_system.dart';

void main() {
  test('AutomationLane binary search optimization test', () {
    final lane = AutomationLane(
      id: 'test',
      name: 'test',
      parameterType: AutomationParameterType.volume,
      targetId: 'test',
    );
    lane.addPoint(AutomationPoint(time: Duration(seconds: 1), value: 0.1));
    lane.addPoint(AutomationPoint(time: Duration(seconds: 2), value: 0.2));
    lane.addPoint(AutomationPoint(time: Duration(seconds: 3), value: 0.3));

    expect(lane.getValueAtTime(Duration(seconds: 0)), closeTo(0.1, 0.0001));
    expect(lane.getValueAtTime(Duration(seconds: 1)), closeTo(0.1, 0.0001));
    expect(lane.getValueAtTime(Duration(milliseconds: 1500)), closeTo(0.15, 0.0001));
    expect(lane.getValueAtTime(Duration(seconds: 2)), closeTo(0.2, 0.0001));
    expect(lane.getValueAtTime(Duration(milliseconds: 2500)), closeTo(0.25, 0.0001));
    expect(lane.getValueAtTime(Duration(seconds: 3)), closeTo(0.3, 0.0001));
    expect(lane.getValueAtTime(Duration(seconds: 4)), closeTo(0.3, 0.0001));
  });
}
