class UserProfileModel {
  final String id;
  final String name;
  final String email;
  final String photoUrl;
  final String currencyCode;
  final String currencySymbol;
  final String tier;
  final bool isCustomPhoto;

  const UserProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.photoUrl,
    this.currencyCode = 'USD',
    this.currencySymbol = '\$',
    this.tier = 'PRO TIER',
    this.isCustomPhoto = false,
  });

  UserProfileModel copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
    String? currencyCode,
    String? currencySymbol,
    String? tier,
    bool? isCustomPhoto,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      currencyCode: currencyCode ?? this.currencyCode,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      tier: tier ?? this.tier,
      isCustomPhoto: isCustomPhoto ?? this.isCustomPhoto,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'photoUrl': photoUrl,
        'currencyCode': currencyCode,
        'currencySymbol': currencySymbol,
        'tier': tier,
        'isCustomPhoto': isCustomPhoto,
      };

  factory UserProfileModel.fromJson(Map<String, dynamic> json) => UserProfileModel(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        photoUrl: json['photoUrl'] as String,
        currencyCode: json['currencyCode'] as String? ?? 'USD',
        currencySymbol: json['currencySymbol'] as String? ?? '\$',
        tier: json['tier'] as String? ?? 'PRO TIER',
        isCustomPhoto: json['isCustomPhoto'] as bool? ?? false,
      );
}

class CurrencyInfo {
  final String code;
  final String symbol;
  final String name;
  final String flag;

  const CurrencyInfo({
    required this.code,
    required this.symbol,
    required this.name,
    required this.flag,
  });
}

class SupportedCurrencies {
  static const List<CurrencyInfo> all = [
    CurrencyInfo(code: 'USD', symbol: '\$', name: 'US Dollar', flag: '🇺🇸'),
    CurrencyInfo(code: 'EUR', symbol: '€', name: 'Euro', flag: '🇪🇺'),
    CurrencyInfo(code: 'GBP', symbol: '£', name: 'British Pound', flag: '🇬🇧'),
    CurrencyInfo(code: 'INR', symbol: '₹', name: 'Indian Rupee', flag: '🇮🇳'),
    CurrencyInfo(code: 'JPY', symbol: '¥', name: 'Japanese Yen', flag: '🇯🇵'),
    CurrencyInfo(code: 'CAD', symbol: 'CA\$', name: 'Canadian Dollar', flag: '🇨🇦'),
    CurrencyInfo(code: 'AUD', symbol: 'A\$', name: 'Australian Dollar', flag: '🇦🇺'),
    CurrencyInfo(code: 'SGD', symbol: 'S\$', name: 'Singapore Dollar', flag: '🇸🇬'),
    CurrencyInfo(code: 'AED', symbol: 'AED', name: 'UAE Dirham', flag: '🇦🇪'),
    CurrencyInfo(code: 'CHF', symbol: 'CHF', name: 'Swiss Franc', flag: '🇨🇭'),
  ];

  static CurrencyInfo findByCode(String code) {
    return all.firstWhere(
      (c) => c.code.toUpperCase() == code.toUpperCase(),
      orElse: () => all.first,
    );
  }
}
