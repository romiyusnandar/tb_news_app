import 'package:flutter/material.dart';
import 'package:my_berita/model/article_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class NewsDetailScreen extends StatelessWidget {
  final Article article;
  const NewsDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C2833),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverSafeArea(
            top: false,
            sliver: _buildSliverContent(context),
          )
        ],
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: const Color(0xFF1A1A2E),
      expandedHeight: 270.0,
      pinned: true,
      stretch: true,
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Hero(
          tag: article.id,
          child: article.featuredImageUrl != null && article.featuredImageUrl!.isNotEmpty
              ? FadeInImage.assetNetwork(
            placeholder: 'assets/images/placeholder.png',
            image: article.featuredImageUrl!,
            fit: BoxFit.cover,
            imageErrorBuilder: (c, o, s) =>
            const Icon(Icons.broken_image, color: Colors.grey, size: 50),
          )
              : Container(
            color: Colors.grey[800],
            child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 50),
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildSliverContent(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kategori
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                article.category,
                style: const TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Judul
            Text(
              article.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26.0,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            // Ringkasan
            if (article.summary != null && article.summary!.isNotEmpty)
              Text(
                article.summary!,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16.0,
                  fontStyle: FontStyle.italic,
                ),
              ),
            const SizedBox(height: 20),

            // Info Penulis
            _buildAuthorInfo(),
            const Divider(color: Colors.white24, height: 40),

            // Konten Utama
            Text(
              article.content,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17.0,
                height: 1.7,
              ),
            ),
            const SizedBox(height: 24),

            // Tags
            _buildTags(),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthorInfo() {
    return Row(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: Colors.grey.shade800,
          backgroundImage: article.authorAvatar != null && article.authorAvatar!.isNotEmpty
              ? NetworkImage(article.authorAvatar!)
              : null,
          child: article.authorAvatar == null || article.authorAvatar!.isEmpty
              ? const Icon(Icons.person, color: Colors.white70)
              : null,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              article.authorName,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
            const SizedBox(height: 2),
            Text(
              timeago.format(article.publishedAt, locale: 'id'),
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildTags() {
    if (article.tags.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Tags", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10.0,
          runSpacing: 10.0,
          children: article.tags.map((tag) => Chip(
            label: Text(tag, style: const TextStyle(color: Colors.white)),
            backgroundColor: const Color(0xFF2C3E50),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          )).toList(),
        ),
      ],
    );
  }
}
