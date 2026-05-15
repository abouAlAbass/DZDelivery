class ProjectPhoto {
  final int? id;
  final int projectId;
  final String imagePath;
  final String category; // before, during, after
  final String? comment;
  final DateTime createdAt;

  const ProjectPhoto({
    this.id,
    required this.projectId,
    required this.imagePath,
    required this.category,
    this.comment,
    required this.createdAt,
  });

  ProjectPhoto copyWith({
    int? id,
    int? projectId,
    String? imagePath,
    String? category,
    String? comment,
    DateTime? createdAt,
  }) {
    return ProjectPhoto(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      imagePath: imagePath ?? this.imagePath,
      category: category ?? this.category,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
