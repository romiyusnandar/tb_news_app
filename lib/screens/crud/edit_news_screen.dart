import 'package:flutter/material.dart';
import 'package:my_berita/model/article/article_model.dart';
import 'package:my_berita/repository/repository_second.dart';

class EditNewsScreen extends StatefulWidget {
  final Article article;
  const EditNewsScreen({super.key, required this.article});

  @override
  State<EditNewsScreen> createState() => _EditNewsScreenState();
}

class _EditNewsScreenState extends State<EditNewsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _categoryController;
  late TextEditingController _readTimeController;
  late TextEditingController _imageUrlController;
  late TextEditingController _contentController;
  late TextEditingController _tagsController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.article.title);
    _categoryController = TextEditingController(text: widget.article.category);
    _readTimeController = TextEditingController(text: widget.article.readTime);
    _imageUrlController = TextEditingController(text: widget.article.imageUrl);
    _contentController = TextEditingController(text: widget.article.content);
    _tagsController = TextEditingController(text: widget.article.tags.join(', '));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _readTimeController.dispose();
    _imageUrlController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _submitUpdate() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final tagsList = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      final updatedData = {
        'title': _titleController.text,
        'category': _categoryController.text,
        'readTime': _readTimeController.text,
        'imageUrl': _imageUrlController.text,
        'content': _contentController.text,
        'tags': tagsList,
      };

      try {
        final newsRepository = NewsRepositorySecond();
        await newsRepository.updateArticle(widget.article.id, updatedData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Artikel berhasil diperbarui!"), backgroundColor: Colors.green),
          );
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Gagal memperbarui: ${e.toString()}"), backgroundColor: Colors.red),
          );
        }
      } finally {
        if(mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C2833),
      appBar: AppBar(
        title: const Text("Edit Artikel"),
        backgroundColor: const Color(0xFF1A1A2E),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTextField(_titleController, "Judul"),
                  _buildTextField(_categoryController, "Kategori"),
                  _buildTextField(_tagsController, "Tags (pisahkan dengan koma)"),
                  _buildTextField(_readTimeController, "Waktu Baca"),
                  _buildTextField(_imageUrlController, "URL Gambar"),
                  _buildTextField(_contentController, "Konten Berita", maxLines: 8),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitUpdate,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blueAccent,
                    ),
                    child: const Text("Simpan Perubahan", style: TextStyle(color: Colors.white)),
                  )
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          border: const OutlineInputBorder(),
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
        ),
        validator: (value) => value!.isEmpty ? '$label tidak boleh kosong' : null,
      ),
    );
  }
}
