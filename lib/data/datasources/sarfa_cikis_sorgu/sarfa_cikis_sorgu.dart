import 'package:dio/dio.dart';
import 'package:xml/xml.dart' as xml;

class SarfaCikisSorgu {
  final Dio dio = Dio(BaseOptions(
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 10),
  ));
  final String endpoint = '';
  String? _sessionId;

  Future<Map<String, dynamic>> kaydetSarfaCikisCubit(
      String barkodNo, String maliyetMerkezi, String depo, String miktar, String islemTipi) async {
    await _ensureSession();

    final barkodParcalar = barkodNo.split('-');
    if (barkodParcalar.length != 3) {
      throw Exception("Barkod formatı geçersiz. Beklenen format: FIRMA-TESIS-MALZEME");
    }

    final firma = barkodParcalar[0];
    final tesis = barkodParcalar[1];
    final malzeme = barkodParcalar[2];

    final parametre = "$islemTipi,$firma,$tesis,$malzeme,$depo,$maliyetMerkezi,${miktar.replaceAll(',', '.')}";
    final String envelope = '''
<?xml version="1.0" encoding="utf-8"?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:web="http://web.ias.com">
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
      print('Sarfa çıkış isteği gönderiliyor...');
      print('Gönderilen XML: $envelope');
      print('Parametre: $parametre');
      final response = await dio.post(
        endpoint,
        options: Options(
          headers: {'Content-Type': 'text/xml; charset=utf-8', 'SOAPAction': ''},
        ),
        data: envelope,
      );

      print('SARF Cevabı: ${response.statusCode} - ${response.data}');

      if (response.statusCode == 200) {
        final document = xml.XmlDocument.parse(response.data);
        final resultText = document.findAllElements('callIASServiceReturn').firstOrNull?.text;
        if (resultText == null || resultText.isEmpty) {
          throw Exception("İşlem başarısız: Sunucudan veri alınamadı.");
        }

        if (resultText.toLowerCase().contains("hata")) {
          throw Exception("Servis Hatası: $resultText");
        }

        if (islemTipi == "1") {
          // Sorgulama işlemi için XML ayrıştırma
          final dataDoc = xml.XmlDocument.parse(resultText);
          final rows = dataDoc.findAllElements('row');
          if (rows.isEmpty) {
            throw Exception("Stok bilgisi alınamadı.");
          }

          final row = rows.first;
          final stokMiktar = double.parse(row.findElements('Miktar').first.text);
          final girilenMiktar = double.parse(miktar.replaceAll(',', '.'));
          final kalanMiktar = stokMiktar - girilenMiktar;

          if (kalanMiktar < 0) {
            throw Exception("Yetersiz Miktar!");
          }

          return {
            'stokMiktar': stokMiktar,
            'girilenMiktar': girilenMiktar,
            'kalanMiktar': kalanMiktar,
          };
        } else {
          // Onay işlemi için yalnızca sonucu döndür
          return {'sonuc': resultText};
        }
      } else {
        throw Exception("Servis bağlantı hatası: ${response.statusCode}");
      }
    } catch (e) {
      print('SARF hata: $e');
      if (e is DioException && e.response != null) {
        print('Sunucu cevabı: ${e.response?.statusCode} - ${e.response?.data}');
      }
      throw Exception('Sarfa çıkış hatası: $e');
    }
  }

  Future<void> _ensureSession() async {
    _sessionId ??= await _getSessionId();
  }

  Future<String> _getSessionId() async {
    final String envelope = '''
<?xml version="1.0" encoding="utf-8"?>
<soapenv:Envelope xmlns:soapenv="http://..org///" xmlns:web="://.com">
  <soapenv:Header/>
  <soapenv:Body>
    <web:login>
      <p_strClient></p_strClient>
      <p_strLanguage></p_strLanguage>
      <p_strDBName></p_strDBName>
      <p_strDBServer></p_strDBServer>
      <p_strAppServer>19</p_strAppServer>
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
