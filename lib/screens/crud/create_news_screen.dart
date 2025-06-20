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
  final _tagsController = TextEditingController(); // PERUBAHAN: Controller untuk tags

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
    _tagsController.dispose(); // PERUBAHAN: Dispose controller tags
    super.dispose();
  }

  void _submitArticle() {
    if (_formKey.currentState!.validate()) {
      // PERUBAHAN: Mengubah string tags menjadi List<String>
      final tagsList = _tagsController.text
          .split(',')
          .map((tag) => tag.trim()) // Menghapus spasi ekstra
          .where((tag) => tag.isNotEmpty) // Menghapus tag kosong
          .toList();

      createArticleBloc.createArticle(
        title: _titleController.text,
        category: _categoryController.text,
        readTime: _readTimeController.text,
        imageUrl: _imageUrlController.text,
        content: _contentController.text,
        tags: tagsList, // PERUBAHAN: Mengirimkan list of tags
      );
    }
  }

  // --- FUNGSI BARU UNTUK MENAMPILKAN DIALOG ERROR ---
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C3E50),
        title: const Text("Gagal Mempublikasikan", style: TextStyle(color: Colors.white)),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK", style: TextStyle(color: Colors.blueAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C2833),
      appBar: AppBar(
        title: const Text("Buat Artikel Baru"),
        backgroundColor: const Color(0xFF1A1A2E),
      ),
      body: StreamBuilder<CreateArticleResult>(
        stream: createArticleBloc.subject.stream,
        initialData: CreateArticleResult(CreateArticleState.initial),
        builder: (context, snapshot) {
          final result = snapshot.data!;

          // PERUBAHAN: Gunakan dialog untuk menampilkan error.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (result.state == CreateArticleState.success) {
              Navigator.of(context).pop(result.article);
            } else if (result.state == CreateArticleState.error) {
              _showErrorDialog(result.errorMessage!); // Panggil dialog
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
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextField(_titleController, "Judul"),
            _buildTextField(_categoryController, "Kategori (e.g., Olahraga)"),
            _buildTextField(_tagsController, "Tags (pisahkan dengan koma)"), // PERUBAHAN: Menambahkan field tags
            _buildTextField(_readTimeController, "Waktu Baca (e.g., 5 menit)"),
            _buildTextField(_imageUrlController, "URL Gambar"),
            _buildTextField(_contentController, "Konten Berita", maxLines: 8),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitArticle,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blueAccent,
              ),
              child: const Text("Publikasikan", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
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