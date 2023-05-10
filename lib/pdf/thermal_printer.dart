import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:image/image.dart' as Imag;
import 'package:native_pdf_renderer/native_pdf_renderer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';
import 'package:vansales/pdf/invoice_model.dart';
import 'package:vansales/pdf/thermal.dart';

class ThermalPrinter {
  Future<List<int>> testTicket(Invoice invoice, String name, String companyName,
      String companyNameA, String addressA, String vatNo, String phone) async {
    List<int> bytes = [];
    // Using default profile
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    //bytes += generator.setGlobalFont(PosFontType.fontA);
    bytes += generator.reset();

    // final ByteData data = await rootBundle.load('assets/images/printlogo.png');
    // final Uint8List bytesImg = data.buffer.asUint8List();
    // final image = Imag.decodeImage(bytesImg);

    // final pdfData = await Thermal.generate(invoice);
    // final document = await PdfDocument.openData(pdfData);
    // final page = await document.getPage(1);
    // final pageImage = await page.render(
    //     width: page.width,
    //     height: page.height,
    //   format: PdfPageFormat.PNG,
    //
    // );
    // await page.close();

    /// ***** PDF TO IMAGE *****
    var pdfImage;
    await for (var page in Printing.raster(
        await Thermal.generate(
            invoice, name, companyName, companyNameA, addressA, vatNo, phone),
        dpi: 190)) {
      pdfImage = page.toPng(); // ...or page.toPng()
      print(pdfImage);
      //bytes += generator.image(pdfImage);
    }

    // final document = await PdfDocument.openData(await Thermal.generate(invoice, name, companyNameA, addressA, vatNo, phone));
    // final page = await document.getPage(1);
    // final pageImage = await page.render(width: 610, height: 800);
    // await page.close();

    ///fhyjju

    // Directory directory = Directory("");
    // if(Platform.isAndroid) {
    //   if(await _requestPermission(Permission.storage) && await _requestPermission(Permission.accessMediaLocation) && await _requestPermission(Permission.manageExternalStorage)) {
    //     directory = (await getExternalStorageDirectory())!;
    //     print(directory.path);
    //     String newPath = "";
    //     List<String> folders = directory.path.split("/");
    //     for(int i = 1; i < folders.length; i++) {
    //       String folder = folders[i];
    //       if(folder != "Android") {
    //         newPath += "/"+ folder;
    //       } else {
    //         break;
    //       }
    //     }
    //     newPath = newPath+"/VanSale";
    //
    //     directory = Directory(newPath);
    //   } else {
    //
    //   }
    // }

    // File imgfile = File('${directory.path}/screen.png');
    // imgfile.writeAsBytes(await pdfImage);
    // print("moneeeee saved");

    ///htytyt
    // final pimage = pageImage?.bytes;
    Imag.Image? imagefile = Imag.decodePng(await pdfImage);

    bytes += generator.image(imagefile!);

    /// *****

    // Using `ESC *`
    //
    // bytes += generator.text(companyName,
    //     styles: PosStyles(align: PosAlign.center, bold: true, height: PosTextSize.size2, width: PosTextSize.size2));
    //
    // bytes += generator.text(address,
    //     styles: PosStyles(align: PosAlign.center));
    //
    // bytes += generator.text('Vat No: $vatNo',
    //     styles: PosStyles(align: PosAlign.center));
    //
    // bytes += generator.text('phone no: $phone',
    //     styles: PosStyles(align: PosAlign.center));
    //
    // bytes += generator.hr();
    //
    // bytes += generator.text('Simplified Tax Invoice',
    //     styles: PosStyles(align: PosAlign.center));
    // bytes += generator.hr();

    // bytes += generator.row([
    //   PosColumn(text: 'Bill No: ${invoice.id}', width: 6, styles: PosStyles(align: PosAlign.left)),
    //   PosColumn(text: 'Time: $time', width: 6, styles: PosStyles(align: PosAlign.right))
    // ]);
    //
    // bytes += generator.row([
    //   PosColumn(text: 'Date: $date', width: 6, styles: PosStyles(align: PosAlign.left)),
    //   PosColumn(text: name, width: 6, styles: PosStyles(align: PosAlign.right))
    // ]);
    //
    // bytes += generator.hr();

    /// *******
    // bytes += generator.row([
    //   PosColumn(text: 'ANo', width: 3, styles: PosStyles(align: PosAlign.left)),
    //   PosColumn(text: 'AQty', width: 3, styles: PosStyles(align: PosAlign.center)),
    //   PosColumn(text: 'APrice', width: 3, styles: PosStyles(align: PosAlign.center)),
    //   PosColumn(text: 'ATotal', width: 3, styles: PosStyles(align: PosAlign.right)),
    // ]);
    ///*******

    // bytes += generator.row([
    //   PosColumn(text: 'No', width: 3, styles: PosStyles(align: PosAlign.left)),
    //   PosColumn(text: 'Qty', width: 3, styles: PosStyles(align: PosAlign.center)),
    //   PosColumn(text: 'Price', width: 3, styles: PosStyles(align: PosAlign.center)),
    //   PosColumn(text: 'Total', width: 3, styles: PosStyles(align: PosAlign.right)),
    // ]);
    //
    // bytes += generator.hr();
    //
    // for(int i = 0; i < invoice.items.length; i++){
    //   bytes += generator.text(invoice.items[i].description, styles: PosStyles(align: PosAlign.left));
    //
    //   bytes += generator.row([
    //     PosColumn(text: '${invoice.items[i].no}', width: 3, styles: PosStyles(align: PosAlign.left)),
    //     PosColumn(text: '${invoice.items[i].quantity}', width: 3, styles: PosStyles(align: PosAlign.center)),
    //     PosColumn(text: invoice.items[i].unitprice.toStringAsFixed(2), width: 3, styles: PosStyles(align: PosAlign.center)),
    //     PosColumn(text: (invoice.items[i].quantity * (invoice.items[i].unitprice + (invoice.items[i].vat * invoice.items[i].unitprice))).toStringAsFixed(2), width: 3, styles: PosStyles(align: PosAlign.right)),
    //   ]);
    // }
    //
    // bytes += generator.hr();
    //
    // bytes += generator.row([
    //   PosColumn(text: 'Total Amount', width: 6, styles: PosStyles(align: PosAlign.left)),
    //   PosColumn(text: invoice.price.totalamt.toStringAsFixed(2), width: 6, styles: PosStyles(align: PosAlign.right))
    // ]);
    //
    // bytes += generator.row([
    //   PosColumn(text: 'Vat Amount', width: 6, styles: PosStyles(align: PosAlign.left)),
    //   PosColumn(text: invoice.price.vat.toStringAsFixed(2), width: 6, styles: PosStyles(align: PosAlign.right))
    // ]);
    //
    // bytes += generator.row([
    //   PosColumn(text: 'Net Amount', width: 6, styles: PosStyles(align: PosAlign.left, bold: true, fontType: PosFontType.fontA)),
    //   PosColumn(text: invoice.price.netamt.toStringAsFixed(2), width: 6, styles: PosStyles(align: PosAlign.right, bold: true, fontType: PosFontType.fontA))
    // ]);
    //
    // bytes += generator.hr();
    // bytes += generator.qrcode('${invoice.id}');
    // bytes += generator.hr();
    // bytes += generator.text('Thank you for visit, Come again', styles: PosStyles(align: PosAlign.center));
    // bytes += generator.hr();
    // bytes += generator.hr();

    bytes += generator.feed(2);
    //bytes += generator.cut();
    return bytes;
  }
}
