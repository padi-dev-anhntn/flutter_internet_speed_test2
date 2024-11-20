<div align="center">

# flutter_internet_speed_test 2.0

A Flutter plugin to test internet download and upload speeds. This is the updated version `2.0` with
added features and improvements.

## Breaking Changes in 2.0

- The API has been updated to support custom download and upload test servers.
- Error handling and progress tracking have been improved.

## Getting Started

Add the following dependency to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_internet_speed_test_2.0: ^1.0.0
  
  Example
  
import 'package:flutter_internet_speed_test/flutter_internet_speed_test.dart';

void main() {
  final speedTest = FlutterInternetSpeedTest(
    customDownloadServer: 'https://customdownloadserver.com',
    customUploadServer: 'https://customuploadserver.com',
  );

  speedTest.startTesting(
    onStarted: () {
      print('Test started');
    },
    onCompleted: (download, upload) {
      print('Download Speed: ${download.speed} Mbps');
      print('Upload Speed: ${upload.speed} Mbps');
    },
    onProgress: (percent) {
      print('Progress: ${percent * 100}%');
    },
    onError: (errorMessage) {
      print('Error: $errorMessage');
    },
    onCancel: () {
      print('Test cancelled');
    },
  );
}

New Features in Version 2.0:
Custom Server Support: Specify custom servers for both download and upload tests.
Improved Error Handling: Get detailed error messages if the test fails.
Progress Updates: Track test progress with real-time updates.
Platforms
Android
iOS
shell
Copy code
### **Step 5: Update `CHANGELOG.md`**

Add a changelog entry for version 2.0:

```markdown
## [2.0.0] - 2024-11-20
### Added
- Support for custom download and upload test servers.
- Improved error handling with detailed messages.
- Enhanced progress tracking during tests.

### Changed
- Updated the API for better flexibility and performance.

### Removed
- Deprecated old methods that are no longer needed.