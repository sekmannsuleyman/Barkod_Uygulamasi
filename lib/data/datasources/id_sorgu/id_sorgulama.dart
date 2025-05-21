import 'package:dio/dio.dart';
import 'package:xml/xml.dart' as xml;

class IdSorgulama {
  final Dio dio = Dio();
  final String endpoint = 'http://195.175.82.182:8080/CaniasWS-v1/services/iasWebService';
  String? _sessionId;

  Future<void> _ensureSession() async {
    _sessionId ??= await _getSessionId();
  }

  Future<String> _getSessionId() async {
    final String envelope = '''
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
''';

    try {
      print('Oturum açma isteği gönderiliyor...');
      print('Gönderilen XML: $envelope');
      final response = await dio.post(
        endpoint,
        options: Options(
          headers: {'Content-Type': 'text/xml; charset=utf-8', 'SOAPAction': ''},
        ),
        data: envelope,
      );

      print('Oturum açma cevabı alındı: ${response.statusCode} - ${response.data}');

      if (response.statusCode == 200) {
        final document = xml.XmlDocument.parse(response.data);
        final sessionId = document.findAllElements('loginReturn').firstOrNull?.text;
        if (sessionId == null || sessionId.isEmpty) {
          throw Exception('Oturum açılamadı: Sunucudan geçerli bir oturum ID\'si alınamadı.');
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

  Future<List<Map<String, dynamic>>> idSorgula(String id) async {
    await _ensureSession();

    final String envelope = '''
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:web="http://web.ias.com">
  <soapenv:Header/>
  <soapenv:Body>
    <web:callIASService>
      <sessionid>$_sessionId</sessionid>
      <serviceid>IDSORGULA</serviceid>
      <args>$id</args>
      <returntype>STRING</returntype>
      <permanent>true</permanent>
    </web:callIASService>
  </soapenv:Body>
</soapenv:Envelope>
''';

    try {
      print('ID sorgu isteği gönderiliyor...');
      print('Gönderilen XML: $envelope');
      final response = await dio.post(
        endpoint,
        options: Options(
          headers: {'Content-Type': 'text/xml; charset=utf-8', 'SOAPAction': ''},
        ),
        data: envelope,
      );

      print('IDSORGULA Cevabı: ${response.statusCode} - ${response.data}');

      if (response.statusCode == 200) {
        final document = xml.XmlDocument.parse(response.data);
        final resultElement = document.findAllElements('callIASServiceReturn').firstOrNull;

        if (resultElement == null || resultElement.text.trim().isEmpty) {
          throw Exception('Kayıt bulunamadı.');
        }

        final parsed = xml.XmlDocument.parse(resultElement.text);
        final rows = parsed.findAllElements('DATA');

        List<Map<String, dynamic>> veriler = [];

        for (var row in rows) {
          final map = <String, dynamic>{};
          for (var field in row.children.whereType<xml.XmlElement>()) {
            final key = field.name.toString();
            if (key == 'QUANTITY') {
              final val = double.tryParse(field.text) ?? 0.0;
              print('Ham QUANTITY değeri: ${field.text}, Çarpılmış değer: ${(val * 100).round()}');
              map[key] = (val * 100).round().toString(); // 100 ile çarp ve tam sayıya yuvarla
            } else {
              map[key] = field.text;
            }
          }
          veriler.add(map);
        }

        return veriler;
      } else {
        throw Exception("Servis hatası: ${response.statusCode}");
      }
    } catch (e) {
      print('IDSORGULA hata: $e');
      if (e is DioException && e.response != null) {
        print('Sunucu cevabı: ${e.response?.statusCode} - ${e.response?.data}');
      }
      throw Exception(e.toString());
    }
  }
}