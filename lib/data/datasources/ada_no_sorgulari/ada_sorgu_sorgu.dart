import 'package:dio/dio.dart';
import 'package:xml/xml.dart' as xml;

class AdaSorguSorgu {
  final Dio dio = Dio(BaseOptions(
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 10),
  ));
  final String endpoint = 'http://195.175.82.182:8080/CaniasWS-v1/services/iasWebService';
  String? _sessionId;

  Future<List<Map<String, String>>> kaydetAdaSorgu(String adaNo, String siraNo) async {
    await _ensureSession();

    final paddedSiraNo = siraNo.padLeft(4, '0');
    final parametre = "$adaNo,$paddedSiraNo";
    final String envelope = '''
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:web="http://web.ias.com">
  <soapenv:Header/>
  <soapenv:Body>
    <web:callIASService>
      <sessionid>$_sessionId</sessionid>
      <serviceid>ADANOSORGULA</serviceid>
      <args>$parametre</args>
      <returntype>STRING</returntype>
      <permanent>true</permanent>
    </web:callIASService>
  </soapenv:Body>
</soapenv:Envelope>
''';

    try {
      final response = await dio.post(
        endpoint,
        options: Options(headers: {
          'Content-Type': 'text/xml; charset=utf-8',
          'SOAPAction': 'http://web.ias.com/callIASService',
        }),
        data: envelope,
      );

      print('ADANOSORGULA Cevabı: ${response.statusCode} - ${response.data}');

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
''';

    try {
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