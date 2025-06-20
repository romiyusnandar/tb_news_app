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
  late bool _isTrending;

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
    _isTrending = widget.article.isTrending;
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
        'isTrending': _isTrending,
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
        title: const Text("Edit Artikel", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1A1A2E),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            _buildForm(),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("Informasi Utama"),
            _buildTextField(_titleController, "Judul Artikel", icon: Icons.title),
            _buildTextField(_categoryController, "Kategori", icon: Icons.category_outlined),
            _buildTextField(_tagsController, "Tags (pisahkan koma)", icon: Icons.sell_outlined),

            _buildSectionHeader("Detail & Konten"),
            _buildTextField(_readTimeController, "Waktu Baca", icon: Icons.timer_outlined),
            _buildTextField(_imageUrlController, "URL Gambar Sampul", icon: Icons.image_outlined),
            _buildTextField(_contentController, "Tulis konten berita di sini...", maxLines: 10),

            _buildSectionHeader("Pengaturan"),
            _buildSwitchTile(),

            const SizedBox(height: 32),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0, left: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.blueAccent,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1, IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: const TextStyle(color: Colors.white54),
          prefixIcon: icon != null ? Icon(icon, color: Colors.white70, size: 20) : null,
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5),
          ),
        ),
        validator: (value) => value!.isEmpty ? '$label tidak boleh kosong' : null,
      ),
    );
  }

  Widget _buildSwitchTile() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: SwitchListTile(
        title: const Text("Jadikan Berita Trending?", style: TextStyle(color: Colors.white)),
        value: _isTrending,
        onChanged: (bool value) {
          setState(() { _isTrending = value; });
        },
        activeColor: Colors.blueAccent,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        gradient: const LinearGradient(
          colors: [Colors.blueAccent, Colors.lightBlueAccent],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitUpdate,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        ),
        child: const Text(
          "Simpan Perubahan",
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}