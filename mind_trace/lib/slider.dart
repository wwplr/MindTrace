import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';

class TSlider extends StatefulWidget {
  const TSlider({Key? key}) : super(key: key);

  @override
  State<TSlider> createState() => _TSliderState();
}

class _TSliderState extends State<TSlider> {
  final CarouselController carouselController = CarouselController();
  int current = 0;
  String description = 'Go to your profile page on TikTok and click on the menu bar on the top right corner.';

  final List<String> imgList = [
    'assets/images/1.png',
    'assets/images/2.png',
    'assets/images/3.png',
    'assets/images/4.png',
    'assets/images/5.png',
    'assets/images/6.png',
    'assets/images/7.png',
    'assets/images/8.png',
    'assets/images/9.png',
    'assets/images/10.png',
    'assets/images/11.png',
    'assets/images/12.png'
  ];

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void changeDescription(int index) {
    if(index == 0) {
      description = 'Go to your TikTok profile page and tap the menu icon in the top right corner.';
    } else if (index == 1) {
      description = "Click on 'Settings and privacy'.";
    } else if (index == 2) {
      description = "Click on 'Account'.";
    } else if (index == 3) {
      description = "Click on 'Download your data'.";
    } else if (index == 4) {
      description = "Make sure to select 'All data' and 'TXT' file format. Then click 'Request data'.";
    } else if (index == 5) {
      description = "File generation takes a few minutes. Once complete, click 'Download'. You'll receive a verification code from TikTok to verify your identity.";
    } else if (index == 6) {
      description = "You will be directed to a web browser. Click 'Download'.";
    } else if (index == 7) {
      description = "Go to the menu on the top left corner. Click on 'Downloads'.";
    } else if (index == 8) {
      description = "Click on the magnifying glass.";
    } else if (index == 9) {
      description = "You will be directed to the Files app. Tap the zip file once to uncompress.";
    } else if (index == 10) {
      description = "Open MindTrace app and click on the 'Upload File' button. Open the uncompressed folder and navigate to 'Activity'.";
    } else if (index == 11) {
      description = "Select 'Browsing History'.";
    }
  }

  double currentScale = 1;

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double fontSize = width * 0.03;

    return PopScope(
        canPop: false,
        child: Center(
            child: SizedBox(
                width: width*0.85,
                height: height*0.75,
                child: DecoratedBox(
                    decoration: BoxDecoration(
                        color: Color(0xFFFFF8EA),
                        borderRadius: BorderRadius.all(Radius.circular(10))
                    ),
                    child: Container(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                alignment: Alignment.topRight,
                                margin: EdgeInsets.only(top: height*0.01, right: width*0.015),
                                child: IconButton(
                                  icon: Icon(Icons.close_outlined),
                                  color: Color(0xFF2A364E),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ),
                              CarouselSlider(
                                items: imgList.map((item) {
                                  return Builder(
                                    builder: (BuildContext context) {
                                      return GestureDetector(
                                        onScaleUpdate: (details) {
                                          double scale = details.scale;
                                          double newScale = scale;
                                          setState(() {
                                            currentScale = newScale;
                                          });
                                        },
                                        child: Container(
                                          constraints: BoxConstraints.expand(
                                          height: height,
                                          ),
                                          child: PhotoView(
                                            imageProvider: AssetImage(item),
                                            minScale: PhotoViewComputedScale.contained,
                                            maxScale: PhotoViewComputedScale.covered * 2.0,
                                            initialScale: PhotoViewComputedScale.contained,
                                            scaleStateController: PhotoViewScaleStateController(),
                                            backgroundDecoration: BoxDecoration(
                                              color: Colors.transparent,
                                            ),
                                          ),
                                        )
                                      );
                                    },
                                  );
                                }).toList(),
                                carouselController: carouselController,
                                options: CarouselOptions(
                                  height: height * 0.55,
                                  autoPlay: false,
                                  enlargeCenterPage: true,
                                  onPageChanged: (index, reason) {
                                    setState(() {
                                      current = index;
                                      changeDescription(index);
                                    });
                                  },
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: imgList.asMap().entries.map((entry) {
                                  return GestureDetector(
                                    onTap: () => carouselController.animateToPage(entry.key),
                                    child: Container(
                                      width: 12.0,
                                      height: 12.0,
                                      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: (Theme.of(context).brightness == Brightness.dark
                                              ? Colors.white
                                              : Colors.black)
                                              .withOpacity(current == entry.key ? 0.9 : 0.4)
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              Container(
                                padding: EdgeInsets.only(top: height*0.005, left: width*0.025, right: width*0.025),
                                child: Text(
                                  description,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: fontSize*1.2,
                                    fontFamily: 'Quicksand',
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal,
                                      decoration: TextDecoration.none
                                  ),
                                )
                              )
                            ]
                        )
                    )
                )
            )
        )
    );
  }
}