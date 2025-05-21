import 'package:dio/dio.dart';
import 'package:xml/xml.dart' as xml;

class UretimSilmeSorgu {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 10),
  ));
  final String _baseUrl = "";

  Future<String?> _login() async {
    try {
      final loginEnvelope = '''<?xml version="1.0" encoding="utf-8"?>
<soapenv:Envelope xmlns:soapenv="h/" xmlns:web="htm">
  <soapenv:Header/>
  <soapenv:Body>
    <web:login>
      <p_strClient></p_strClient>
      <p_strLanguage>T</p_strLanguage>
      <p_strDBName></p_strDBName>
      <p_strDBServer></p_strDBServer>
      <p_strAppServer></p_strAppServer>
      <p_strUserName></p_strUserName>
      <p_strPassword></p_strPassword>
    </web:login>
  </soapenv:Body>
</soapenv:Envelope>'''.trim();

      print('Oturum açma isteği gönderiliyor...');
      print('Gönderilen XML: $loginEnvelope');
      final response = await _dio.post(
        _baseUrl,
        data: loginEnvelope,
        options: Options(
          headers: {
            'Content-Type': 'text/xml; charset=utf-8',
            'SOAPAction': '',
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
        throw Exception("Oturum açma başarısız: ${response.statusCode}");
      }
    } catch (e) {
      print("Login hata: $e");
      if (e is DioException && e.response != null) {
        print('Sunucu cevabı: ${e.response?.statusCode} - ${e.response?.data}');
      }
      throw Exception("Oturum açma hatası: $e");
    }
  }

  Future<String?> kaydetUretimSilmeCubit(String emirNo, String barkodNo) async {
    try {
      final sessionId = await _login();
      if (sessionId == null) {
        throw Exception("Oturum açılamadı.");
      }

      final callEnvelope = '''<?xml version="1.0" encoding="utf-8"?>
<soapenv:Envelope xmlns:soapenv="http:/" xmlns:web="h">
  <soapenv:Header/>
  <soapenv:Body>
    <web:callIASService>
      <sessionid>$</sessionid>
      <serviceid></serviceid>
      <args>1,$</args>
      <returntype></returntype>
      <permanent></permanent>
    </web:callIASService>
  </soapenv:Body>
</soapenv:Envelope>'''.trim();

      print('Üretim silme isteği gönderiliyor...');
      print('Gönderilen XML: $callEnvelope');
      final response = await _dio.post(
        _baseUrl,
        data: callEnvelope,
        options: Options(
          headers: {
            'Content-Type': 'text/xml; charset=utf-8',
            'SOAPAction': '',
          },
        ),
      );

      print('URETIM Silme Cevabı: ${response.statusCode} - ${response.data}');

      if (response.statusCode == 200) {
        final xmlDoc = xml.XmlDocument.parse(response.data);
        final resultText = xmlDoc.findAllElements('callIASServiceReturn').firstOrNull?.text;
        if (resultText == null || resultText.isEmpty) {
          throw Exception("İşlem başarısız: Sunucudan mesaj alınamadı.");
        }
        if (resultText.toLowerCase().contains("hata")) {
          throw Exception("Hata: Ürün bulunamadı.");
        }
        return resultText;
      } else {
        throw Exception("Servis hatası: ${response.statusCode}");
      }
    } catch (e) {
      print("Hata oluştu: $e");
      if (e is DioException && e.response != null) {
        print('Sunucu cevabı: ${e.response?.statusCode} - ${e.response?.data}');
      }
      throw Exception("Hata: $e");
    }
  }
}
