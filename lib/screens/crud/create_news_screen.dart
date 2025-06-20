import 'package:flutter/material.dart';
import 'package:my_berita/bloc/create_article_bloc.dart';

class CreateNewsScreen extends StatefulWidget {
  const CreateNewsScreen({super.key});

  @override
  State<CreateNewsScreen> createState() => _CreateNewsScreenState();
}

class _CreateNewsScreenState extends State<CreateNewsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _categoryController = TextEditingController();
  final _readTimeController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagsController = TextEditingController();
  bool _isTrending = false;

  @override
  void initState() {
    super.initState();
    createArticleBloc.reset();
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

  void _submitArticle() {
    if (_formKey.currentState!.validate()) {
      final tagsList = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      createArticleBloc.createArticle(
        title: _titleController.text,
        category: _categoryController.text,
        readTime: _readTimeController.text,
        imageUrl: _imageUrlController.text,
        content: _contentController.text,
        tags: tagsList,
        isTrending: _isTrending,
      );
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C3E50),
        title: const Text("Gagal Mempublikasikan", style: TextStyle(color: Colors.white)),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [ TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("OK", style: TextStyle(color: Colors.blueAccent))) ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C2833),
      appBar: AppBar(
        title: const Text("Buat Artikel Baru", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1A1A2E),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: StreamBuilder<CreateArticleResult>(
          stream: createArticleBloc.subject.stream,
          initialData: CreateArticleResult(CreateArticleState.initial),
          builder: (context, snapshot) {
            final result = snapshot.data!;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (result.state == CreateArticleState.success) {
                Navigator.of(context).pop(result.article);
              } else if (result.state == CreateArticleState.error) {
                _showErrorDialog(result.errorMessage!);
                createArticleBloc.reset();
              }
            });

            return Stack(
              children: [
                _buildForm(),
                if (result.state == CreateArticleState.loading)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  // === TAMPILAN FORM YANG BARU DAN LEBIH BAIK ===

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
        onPressed: _submitArticle,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        ),
        child: const Text(
          "Publikasikan Artikel",
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}