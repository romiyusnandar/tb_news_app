import 'package:flutter/material.dart';
import 'package:my_berita/model/article/article_model.dart';
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
          _buildSliverAppBar(),
          SliverSafeArea(
            top: false,
            sliver: _buildSliverContent(),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      backgroundColor: const Color(0xFF1A1A2E),
      expandedHeight: 250.0,
      pinned: true,
      iconTheme: IconThemeData(color: Colors.white),
      flexibleSpace: FlexibleSpaceBar(
        background: article.imageUrl != null
            ? FadeInImage.assetNetwork(
          placeholder: 'assets/images/placeholder.png',
          image: article.imageUrl!,
          fit: BoxFit.cover,
          imageErrorBuilder: (c, o, s) =>
          const Icon(Icons.broken_image, color: Colors.grey),
        )
            : Container(color: Colors.grey[800]),
      ),
    );
  }

  SliverToBoxAdapter _buildSliverContent() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              article.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildAuthorInfo(),
            const Divider(color: Colors.white24, height: 30),
            _buildMetadata(),
            const SizedBox(height: 20),
            Text(
              article.content ?? 'Konten tidak tersedia.',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16.0,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 20),

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
          backgroundImage: article.author.avatar != null &&
              article.author.avatar!.isNotEmpty
              ? NetworkImage(article.author.avatar!)
              : null,
          child: article.author.avatar == null ||
              article.author.avatar!.isEmpty
              ? const Icon(Icons.person)
              : null,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              article.author.name,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
            Text(
              article.author.title ?? 'Kontributor',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildMetadata() {
    return Row(
      children: [
        _buildMetadataItem(Icons.category_outlined, article.category),
        const SizedBox(width: 20),
        _buildMetadataItem(Icons.timer_outlined, article.readTime ?? 'N/A'),
        const SizedBox(width: 20),
        _buildMetadataItem(
            Icons.date_range_outlined, timeago.format(article.publishedAt, locale: 'id')),
      ],
    );
  }

  Widget _buildMetadataItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: Colors.white70, fontSize: 14)),
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
        const Divider(color: Colors.white24, height: 30),
        const Text("Tags",
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: article.tags
              .map((tag) => Chip(
            label: Text(tag),
            backgroundColor: const Color(0xFF2C3E50),
            labelStyle: const TextStyle(color: Colors.white),
          ))
              .toList(),
        ),
      ],
    );
  }
}
