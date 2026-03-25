enum MemorizationStatus {
  notStarted,
  inProgress,
  memorized,
  needsReview;

  String get label => switch (this) {
    notStarted => 'Belum Mulai',
    inProgress => 'Sedang Dihafal',
    memorized => 'Sudah Hafal',
    needsReview => 'Perlu Murojaah',
  };
}
