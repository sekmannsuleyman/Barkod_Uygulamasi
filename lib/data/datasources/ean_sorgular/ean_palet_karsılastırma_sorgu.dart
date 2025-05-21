import 'package:dio/dio.dart';
import 'package:xml/xml.dart';

import '../../../ui/cubit/ean_sorgu_cubit/ean_palet_karsilastirma_cubit.dart';

class EanPaletKarsilastirmaSorgu{
  final Dio dio = Dio();

  Future<EanPaletKarsilastirmaState> karsilastirEanPalet(String paletId, String eanNo) async {
    try {
      // Palet ID'den EAN çek (Veritabanı yerine SOAP dummy)
      final dbEan = await _eanFromPaletId(paletId);
      if (dbEan == null) {
        return EanPaletKarsilastirmaState(
          mesaj: "Palet ID veritabanında bulunamadı.",
          hata: true,
        );
      }

      if (eanNo == dbEan) {
        return EanPaletKarsilastirmaState(
          mesaj: "Ean ve Palet ID benzer.",
          hata: false,
        );
      } else {
        return EanPaletKarsilastirmaState(
          mesaj: "Ean ve Palet ID uyuşmuyor.!",
          hata: true,
        );
      }
    } catch (e) {
      return EanPaletKarsilastirmaState(
        mesaj: "Ean ve Palet ID FARKLI.!",
        hata: true,
      );
    }
  }

  Future<String?> _eanFromPaletId(String paletId) async {
    const serviceId = ""; // dummy olarak
    final argsXml = paletId;

    final requestXml = '''
<soapenv:Envelope xmlns:soapenv="">
  <soapenv:Body>
    <callIASService xmlns="">
      <sessionid>dummy-session</sessionid>
      <serviceid>$serviceId</serviceid>
      <args><![CDATA[$argsXml]]></args>
      <returntype>STRING</returntype>
      <permanent>true</permanent>
    </callIASService>
  </soapenv:Body>
</soapenv:Envelope>
''';

    final response = await dio.post(
      '',
      data: requestXml,
      options: Options(headers: {
        'Content-Type': 'text/xml; charset=utf-8',
        'SOAPAction': '',
      }),
    );

    final outer = XmlDocument.parse(response.data);
    final innerCdata = outer.findAllElements('callIASServiceReturn').first.text;
    final innerXml = XmlDocument.parse(innerCdata);
    final eanCode = innerXml.findAllElements('EANCODE').first.text.trim();
    return eanCode;
  }


}
