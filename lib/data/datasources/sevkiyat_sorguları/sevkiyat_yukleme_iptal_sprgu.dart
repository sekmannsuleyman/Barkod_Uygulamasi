import 'package:dio/dio.dart';
import 'package:xml/xml.dart' as xml;

class SevkiyatYuklemeIptalSorgu {
  final Dio dio = Dio(BaseOptions(
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 10),
  ));
  final String endpoint = 'http://195.175.82.182:8080/CaniasWS-v1/services/iasWebService';
  String? _sessionId;

  // Oturum ID’sini kontrol eder ve yoksa alır
  Future<void> _ensureSession() async {
    _sessionId ??= await _getSessionId();
  }

  Future<String> _getSessionId() async {
    const username = "BIENURETIM";
    const password = "kp2010";

    final loginEnvelope = '''
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
      <p_strUserName>$username</p_strUserName>
      <p_strPassword>$password</p_strPassword>
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

  Future<String> kaydetSevkiyatYuklemeIptalCubit(String emirNo, String barkodNo) async {
    await _ensureSession();
    final parametre = "SIL$emirNo$barkodNo,"; // Backend formatı: SIL{emirNo}{barkodNo},

    final soapEnvelope = '''
<?xml version="1.0" encoding="utf-8"?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:web="http://web.ias.com">
  <soapenv:Header/>
  <soapenv:Body>
    <web:callIASService>
      <sessionid>$_sessionId</sessionid>
      <serviceid>SEVKIYAT</serviceid>
      <args>$parametre</args>
      <returntype>STRING</returntype>
      <permanent>true</permanent>
    </web:callIASService>
  </soapenv:Body>
</soapenv:Envelope>
'''.trim();

    try {
      print('Sevkiyat iptal işlemi isteği gönderiliyor...');
      print('Gönderilen XML: $soapEnvelope');
      print('Parametre: $parametre');
      final response = await dio.post(
        endpoint,
        data: soapEnvelope,
        options: Options(
          headers: {
            'Content-Type': 'text/xml; charset=utf-8',
            'SOAPAction': '',
          },
        ),
      );

      print('SEVKIYAT İptal Cevabı: ${response.statusCode} - ${response.data}');

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
      print("SOAP Hata: $e");
      if (e is DioException && e.response != null) {
        print('Sunucu cevabı: ${e.response?.statusCode} - ${e.response?.data}');
      }
      throw Exception("Sevkiyat iptal işlemi başarısız oldu: $e");
    }
  }
}