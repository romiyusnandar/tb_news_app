# MyBerita App (Android)

MyBerita App adalah aplikasi berita mobile untuk Android yang dibangun menggunakan Flutter. Aplikasi ini memungkinkan pengguna untuk menjelajahi berita terbaru dan, setelah login, memberikan kemampuan untuk membuat, mengelola, dan mempersonalisasi konten berita mereka sendiri.

## Fitur Utama

- **Akses Publik & Terautentikasi:** Semua pengguna dapat membaca berita. Pengguna yang login mendapatkan akses ke fitur-fitur eksklusif.
- **Beranda Dinamis:** Menampilkan berita teratas dalam slider interaktif dan daftar semua berita dengan *infinite scroll*.
- **Tarik untuk Menyegarkan:** Muat ulang konten dengan mudah menggunakan gestur *pull-to-refresh*.
- **Manajemen State Reaktif:** Menggunakan BLoC (Business Logic Component) untuk manajemen state yang terpisah dan efisien.
- **Autentikasi Pengguna:** Alur login yang aman untuk mengakses fitur penulis.
- **CRUD Artikel:** Pengguna yang sudah login dapat **C**reate (membuat), **R**ead (membaca), **U**pdate (mengedit), dan **D**elete (menghapus) artikel mereka sendiri.
- **Bookmark Lokal:** Pengguna dapat menandai artikel favorit mereka, yang disimpan secara lokal di perangkat.
- **Halaman Profil:** Menampilkan informasi pengguna yang login dan daftar artikel yang telah mereka buat.
- **Tampilan Detail Artikel:** Halaman baca yang elegan dengan gambar header yang dinamis (*SliverAppBar*).

## Penjelasan Arsitektur

Aplikasi ini dirancang dengan arsitektur yang bersih untuk memisahkan tanggung jawab antara lapisan-lapisan yang berbeda, membuatnya mudah dikelola dan dikembangkan. Alur data utama mengikuti pola: **UI ➔ BLoC ➔ Repository ➔ API**.

### 1. UI (User Interface) - Lapisan Tampilan
- **Tugas:** Bertanggung jawab penuh untuk menampilkan data kepada pengguna. Lapisan ini bersifat "pasif" atau "bodoh" (*dumb*).
- **Cara Kerja:** UI tidak tahu cara mengambil data. Ia hanya bereaksi terhadap *state* (keadaan) yang diberikan oleh BLoC. Jika BLoC memberi *state* `success` dengan data berita, UI akan menampilkan daftar berita. Jika diberi *state* `loading`, ia akan menampilkan *shimmer effect* atau *progress indicator*.
- **Kenapa Penting?** Ini membuat kode tampilan menjadi sangat bersih dan fokus hanya pada aspek visual, sehingga mudah untuk diubah desainnya tanpa merusak logika aplikasi.

### 2. BLoC (Business Logic Component) - Lapisan Logika
- **Tugas:** Menjadi "otak" di balik setiap fitur. BLoC menjembatani interaksi pengguna di UI dengan sumber data.
- **Cara Kerja:** BLoC menerima *event* (perintah) dari UI (misalnya, "pengguna menarik layar untuk me-refresh"). Kemudian, ia berkomunikasi dengan `Repository` untuk meminta data yang sesuai. Setelah itu, ia mengeluarkan *state* baru (misalnya, `loading`, `success`, atau `error`) yang akan "didengarkan" oleh UI.
- **Kenapa Penting?** Ini memisahkan logika (apa yang harus dilakukan) dari tampilan (bagaimana menampilkannya), membuat kode lebih terstruktur, mudah diuji, dan mencegah *bug* terkait state.

### 3. Repository - Lapisan Data
- **Tugas:** Bertindak sebagai satu-satunya gerbang untuk semua sumber data aplikasi. Ia menyembunyikan kompleksitas dari mana dan bagaimana data diambil (dalam kasus ini, dari API eksternal).
- **Cara Kerja:** Ketika BLoC membutuhkan data, ia hanya akan bertanya ke `Repository`. Repository-lah yang tahu URL endpoint mana yang harus dipanggil, header apa yang harus digunakan, dan bagaimana cara mem-parsing respons JSON.
- **Kenapa Penting?** Jika suatu saat sumber data berubah (misalnya, pindah ke API baru atau menambahkan database lokal), kita **hanya perlu mengubah kode di dalam `Repository`**. Bagian BLoC dan UI tidak akan terpengaruh sama sekali.

## Teknologi yang Digunakan

- **Bahasa:** Dart
- **Framework:** Flutter
- **State Management:** `rxdart` (khususnya `BehaviorSubject`) untuk membuat aliran data yang reaktif.
- **Networking:** `dio` untuk menangani semua permintaan HTTP ke API, dengan penanganan error yang kuat.
- **Penyimpanan Lokal:** `shared_preferences` untuk menyimpan data sesi (token autentikasi) dan preferensi pengguna (bookmark).
- **Komponen UI:**
    - `carousel_slider`: Untuk menampilkan berita teratas di beranda.
    - `eva_icons_flutter`: Untuk set ikon yang konsisten dan modern.
    - `hexcolor`: Untuk penggunaan warna kustom.

## Setup & Instalasi

Untuk menjalankan proyek ini secara lokal, ikuti langkah-langkah berikut:

1.  **Prasyarat:** Pastikan Anda sudah menginstal [Flutter SDK](https://flutter.dev/docs/get-started/install) di mesin Anda.
2.  **Clone Repository:**
    ```sh
    git clone https://github.com/romiyusnandar/tb_news_app
    cd my_berita
    ```
3.  **Instal Dependensi:**
    ```sh
    flutter pub get
    ```
4.  **Jalankan Aplikasi:**
    Hubungkan perangkat Android atau jalankan emulator, lalu jalankan perintah berikut:
    ```sh
    flutter run
    ```

