import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:my_berita/bloc/get_trending_news.dart';
import 'package:my_berita/model/article/article_response.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:my_berita/model/article/article_model.dart';

class TrendingSliderWidget extends StatefulWidget {
  const TrendingSliderWidget({super.key});

  @override
  State<TrendingSliderWidget> createState() => _TrendingSliderWidgetState();
}

class _TrendingSliderWidgetState extends State<TrendingSliderWidget> {

  @override
  void initState() {
    super.initState();
    getTrendingNewsBloc.getTrendingNews();
    timeago.setLocaleMessages('id', timeago.IdMessages());
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ArticleResponse>(
      stream: getTrendingNewsBloc.subject.stream,
      builder: (context, AsyncSnapshot<ArticleResponse> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.error == "loading") {
            return _buildShimmerSlider();
          }
          if (snapshot.data!.error.isNotEmpty || !snapshot.data!.success) {
            return _buildErrorWidget(snapshot.data!.error);
          }
          return _buildTrendingSliderWidget(snapshot.data!);
        } else if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error.toString());
        } else {
          return _buildShimmerSlider();
        }
      },
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 40),
          const SizedBox(height: 8),
          Text(
            "Gagal memuat berita: $error",
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerSlider() {
    return CarouselSlider.builder(
      itemCount: 3,
      itemBuilder: (context, index, realIndex) {
        return const _ShimmerSliderCard();
      },
      options: CarouselOptions(
        autoPlay: false,
        enableInfiniteScroll: false,
        height: 230.0,
        viewportFraction: 0.8,
      ),
    );
  }

  Widget _buildTrendingSliderWidget(ArticleResponse data) {
    List<Article> articles = data.articles;
    if (articles.isEmpty) {
      return const Center(child: Text("Tidak ada berita trending saat ini."));
    } else {
      return CarouselSlider(
        items: _getSliderItems(articles),
        options: CarouselOptions(
          autoPlay: true,
          enableInfiniteScroll: articles.length > 1,
          height: 230.0,
          viewportFraction: 0.8,
        ),
      );
    }
  }

  List<Widget> _getSliderItems(List<Article> articles) {
    return articles.map((article) {
      return GestureDetector(
        onTap: () {
          // Navigator.push(context, MaterialPageRoute(builder: (context) => DetailPage(article: article)));
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
          child: Stack(
            children: <Widget>[
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                child: article.imageUrl != null && article.imageUrl!.isNotEmpty
                    ? FadeInImage.assetNetwork(
                  placeholder: 'assets/images/placeholder.png',
                  image: article.imageUrl!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  imageErrorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    );
                  },
                )
                    : Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported, color: Colors.grey),
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    stops: [0.1, 0.9],
                    colors: [
                      Colors.black87,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 50.0,
                left: 15.0,
                right: 15.0,
                child: Text(
                  article.title,
                  style: const TextStyle(
                    height: 1.4,
                    color: Colors.white,
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Positioned(
                bottom: 15.0,
                left: 15.0,
                right: 15.0,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 14.0,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: (article.author.avatar != null && article.author.avatar!.isNotEmpty)
                          ? NetworkImage(article.author.avatar!)
                          : null,
                      child: (article.author.avatar == null || article.author.avatar!.isEmpty)
                          ? const Icon(Icons.person, size: 16, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: Text(
                        article.author.name,
                        style: const TextStyle(color: Colors.white, fontSize: 12.0, fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Text(
                      timeUntil(article.publishedAt),
                      style: const TextStyle(color: Colors.white70, fontSize: 12.0),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  String timeUntil(DateTime dateTime) {
    return timeago.format(dateTime, locale: 'id', allowFromNow: true);
  }
}

class _ShimmerSliderCard extends StatelessWidget {
  const _ShimmerSliderCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2C3E50),
          borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: 15.0,
              left: 15.0,
              right: 15.0,
              child: Row(
                children: [
                  Container(
                    height: 28,
                    width: 28,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    height: 12,
                    width: 100,
                    color: Colors.black.withOpacity(0.2),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 60.0, // Posisi sedikit di atas info penulis
              left: 15.0,
              right: 15.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: double.infinity,
                    color: Colors.black.withOpacity(0.2),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 16,
                    width: MediaQuery.of(context).size.width * 0.5,
                    color: Colors.black.withOpacity(0.2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
