import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

import 'parseXml.dart';
import 'utils.dart';

void main(List<String> arguments) async {
  String spdxId;

  //Handle valid Input by user
  if (arguments.isEmpty) {
    print('Enter a valid SPDX identifier');
    spdxId = stdin.readLineSync();
  } else if (arguments.length == 1) {
    spdxId = arguments[0];
  } else {
    coloredPrint('Enter only 1 valid SPDX identifier', TextColor.red, true);
    exit(0);
  }

  var progress = Progress();
  await progress.start('Fetching License ');

  // get license in xml format from the github repo
  var licenseResponse = await http.get(SpdxUrl(spdxId));

  try {
    if (licenseResponse.statusCode == 200) {
      progress.stop();
      var res = XmlDocument.parse(licenseResponse.body);

      print('\n');
      parseXml(res);

      exit(3);
    } else {
      print(
          '\x1B[31mError: Make sure that you input valid SPDX identifier\x1B[0m');
      exit(1);
    }
  } on Error catch (e) {
    coloredPrint('Error: ' + e.toString(), TextColor.red, true);
    exit(2);
  }
}
