import 'package:firebase_performance/firebase_performance.dart';
import 'package:kidsplay/src/service/crashlytics_service.dart';

class PerformanceService {
  static final FirebasePerformance _performance = FirebasePerformance.instance;

  static Future<void> initialize() async {
    if (!(await _performance.isPerformanceCollectionEnabled())) {
      await _performance.setPerformanceCollectionEnabled(true);
    }
  }

  static Trace startTrace(String traceName) {
    final Trace trace = _performance.newTrace(traceName);
    trace.start();
    return trace;
  }

  static Future<void> stopTrace(Trace trace) async {
    try {
      await trace.stop();
    } catch (e) {
      _logError('stopTrace', e);
    }
  }

  static void _logError(
    String methodName,
    dynamic error, {
    Map<String, String>? additionalInfo,
  }) {
    CrashlyticsService.logError(
      error,
      reason: 'Error in $methodName',
      requestBody: additionalInfo?.toString(),
    );
  }
}
