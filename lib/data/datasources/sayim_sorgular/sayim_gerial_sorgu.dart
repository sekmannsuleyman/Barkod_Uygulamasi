import 'package:dio/dio.dart';
import 'package:xml/xml.dart' as xml;

class SayimGerialSorgu {
  final Dio dio = Dio(BaseOptions(
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 10),
  ));
  final String endpoint = 'htp://';
  String? _sessionId;

  Future<String> kaydetSayimGerial(String barkodNo) async {
    await _ensureSession();

    final parametre = barkodNo;
    final String envelope = '''
<soapenv:Envelope xmlns:soapenv="httppe/" xmlns:web="h.com">
  <soapenv:Header/>
  <soapenv:Body>
    <web:callIASService>
      <sessionid>$</sessionid>
      <serviceid></serviceid>
      <args>$</args>
      <returntype></returntype>
      <permanent>tue</permanent>
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
          'SOAPAction': 'http/.com/',
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
<soapenv:Envelope xmlns:soapenv="http://ope/" xmlns:web="om">
  <soapenv:Header/>
  <soapenv:Body>
    <web:login>
      <p_strClient></p_strClient>
      <p_strLanguage></p_strLanguage>
      <p_strDBName></p_strDBName>
      <p_strDBServer></p_strDBServer>
      <p_strAppServer>.:</p_strAppServer>
      <p_strUserName></p_strUserName>
      <p_strPassword></p_strPassword>
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
