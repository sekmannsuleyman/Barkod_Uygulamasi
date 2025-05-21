import 'package:dio/dio.dart';
import 'package:xml/xml.dart' as xml;

class SevkiyatYuklemeSorgu {
  final Dio dio = Dio(BaseOptions(
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 10),
  ));
  final String endpoint = '';

  Future<String> _getSessionId() async {
    const username = "";
    const password = "";

    final loginEnvelope = '''
<?xml version="1.0" encoding="utf-8"?>
<soapenv:Envelope xmlns:soapenv="h/" xmlns:web="h">
  <soapenv:Header/>
  <soapenv:Body>
    <web:login>
      <p_strClient></p_strClient>
      <p_strLanguage></p_strLanguage>
      <p_strDBName></p_strDBName>
      <p_strDBServer></p_strDBServer>
      <p_strAppServer>:</p_strAppServer>
      <p_strUserName></p_strUserName>
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
        options: Options(headers: {
          'Content-Type': 'text/xml; charset=utf-8',
          'SOAPAction': '', // id_sorgulama.dart ile uyumlu
        }),
      );

      print('Oturum açma cevabı alındı: ${response.statusCode} - ${response.data}');

      final xmlDoc = xml.XmlDocument.parse(response.data);
      final sessionId = xmlDoc.findAllElements('loginReturn').firstOrNull?.text;
      if (sessionId == null || sessionId.isEmpty) {
        throw Exception("Oturum açılamadı: Sunucudan geçerli bir oturum ID'si alınamadı.");
      }
      return sessionId;
    } catch (e) {
      print('Oturum açma hatası: $e');
      if (e is DioException && e.response != null) {
        print('Sunucu cevabı: ${e.response?.statusCode} - ${e.response?.data}');
      }
      throw Exception("Oturum hatası: $e");
    }
  }

  Future<List<Map<String, String>>> kaydetSevkiyatYuklemeSorguCubit(String emirNo, bool banyoSorgu) async {
    final sessionId = await _getSessionId();
    final serviceId = banyoSorgu ? "SEVKIYATSORGUBANYO" : "SEVKIYATSORGU";

    final soapEnvelope = '''
<?xml version="1.0" encoding="utf-8"?>
<soapenv:Envelope xmlns:soapenv="he/" xmlns:web="hm">
  <soapenv:Header/>
  <soapenv:Body>
    <web:callIASService>
      <sessionid>$</sessionid>
      <serviceid>$</serviceid>
      <args>$</args>
      <returntype></returntype>
      <permanent></permanent>
    </web:callIASService>
  </soapenv:Body>
</soapenv:Envelope>
'''.trim();

    try {
      print('Sevkiyat sorgu isteği gönderiliyor...');
      print('Gönderilen XML: $soapEnvelope');
      final response = await dio.post(
        endpoint,
        data: soapEnvelope,
        options: Options(headers: {
          'Content-Type': 'text/xml; charset=utf-8',
          'SOAPAction': '', // id_sorgulama.dart ile uyumlu
        }),
      );

      print('SEVKIYATSORGU Cevabı: ${response.statusCode} - ${response.data}');

      if (response.statusCode == 200) {
        final document = xml.XmlDocument.parse(response.data);
        final resultText = document.findAllElements('callIASServiceReturn').firstOrNull?.text;

        if (resultText == null || resultText.isEmpty) {
          return [];
        }

        try {
          final parsed = xml.XmlDocument.parse(resultText);
          final rows = parsed.findAllElements('row');

          if (rows.isEmpty) {
            return [];
          }

          return rows.map((row) {
            final Map<String, String> data = {};
            for (var element in row.children.whereType<xml.XmlElement>()) {
              data[element.name.toString()] = element.text ?? '';
            }
            return {
              'MALZEME': data['MALZEME'] ?? '-',
              'PARTI': data['PARTI'] ?? '-',
              'KALAN': data['KALAN'] ?? '-',
              'BIRIM': data['BIRIM'] ?? '-',
            };
          }).toList();
        } catch (e) {
          print('XML parse hatası: $e');
          throw Exception("XML parse hatası: $e");
        }
      } else {
        throw Exception("Servis hatası: ${response.statusCode}");
      }
    } catch (e) {
      print("SOAP Hata: $e");
      if (e is DioException && e.response != null) {
        print('Sunucu cevabı: ${e.response?.statusCode} - ${e.response?.data}');
      }
      throw Exception("Web servisten veri alınamadı: $e");
    }
  }
}
