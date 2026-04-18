import re

with open('lib/services/enhanced_audio_processing_service.dart', 'r') as f:
    content = f.read()

# Fix ReturnCode issues
content = content.replace("ReturnCode.isSuccess(returnCode)", "returnCode?.isValueSuccess() == true")
content = content.replace("ReturnCode.isSuccess(mixReturnCode)", "mixReturnCode?.isValueSuccess() == true")
content = content.replace("ReturnCode.isSuccess(masterReturnCode)", "masterReturnCode?.isValueSuccess() == true")
content = content.replace("ReturnCode.isSuccess(alignReturnCode)", "alignReturnCode?.isValueSuccess() == true")
content = content.replace("ReturnCode.isSuccess(processReturnCode)", "processReturnCode?.isValueSuccess() == true")
content = content.replace("ReturnCode.isSuccess(finalReturnCode)", "finalReturnCode?.isValueSuccess() == true")

# Clean up temp files logic
if "Future<void> _cleanTempFiles" not in content:
    content = content.replace("}\n", """
  Future<void> _cleanTempFiles(List<String> paths) async {
    for (final path in paths) {
      try {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        print('Failed to delete temp file: $path');
      }
    }
  }
}
""")

with open('lib/services/enhanced_audio_processing_service.dart', 'w') as f:
    f.write(content)
