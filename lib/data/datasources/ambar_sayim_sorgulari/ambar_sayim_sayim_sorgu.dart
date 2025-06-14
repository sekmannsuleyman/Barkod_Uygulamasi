import 'package:dio/dio.dart';
import 'package:xml/xml.dart' as xml;

class AmbarSayimSorguSorgu {
  final Dio dio = Dio(BaseOptions(
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 10),
  ));
  final String endpoint = '';
  String? _sessionId;

  Future<List<Map<String, String>>> kaydetAmbarSayimSorgu(String rafNo, String gozNo, String barkodNo) async {
    await _ensureSession();

    final parametre = "$rafNo,$gozNo,$barkodNo";
    final String envelope = '''
<soapenv:Envelope xmlns:soapenv="" xmlns:web="">
  <soapenv:Header/>
  <soapenv:Body>
    <web:callIASService>
      <sessionid></sessionid>
      <serviceid></serviceid>
      <args></args>
      <returntype></returntype>
      <permanent></permanent>
    </web:callIASService>
  </soapenv:Body>
</soapenv:Envelope>
''';

    try {
      final response = await dio.post(
        endpoint,
        options: Options(headers: {
          'Content-Type': 'text/xml; charset=utf-8',
          'SOAPAction': '',
        }),
        data: envelope,
      );

      print('AMBARSAYIMSORGU Cevabı: ${response.statusCode} - ${response.data}');

      if (response.statusCode == 200) {
        final document = xml.XmlDocument.parse(response.data);
        final resultText = document.findAllElements('callIASServiceReturn').firstOrNull?.text;

        if (resultText == null || resultText.isEmpty) {
          throw Exception("Servisten veri alınamadı.");
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
            return data;
          }).toList();
        } catch (e) {
          throw Exception("XML parse hatası: $e");
        }
      } else {
        throw Exception("Servis hatası: ${response.statusCode} - ${response.data}");
      }
    } on DioException catch (e) {
      throw Exception("Sorgu başarısız: ${e.response?.data ?? e.message}");
    } catch (e) {
      throw Exception("Sorgu başarısız: $e");
    }
  }

  Future<void> _ensureSession() async {
    if (_sessionId == null) {
      _sessionId = await _getSessionId();
    }
  }

  Future<String> _getSessionId() async {
    final envelope = '''
<soapenv:Envelope xmlns:soapenv="ht/" xmlns:web="hm">
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
''';

    try {
      final response = await dio.post(
        endpoint,
        options: Options(headers: {
          'Content-Type': 'text/xml; charset=utf-8',
          'SOAPAction': '',
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
