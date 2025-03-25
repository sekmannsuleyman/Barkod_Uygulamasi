class BilgilerDaoRepository {
  // adano Kaydet
  Future<void> kaydetAda(String emirNo, String adaNo, String siraNo) async {
    print("kayetcekmi:$emirNo - $adaNo- $siraNo");
  }

  // KAydet Ada Sorgula
  Future<void> kaydetadasorgula(String adaNo, String siraNo) async {
    print("kayetcekmi:- $adaNo- $siraNo");
  }

  // Ambar sayim Kaydet
  Future<void> kaydetAmbarSayim(
    String rafNo,
    String gozNo,
    String barkodNo,
    String adet,
    String sayimNo,
  ) async {
    print("kayetcekmi:- $rafNo- $gozNo- $barkodNo-$adet-$sayimNo");
  }

  // kaydet sayım sorgu
  Future<void> kaydetAmbarSayimSorgu(
    String rafNo,
    String gozNo,
    String barkodNo,
  ) async {
    print("kayetcekmi:- $rafNo- $gozNo- $barkodNo");
  }

  // ambar sayım geri al kaydet
  Future<void> kaydetAmbarGerial(String barkodNo) async {
    print("kayetcekmi:- $barkodNo");
  }
  // Ean Sorgu kaydet

  Future<void> kaydetEanSorguCubit(String eanNo) async {
    print("kayetcekmi:- $eanNo");
  }

  // Ean palet karsilastirma kaydet
  Future<void> kaydetEanPaletKarsilastirmaCubit(
    String paletId,
    String eanNo,
  ) async {
    print("kayetcekmi:- $paletId - $eanNo");
  }

  // id sorgu kaydet
  Future<void> kaydetIdSorguCubit(String idNo) async {
    print("kayetcekmi:- $idNo");
  }

  // is emrine baglu uretim kaydet
  Future<void> kaydetIsEmrineBagliuretim(
    String isEmirNo,
    String barkodNo,
    String adaNo,
    String siraNo,
  ) async {
    print("kayetcekmi:- $isEmirNo- $barkodNo-$adaNo-$siraNo");
  }

  // is emrine baglı uretim silme kaydet
  Future<void> kaydetIsEmrineBagliuretimSilme(
    String isEmirNo,
    String barkodNo,
  ) async {
    print("kayetcekmi:- $isEmirNo- $barkodNo-");
  }

  // Numune ada  kaydet
  Future<void> kaydetNumuneAdaKaydetCubit(
    String malzemeKodu,
    String rafNo,
    String gozNo,
  ) async {
    print("kayetcekmi:- $malzemeKodu- $rafNo-$gozNo");
  }

  // numune ada sorgula kaydet
  Future<void> kaydetNumuneAdaSorgulaCubit(String rafNo, String gozNo) async {
    print("kayetcekmi: - $rafNo-$gozNo");
  }

  // Paletleme kaydet
  Future<void> kaydetPaletlemeCubit(
    String kutuBarkod,
    String paletBarkod,
  ) async {
    print("kayetcekmi: - $kutuBarkod-$paletBarkod");
  }

  // kaydet paletsilme
  Future<void> kaydetPaletSilmeCubit(String kutuBarkod) async {
    print("kayetcekmi: - $kutuBarkod-");
  }

  // kaydet sarfa cikis
  Future<void> kaydetSarfaCikisCubit(
    String barkodNo,
    String maliyetMerkezi,
    String depo,
    String miktar,
  ) async {
    print("kayetcekmi: - $barkodNo-$maliyetMerkezi-$depo-$miktar");
  }

  Future<void> kaydetSayimCubit(
    String adoNo,
    String siraNo,
    String barkodNo,
    String sayimNo,
  ) async {
    print("kayetcekmi: - $adoNo-$siraNo-$barkodNo-$sayimNo");
  }

  // sarfa cikis geri al
  Future<void> kaydetSayimGerialCubit(String barkodNo) async {
    print("kaydetcekmi:-$barkodNo");
  }

  Future<void> kaydetSayimSorguCubit(String rafNo, String barkodNo) async {
    print("kaydetcekmi:-$rafNo-$barkodNo");
  }

  // sevkiyat yukleme kaydet
  Future<void> kaydetSevkiyatYuklemeCubit(
    String emirNo,
    String barkodNo,
    String agirlik,
  ) async {
    print("kaydetcekmi -$emirNo-$barkodNo-$agirlik");
  }

  // sevkiyat yukleme sorguuu
  Future<void> kaydetSevkiyatYuklemeSorguCubit(String emirNo) async {
    print("kaydetcekmi -$emirNo");
  }
  // sevkiyat yukleme iptal sorgu

  Future<void> kaydetSevkiyatYuklemeIptalCubit(
    String emirNo,
    String barkodNo,
  ) async {
    print("kaydetcekmi -$emirNo- $barkodNo");
  }

  // transfer hareketleri
  Future<void> kaydetTransferHareketleriCubit(
    String adaNo,
    String siraNo,
    String emirNo,
    String barkodNo,
  ) async {
    print("kaydetcekmi - $adaNo-$siraNo-$emirNo-$barkodNo");
  }

  // malzeme donusumu
  Future<void> kaydetMalzemeDonusumCubit(
    String emirNo,
    String eskiBarkodNo,
    String yeniBarkodNo,
  ) async {
    print("kaydetcekmi - $emirNo-$eskiBarkodNo-$emirNo-$yeniBarkodNo");
  }

  // transfer emir kalan
  Future<void> kaydetEmirKalanCubit(String emirNo) async {
    print("kaydetcekmidd - $emirNo-");
  }

  // uretim giris
  Future<void> kaydetUretimGirisCubit(String emirNo, String barkodNo) async {
    print("kaydetcekmi -$emirNo- $barkodNo");
  }

  // uretim silme
  Future<void> kaydetUretimSilmeCubit(String emirNo, String barkodNo) async {
    print("kaydetcekmi -$emirNo- $barkodNo");
  }

  // uretim kismi iptal
  Future<void> kaydetUretimKismiIptalCubit(
    String belgeNo,
    String paletBarkodNo,
  ) async {
    print("kaydetcekmi -$belgeNo- $paletBarkodNo");
  }

  // urun sorgu
  Future<void> kaydetUrunSorguCubit(String urunIdNo) async {
    print("kaydetcekmi -$urunIdNo");
  }

  // kullanici giris
  Future<void> kaydetKullanciGirisCubit(
    String kullaniciAdi,
    String sifre,
  ) async {
    print("kaydetcekmi -$kullaniciAdi- $sifre");
  }
}
