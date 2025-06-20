import 'package:flutter/material.dart';
import 'package:my_berita/bloc/get_manage_article_bloc.dart';
import 'package:my_berita/model/article/article_model.dart';
import 'package:my_berita/model/article/article_response.dart';
import 'package:my_berita/repository/repository_second.dart';
import 'package:my_berita/screens/crud/edit_news_screen.dart';

class ManageNewsScreen extends StatefulWidget {
  const ManageNewsScreen({super.key});

  @override
  State<ManageNewsScreen> createState() => _ManageNewsScreenState();
}

class _ManageNewsScreenState extends State<ManageNewsScreen> {
  final NewsRepositorySecond _repository = NewsRepositorySecond();

  @override
  void initState() {
    super.initState();
    getManagedArticlesBloc.getManagedArticles();
  }

  void _navigateToEditScreen(Article article) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => EditNewsScreen(article: article)),
    );

    if (result == true) {
      getManagedArticlesBloc.getManagedArticles();
    }
  }

  void _deleteArticle(String articleId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C3E50),
        title: const Text("Hapus Artikel", style: TextStyle(color: Colors.white)),
        content: const Text("Apakah Anda yakin ingin menghapus artikel ini secara permanen?", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text("Batal", style: TextStyle(color: Colors.white))),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text("Hapus"), style: FilledButton.styleFrom(backgroundColor: Colors.redAccent)),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _repository.deleteArticle(articleId);
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Artikel berhasil dihapus"), backgroundColor: Colors.green),
        );
      }
      getManagedArticlesBloc.getManagedArticles();
    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C2833),
      appBar: AppBar(
        title: const Text("Manage article", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1A1A2E),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: StreamBuilder<ArticleResponse>(
          stream: getManagedArticlesBloc.subject.stream,
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data?.error == "loading") {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.data!.error.isNotEmpty) {
              return Center(child: Text(snapshot.data!.error, style: const TextStyle(color: Colors.white)));
            }
            final articles = snapshot.data!.articles;
            if (articles.isEmpty) {
              return const Center(child: Text("Anda belum memiliki artikel.", style: TextStyle(color: Colors.white70)));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];
                return _ManagedArticleCard(
                  article: article,
                  onEdit: () => _navigateToEditScreen(article),
                  onDelete: () => _deleteArticle(article.id),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ManagedArticleCard extends StatelessWidget {
  final Article article;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ManagedArticleCard({
    required this.article,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF2C3E50),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(article.title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(article.category, style: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic)),
            const Divider(color: Colors.white24, height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text("Edit"),
                  style: TextButton.styleFrom(foregroundColor: Colors.blueAccent),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, size: 18),
                  label: const Text("Hapus"),
                  style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}