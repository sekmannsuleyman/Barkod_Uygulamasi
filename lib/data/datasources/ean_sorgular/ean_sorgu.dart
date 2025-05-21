import 'package:dio/dio.dart';
import 'package:xml/xml.dart';

import '../../entity/ean_model/ean_model_bilgi.dart';

class EanSorgu{
  final Dio dio = Dio();
  Future<List<EanModel>> callEanSorgu(String eanNo) async {
    final sessionId = await _login();
    if (sessionId == null) throw Exception("Giriş başarısız.");

    final argsXml = eanNo;
    const serviceId = "EANSORGU";

    final soapEnvelope = '''
<?xml version="1.0" encoding="utf-8"?>
<soapenv:Envelope xmlns:soapenv="ht/">
  <soapenv:Body>
    <callIASService xmlns="">
      <sessionid></sessionid>
      <serviceid></serviceid>
      <args><></args>
      <returntype>STRING</returntype>
      <permanent>true</permanent>
    </callIASService>
  </soapenv:Body>
</soapenv:Envelope>
''';

    try {
      final response = await dio.post(
        '',
        data: soapEnvelope,
        options: Options(headers: {
          'Content-Type': 'text/xml; charset=utf-8',
          'SOAPAction': '',
        }),
      );

      // Ham XML verisini logla
      print('[SOAP] Ham XML: ${response.data}');

      final outerXml = XmlDocument.parse(response.data.toString());
      final innerCdata = outerXml.findAllElements('callIASServiceReturn').first.text;
      print('[SOAP] İç CDATA: $innerCdata');

      if (innerCdata.trim().isEmpty) {
        print('[SOAP] İç CDATA boş!');
        return [];
      }

      try {
        final innerXml = XmlDocument.parse(innerCdata);
        final params = innerXml.findAllElements('DATA');
        if (params.isEmpty) {
          print('[SOAP] DATA etiketi bulunamadı!');
          return [];
        }

        // Her bir DATA etiketini logla
        return params.map((e) {
          final aciklama = e.findElements('STEXT').isNotEmpty ? e.findElements('STEXT').first.text.trim() : '';
          final kod = e.findElements('MATERIAL').isNotEmpty ? e.findElements('MATERIAL').first.text.trim() : '';
          final miktar = e.findElements('QUANTITY').isNotEmpty ? e.findElements('QUANTITY').first.text.trim() : '';
          print('[SOAP] DATA: Açıklama=$aciklama, Kod=$kod, Miktar=$miktar');
          return EanModel.fromXml(e);
        }).toList();
      } catch (e) {
        print('[XML Parse Hatası]: $e');
        return [];
      }
    } catch (e) {
      print('[SOAP Hata]: $e');
      return [];
    } finally {
      await _logout(sessionId);
    }
  }
  Future<String?> _login() async {
    const loginEnvelope = '''
<?xml version="1.0" encoding="utf-8"?>
<soapenv:Envelope xmlns:soapenv="h">
  <soapenv:Body>
    <login xmlns="">
      <p_strClient></p_strClient>
      <p_strLanguage>E</p_strLanguage> <!-- Türkçe yerine İngilizce -->
      <p_strDBName></p_strDBName>
      <p_strDBServer></p_strDBServer>
      <p_strAppServer></p_strAppServer>
      <p_strUserName></p_strUserName>
      <p_strPassword></p_strPassword>
    </login>
  </soapenv:Body>
</soapenv:Envelope>
''';

    final response = await dio.post(
      '',
      data: loginEnvelope,
      options: Options(headers: {
        'Content-Type': 'text/xml; charset=utf-8',
        'SOAPAction': '',
      }),
    );

    final loginXml = XmlDocument.parse(response.data);
    return loginXml.findAllElements('loginReturn').first.text;
  }
  Future<void> _logout(String sessionId) async {
    final logoutEnvelope = '''
<?xml version="1.0" encoding="utf-8"?>
<soapenv:Envelope xmlns:soapenv="/">
  <soapenv:Body>
    <logout xmlns="">
      <p_strSessionId>$sessionId</p_strSessionId>
    </logout>
  </soapenv:Body>
</soapenv:Envelope>
''';

    await dio.post(
      '',
      data: logoutEnvelope,
      options: Options(headers: {
        'Content-Type': 'text/xml; charset=utf-8',
        'SOAPAction': '',
      }),
    );
  }




}
