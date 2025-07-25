import 'package:flutter_speed_test_plus/src/speed_test_utils.dart';
import 'package:flutter_speed_test_plus/src/test_result.dart';

import 'callbacks_enum.dart';
import 'flutter_speed_test_plus_platform_interface.dart';
import 'models/server_selection_response.dart';

typedef DefaultCallback = void Function();
typedef ResultCallback = void Function(TestResult upload);
typedef TestProgressCallback = void Function(double percent, TestResult data);
typedef ResultCompletionCallback = void Function(TestResult data);
typedef DefaultServerSelectionCallback = void Function(Client? client);

class FlutterInternetSpeedTest {
  static const _defaultDownloadTestServer =
      'http://speedtest.ftp.otenet.gr/files/test10Mb.db';
  static const _defaultUploadTestServer = 'http://speedtest.ftp.otenet.gr/';
//  static int defaultFileSize = 10 * 1024 * 1024; //10 MB

  static final FlutterInternetSpeedTest _instance =
      FlutterInternetSpeedTest._private();

  bool _isTestInProgress = false;
  bool _isCancelled = false;

  factory FlutterInternetSpeedTest() => _instance;

  FlutterInternetSpeedTest._private();

  bool isTestInProgress() => _isTestInProgress;

  Future<void> startTesting({
    required ResultCallback onCompleted,
    DefaultCallback? onStarted,
    ResultCompletionCallback? onUploadComplete,
    TestProgressCallback? onProgress,
    DefaultCallback? onDefaultServerSelectionInProgress,
    DefaultServerSelectionCallback? onDefaultServerSelectionDone,
    ErrorCallback? onError,
    CancelCallback? onCancel,
    String? downloadTestServer,
    String? uploadTestServer,
    int fileSizeInBytes = 256 * 1024,
    bool useFastApi = true,
  }) async {
    if (_isTestInProgress) {
      return;
    }
    if (await isInternetAvailable() == false) {
      if (onError != null) {
        onError('No internet connection', 'No internet connection');
      }
      return;
    }

    _isTestInProgress = true;

    if (onStarted != null) onStarted();

    if ((downloadTestServer == null || uploadTestServer == null) &&
        useFastApi) {
      if (onDefaultServerSelectionInProgress != null) {
        onDefaultServerSelectionInProgress();
      }
      final serverSelectionResponse =
          await FlutterInternetSpeedTestPlatform.instance.getDefaultServer();

      if (onDefaultServerSelectionDone != null) {
        onDefaultServerSelectionDone(serverSelectionResponse?.client);
      }
      String? url = serverSelectionResponse?.targets?.first.url;
      if (url != null) {
        downloadTestServer = downloadTestServer ?? url;
        uploadTestServer = uploadTestServer ?? url;
      }
    }
    if (downloadTestServer == null || uploadTestServer == null) {
      downloadTestServer = downloadTestServer ?? _defaultDownloadTestServer;
      uploadTestServer = uploadTestServer ?? _defaultUploadTestServer;
    }

    if (_isCancelled) {
      if (onCancel != null) {
        onCancel();
        _isTestInProgress = false;
        _isCancelled = false;
        return;
      }
    }

    final startUploadTimeStamp = DateTime.now().millisecondsSinceEpoch;
    FlutterInternetSpeedTestPlatform.instance.startUploadTesting(
      onDone: (double transferRate, SpeedUnit unit) {
        final uploadDuration =
            DateTime.now().millisecondsSinceEpoch - startUploadTimeStamp;
        final uploadResult = TestResult(TestType.upload, transferRate, unit,
            durationInMillis: uploadDuration);

        if (onProgress != null) onProgress(100, uploadResult);
        if (onUploadComplete != null) onUploadComplete(uploadResult);

        onCompleted(uploadResult);
        _isTestInProgress = false;
        _isCancelled = false;
      },
      onProgress: (double percent, double transferRate, SpeedUnit unit) {
        final uploadProgressResult =
            TestResult(TestType.upload, transferRate, unit);
        if (onProgress != null) {
          onProgress(percent, uploadProgressResult);
        }
      },
      onError: (String errorMessage, String speedTestError) {
        if (onError != null) onError(errorMessage, speedTestError);
        _isTestInProgress = false;
        _isCancelled = false;
      },
      onCancel: () {
        if (onCancel != null) onCancel();
        _isTestInProgress = false;
        _isCancelled = false;
      },
      fileSize: fileSizeInBytes,
      testServer: uploadTestServer,
    );
  }

  void enableLog() {
    FlutterInternetSpeedTestPlatform.instance.toggleLog(value: true);
  }

  void disableLog() {
    FlutterInternetSpeedTestPlatform.instance.toggleLog(value: false);
  }

  Future<bool> cancelTest() async {
    _isCancelled = true;
    return await FlutterInternetSpeedTestPlatform.instance.cancelTest();
  }

  bool get isLogEnabled => FlutterInternetSpeedTestPlatform.instance.logEnabled;
}
