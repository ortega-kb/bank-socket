class Account {
  final int accountNumber;
  final String name;
  final String surname;
  final String address;

  Account({
    required this.accountNumber,
    required this.address,
    required this.name,
    required this.surname,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      accountNumber: json['account_number'],
      name: json['name'],
      surname: json['surname'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account_number': accountNumber,
      'name': name,
      'surname': surname,
      'address': address,
    };
  }
}
