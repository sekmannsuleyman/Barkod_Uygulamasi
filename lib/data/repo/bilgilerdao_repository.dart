


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
  Future<void> kaydetAmbarSayim(String rafNo,
      String gozNo,
      String barkodNo,
      String adet,
      String sayimNo,) async {
    print("kayetcekmi:- $rafNo- $gozNo- $barkodNo-$adet-$sayimNo");
  }

  // kaydet sayım sorgu
  Future<void> kaydetAmbarSayimSorgu(String rafNo,
      String gozNo,
      String barkodNo,) async {
    print("kayetcekmi:- $rafNo- $gozNo- $barkodNo");
  }

  // ambar sayım geri al kaydet
  Future<void> kaydetAmbarGerial(String barkodNo) async {
    print("kayetcekmi:- $barkodNo");
  }

  // Ean Sorgu kaydet

  // Ean palet karsilastirma kaydet

  // id sorgu kaydet
  Future<void> kaydetIdSorguCubit(String idNo) async {
    print("kayetcekmi:- $idNo");
  }

  // is emrine baglu uretim kaydet
// is emrine baglu uretim kaydet


  // is emrine baglı uretim silme kaydet


  // Numune ada  kaydet
  Future<void> kaydetNumuneAdaKaydetCubit(String malzemeKodu,
      String rafNo,
      String gozNo,) async {
    print("kayetcekmi:- $malzemeKodu- $rafNo-$gozNo");
  }

  // numune ada sorgula kaydet
  Future<void> kaydetNumuneAdaSorgulaCubit(String rafNo, String gozNo) async {
    print("kayetcekmi: - $rafNo-$gozNo");
  }

  // Paletleme kaydet
  Future<void> kaydetPaletlemeCubit(String kutuBarkod,
      String paletBarkod,) async {
    print("kayetcekmi: - $kutuBarkod-$paletBarkod");
  }

  // kaydet paletsilme
  Future<void> kaydetPaletSilmeCubit(String kutuBarkod) async {
    print("kayetcekmi: - $kutuBarkod-");
  }

  // kaydet sarfa cikis
  Future<void> kaydetSarfaCikisCubit(String barkodNo,
      String maliyetMerkezi,
      String depo,
      String miktar,) async {
    print("kayetcekmi: - $barkodNo-$maliyetMerkezi-$depo-$miktar");
  }

  Future<void> kaydetSayimCubit(String adoNo,
      String siraNo,
      String barkodNo,
      String sayimNo,) async {
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

  // sevkiyat yukleme sorguuu



  // sevkiyat yukleme iptal sorgu


  // transfer hareketleri
  Future<void> kaydetTransferHareketleriCubit(String adaNo,
      String siraNo,
      String emirNo,
      String barkodNo,) async {
    print("kaydetcekmi - $adaNo-$siraNo-$emirNo-$barkodNo");
  }

  // malzeme donusumu
  Future<void> kaydetMalzemeDonusumCubit(String emirNo,
      String eskiBarkodNo,
      String yeniBarkodNo,) async {
    print("kaydetcekmi - $emirNo-$eskiBarkodNo-$emirNo-$yeniBarkodNo");
  }

  // transfer emir kalan
  Future<void> kaydetEmirKalanCubit(String emirNo) async {
    print("kaydetcekmidd - $emirNo-");
  }

  // uretim giris



  // uretim silme


  // uretim kismi iptal



  // urun sorgu

}