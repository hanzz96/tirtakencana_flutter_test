class FailedReason {
  final String value;
  final String label;

  const FailedReason({required this.value, required this.label});

  static const List<FailedReason> reasons = [
    FailedReason(value: 'Pemilik Sibuk', label: 'Pemilik Sibuk'),
    FailedReason(value: 'Toko Tutup', label: 'Toko Tutup'),
  ];
}