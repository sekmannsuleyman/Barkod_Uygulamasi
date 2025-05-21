import 'package:dio/dio.dart';
import 'package:xml/xml.dart' as xml;

class UrunIdSorgulama {
  final Dio dio = Dio();
  final String endpoint =
      'http://195.175.82.182:8080/CaniasWS-v1/services/iasWebService';

  String? _sessionId; // login sadece 1 kez yapılacak

  // Otomatik session ID al (giriş yapıldı mı kontrol eder)
  Future<void> _ensureSession() async {
    if (_sessionId == null) {
      _sessionId = await _getSessionId();
      print("[LOGIN] Session alındı: $_sessionId");
    }
  }

  // Ürün sorgula fonksiyonu (login varsa tekrar yapılmaz)
  Future<List<Map<String, dynamic>>> urunSorgula(
    String urunId,
    bool benzerParti,
  ) async {
    await _ensureSession(); // login gerekiyorsa yap

    final String serviceName = 'BENZERURUN';
    final String parameter = '$urunId,${benzerParti ? '1' : '0'}';

    final String soapEnvelope = '''
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:web="http://web.ias.com">
  <soapenv:Header/>
  <soapenv:Body>
    <web:callIASService>
      <sessionid>$_sessionId</sessionid>
      <serviceid>$serviceName</serviceid>
      <args>$parameter</args>
      <returntype>STRING</returntype>
      <permanent>true</permanent>
    </web:callIASService>
  </soapenv:Body>
</soapenv:Envelope>
''';

    try {
      final response = await dio.post(
        endpoint,
        options: Options(
          headers: {
            'Content-Type': 'text/xml; charset=utf-8',
            'SOAPAction': '',
          },
        ),
        data: soapEnvelope,
      );

      print("[SOAP] Sorgu yapıldı: Status ${response.statusCode}");

      if (response.statusCode == 200) {
        final document = xml.XmlDocument.parse(response.data);
        final callReturn = document.findAllElements('callIASServiceReturn');

        if (callReturn.isEmpty) {
          throw Exception("SOAP cevabı bulunamadı.");
        }

        final rawXml = callReturn.first.text;
        if (rawXml.trim().isEmpty) {
          throw Exception("Boş XML cevabı geldi.");
        }

        final parsed = xml.XmlDocument.parse(rawXml);
        final rows = parsed.findAllElements('DATA');

        if (rows.isEmpty) {
          throw Exception("DATA etiketi yok.");
        }

        List<Map<String, dynamic>> result = [];

        for (var row in rows) {
          final map = <String, dynamic>{};

          for (var field in row.children.whereType<xml.XmlElement>()) {
            final key = field.name.toString();

            if (key == 'QUANTITY') {
              final doubleValue = double.tryParse(field.text) ?? 0.0;
              map[key] =
                  (doubleValue * 10).round().toString(); // 2203.2 → 22032
            } else {
              map[key] = field.text;
            }
          }

          result.add(map);
        }

        return result;
      } else {
        throw Exception("HTTP Hatası: ${response.statusCode}");
      }
    } catch (e) {
      print("[SOAP] HATA: $e");
      throw Exception("Ürün sorgulama başarısız: $e");
    }
  }

  // Giriş (login)
  Future<String> _getSessionId() async {
    final String loginEnvelope = '''
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
      final response = await dio.post(
        endpoint,
        options: Options(
          headers: {
            'Content-Type': 'text/xml; charset=utf-8',
            'SOAPAction': '',
          },
        ),
        data: loginEnvelope,
      );

      print("[LOGIN] Kod: ${response.statusCode}");

      if (response.statusCode == 200) {
        final document = xml.XmlDocument.parse(response.data);
        final sessionTag = document.findAllElements('loginReturn');
        if (sessionTag.isEmpty) {
          throw Exception("loginReturn etiketi bulunamadı.");
        }
        return sessionTag.first.text;
      } else {
        throw Exception("Login başarısız: HTTP ${response.statusCode}");
      }
    } catch (e) {
      print("[LOGIN] HATA: $e");
      throw Exception("Login işlemi başarısız: $e");
    }
  }
}
