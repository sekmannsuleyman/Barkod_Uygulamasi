import 'package:dio/dio.dart';
import 'package:xml/xml.dart' as xml;

class UretimKismiIptalSorgu {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: Duration(seconds: 20),
    receiveTimeout: Duration(seconds: 20),
    validateStatus: (status) => true, // TÜM durum kodlarını kabul et ve hatayı manuel yönet
  ));
  final String _baseUrl = "";

  Future<String?> _login() async {
    try {
      final loginEnvelope = '''<?xml version="1.0" encoding="utf-8"?>
<soapenv:Envelope xmlns:soapenv="http:/" xmlns:web="http:m">
  <soapenv:Header/>
  <soapenv:Body>
    <web:login>
      <p_strClient></p_strClient>
      <p_strLanguage></p_strLanguage>
      <p_strDBName></p_strDBName>
      <p_strDBServer></p_strDBServer>
      <p_strAppServer>1</p_strAppServer>
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
            'User-Agent': 'Mozilla/5.0 (compatible; BienTerminalWeb)', // Web uygulamasını taklit et
            'Accept': 'text/xml, application/xml',
            'Host': '0',
            'Connection': 'keep-alive',
          },
        ),
      );

      print('Oturum açma cevabı alındı: ${response.statusCode}');
      print('Tam Yanıt: ${response.data}');

      if (response.statusCode == 200) {
        final xmlDoc = xml.XmlDocument.parse(response.data.toString());
        final sessionId = xmlDoc.findAllElements('loginReturn').firstOrNull?.text;
        if (sessionId == null || sessionId.isEmpty) {
          throw Exception("Oturum açılamadı: Sunucudan geçerli bir oturum ID'si alınamadı.");
        }
        print('Oturum ID alındı: $sessionId');
        return sessionId;
      } else {
        print('Login yanıtı: ${response.data}');
        throw Exception("Oturum açma başarısız: HTTP ${response.statusCode}");
      }
    } catch (e) {
      print("Login hata: $e");
      throw Exception("Oturum açma hatası: $e");
    }
  }

  Future<String?> kaydetUretimKismiIptalCubit(String belgeNo, String paletBarkodNo) async {
    try {
      final sessionId = await _login();
      if (sessionId == null) {
        throw Exception("Oturum açılamadı.");
      }

      // C# kodundaki formata kesinlikle uyumlu parametre
      final parametre = "2,$belgeNo$paletBarkodNo";

      final callEnvelope = '''<?xml version="1.0" encoding="utf-8"?>
<soapenv:Envelope xmlns:soapenv="htt/" xmlns:web="">
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
</soapenv:Envelope>'''.trim();

      print('Üretim kısmi iptal isteği gönderiliyor...');
      print('Belge No: $belgeNo, Palet Barkod No: $paletBarkodNo');
      print('Parametre: $parametre');
      print('Gönderilen XML: $callEnvelope');

      final response = await _dio.post(
        _baseUrl,
        data: callEnvelope,
        options: Options(
          headers: {
            'Content-Type': 'text/xml; charset=utf-8',
            'SOAPAction': '',
            'User-Agent': 'Mozilla/5.0 (compatible; BienTerminalWeb)',
            'Accept': 'text/xml, application/xml',
            'Host': '',
            'Connection': 'keep-alive',
          },
          responseType: ResponseType.plain, // Metin yanıtını al
        ),
      );

      print('URETIM Kısmı İptal Cevabı: ${response.statusCode}');
      print('Yanıt: ${response.data}');

      // 500 dahil tüm yanıtları işliyoruz
      if (response.statusCode == 200) {
        final xmlDoc = xml.XmlDocument.parse(response.data.toString());
        final resultText = xmlDoc.findAllElements('callIASServiceReturn').firstOrNull?.text;
        if (resultText != null && resultText.isNotEmpty) {
          return resultText;
        }
      }

      // 200 olmayan veya XML'de sonuç bulunamayan durum
      if (response.data != null && response.data.toString().isNotEmpty) {
        try {
          // SOAP hatası yakalamaya çalış
          final xmlDoc = xml.XmlDocument.parse(response.data.toString());

          // Olası hata alanlarını kontrol et
          final faultString = xmlDoc.findAllElements('faultstring').firstOrNull?.text;
          if (faultString != null && faultString.isNotEmpty) {
            throw Exception("Sunucu hatası: $faultString");
          }

          // Ek olarak callIASServiceReturn da kontrol et
          final callReturn = xmlDoc.findAllElements('callIASServiceReturn').firstOrNull?.text;
          if (callReturn != null && callReturn.isNotEmpty) {
            throw Exception(callReturn); // Hata mesajı olarak dönen bir sonuç da olabilir
          }

          // Herhangi bir metin içeriği var mı diye bak
          final allText = xmlDoc.descendants
              .where((node) => node is xml.XmlText && node.text.trim().isNotEmpty)
              .map((node) => node.text.trim())
              .join(" ");

          if (allText.isNotEmpty) {
            throw Exception(allText);
          }
        } catch (xmlError) {
          print("XML ayrıştırma hatası: $xmlError");
          // XML değilse düz metin olarak döndür
          if (response.data.toString().length < 200) {
            throw Exception(response.data.toString());
          }
        }
      }

      // Hiçbir şey alınamadıysa
      throw Exception("Sunucu yanıt verdi (HTTP ${response.statusCode}) ancak anlaşılabilir bir sonuç alınamadı.");

    } catch (e) {
      print("Hata oluştu: $e");
      if (e is DioException) {
        print("DioException tip: ${e.type}, mesaj: ${e.message}");
        if (e.response != null) {
          print("Yanıt durumu: ${e.response!.statusCode}");
          print("Yanıt verisi: ${e.response!.data}");
        }

        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          throw Exception("Sunucu bağlantı zaman aşımı.");
        } else if (e.type == DioExceptionType.connectionError) {
          throw Exception("Sunucuya bağlanılamadı. İnternet bağlantınızı kontrol edin.");
        }
      }

      // e bir Exception ise doğrudan mesajını kullan, değilse toString()
      final errorMsg = e is Exception ? e.toString().replaceFirst("Exception: ", "") : e.toString();
      throw Exception(errorMsg);
    }
  }
}
