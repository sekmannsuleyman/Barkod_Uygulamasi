import 'package:dio/dio.dart';
import 'package:xml/xml.dart' as xml;

class SarfaSorguSorgu {
  final Dio dio = Dio(BaseOptions(
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 10),
  ));
  final String endpoint = 'he';
  String? _sessionId;

  // Sarfa Çıkış Sorgu
  Future<List<Map<String, String>>> sarfaCikisSorgu({
    required String barkodNo,
    required String depo,
    required String maliyetMerkezi,
    required String miktar,
  }) async {
    await _ensureSession();

    final parts = barkodNo.split('-');
    if (parts.length != 3) throw Exception("Barkod formatı geçersiz: FIRMA-TESIS-MALZEME");

    final firma = parts[0];
    final tesis = parts[1];
    final malzeme = parts[2];
    final parametre = "1,$firma,$tesis,$malzeme,$depo,$maliyetMerkezi,${miktar.replaceAll(",", ".")}";

    final envelope = '''
<?xml version="1.0" encoding="utf-8"?>
<soapenv:Envelope xmlns:soapenv="" xmlns:web="">
  <soapenv:Header/>
  <soapenv:Body>
    <web:callIASService>
      <sessionid>$</sessionid>
      <serviceid>SARF</serviceid>
      <args>$</args>
      <returntype></returntype>
      <permanent></permanent>
    </web:callIASService>
  </soapenv:Body>
</soapenv:Envelope>
'''.trim();

    try {
      print('Sarfa çıkış sorgusu gönderiliyor...');
      print('Gönderilen XML: $envelope');
      print('Parametre: $parametre');
      final response = await dio.post(
        endpoint,
        options: Options(
          headers: {'Content-Type': 'text/xml; charset=utf-8', 'SOAPAction': ''},
        ),
        data: envelope,
      );

      print('SARF Sorgu Cevabı: ${response.statusCode} - ${response.data}');

      if (response.statusCode == 200) {
        final doc = xml.XmlDocument.parse(response.data);
        final resultText = doc.findAllElements('callIASServiceReturn').firstOrNull?.text;
        if (resultText == null || resultText.isEmpty) {
          throw Exception("İşlem başarısız: Sunucudan veri alınamadı.");
        }

        if (resultText.toLowerCase().contains("hata")) {
          throw Exception("Servis Hatası: $resultText");
        }

        final parsed = xml.XmlDocument.parse(resultText);
        final rows = parsed.findAllElements('row');
        return rows.map((row) {
          final Map<String, String> item = {};
          for (final element in row.children.whereType<xml.XmlElement>()) {
            item[element.name.toString()] = element.text;
          }
          return item;
        }).toList();
      } else {
        throw Exception("Sunucu ile bağlantı kurulamadı: ${response.statusCode}");
      }
    } catch (e) {
      print('SARF Sorgu hata: $e');
      if (e is DioException && e.response != null) {
        print('Sunucu cevabı: ${e.response?.statusCode} - ${e.response?.data}');
      }
      throw Exception('$e');
    }
  }

  // Oturum açma kontrolü
  Future<void> _ensureSession() async {
    _sessionId ??= await _getSessionId();
  }

  // Login SOAP
  Future<String> _getSessionId() async {
    final envelope = '''
<?xml version="1.0" encoding="utf-8"?>
<soapenv:Envelope xmlns:soapenv="ht/" xmlns:web="ht">
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
