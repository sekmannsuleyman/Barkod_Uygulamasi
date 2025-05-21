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
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
  <soapenv:Body>
    <callIASService xmlns="http://192.168.0.6:8080/CaniasWS-v1/services/iasWebService">
      <sessionid>$sessionId</sessionid>
      <serviceid>$serviceId</serviceid>
      <args><![CDATA[$argsXml]]></args>
      <returntype>STRING</returntype>
      <permanent>true</permanent>
    </callIASService>
  </soapenv:Body>
</soapenv:Envelope>
''';

    try {
      final response = await dio.post(
        'http://195.175.82.182:8080/CaniasWS-v1/services/iasWebService',
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
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
  <soapenv:Body>
    <login xmlns="http://195.175.82.182:8080/CaniasWS-v1/services/iasWebService">
      <p_strClient>00</p_strClient>
      <p_strLanguage>E</p_strLanguage> <!-- Türkçe yerine İngilizce -->
      <p_strDBName>BIEN802</p_strDBName>
      <p_strDBServer>CANIAS</p_strDBServer>
      <p_strAppServer>195.175.82.182:27499</p_strAppServer>
      <p_strUserName>BIENURETIM</p_strUserName>
      <p_strPassword>kp2010</p_strPassword>
    </login>
  </soapenv:Body>
</soapenv:Envelope>
''';

    final response = await dio.post(
      'http://195.175.82.182:8080/CaniasWS-v1/services/iasWebService',
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
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
  <soapenv:Body>
    <logout xmlns="http://195.175.82.182:8080/CaniasWS-v1/services/iasWebService">
      <p_strSessionId>$sessionId</p_strSessionId>
    </logout>
  </soapenv:Body>
</soapenv:Envelope>
''';

    await dio.post(
      'http://195.175.82.182:8080/CaniasWS-v1/services/iasWebService',
      data: logoutEnvelope,
      options: Options(headers: {
        'Content-Type': 'text/xml; charset=utf-8',
        'SOAPAction': '',
      }),
    );
  }




}