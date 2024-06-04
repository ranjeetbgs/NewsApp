import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';


class BannerAds extends StatefulWidget {
  const BannerAds({Key? key, this.adUnitId = ''})
      : super(key: key);

  final String adUnitId;

  @override
  State<BannerAds> createState() => _BannerAdsState();
}

class _BannerAdsState extends State<BannerAds> {
  late BannerAd myBanner;
  bool isBannerLoaded = false;

  @override
  void initState() {
      myBannerAd();
    super.initState();
  }

  void myBannerAd() async {
    myBanner = BannerAd(
      adUnitId: widget.adUnitId != '' ? widget.adUnitId : '',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(onAdLoaded: (ad) {
        myBanner = ad as BannerAd;
        isBannerLoaded = true;
        setState(() {});
      }, onAdFailedToLoad: (ad, error) {
        setState(() {
          isBannerLoaded = false;
        });
        ad.dispose();
      }),
    );
    await myBanner.load();
  }

  @override
  void dispose() {
      myBanner.dispose();
      super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    var size2 = MediaQuery.of(context).size;
    // var isDark = Theme.of(context).brightness == Brightness.dark;
    return isBannerLoaded
        ? Container(
            alignment: Alignment.center,
            width: size2.width,
            height: myBanner!.size.height.toDouble(),
            color: Theme.of(context).cardColor,
            child: AdWidget(ad: myBanner!)
          )
        : Container(
            width: size2.width,
            color: Theme.of(context).cardColor,
            alignment: Alignment.center,
            height: 40,
            child: const SizedBox(),
          );
  }
}



class FacebookAd extends StatefulWidget {
  const FacebookAd({Key? key, this.adUnitId = ''})
      : super(key: key);

  final String adUnitId;

  @override
  State<FacebookAd> createState() => _FacebookAdState();
}

class _FacebookAdState extends State<FacebookAd> {

  late Widget facebookAd;
  bool isBannerLoaded = false;

  @override
  void initState() {
 
    facebookAds();
    super.initState();
  }


   facebookAds() {
    facebookAd = FacebookBannerAd(
      placementId: "IMG_16_9_APP_INSTALL#${widget.adUnitId}", //testid
      bannerSize: BannerSize.STANDARD,
      keepAlive:true,
      listener: (result, value) {
        switch (result) {
          case BannerAdResult.LOADED:
           isBannerLoaded=true;
           setState(() { });
            debugPrint('------------- LOADED $value -----------');
            break;
          case BannerAdResult.ERROR:
            debugPrint('------------- ERROR $value -----------');
            break;
          case BannerAdResult.CLICKED:
            debugPrint('------------- CLICKED $value -----------');
            break;
          case BannerAdResult.LOGGING_IMPRESSION:
            debugPrint('------------- LOGGING_IMPRESSION $value -----------');
            break;
        }
        debugPrint("Banner Ad: $result -->  $value");
      },
    );
    print(facebookAd.toString());
  }

  @override
  Widget build(BuildContext context) {
    var size2 = MediaQuery.of(context).size;
    // var isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
            alignment: Alignment.center,
            width: size2.width,
            height: 50,
            color: Theme.of(context).cardColor,
            child: isBannerLoaded
                ? facebookAd
                : const SizedBox(
                  child: Text('Facebook Ads',style: TextStyle(
                    fontSize: 16
                  )),
                ),
          );
        // : Container(
          //   width: size2.width,
          //   color: Theme.of(context).cardColor,
          //   alignment: Alignment.center,
          //   height: 40,
          //   child: const SizedBox(),
          // );
  }
}
