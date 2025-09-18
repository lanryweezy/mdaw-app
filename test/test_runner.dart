import 'package:flutter_test/flutter_test.dart';

// Import all test files
import 'view_models/daw_view_model_test.dart' as daw_view_model_test;
import 'view_models/timeline_view_model_test.dart' as timeline_view_model_test;
import 'services/audio_processing_service_test.dart' as audio_processing_service_test;
import 'widgets/timeline_editor_test.dart' as timeline_editor_test;
import 'screens/enhanced_daw_screen_test.dart' as enhanced_daw_screen_test;
import 'screens/settings_screen_test.dart' as settings_screen_test;
import 'models/track_test.dart' as track_test;

void main() {
  group('ProStudio DAW Test Suite', () {
    group('View Models', () {
      daw_view_model_test.main();
      timeline_view_model_test.main();
    });

    group('Services', () {
      audio_processing_service_test.main();
    });

    group('Widgets', () {
      timeline_editor_test.main();
    });

    group('Screens', () {
      enhanced_daw_screen_test.main();
      settings_screen_test.main();
    });

    group('Models', () {
      track_test.main();
    });
  });
}
