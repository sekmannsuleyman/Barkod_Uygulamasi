import 'package:dio/dio.dart';
import 'package:xml/xml.dart' as xml;

class EmirKalanSorgu {
  final Dio dio = Dio(
    BaseOptions(
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
    ),
  );
  final String endpoint =
      'http://195.175.82.182:8080/CaniasWS-v1/services/iasWebService';
  String? _sessionId;

  Future<List<Map<String, String>>> kaydetEmirKalanCubit(String emirNo) async {
    if (emirNo.length != 12) throw Exception("Emir No 12 karakter olmalıdır.");
    await _ensureSession();

    final tesis = emirNo.substring(0, 2);
    final emir = emirNo.substring(2, 10);
    final kalem = emirNo.substring(10, 12);
    final parametre = "$tesis,$emir,$kalem";

    final String envelope =
        '''
<?xml version="1.0" encoding="utf-8"?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:web="http://web.ias.com">
  <soapenv:Header/>
  <soapenv:Body>
    <web:callIASService>
      <sessionid>$_sessionId</sessionid>
      <serviceid>MTRANSFERKALAN</serviceid>
      <args>$parametre</args>
      <returntype>STRING</returntype>
      <permanent>true</permanent>
    </web:callIASService>
  </soapenv:Body>
</soapenv:Envelope>
'''.trim();

    try {
      print('Emir kalan sorgusu gönderiliyor...');
      print('Gönderilen XML: $envelope');
      print('Parametre: $parametre');
      final response = await dio.post(
        endpoint,
        options: Options(
          headers: {
            'Content-Type': 'text/xml; charset=utf-8',
            'SOAPAction': '',
          },
        ),
        data: envelope,
      );

      print('MTRANSFERKALAN Cevabı: ${response.statusCode} - ${response.data}');

      if (response.statusCode == 200) {
        final document = xml.XmlDocument.parse(response.data);
        final resultText =
            document.findAllElements('callIASServiceReturn').firstOrNull?.text;
        if (resultText == null || resultText.isEmpty) {
          throw Exception("İşlem başarısız: Sunucudan veri alınamadı.");
        }

        final dataDoc = xml.XmlDocument.parse(resultText);
        final rows = dataDoc.findAllElements('row');
        List<Map<String, String>> results = [];

        for (var row in rows) {
          final fields = <String, String>{};
          for (var element in row.children.whereType<xml.XmlElement>()) {
            fields[element.name.toString()] = element.text;
          }
          results.add(fields);
        }

        return results;
      } else {
        throw Exception("Servis bağlantı hatası: ${response.statusCode}");
      }
    } catch (e) {
      print('MTRANSFERKALAN hata: $e');
      if (e is DioException && e.response != null) {
        print('Sunucu cevabı: ${e.response?.statusCode} - ${e.response?.data}');
      }
      throw Exception('Emir kalan sorgusu hatası: $e');
    }
  }

  Future<void> _ensureSession() async {
    _sessionId ??= await _getSessionId();
  }

  Future<String> _getSessionId() async {
    final String envelope =
        '''
<?xml version="1.0" encoding="utf-8"?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:web="http://web.ias.com">
  <soapenv:Header/>
  <soapenv:Body>
    <web:login>
      <p_strClient>00</p_strClient>
      <p_strLanguage>T</p_strLanguage>
      <p_strDBName>BIEN802</p_strDBName>
      <p_strDBServer>CANIAS</p_strDBServer>
      <p_strAppServer>195.175.82.182:27499</p_strAppServer>
      <p_strUserName>BIENURETIM</p_strUserName>
      <p_strPassword>kp2010</p_strPassword>
    </web:login>
  </soapenv:Body>
</soapenv:Envelope>
'''.trim();

    try {
      print('Oturum açma isteği gönderiliyor...');
      print('Gönderilen XML: $envelope');
      final response = await dio.post(
        endpoint,
        options: Options(
          headers: {
            'Content-Type': 'text/xml; charset=utf-8',
            'SOAPAction': '',
          },
        ),
        data: envelope,
      );

      print(
        'Oturum açma cevabı alındı: ${response.statusCode} - ${response.data}',
      );

      if (response.statusCode == 200) {
        final document = xml.XmlDocument.parse(response.data);
        final sessionId =
            document.findAllElements('loginReturn').firstOrNull?.text;
        if (sessionId == null || sessionId.isEmpty) {
          throw Exception(
            "Oturum açılamadı: Sunucudan geçerli bir oturum ID'si alınamadı.",
          );
        }
        return sessionId;
      } else {
        throw Exception('Oturum açma başarısız: ${response.statusCode}');
      }
    } catch (e) {
      print('Oturum açma hatası: $e');
      if (e is DioException && e.response != null) {
        print('Sunucu cevabı: ${e.response?.statusCode} - ${e.response?.data}');
      }
      throw Exception('Oturum açma hatası: $e');
    }
  }
}
