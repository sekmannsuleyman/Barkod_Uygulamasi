import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:html/parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RemoteDataSource {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'h',
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 10),
  ));

  RemoteDataSource() {
    // Cookie yönetimi
    final cookieJar = CookieJar();
    _dio.interceptors.add(CookieManager(cookieJar));
    // Detaylı loglama
    _dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
  }

  Future<bool> kullaniciGiris(String kullaniciAdi, String sifre) async {
    try {
      // 1. GET isteği ile login.aspx sayfasını al
      print('GET isteği gönderiliyor: /login.aspx');
      final getResponse = await _dio.get('/login.aspx');
      print('GET Yanıt Durum Kodu: ${getResponse.statusCode}');
      print('GET Yanıt Verisi: ${getResponse.data}');

      // HTML'i parse et ve __VIEWSTATE, __EVENTVALIDATION değerlerini al
      var document = parse(getResponse.data);
      var viewState = document.querySelector('input[name="__VIEWSTATE"]')?.attributes['value'] ?? '';
      var eventValidation = document.querySelector('input[name="__EVENTVALIDATION"]')?.attributes['value'] ?? '';

      print('__VIEWSTATE: $viewState');
      print('__EVENTVALIDATION: $eventValidation');

      // Kullanıcı adını 8 karaktere tamamla
      String formattedKullaniciAdi = kullaniciAdi.padLeft(8, '0');
      print('Gönderilen Kullanıcı Adı: $formattedKullaniciAdi');
      print('Gönderilen Şifre: $sifre');

      // POST isteği için veri
      var formData = FormData.fromMap({
        'txtAd': formattedKullaniciAdi,
        '': sifre,
        '': 'Giriş',
        '': viewState,
        '': eventValidation,
        '': '',
        '': '',
      });

      // POST isteği gönder
      print('POST ist');
      final postResponse = await _dio.post(
        '/login.aspx',
        data: formData,
        options: Options(
          followRedirects: false,
          validateStatus: (status) => status! < 500,
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
      );

      print('POST Yanıt Durum Kodu: ${postResponse.statusCode}');
      print('POST Yanıt Verisi: ${postResponse.data}');

      if (postResponse.statusCode == 302) {
        // Başarılı giriş, kullanıcı ID'sini sakla
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('kullanici_id', formattedKullaniciAdi);
        print('Giriş başarılı, kullanıcı ID saklandı: $formattedKullaniciAdi');
        return true;
      } else if (postResponse.data.toString().contains('Giriş Başarısız')) {
        print('Hata: Giriş Başarısız mesajı alındı');
        return false;
      }

      print('Bilinmeyen bir hata: ${postResponse.data}');
      return false;
    } catch (e) {
      print('Dio Hatası: $e');
      return false;
    }
  }

  Future<bool> kullaniciCikis() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('kullanici_id');
      print('Çıkış yapıldı, kullanıcı ID kaldırıldı');
      return true;
    } catch (e) {
      print('Çıkış Hatası: $e');
      return false;
    }
  }
}
