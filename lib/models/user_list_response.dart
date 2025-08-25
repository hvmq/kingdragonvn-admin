class UserListResponse {
  final String message;
  final List<UserListItem> users;
  final Pagination pagination;

  UserListResponse({
    required this.message,
    required this.users,
    required this.pagination,
  });

  factory UserListResponse.fromJson(Map<String, dynamic> json) {
    return UserListResponse(
      message: json['message'] as String,
      users: (json['users'] as List)
          .map((user) => UserListItem.fromJson(user))
          .toList(),
      pagination: Pagination.fromJson(json['pagination']),
    );
  }
}

class UserListItem {
  final String id;
  final String username;
  final String phoneNumber;
  final String role;
  final int balance;
  final bool isVerified;
  final String refId;
  final String vip;
  final VipInfo? vipInfo;
  final String? sponsor;

  UserListItem({
    required this.id,
    required this.username,
    required this.phoneNumber,
    required this.role,
    required this.balance,
    required this.isVerified,
    required this.refId,
    required this.vip,
    this.vipInfo,
    this.sponsor,
  });

  factory UserListItem.fromJson(Map<String, dynamic> json) {
    return UserListItem(
      id: json['_id'] as String,
      username: json['username'] as String,
      phoneNumber: json['phoneNumber'] as String,
      role: json['role'] as String,
      balance: json['balance'] as int,
      isVerified: json['isVerified'] as bool,
      refId: json['refId'] as String,
      vip: json['vip'] as String? ?? 'VIP 0',
      vipInfo:
          json['vipInfo'] != null ? VipInfo.fromJson(json['vipInfo']) : null,
      sponsor: json['sponsor'] as String?,
    );
  }
}

class VipInfo {
  final VipPackage? package;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;
  final int remainingDays;

  VipInfo({
    this.package,
    this.startDate,
    this.endDate,
    required this.isActive,
    required this.remainingDays,
  });

  factory VipInfo.fromJson(Map<String, dynamic> json) {
    return VipInfo(
      package:
          json['package'] != null ? VipPackage.fromJson(json['package']) : null,
      startDate:
          json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      isActive: json['isActive'] as bool,
      remainingDays: json['remainingDays'] as int,
    );
  }
}

class VipPackage {
  final String id;
  final String name;
  final int price;
  final int duration;
  final String description;
  final List<String> benefits;
  final bool isActive;
  final String? createdAt;
  final String? updatedAt;
  final int? adjustedPrice;

  VipPackage({
    required this.id,
    required this.name,
    required this.price,
    required this.duration,
    required this.description,
    required this.benefits,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
    this.adjustedPrice,
  });

  factory VipPackage.fromJson(Map<String, dynamic> json) {
    return VipPackage(
      id: json['_id'] as String,
      name: json['name'] as String,
      price: json['price'] as int,
      duration: json['duration'] as int,
      description: json['description'] as String,
      benefits: List<String>.from(json['benefits']),
      isActive: json['isActive'] as bool,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      adjustedPrice: json['adjustedPrice'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'duration': duration,
      'description': description,
      'benefits': benefits,
      'isActive': isActive,
    };
  }

  VipPackage copyWith({
    String? id,
    String? name,
    int? price,
    int? duration,
    String? description,
    List<String>? benefits,
    bool? isActive,
    String? createdAt,
    String? updatedAt,
    int? adjustedPrice,
  }) {
    return VipPackage(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      duration: duration ?? this.duration,
      description: description ?? this.description,
      benefits: benefits ?? this.benefits,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      adjustedPrice: adjustedPrice ?? this.adjustedPrice,
    );
  }
}

class VipPackageResponse {
  final String message;
  final List<VipPackage> packages;
  final String currentVip;
  final int remainingDays;

  VipPackageResponse({
    required this.message,
    required this.packages,
    required this.currentVip,
    required this.remainingDays,
  });

  factory VipPackageResponse.fromJson(Map<String, dynamic> json) {
    return VipPackageResponse(
      message: json['message'] ?? '',
      packages: (json['packages'] as List)
          .map((package) => VipPackage.fromJson(package))
          .toList(),
      currentVip: json['currentVip'] ?? '',
      remainingDays: json['remainingDays'] ?? 0,
    );
  }
}

class Pagination {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  Pagination({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      total: json['total'] as int,
      page: json['page'] as int,
      limit: json['limit'] as int,
      totalPages: json['totalPages'] as int,
    );
  }
}
