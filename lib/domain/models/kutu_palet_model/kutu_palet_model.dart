// models/kutu_palet_model.dart
class KutuPaletModel {
  final String malzemeKodu;
  final String malzemeAdi;
  final String partiNo;
  final List<KutuPaletModel2> detaylar;

  KutuPaletModel({
    required this.malzemeKodu,
    required this.malzemeAdi,
    required this.partiNo,
    required this.detaylar,
  });
}

class KutuPaletModel2 {
  final String adaNo;
  final String sayi;
  final double adet;
  final String durum;

  KutuPaletModel2({
    required this.adaNo,
    required this.sayi,
    required this.adet,
    required this.durum,
  });
}