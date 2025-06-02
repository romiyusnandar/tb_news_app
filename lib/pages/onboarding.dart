import 'package:berita/utils/helper.dart';
import 'package:berita/utils/image_strings.dart';
import 'package:berita/utils/sizes.dart';
import 'package:berita/utils/text_strings.dart';
import 'package:flutter/material.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            children: const [
              OnBoarding(
                image: TImages.onBoardingImage1,
                title: TTexts.onBoardingTitle1,
                subtitle: TTexts.onBoardingSubtitle1
              ),
              OnBoarding(
                image: TImages.onBoardingImage2,
                title: TTexts.onBoardingTitle2,
                subtitle: TTexts.onBoardingSubtitle2
              ),
              OnBoarding(
                image: TImages.onBoardingImage3,
                title: TTexts.onBoardingTitle3,
                subtitle: TTexts.onBoardingSubtitle3
              ),
            ],
          )
        ],
      ),
    );
  }
}

class OnBoarding extends StatelessWidget {
  const OnBoarding({
    super.key,
    required this.image,
    required this.title,
    required this.subtitle,
  });

  final String image, title, subtitle;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(TSizes.defaultSpace),
      child: Column(
        children: [
          Image(
                width: THelperFunctions.screenWidth() * 0.8,
                height: THelperFunctions.screenHeight() * 0.6,
                image: AssetImage(image)
          ),
          Text(title, style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center,),
          SizedBox(height: 32.0,),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center,),
        ],
      ),
    );
  }
}