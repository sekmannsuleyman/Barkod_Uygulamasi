import 'dart:async';
import 'package:bien_proje/data/datasources/remote_data_source.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class KullaniciGirisCubit extends Cubit<String> with WidgetsBindingObserver {
  KullaniciGirisCubit() : super('') {
    WidgetsBinding.instance.addObserver(this);
  }

  final RemoteDataSource bilgilerDaoRepository = RemoteDataSource();
  Timer? _inactivityTimer;
  DateTime? _lastInteractionTime;

  // Hareketsizlik süresi (5 dakika = 300 saniye)
  static const int _inactivityTimeoutSeconds = 300;

  // Zamanlayıcıyı başlat
  void startInactivityTimer() {
    print('Hareketsizlik zamanlayıcısı başlatıldı');
    _lastInteractionTime = DateTime.now();
    _resetInactivityTimer();
  }

  // Zamanlayıcıyı sıfırla (kullanıcı etkileşimi algılandığında çağrılır)
  void resetInactivityTimer() {
    print('Hareketsizlik zamanlayıcısı sıfırlandı');
    _lastInteractionTime = DateTime.now();
    _resetInactivityTimer();
  }

  // Yardımcı metod: Zamanlayıcıyı sıfırla ve yeniden başlat
  void _resetInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(Duration(seconds: _inactivityTimeoutSeconds), () {
      print('Hareketsizlik süresi doldu, çıkış yapılıyor');
      _forceLogout();
    });
  }

  // Zorunlu çıkış işlemi
  void _forceLogout() {
    stopInactivityTimer();
    emit('loggedOut');
    print('Zorunlu çıkış yapıldı, state: loggedOut');
  }

  // Zamanlayıcıyı durdur
  void stopInactivityTimer() {
    print('Hareketsizlik zamanlayıcısı durduruldu');
    _inactivityTimer?.cancel();
  }

  // Yaşam döngüsü olaylarını dinle
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('AppLifecycleState: $state');
    if (state == AppLifecycleState.paused) {
      // Ekran kapandığında zamanlayıcıyı durdur ve zaman damgasını kaydet
      stopInactivityTimer();
      _lastInteractionTime ??= DateTime.now();
      _saveLastInteractionTime();
    } else if (state == AppLifecycleState.resumed) {
      // Ekran açıldığında geçen süreyi kontrol et
      _checkInactivityOnResume();
    }
  }

  // Son etkileşim zamanını kaydet
  Future<void> _saveLastInteractionTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_interaction', _lastInteractionTime!.toIso8601String());
    print('Son etkileşim zamanı kaydedildi: $_lastInteractionTime');
  }

  // Ekran açıldığında hareketsizlik süresini kontrol et
  Future<void> _checkInactivityOnResume() async {
    final prefs = await SharedPreferences.getInstance();
    final lastInteraction = prefs.getString('last_interaction');
    if (lastInteraction != null) {
      final lastTime = DateTime.parse(lastInteraction);
      final now = DateTime.now();
      final difference = now.difference(lastTime).inSeconds;
      print('Ekran açıldı, geçen süre: $difference saniye');
      if (difference >= _inactivityTimeoutSeconds) {
        print('Hareketsizlik süresi aşıldı, çıkış yapılıyor');
        _forceLogout();
      } else {
        // Kalan süreyi hesapla ve zamanlayıcıyı başlat
        final remainingSeconds = _inactivityTimeoutSeconds - difference;
        _lastInteractionTime = now;
        _inactivityTimer?.cancel();
        _inactivityTimer = Timer(Duration(seconds: remainingSeconds), () {
          print('Hareketsizlik süresi doldu, çıkış yapılıyor');
          _forceLogout();
        });
        print('Zamanlayıcı kalan süreyle başlatıldı: $remainingSeconds saniye');
      }
    }
  }

  Future<void> kaydetKullanciGirisCubit(String kullaniciAdi, String sifre) async {
    print('Kullanıcı giriş denemesi: $kullaniciAdi, $sifre');
    emit('loading');
    try {
      bool isLoggedIn = await bilgilerDaoRepository.kullaniciGiris(kullaniciAdi, sifre);
      if (isLoggedIn) {
        startInactivityTimer();
      }
      emit(isLoggedIn ? 'success' : 'error');
      print('Giriş durumu: ${isLoggedIn ? 'Başarılı' : 'Başarısız'}');
    } catch (e) {
      emit('error');
      print('Cubit Hatası: $e');
    }
  }

  Future<void> cikisYap() async {
    print('Çıkış yapılıyor');
    stopInactivityTimer();
    emit('loggingOut');
    try {
      bool isLoggedOut = await bilgilerDaoRepository.kullaniciCikis();
      emit(isLoggedOut ? 'loggedOut' : 'logoutError');
      print('Çıkış durumu: ${isLoggedOut ? 'Başarılı' : 'Başarısız'}');
    } catch (e) {
      emit('loggedOut'); // Hata olsa bile loggedOut emit et
      print('Çıkış Hatası, yine de loggedOut emit edildi: $e');
    }
  }

  @override
  Future<void> close() {
    stopInactivityTimer();
    WidgetsBinding.instance.removeObserver(this);
    return super.close();
  }
}