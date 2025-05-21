import 'package:dio/dio.dart';
import 'package:xml/xml.dart' as xml;

class SayimGerialSorgu {
  final Dio dio = Dio(BaseOptions(
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 10),
  ));
  final String endpoint = 'http://195.175.82.182:8080/CaniasWS-v1/services/iasWebService';
  String? _sessionId;

  Future<String> kaydetSayimGerial(String barkodNo) async {
    await _ensureSession();

    final parametre = barkodNo;
    final String envelope = '''
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:web="http://web.ias.com">
  <soapenv:Header/>
  <soapenv:Body>
    <web:callIASService>
      <sessionid>$_sessionId</sessionid>
      <serviceid>SAYIMGERIAL</serviceid>
      <args>$parametre</args>
      <returntype>STRING</returntype>
      <permanent>true</permanent>
    </web:callIASService>
  </soapenv:Body>
</soapenv:Envelope>
''';

    try {
      print('SAYIMGERIAL isteği gönderiliyor...');
      print('Parametre: $parametre');
      final response = await dio.post(
        endpoint,
        options: Options(headers: {
          'Content-Type': 'text/xml; charset=utf-8',
          'SOAPAction': 'http://web.ias.com/callIASService',
        }),
        data: envelope,
      );

      print('SAYIMGERIAL Cevabı: ${response.statusCode} - ${response.data}');

      if (response.statusCode == 200) {
        final document = xml.XmlDocument.parse(response.data);
        final resultText = document.findAllElements('callIASServiceReturn').firstOrNull?.text;

        if (resultText == null || resultText.isEmpty) {
          throw Exception("İşlem başarısız: Sunucudan mesaj alınamadı.");
        }

        // İç içe XML'i ayrıştır
        try {
          final innerXml = xml.XmlDocument.parse(resultText);
          final message = innerXml.findAllElements('MESSAGE').firstOrNull?.text;
          final isError = innerXml.findAllElements('ISERROR').firstOrNull?.text;

          if (message == null || message.isEmpty) {
            throw Exception("İşlem başarısız: Mesaj içeriği alınamadı.");
          }

          // Hata durumunda mesajı fırlat
          if (isError == "1") {
            throw Exception(message);
          }

          return message; // Başarı durumunda mesajı döndür
        } catch (e) {
          throw Exception("$e");
        }
      } else {
        throw Exception("Servis hatası: ${response.statusCode} - ${response.data}");
      }
    } on DioException catch (e) {
      throw Exception("İşlem başarısız: ${e.response?.data ?? e.message}");
    } catch (e) {
      throw Exception("İşlem başarısız: $e");
    }
  }

  Future<void> _ensureSession() async {
    if (_sessionId == null) {
      _sessionId = await _getSessionId();
    }
  }

  Future<String> _getSessionId() async {
    final envelope = '''
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
        options: Options(headers: {
          'Content-Type': 'text/xml; charset=utf-8',
          'SOAPAction': 'http://web.ias.com/login',
        }),
        data: envelope,
      );

      print('Login Cevabı: ${response.statusCode} - ${response.data}');

      if (response.statusCode == 200) {
        final doc = xml.XmlDocument.parse(response.data);
        final sessionId = doc.findAllElements('loginReturn').firstOrNull?.text;
        if (sessionId == null || sessionId.isEmpty) {
          throw Exception("Oturum açılamadı: Session ID alınamadı.");
        }
        print('Oturum ID alındı: $sessionId');
        return sessionId;
      } else {
        throw Exception("Login hatası: ${response.statusCode} - ${response.data}");
      }
    } on DioException catch (e) {
      throw Exception("Oturum hatası: ${e.response?.data ?? e.message}");
    } catch (e) {
      throw Exception("Oturum hatası: $e");
    }
  }
}