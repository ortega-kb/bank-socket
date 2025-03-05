class History {
  final String date;
  final String libelle;
  final double amount;

  const History({
    required this.date,
    required this.libelle,
    required this.amount,
  });

  factory History.fromJson(Map<String, dynamic> json) {
    return History(
      amount: json['montant'] as double,
      libelle: json['libelle'],
      date: json['date'],
    );
  }
}
