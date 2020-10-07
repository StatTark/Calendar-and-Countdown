import 'package:firebase_admob/firebase_admob.dart';

const String testDevice = 'Mobile_id';

class Advert {
  /// Tekil ornek olusturulmasi icin
  static final Advert _instance = Advert._internal();

  /// Obje olucturuldugunda _instace objeside olusturuluyor
  factory Advert() => _instance;

  /// Ad icin gerekli target infosu
  MobileAdTargetingInfo _targetingInfo = MobileAdTargetingInfo();

  // Banned reklam id
  final String _bannerId = "ca-app-pub-7253836882495109/2763559909";

  // Intersitial reklam id
  final String _interId = "ca-app-pub-7253836882495109/4991758688";

  Advert._internal() {
    _targetingInfo = MobileAdTargetingInfo(
        testDevices: testDevice != null ? <String>[testDevice] : null,
        nonPersonalizedAds: true,
        keywords: <String>["Takvim", "Ajanda"]);
  }

  /// Banner reklam objesi
  static BannerAd _bannerAd;
  /// Banner reklam olusturma fonksiyonu
  BannerAd createBannerAd() {
    return BannerAd(
        adUnitId: _bannerId,
        size: AdSize.smartBanner,
        targetingInfo: _targetingInfo,
        listener: (MobileAdEvent event) {
          print("CreateBannerAd: $event");
        });
  }

  /// Banner reklamini gosteren fonksiyon
  showBannerAd() async {
    // _bannerAd objesine reklam bilgileri veriliyor
    _bannerAd = createBannerAd();
    // Banner yukleniyor ve verilen pozisyonda gosteriliyor
    _bannerAd
      ..load()
      ..show(anchorOffset: 80);
  }

  /// Banner reklamini kapatan fonksiyon
  closeBannerAd() async {
    // Banner'in yuklu olup olmadigini kontrol etmek icin gerekli degisken
    if(_bannerAd!=null){ //
      var isloaded = await _bannerAd?.isLoaded();
      print("isloaded : $isloaded");
      isloaded ? await _bannerAd.dispose() : print("[ADS] [closeBannerAd] Ad isnt loaded");}
    else{
      print("[ADS] [closeBannerAd] _bannerAd is null");
    }
  }

  /// Intersitial olusturup gosteren ve kullanilan kaynaklari bosa cikaran fonksiyon
  void showIntersitial() {
    InterstitialAd interstitialAd = InterstitialAd(
        adUnitId: _interId, // BannerAd.testAdUnitId
        targetingInfo: _targetingInfo,
        listener: (MobileAdEvent event) {
          print("CreateBannerAd: $event");
        });
    interstitialAd
      ..load()
      ..show();
    interstitialAd.dispose();
  }

}
