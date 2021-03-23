import 'dart:io';

import 'dart:isolate';

/// returns the Url for License in XML format from the github Repository
Uri SpdxUrl(license) => Uri.parse(
    'https://raw.githubusercontent.com/spdx/license-list-XML/master/src/$license.xml');

/// text colors for coloredPrint
enum TextColor { red, blue, green, white }

extension on TextColor {
  /// returns ansi code for Text Color in coloredPrint
  String get code {
    switch (this) {
      case (TextColor.red):
        return '\x1B[31m';

      case (TextColor.blue):
        return '\x1B[34m';

      case (TextColor.green):
        return '\x1B[32m';
      default:
        return '';
    }
  }
}

/// prints colored string in Console
void coloredPrint(String text, TextColor color, [bool lineBreak = false]) {
  lineBreak
      ? print(color.code + text + '\x1B[0m')
      : stdout.write(color.code + text + '\x1B[0m');
}

//show progress is being done
class Progress {
  Isolate isolate;
  ReceivePort receivePort;

  Future<void> start(String msg) async {
    receivePort = ReceivePort();
    isolate = await Isolate.spawn(_showProgress, receivePort.sendPort);
    receivePort.listen((message) {
      coloredPrint(msg + message + '\r', TextColor.green);
    });
  }

  static Future<void> _showProgress(SendPort sendPort) async {
    var list = ['\ ', ' ', '|', ' ', '-', ' ', '/', ' ', '-', ' '];
    for (var i = 0;; i++) {
      sendPort.send(list[i % list.length]);
      await Future.delayed(Duration(milliseconds: 100));
    }
  }

  void stop() {
    if (isolate != null) {
      isolate.kill(priority: Isolate.immediate);
      isolate = null;
    }
  }
}
