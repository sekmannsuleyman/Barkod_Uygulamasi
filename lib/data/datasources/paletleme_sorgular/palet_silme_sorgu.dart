import 'package:dio/dio.dart';
import 'package:xml/xml.dart' as xml;

class PaletSilmeSorgu {
  final Dio dio = Dio(
    BaseOptions(
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
    ),
  );
  final String endpoint = '';
  String? _sessionId;

  Future<void> _ensureSession() async {
    _sessionId ??= await _getSessionId();
  }

  Future<String> _getSessionId() async {
    final String envelope = '''
<?xml version="1.0" encoding="utf-8"?>
<soapenv:Envelope xmlns:soapenv=".//" xmlns:web=".">
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

      print('Oturum açma cevabı alındı: ${response.statusCode} - ${response.data}');

      if (response.statusCode == 200) {
        final document = xml.XmlDocument.parse(response.data);
        final sessionId = document.findAllElements('loginReturn').firstOrNull?.text;
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
      throw Exception('Oturum açma hatası: $e');
    }
  }

  Future<String> kaydetPaletSilmeCubit(String kutuBarkod) async {
    await _ensureSession();

    final parametre = '1,$kutuBarkod,'; // Backend formatı: 1,{kutuBarkod},
    final String envelope = '''
<?xml version="1.0" encoding="utf-8"?>
<soapenv:Envelope xmlns:soapenv="///" xmlns:web="tp://om">
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
      print('Palet silme isteği gönderiliyor...');
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

      print('SSGPALETLEME Silme Cevabı: ${response.statusCode} - ${response.data}');

      if (response.statusCode == 200) {
        final document = xml.XmlDocument.parse(response.data);
        final result = document.findAllElements('callIASServiceReturn').firstOrNull?.text;
        if (result == null || result.isEmpty) {
          throw Exception("İşlem başarısız: Sunucudan mesaj alınamadı.");
        }
        // Hata mesajlarını kontrol et
        if (result.toLowerCase().contains("hata") || result.toLowerCase().contains("bulunamadı")) {
          throw Exception(result); // Hata mesajını fırlat
        }
        return result; // Başarı durumunda sonucu döndür
      } else {
        throw Exception("Servis bağlantı hatası: ${response.statusCode}");
      }
    } catch (e) {
      print('SSGPALETLEME Silme hata: $e');
      if (e is DioException && e.response != null) {
        print('Sunucu cevabı: ${e.response?.statusCode} - ${e.response?.data}');
      }
      throw Exception(e.toString());
    }
  }
}
