import 'package:dio/dio.dart';
import 'package:xml/xml.dart' as xml;

class SayimSayimSorgu {
  final Dio dio = Dio(BaseOptions(
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 10),
  ));
  final String endpoint = 'h';
  String? _sessionId;

  Future<String> kaydetSayimCubit(
      String adaNo, String siraNo, String barkodNo, String sayimNo, String sicilNo) async {
    await _ensureSession();

    final parametre = "0,0,$sayimNo,$barkodNo,$adaNo,$siraNo,$sicilNo";

    final envelope = '''
<?xml version="1.0" encoding="utf-8"?>
<soapenv:Envelope xmlns:soapenv="htt/" xmlns:web="ht">
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
      print('Sayım isteği gönderiliyor...');
      print('Gönderilen XML: $envelope');
      print('Parametre: $parametre');
      final response = await dio.post(
        endpoint,
        options: Options(headers: {
          'Content-Type': 'text/xml; charset=utf-8',
          'SOAPAction': ''
        }),
        data: envelope,
      );

      print('SAYIM Cevabı: ${response.statusCode} - ${response.data}');

      if (response.statusCode == 200) {
        final document = xml.XmlDocument.parse(response.data);
        final resultText = document.findAllElements('callIASServiceReturn').firstOrNull?.text;

        if (resultText == null || resultText.isEmpty) {
          throw Exception("İşlem başarısız: Sunucudan veri alınamadı.");
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
          throw Exception("XML ayrıştırma hatası: $e");
        }
      } else {
        throw Exception("Sunucu ile bağlantı kurulamadı: ${response.statusCode}");
      }
    } catch (e) {
      print('SAYIM hata: $e');
      if (e is DioException && e.response != null) {
        print('Sunucu cevabı: ${e.response?.statusCode} - ${e.response?.data}');
      }
      throw Exception(e.toString());
    }
  }

  Future<void> _ensureSession() async {
    _sessionId ??= await _getSessionId();
  }

  Future<String> _getSessionId() async {
    final envelope = '''
<?xml version="1.0" encoding="utf-8"?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:web="http://web.ias.com">
  <soapenv:Header/>
  <soapenv:Body>
    <web:login>
      <p_strClient></p_strClient>
      <p_strLanguage></p_strLanguage>
      <p_strDBName></p_strDBName>
      <p_strDBServer></p_strDBServer>
      <p_strAppServer></p_strAppServer>
      <p_strUserName></p_strUserName>
      <p_strPassword></p_strPassword>
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
          headers: {'Content-Type': 'text/xml; charset=utf-8', 'SOAPAction': ''},
        ),
        data: envelope,
      );

      print('Oturum açma cevabı alındı: ${response.statusCode} - ${response.data}');

      if (response.statusCode == 200) {
        final document = xml.XmlDocument.parse(response.data);
        final sessionId = document.findAllElements('loginReturn').firstOrNull?.text;
        if (sessionId == null || sessionId.isEmpty) {
          throw Exception("Oturum açılamadı: Sunucudan geçerli bir oturum ID'si alınamadı.");
        }
        print('Oturum ID alındı: $sessionId');
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
