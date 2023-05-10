import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';

class PdfMain {
  static Future<File> saveDocument(
      {required String name, Document? pdf, List? byties}) async {
    final bytes;
    if (pdf != null) {
      bytes = await pdf.save();
    } else {
      bytes = byties;
    }

    Directory directory = Directory("");

    try {
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        final version = androidInfo.version.release;
        print(version);
        if (int.parse(version) <= 10
            ? (await _requestPermission(Permission.storage) &&
                await _requestPermission(Permission.accessMediaLocation))
            : (await _requestPermission(Permission.storage) &&
                await _requestPermission(Permission.accessMediaLocation) &&
                await _requestPermission(Permission.manageExternalStorage))) {
          directory = (await getExternalStorageDirectory())!;
          print("this is directory - ${directory.path}");
          String newPath = "";
          List<String> folders = directory.path.split("/");
          for (int i = 1; i < folders.length; i++) {
            String folder = folders[i];
            if (folder != "Android") {
              newPath += "/" + folder;
            } else {
              break;
            }
          }
          newPath = newPath + "/VanSale";
          if (pdf != null) {
            newPath = newPath + '/sales';
          } else {
            newPath = newPath + '/salesreport';
          }
          directory = Directory(newPath);
        } else {}
      } else {}

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      if (await directory.exists()) {
        final file = File('${directory.path}/$name.pdf');
        await file.writeAsBytes(bytes);
        return file;
      }
    } catch (e) {
      print(e);
    }
    throw Exception("gdgd");
  }

  static Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result == PermissionStatus.granted) {
        return true;
      } else {
        return false;
      }
    }
  }

  static Future openFile(File file) async {
    final url = file.path;

    await OpenFile.open(url);
  }
}
