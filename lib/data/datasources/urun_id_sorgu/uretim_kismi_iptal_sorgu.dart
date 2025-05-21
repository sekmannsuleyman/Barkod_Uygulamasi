import 'package:dio/dio.dart';

class UretimKismiIptalSorgu {

  final Dio _dio = Dio();
  final String _baseUrl = "h";

  Future<String?> kaydetUretimKismiIptalCubit(String belgeNo, String paletBarkodNo) async {
    try {
      final loginEnvelope = '''<?xml version="1.0" encoding="utf-8"?>
<soapenv:Envelope xmlns:soapenv="http/" xmlns:web="hm">
  <soapenv:Header/>
  <soapenv:Body>
    <web:login>
      <p_strClient></p_strClient>
      <p_strLanguage></p_strLanguage>
      <p_strDBName></p_strDBName>
      <p_strDBServer>254</p_strDBServer>
      <p_strAppServer>1</p_strAppServer>
      <p_strUserName>mobil</p_strUserName>
      <p_strPassword>mobil</p_strPassword>
    </web:login>
  </soapenv:Body>
</soapenv:Envelope>''';

      final loginResponse = await _dio.post(
        _baseUrl,
        data: loginEnvelope,
        options: Options(headers: {'Content-Type': 'text/xml; charset=utf-8'}),
      );

      final loginBody = loginResponse.data as String;
      final sessionStart = loginBody.indexOf("<loginReturn>") + 13;
      final sessionEnd = loginBody.indexOf("</loginReturn>");
      final sessionId = loginBody.substring(sessionStart, sessionEnd);

      final callEnvelope = '''<?xml version="1.0" encoding="utf-8"?>
<soapenv:Envelope xmlns:soapenv="htt/" xmlns:web="h">
  <soapenv:Header/>
  <soapenv:Body>
    <web:callIASService>
      <sessionid>$</sessionid>
      <serviceid></serviceid>
      <args>2,$</args>
      <returntype></returntype>
      <permanent></permanent>
    </web:callIASService>
  </soapenv:Body>
</soapenv:Envelope>''';

      final callResponse = await _dio.post(
        _baseUrl,
        data: callEnvelope,
        options: Options(headers: {'Content-Type': 'text/xml; charset=utf-8'}),
      );

      final callBody = callResponse.data as String;
      final resultStart = callBody.indexOf("<callIASServiceReturn>") + 21;
      final resultEnd = callBody.indexOf("</callIASServiceReturn>");
      final sonuc = callBody.substring(resultStart, resultEnd);

      return sonuc;
    } catch (e) {
      print("Hata oluştu: $e");
      return null;
    }
  }












}
