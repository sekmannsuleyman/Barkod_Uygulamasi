import 'package:dio/dio.dart';
import 'package:xml/xml.dart' as xml;

class TransferHareketleriSorgu {
  final Dio dio = Dio(
    BaseOptions(
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
    ),
  );
  final String endpoint =
      'he';
  String? _sessionId;

  Future<void> _ensureSession() async {
    _sessionId ??= await _getSessionId();
  }

  Future<String> _getSessionId() async {
    final String envelope =
        '''
<?xml version="1.0" encoding="utf-8"?>
<soapenv:Envelope xmlns:soapenv="ht/" xmlns:web="htm">
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

      print(
        'Oturum açma cevabı alındı: ${response.statusCode} - ${response.data}',
      );

      if (response.statusCode == 200) {
        final document = xml.XmlDocument.parse(response.data);
        final sessionId =
            document.findAllElements('loginReturn').firstOrNull?.text;
        if (sessionId == null || sessionId.isEmpty) {
          throw Exception(
            "Oturum açılamadı: Sunucudan geçerli bir oturum ID'si alınamadı.",
          );
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

  Future<String> kaydetTransferHareketleriCubit(
    String adaNo,
    String siraNo,
    String emirNo,
    String barkodNo,
  ) async {
    await _ensureSession();

    String tesis = emirNo.length >= 2 ? emirNo.substring(0, 2) : '';
    String emir = emirNo.length >= 10 ? emirNo.substring(2, 10) : '';
    String kalemNo =
        emirNo.length > 10
            ? emirNo.substring(10)
            : (int.tryParse(siraNo) ?? 1).toString();
    String serviceId = emirNo.length == 10 ? 'MTRANSFEROO' : 'MTRANSFER';

    final parametre = '$tesis,$emir,$kalemNo,$barkodNo,$adaNo';

    final String envelope =
        '''
<?xml version="1.0" encoding="utf-8"?>
<soapenv:Envelope xmlns:soapenv="http:///" xmlns:web="ht">
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
      print('Transfer hareketleri isteği gönderiliyor...');
      print('Gönderilen XML: $envelope');
      print('Parametre: $parametre');
      print('Servis: $serviceId');
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

      print(
        'MTRANSFER/MTRANSFEROO Cevabı: ${response.statusCode} - ${response.data}',
      );

      if (response.statusCode == 200) {
        final document = xml.XmlDocument.parse(response.data);
        final result =
            document.findAllElements('callIASServiceReturn').firstOrNull?.text;
        if (result == null || result.isEmpty) {
          throw Exception("İşlem başarısız: Sunucudan mesaj alınamadı.");
        }
        if (result.toLowerCase().contains("hata")) {
          throw Exception("Servis Hatası: $result");
        }
        return result;
      } else {
        throw Exception("Servis bağlantı hatası: ${response.statusCode}");
      }
    } catch (e) {
      print('MTRANSFER/MTRANSFEROO hata: $e');
      if (e is DioException && e.response != null) {
        print('Sunucu cevabı: ${e.response?.statusCode} - ${e.response?.data}');
      }
      throw Exception('Transfer hareketleri hatası: $e');
    }
  }
}
