import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:my_berita/model/article_model.dart';
import 'package:my_berita/screens/news_detail_screen.dart';

class TrendingSliderWidget extends StatelessWidget {
  final List<Article> articles;
  final bool isLoading;

  const TrendingSliderWidget({
    super.key,
    required this.articles,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && articles.isEmpty) {
      return _buildShimmerSlider();
    }

    if (articles.isEmpty) {
      return Container(
        height: 230,
        alignment: Alignment.center,
        child: const Text(
          "Tidak ada berita untuk ditampilkan.",
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return _buildTrendingSliderWidget(context, articles);
  }

  Widget _buildShimmerSlider() {
    return CarouselSlider.builder(
      itemCount: 3,
      itemBuilder: (c, i, r) => const _ShimmerSliderCard(),
      options: CarouselOptions(
        height: 230.0,
        viewportFraction: 0.85,
        enableInfiniteScroll: false,
      ),
    );
  }

  Widget _buildTrendingSliderWidget(BuildContext context, List<Article> articles) {
    final sliderArticles = articles.take(5).toList();

    return CarouselSlider(
      items: sliderArticles.map((article) => _buildSliderItem(context, article)).toList(),
      options: CarouselOptions(
        height: 230.0,
        viewportFraction: 0.85,
        autoPlay: true,
        enlargeCenterPage: true,
      ),
    );
  }

  Widget _buildSliderItem(BuildContext context, Article article) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => NewsDetailScreen(),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5.0),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(12.0)),
              child: FadeInImage.assetNetwork(
                placeholder: 'assets/images/placeholder.png',
                image: article.featuredImageUrl ?? '',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                imageErrorBuilder: (c, o, s) => Container(color: Colors.grey[800]),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  stops: const [0.0, 0.7],
                  colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                ),
              ),
            ),
            Positioned(
              bottom: 20.0,
              left: 20.0,
              right: 20.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.category,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        height: 1.3,
                        color: Colors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _ShimmerSliderCard extends StatelessWidget {
  const _ShimmerSliderCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5.0),
      decoration: BoxDecoration(
          color: const Color(0xFF2C3E50),
          borderRadius: BorderRadius.circular(12.0)),
    );
  }
}