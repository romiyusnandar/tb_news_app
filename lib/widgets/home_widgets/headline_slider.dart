import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:my_berita/bloc/get_top_headlines.dart';
import 'package:my_berita/model/article/article_model.dart';
import 'package:my_berita/model/article/article_response.dart';
import 'package:my_berita/utils/utility.dart';

class HeadlineSliderWidget extends StatefulWidget {
  const HeadlineSliderWidget({super.key});

  @override
  State<HeadlineSliderWidget> createState() => _HeadlineSliderWidgetState();
}

class _HeadlineSliderWidgetState extends State<HeadlineSliderWidget> {

  @override
  void initState() {
    super.initState();
    getTopHeadlinesBloc.getHeadlines();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ArticleResponse>(
      stream: getTopHeadlinesBloc.subject.stream,
      builder: (context, AsyncSnapshot<ArticleResponse> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.error.isNotEmpty) {
            return SizedBox();
          }
          return _buildHeadlineSliderWidget(snapshot.data!);
        } else if (snapshot.hasError) {
          return SizedBox();
        } else {
          return SizedBox();
        }
      },
    );
  }

  _buildHeadlineSliderWidget(ArticleResponse data) {
    List<Article>? articles = data.articles;
    if (articles.isEmpty) {
      return SizedBox();
    } else {
      return CarouselSlider(
        items: getExpenseSlider(articles),
        options: CarouselOptions(
          autoPlay: true,
          enlargeCenterPage: true,
          enableInfiniteScroll: false,

          height: 230.0,
          viewportFraction: 0.8,
        ),
      );
    }
    return Scaffold();
  }

  getExpenseSlider(List<Article> articles) {
    return articles.map((article) => GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.only(left: 5.0, right: 5.0, top: 10.0, bottom: 10.0),
        child: Stack(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                shape: BoxShape.rectangle,
                // image: DecorationImage(
                //   fit: BoxFit.cover,
                //   image: Utility.getImageComponent(article.urlToImage),
                // )
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    stops: const [0.1, 0.9],
                    colors: [
                      Colors.black.withOpacity(0.9),
                      Colors.white.withOpacity(0.0),
                    ],
                  ),
              ),
            ),
            Positioned(
              bottom: 30.0,
              child: Container(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                width: 250.0,
                child: Column(
                  children: [
                    Text(
                      article.title,
                      style: const TextStyle(
                        height: 1.5,
                        color: Colors.white,
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              )
            ),
            // Positioned(
            //   bottom: 10.0,
            //   left: 10.0,
            //   child: Text(article.source.name!, style: TextStyle(color: Colors.white54, fontSize: 9.0),),
            // ),
            Positioned(
              bottom: 10.0,
              right: 10.0,
              child: Text(timeUntil(article.publishedAt), style: TextStyle(color: Colors.white54, fontSize: 9.0),),
            )
          ],
        ),
      ),
    )).toList();
  }

  String timeUntil(DateTime dateTime) {
    return timeago.format(
      dateTime,
      locale: 'en',
      allowFromNow: true,
    );
  }
}
