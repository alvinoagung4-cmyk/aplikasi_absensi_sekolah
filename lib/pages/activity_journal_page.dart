import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:projectone/services/activity_service.dart';
import 'package:projectone/models/activity_model.dart';

class ActivityJournalPage extends StatefulWidget {
  const ActivityJournalPage({super.key});

  @override
  State<ActivityJournalPage> createState() => _ActivityJournalPageState();
}

class _ActivityJournalPageState extends State<ActivityJournalPage> {
  final ImagePicker _imagePicker = ImagePicker();
  List<ActivityJournal> journals = [];
  List<File> selectedPhotos = [];
  bool isLoading = false;

  // Form controllers
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController subjectController;
  late TextEditingController locationController;
  late TextEditingController totalParticipantsController;

  late int selectedMonth = DateTime.now().month;
  late int selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    descriptionController = TextEditingController();
    subjectController = TextEditingController();
    locationController = TextEditingController();
    totalParticipantsController = TextEditingController();
    _loadJournals();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    subjectController.dispose();
    locationController.dispose();
    totalParticipantsController.dispose();
    super.dispose();
  }

  Future<void> _loadJournals() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final data = await ActivityService.getActivityJournals(
        bulan: selectedMonth,
        tahun: selectedYear,
      );
      if (mounted) setState(() => journals = data);
    } catch (e) {
      if (mounted) _showErrorSnackBar('Gagal memuat jurnal: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        if (mounted) {
          setState(() {
            selectedPhotos.add(File(pickedFile.path));
          });
        }
      }
    } catch (e) {
      if (mounted) _showErrorSnackBar('Gagal mengambil foto: $e');
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        if (mounted) {
          setState(() {
            selectedPhotos.add(File(pickedFile.path));
          });
        }
      }
    } catch (e) {
      if (mounted) _showErrorSnackBar('Gagal memilih foto: $e');
    }
  }

  String _encodeImageToBase64(File imageFile) {
    List<int> imageBytes = imageFile.readAsBytesSync();
    return base64Encode(imageBytes);
  }

  Future<void> _createJournal() async {
    if (titleController.text.isEmpty || descriptionController.text.isEmpty) {
      _showErrorSnackBar('Judul dan deskripsi harus diisi');
      return;
    }

    if (selectedPhotos.isEmpty) {
      _showErrorSnackBar('Tambahkan minimal 1 foto');
      return;
    }

    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      // Buat jurnal
      final journal = await ActivityService.createActivityJournal(
        judulKegiatan: titleController.text,
        deskripsiKegiatan: descriptionController.text,
        mataPelajaran: subjectController.text.isEmpty ? null : subjectController.text,
        lokasi: locationController.text.isEmpty ? null : locationController.text,
        totalPeserta: totalParticipantsController.text.isEmpty
            ? null
            : int.tryParse(totalParticipantsController.text),
      );

      if (journal != null) {
        // Upload foto-foto
        for (int i = 0; i < selectedPhotos.length; i++) {
          await ActivityService.uploadActivityPhoto(
            activityId: journal.id,
            photoBase64: _encodeImageToBase64(selectedPhotos[i]),
            photoOrder: i + 1,
          );
        }

        // Submit jurnal
        await ActivityService.submitActivityJournal(journal.id);

        if (mounted) {
          _showSuccessSnackBar('Jurnal kegiatan berhasil dibuat dan foto uploaded!');
          _clearForm();
          await _loadJournals();
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) _showErrorSnackBar('Gagal membuat jurnal: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _clearForm() {
    titleController.clear();
    descriptionController.clear();
    subjectController.clear();
    locationController.clear();
    totalParticipantsController.clear();
    if (mounted) setState(() => selectedPhotos.clear());
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('📝 Jurnal Kegiatan'),
          backgroundColor: Colors.blue,
          elevation: 0,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Daftar Jurnal'),
              Tab(text: 'Buat Jurnal'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildJournalList(),
            _buildCreateJournalForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildJournalList() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (journals.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.menu_book,
                size: 64,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 16),
              Text(
                'Belum ada jurnal',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Mulai buat jurnal kegiatan Anda',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadJournals,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: journals.length,
        itemBuilder: (context, index) {
          final journal = journals[index];
          return _buildJournalCard(journal);
        },
      ),
    );
  }

  Widget _buildJournalCard(ActivityJournal journal) {
    Color statusColor;
    String statusLabel;

    switch (journal.status) {
      case 'draft':
        statusColor = Colors.grey;
        statusLabel = 'Draft';
        break;
      case 'submitted':
        statusColor = Colors.blue;
        statusLabel = 'Disubmit';
        break;
      case 'approved':
        statusColor = Colors.green;
        statusLabel = 'Disetujui';
        break;
      default:
        statusColor = Colors.grey;
        statusLabel = journal.status;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        journal.judulKegiatan,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        journal.tanggal,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  journal.deskripsiKegiatan,
                  style: const TextStyle(fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    if (journal.mataPelajaran != null)
                      _buildInfoChip('📚 ${journal.mataPelajaran}'),
                    if (journal.lokasi != null)
                      _buildInfoChip('📍 ${journal.lokasi}'),
                    if (journal.totalPeserta != null)
                      _buildInfoChip('👥 ${journal.totalPeserta} peserta'),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Foto: ${journal.photos.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (journal.photos.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: journal.photos.length,
                      itemBuilder: (context, index) {
                        final photo = journal.photos[index];
                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[300],
                          ),
                          child: photo.photoUrl.startsWith('data:image')
                              ? Image.memory(
                                  base64Decode(
                                    photo.photoUrl.split(',')[1],
                                  ),
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image),
                                ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11),
      ),
    );
  }

  Widget _buildCreateJournalForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul
          _buildFormField(
            label: 'Judul Kegiatan *',
            controller: titleController,
            hint: 'Contoh: Praktikum Kimia',
            maxLines: 1,
          ),
          const SizedBox(height: 16),

          // Deskripsi
          _buildFormField(
            label: 'Deskripsi Kegiatan *',
            controller: descriptionController,
            hint: 'Jelaskan kegiatan yang dilakukan...',
            maxLines: 4,
          ),
          const SizedBox(height: 16),

          // Mata Pelajaran
          _buildFormField(
            label: 'Mata Pelajaran',
            controller: subjectController,
            hint: 'Contoh: Kimia',
            maxLines: 1,
          ),
          const SizedBox(height: 16),

          // Lokasi
          _buildFormField(
            label: 'Lokasi Kegiatan',
            controller: locationController,
            hint: 'Contoh: Lab Kimia',
            maxLines: 1,
          ),
          const SizedBox(height: 16),

          // Total Peserta
          _buildFormField(
            label: 'Total Peserta',
            controller: totalParticipantsController,
            hint: 'Contoh: 30',
            maxLines: 1,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),

          // Upload Foto Section
          const Text(
            'Upload Foto Kegiatan',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 12),

          // Photo Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Ambil Foto'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _pickImageFromGallery,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Pilih dari Galeri'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Preview Foto
          if (selectedPhotos.isNotEmpty) ...[
            Text(
              'Foto yang dipilih (${selectedPhotos.length})',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: selectedPhotos.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            selectedPhotos[index],
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () {
                              setState(() => selectedPhotos.removeAt(index));
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: isLoading ? null : _createJournal,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                disabledBackgroundColor: Colors.grey,
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Buat Jurnal',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          maxLines: maxLines,
          keyboardType: keyboardType,
        ),
      ],
    );
  }
}
