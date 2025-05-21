import 'package:dio/dio.dart';
import 'package:xml/xml.dart' as xml;

class SevkiyatYukleme {
  final Dio dio = Dio(BaseOptions(
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 10),
  ));
  final String endpoint = 'e';
  String? _sessionId;

  // Oturum ID’sini kontrol eder ve yoksa alır
  Future<void> _ensureSession() async {
    _sessionId ??= await _getSessionId();
  }

  // Oturum ID’sini alır
  Future<String> _getSessionId() async {
    const username = "";
    const password = "";

    final loginEnvelope = '''
<?xml version="1.0" encoding="utf-8"?>
<soapenv:Envelope xmlns:soapenv="http/envelope/" xmlns:web="http:">
  <soapenv:Header/>
  <soapenv:Body>
    <web:login>
      <p_strClient></p_strClient>
      <p_strLanguage></p_strLanguage>
      <p_strDBName></p_strDBName>
      <p_strDBServer></p_strDBServer>
      <p_strAppServer></p_strAppServer>
      <p_strUserName>$</p_strUserName>
      <p_strPassword>$</p_strPassword>
    </web:login>
  </soapenv:Body>
</soapenv:Envelope>
'''.trim();

    try {
      print('Oturum açma isteği gönderiliyor...');
      print('Gönderilen XML: $loginEnvelope');
      final response = await dio.post(
        endpoint,
        data: loginEnvelope,
        options: Options(
          headers: {
            'Content-Type': 'text/xml; charset=utf-8',
            'SOAPAction': '', // id_sorgulama.dart ile uyumlu
          },
        ),
      );

      print('Oturum açma cevabı alındı: ${response.statusCode} - ${response.data}');

      if (response.statusCode == 200) {
        final xmlDoc = xml.XmlDocument.parse(response.data);
        final sessionId = xmlDoc.findAllElements('loginReturn').firstOrNull?.text;
        if (sessionId == null || sessionId.isEmpty) {
          throw Exception("Oturum açılamadı: Sunucudan geçerli bir oturum ID'si alınamadı.");
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
      throw Exception("Sunucu ile bağlantı kurulamadı. Lütfen internet bağlantınızı kontrol edin veya daha sonra tekrar deneyin.");
    }
  }

  // Sevkiyat yükleme işlemi
  Future<String> kaydetSevkiyatYuklemeCubit(String emirNo, String barkodNo, String sicilNo) async {
    await _ensureSession();
    final parametre = "OKU$emirNo$barkodNo,$sicilNo"; // Backend formatı: OKU{emirNo}{barkodNo},{sicilNo}

    final soapEnvelope = '''
<?xml version="1.0" encoding="utf-8"?>
<soapenv:Envelope xmlns:soapenv="/" xmlns:web="h">
  <soapenv:Header/>
  <soapenv:Body>
    <web:callIASService>
      <sessionid>$</sessionid>
      <serviceid></serviceid>
      <args>$</args>
      <returntype></returntype>
      <permanent></permanent>
    </web:callIASService>
  </soapenv:Body>
</soapenv:Envelope>
'''.trim();

    try {
      print('Sevkiyat işlemi isteği gönderiliyor...');
      print('Gönderilen XML: $soapEnvelope');
      print('Parametre: $parametre');
      final response = await dio.post(
        endpoint,
        data: soapEnvelope,
        options: Options(
          headers: {
            'Content-Type': 'text/xml; charset=utf-8',
            'SOAPAction': '', // id_sorgulama.dart ile uyumlu
          },
        ),
      );

      print('SEVKIYAT Cevabı: ${response.statusCode} - ${response.data}');

      if (response.statusCode == 200) {
        final document = xml.XmlDocument.parse(response.data);
        final resultText = document.findAllElements('callIASServiceReturn').firstOrNull?.text;

        if (resultText == null || resultText.isEmpty) {
          throw Exception("İşlem başarısız: Sunucudan mesaj alınamadı.");
        }

        return resultText;
      } else {
        throw Exception("Servis hatası: ${response.statusCode}");
      }
    } catch (e) {
      print('SOAP Hata: $e');
      if (e is DioException && e.response != null) {
        print('Sunucu cevabı: ${e.response?.statusCode} - ${e.response?.data}');
      }
      throw Exception("Sevkiyat işlemi başarısız oldu: $e");
    }
  }

  // Ağırlık sorgulama işlemi
  Future<String> getAgirlik(String emirNo) async {
    await _ensureSession();
    final ilkIki = emirNo.length >= 2 ? emirNo.substring(0, 2) : "";
    final sonraki = emirNo.length > 2 ? emirNo.substring(2) : "";
    final parametre = "01,$ilkIki,$sonraki"; // Backend formatı: 01,ilkIki,sonraki

    final soapEnvelope = '''
<?xml version="1.0" encoding="utf-8"?>
<soapenv:Envelope xmlns:soapenv="hpe/" xmlns:web="h">
  <soapenv:Header/>
  <soapenv:Body>
    <web:callIASService>
      <sessionid>$</sessionid>
      <serviceid></serviceid>
      <args>$</args>
      <returntype></returntype>
      <permanent></permanent>
    </web:callIASService>
  </soapenv:Body>
</soapenv:Envelope>
'''.trim();

    try {
      print('Ağırlık sorgulama isteği gönderiliyor...');
      print('Gönderilen XML: $soapEnvelope');
      print('Parametre: $parametre');
      final response = await dio.post(
        endpoint,
        data: soapEnvelope,
        options: Options(
          headers: {
            'Content-Type': 'text/xml; charset=utf-8',
            'SOAPAction': '', // id_sorgulama.dart ile uyumlu
          },
        ),
      );

      print('YUKAGIRLIK Cevabı: ${response.statusCode} - ${response.data}');

      if (response.statusCode == 200) {
        final document = xml.XmlDocument.parse(response.data);
        final resultText = document.findAllElements('callIASServiceReturn').firstOrNull?.text;

        if (resultText == null || resultText.isEmpty) {
          throw Exception("Ağırlık alınamadı: Sunucudan mesaj alınamadı.");
        }

        return resultText;
      } else {
        throw Exception("Servis hatası: ${response.statusCode}");
      }
    } catch (e) {
      print('SOAP Hata: $e');
      if (e is DioException && e.response != null) {
        print('Sunucu cevabı: ${e.response?.statusCode} - ${e.response?.data}');
      }
      throw Exception("Ağırlık sorgulama başarısız oldu: $e");
    }
  }
}
