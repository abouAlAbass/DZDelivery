enum ProjectStatus { planned, inProgress, completed, awaitingPayment }

String projectStatusCode(ProjectStatus status) {
  switch (status) {
    case ProjectStatus.planned:
      return 'planned';
    case ProjectStatus.inProgress:
      return 'in_progress';
    case ProjectStatus.completed:
      return 'completed';
    case ProjectStatus.awaitingPayment:
      return 'awaiting_payment';
  }
}

ProjectStatus projectStatusFromCode(String code) {
  switch (code) {
    case 'in_progress':
      return ProjectStatus.inProgress;
    case 'completed':
      return ProjectStatus.completed;
    case 'awaiting_payment':
      return ProjectStatus.awaitingPayment;
    case 'planned':
    default:
      return ProjectStatus.planned;
  }
}
