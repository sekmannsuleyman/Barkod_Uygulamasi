import 'package:dio/dio.dart';
import 'package:xml/xml.dart' as xml;
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';

class IsEmrineBagliUretimGirisSorgu {
  final Dio dio = Dio(BaseOptions(
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 10),
  ));
  final String endpoint = 'http://195.175.82.182:8080/CaniasWS-v1/services/iasWebService';
  final String loginUrl = 'http://195.175.82.182/terminal/login.aspx/login.aspx';
  String? _sessionId;
  final CookieJar cookieJar = CookieJar();

  IsEmrineBagliUretimGirisSorgu() {
    // Dio'ya çerez yöneticisi ekle
    dio.interceptors.add(CookieManager(cookieJar));
  }

  Future<void> _ensureSession() async {
    _sessionId ??= await _getSessionId();
  }

  Future<String> _getSessionId() async {
    final String envelope = '''
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
            'User-Agent': 'Mozilla/5.0 (compatible; BienTerminalWeb)',
            'Accept': 'text/xml, application/xml',
            'Host': '195.175.82.182:8080',
            'Connection': 'keep-alive',
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
        print('Oturum ID alındı: $sessionId');

        // Çerezleri kontrol et
        final cookies = await cookieJar.loadForRequest(Uri.parse(endpoint));
        print('Çerezler: $cookies');

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

  Future<String> kaydetIsEmrineBagliuretim(String isEmirNo, String barkodNo, String adaNo, String siraNo) async {
    await _ensureSession();

    final parametre = '0,$isEmirNo$barkodNo,$adaNo,$siraNo'; // Backend formatı: 0,{isEmirNo}{barkodNo},{adaNo},{siraNo}
    final String envelope = '''
<?xml version="1.0" encoding="utf-8"?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:web="http://web.ias.com">
  <soapenv:Header/>
  <soapenv:Body>
    <web:callIASService>
      <sessionid>$_sessionId</sessionid>
      <serviceid>ISEMIRURETIMGIRIS</serviceid>
      <args>$parametre</args>
      <returntype>STRING</returntype>
      <permanent>true</permanent>
    </web:callIASService>
  </soapenv:Body>
</soapenv:Envelope>
'''.trim();

    try {
      print('İş emrine bağlı üretim giriş isteği gönderiliyor...');
      print('Gönderilen XML: $envelope');
      print('Parametre: $parametre');

      // Çerezleri kontrol et
      final cookies = await cookieJar.loadForRequest(Uri.parse(endpoint));
      print('Çerezler: $cookies');

      final response = await dio.post(
        endpoint,
        options: Options(
          headers: {
            'Content-Type': 'text/xml; charset=utf-8',
            'SOAPAction': '',
            'User-Agent': 'Mozilla/5.0 (compatible; BienTerminalWeb)',
            'Accept': 'text/xml, application/xml',
            'Host': '195.175.82.182:8080',
            'Connection': 'keep-alive',
          },
          responseType: ResponseType.plain, // Metin yanıtı al
        ),
        data: envelope,
      );

      print('ISEMIRURETIMGIRIS Cevabı: ${response.statusCode} - ${response.data}');

      if (response.statusCode == 200) {
        final document = xml.XmlDocument.parse(response.data);
        final result = document.findAllElements('callIASServiceReturn').firstOrNull?.text;
        if (result == null || result.isEmpty) {
          // SOAP hata etiketlerini kontrol et
          final possibleErrorTags = [
            'faultstring',
            'callIASServiceReturn',
            'error',
            'message',
            'detail',
            'fault',
            'soap:Fault',
            'soap:Reason',
            'soap:Text',
            'errorMessage',
            'exception',
            'reason',
            'description',
            'errorCode',
            'errorDescription'
          ];
          String? errorMessage;
          for (var tag in possibleErrorTags) {
            errorMessage = document.findAllElements(tag).firstOrNull?.text;
            if (errorMessage != null && errorMessage.isNotEmpty) {
              break;
            }
          }
          // XML’deki tüm metin içeriğini tara
          if (errorMessage == null) {
            final allText = document.descendants
                .where((node) => node is xml.XmlText && node.text.trim().isNotEmpty)
                .map((node) => node.text.trim())
                .join(' ');
            if (allText.isNotEmpty) {
              errorMessage = allText;
            }
          }
          if (errorMessage != null && errorMessage.isNotEmpty) {
            throw Exception(errorMessage);
          }
          throw Exception("İşlem başarısız: Sunucudan mesaj alınamadı.");
        }
        print('Sunucudan gelen mesaj: $result');
        // Hata mesajlarını kontrol et
        if (result.trim().toLowerCase().contains("hata") ||
            result.trim().toLowerCase().contains("kayıtlıdır") ||
            result.trim().toLowerCase().contains("bulunamadı") ||
            result.trim().toLowerCase().contains("stokta değil")) {
          print('Hata mesajı yakalandı: $result');
          throw Exception(result); // Hata mesajını fırlat
        }
        return result; // Başarı durumunda sonucu döndür
      } else {
        throw Exception("Servis bağlantı hatası: ${response.statusCode}");
      }
    } catch (e) {
      print('ISEMIRURETIMGIRIS hata: $e');
      if (e is DioException && e.response != null) {
        print('Sunucu cevabı: ${e.response?.statusCode} - ${e.response?.data}');
      }
      throw Exception(e.toString());
    }
  }
}