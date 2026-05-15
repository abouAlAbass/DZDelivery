import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:hissab_dz/features/projects/domain/entities/project_photo.dart';
import 'package:hissab_dz/features/projects/presentation/providers/project_providers.dart';
import 'package:hissab_dz/l10n/app_localizations.dart';

class PhotoCaptureSheet extends ConsumerStatefulWidget {
  final int projectId;

  const PhotoCaptureSheet({super.key, required this.projectId});

  @override
  ConsumerState<PhotoCaptureSheet> createState() => _PhotoCaptureSheetState();
}

class _PhotoCaptureSheetState extends ConsumerState<PhotoCaptureSheet> {
  final _commentController = TextEditingController();
  String _selectedCategory = 'before';
  File? _imageFile;
  final _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 70,
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _savePhoto() async {
    if (_imageFile == null) return;

    // Save image to app docs to persist it
    final appDir = await getApplicationDocumentsDirectory();
    final photosDir = Directory(p.join(appDir.path, 'project_photos'));
    if (!photosDir.existsSync()) photosDir.createSync(recursive: true);

    final fileName = 'project_${widget.projectId}_${DateTime.now().millisecondsSinceEpoch}${p.extension(_imageFile!.path)}';
    final savedFilePath = p.join(photosDir.path, fileName);
    await _imageFile!.copy(savedFilePath);

    final photo = ProjectPhoto(
      projectId: widget.projectId,
      imagePath: savedFilePath,
      category: _selectedCategory,
      comment: _commentController.text.trim().isEmpty ? null : _commentController.text.trim(),
      createdAt: DateTime.now(),
    );

    await ref.read(projectRepositoryProvider).addProjectPhoto(photo);
    ref.invalidate(projectPhotosProvider(widget.projectId));

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.fromLTRB(16, 0, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.addPhoto, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            if (_imageFile != null)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(_imageFile!, height: 200, width: double.infinity, fit: BoxFit.cover),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: IconButton.filled(
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() => _imageFile = null),
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: Text(l10n.camera),
                      onPressed: () => _pickImage(ImageSource.camera),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.photo_library_outlined),
                      label: Text(l10n.gallery),
                      onPressed: () => _pickImage(ImageSource.gallery),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            Text(l10n.photoCategory, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'before', label: Text(l10n.before)),
                ButtonSegment(value: 'during', label: Text(l10n.during)),
                ButtonSegment(value: 'after', label: Text(l10n.after)),
              ],
              selected: {_selectedCategory},
              onSelectionChanged: (val) => setState(() => _selectedCategory = val.first),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                labelText: l10n.comment,
                hintText: l10n.notesOptional,
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _imageFile != null ? _savePhoto : null,
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}
