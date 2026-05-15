import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hissab_dz/features/projects/domain/entities/project_photo.dart';
import 'package:hissab_dz/features/projects/presentation/providers/project_providers.dart';
import 'package:hissab_dz/l10n/app_localizations.dart';

class ProjectPhotosSection extends ConsumerWidget {
  final int projectId;

  const ProjectPhotosSection({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final photosAsync = ref.watch(projectPhotosProvider(projectId));

    return photosAsync.when(
      data: (photos) {
        if (photos.isEmpty) return const SizedBox.shrink();

        final beforePhotos = photos.where((p) => p.category == 'before').toList();
        final duringPhotos = photos.where((p) => p.category == 'during').toList();
        final afterPhotos = photos.where((p) => p.category == 'after').toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text(l10n.projectPhotos, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            if (beforePhotos.isNotEmpty) _buildCategoryGroup(context, l10n.before, beforePhotos),
            if (duringPhotos.isNotEmpty) _buildCategoryGroup(context, l10n.during, duringPhotos),
            if (afterPhotos.isNotEmpty) _buildCategoryGroup(context, l10n.after, afterPhotos),
          ],
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, st) => Text('${l10n.error}: $e'),
    );
  }

  Widget _buildCategoryGroup(BuildContext context, String title, List<ProjectPhoto> photos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13)),
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: photos.length,
            itemBuilder: (context, index) {
              final photo = photos[index];
              return _PhotoCard(photo: photo);
            },
          ),
        ),
      ],
    );
  }
}

class _PhotoCard extends StatelessWidget {
  final ProjectPhoto photo;

  const _PhotoCard({required this.photo});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(right: 12, bottom: 8),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Stack(
        children: [
          SizedBox(
            width: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _viewImage(context),
                    child: Image.file(
                      File(photo.imagePath),
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                if (photo.comment != null)
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      photo.comment!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
              ],
            ),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: Consumer(
              builder: (context, ref, child) {
                return Material(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => _confirmDelete(context, ref, photo),
                    child: const Padding(
                      padding: EdgeInsets.all(6.0),
                      child: Icon(Icons.delete_outline, size: 18, color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _viewImage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: InteractiveViewer(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(File(photo.imagePath)),
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton.filled(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
                style: IconButton.styleFrom(backgroundColor: Colors.black45),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, ProjectPhoto photo) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDelete),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () async {
              await ref.read(projectRepositoryProvider).deleteProjectPhoto(photo.id!);
              ref.invalidate(projectPhotosProvider(photo.projectId));
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
