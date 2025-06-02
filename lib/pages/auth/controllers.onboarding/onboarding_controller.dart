import 'package:berita/pages/home_page.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class OnboardingController extends GetxController {
  static OnboardingController get instance => Get.find();

  final pageController = PageController();
  Rx<int> curretPage = 0.obs;

  void updatePageIndicator(index) => curretPage.value = index;

  void dotNavigationClicked(index) {
    curretPage.value = index;
    pageController.jumpTo(index);
  }

  void nextPage() {
    if (curretPage.value == 2) {
      Get.to(HomePage());
    } else {
      int page = curretPage.value + 1;
      pageController.jumpToPage(page);
    }
  }

  void skipPage() {
    curretPage.value = 2;
    pageController.jumpToPage(2);
  }
}