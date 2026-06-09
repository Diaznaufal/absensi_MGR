import 'dart:convert';

class AuthResponseModel {
    final User? user;
    final String? token;
    final String? role;
    final Position? position;
    final DefaultShift? defaultShift;
    final DefaultShiftDetail? defaultShiftDetail;
    final Department? department;

    AuthResponseModel({
        this.user,
        this.token,
        this.role,
        this.position,
        this.defaultShift,
        this.defaultShiftDetail,
        this.department,
    });

    factory AuthResponseModel.fromJson(String str) => AuthResponseModel.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory AuthResponseModel.fromMap(Map<String, dynamic> json) => AuthResponseModel(
        user: json["user"] == null ? null : User.fromMap(json["user"]),
        token: json["token"],
        role: json["role"],
        position: json["position"] == null ? null : Position.fromMap(json["position"]),
        defaultShift: json["default_shift"] == null ? null : DefaultShift.fromMap(json["default_shift"]),
        defaultShiftDetail: json["default_shift_detail"] == null ? null : DefaultShiftDetail.fromMap(json["default_shift_detail"]),
        department: json["department"] == null ? null : Department.fromMap(json["department"]),
    );

    Map<String, dynamic> toMap() => {
        "user": user?.toMap(),
        "token": token,
        "role": role,
        "position": position?.toMap(),
        "default_shift": defaultShift?.toMap(),
        "default_shift_detail": defaultShiftDetail?.toMap(),
        "department": department?.toMap(),
    };

  AuthResponseModel copyWith({
    User? user,
    String? token,
    String? role,
    Position? position,
    DefaultShift? defaultShift,
    DefaultShiftDetail? defaultShiftDetail,
    Department? department,
  }) {
    return AuthResponseModel(
      user: user ?? this.user,
      token: token ?? this.token,
      role: role ?? this.role,
      position: position ?? this.position,
      defaultShift: defaultShift ?? this.defaultShift,
      defaultShiftDetail: defaultShiftDetail ?? this.defaultShiftDetail,
      department: department ?? this.department,
    );
  }
}

class User {
    final int? id;
    final String? name;
    final String? email;
    final DateTime? emailVerifiedAt;
    final dynamic twoFactorSecret;
    final dynamic twoFactorRecoveryCodes;
    final dynamic twoFactorConfirmedAt;
    final dynamic fcmToken;
    final DateTime? createdAt;
    final DateTime? updatedAt;
    final String? phone;
    final String? role;
    final String? position;
    final String? department;
    final int? jabatanId;
    final int? departemenId;
    final int? shiftKerjaId;
    final dynamic faceEmbedding;
    final dynamic imageUrl;
    final ShiftKerja? shiftKerja;
    final Departemen? departemen;

    User({
        this.id,
        this.name,
        this.email,
        this.emailVerifiedAt,
        this.twoFactorSecret,
        this.twoFactorRecoveryCodes,
        this.twoFactorConfirmedAt,
        this.fcmToken,
        this.createdAt,
        this.updatedAt,
        this.phone,
        this.role,
        this.position,
        this.department,
        this.jabatanId,
        this.departemenId,
        this.shiftKerjaId,
        this.faceEmbedding,
        this.imageUrl,
        this.shiftKerja,
        this.departemen,
    });

    factory User.fromJson(String str) => User.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory User.fromMap(Map<String, dynamic> json) => User(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        emailVerifiedAt: json["email_verified_at"] == null ? null : DateTime.parse(json["email_verified_at"]),
        twoFactorSecret: json["two_factor_secret"],
        twoFactorRecoveryCodes: json["two_factor_recovery_codes"],
        twoFactorConfirmedAt: json["two_factor_confirmed_at"],
        fcmToken: json["fcm_token"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        phone: json["phone"],
        role: json["role"],
        position: json["position"],
        department: json["department"],
        jabatanId: json["jabatan_id"],
        departemenId: json["departemen_id"],
        shiftKerjaId: json["shift_kerja_id"],
        faceEmbedding: json["face_embedding"],
        imageUrl: json["image_url"],
        shiftKerja: json["shift_kerja"] == null ? null : ShiftKerja.fromMap(json["shift_kerja"]),
        departemen: json["departemen"] == null ? null : Departemen.fromMap(json["departemen"]),
    );

    Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "email": email,
        "email_verified_at": emailVerifiedAt?.toIso8601String(),
        "two_factor_secret": twoFactorSecret,
        "two_factor_recovery_codes": twoFactorRecoveryCodes,
        "two_factor_confirmed_at": twoFactorConfirmedAt,
        "fcm_token": fcmToken,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "phone": phone,
        "role": role,
        "position": position,
        "department": department,
        "jabatan_id": jabatanId,
        "departemen_id": departemenId,
        "shift_kerja_id": shiftKerjaId,
        "face_embedding": faceEmbedding,
        "image_url": imageUrl,
        "shift_kerja": shiftKerja?.toMap(),
        "departemen": departemen?.toMap(),
    };
}

class ShiftKerja {
    final int? id;
    final String? name;
    final String? startTime;
    final String? endTime;
    final bool? isCrossDay;
    final int? gracePeriodMinutes;
    final bool? isActive;
    final String? description;
    final DateTime? createdAt;
    final DateTime? updatedAt;

    ShiftKerja({
        this.id,
        this.name,
        this.startTime,
        this.endTime,
        this.isCrossDay,
        this.gracePeriodMinutes,
        this.isActive,
        this.description,
        this.createdAt,
        this.updatedAt,
    });

    factory ShiftKerja.fromJson(String str) => ShiftKerja.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory ShiftKerja.fromMap(Map<String, dynamic> json) => ShiftKerja(
        id: json["id"],
        name: json["name"],
        startTime: json["start_time"],
        endTime: json["end_time"],
        isCrossDay: json["is_cross_day"],
        gracePeriodMinutes: json["grace_period_minutes"],
        isActive: json["is_active"],
        description: json["description"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    );

    Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "start_time": startTime,
        "end_time": endTime,
        "is_cross_day": isCrossDay,
        "grace_period_minutes": gracePeriodMinutes,
        "is_active": isActive,
        "description": description,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
    };
}

class Departemen {
    final int? id;
    final String? name;
    final String? description;
    final DateTime? createdAt;
    final DateTime? updatedAt;

    Departemen({
        this.id,
        this.name,
        this.description,
        this.createdAt,
        this.updatedAt,
    });

    factory Departemen.fromJson(String str) => Departemen.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory Departemen.fromMap(Map<String, dynamic> json) => Departemen(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    );

    Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "description": description,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
    };
}

class DefaultShift {
    final int? id;
    final String? name;

    DefaultShift({
        this.id,
        this.name,
    });

    factory DefaultShift.fromJson(String str) => DefaultShift.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory DefaultShift.fromMap(Map<String, dynamic> json) => DefaultShift(
        id: json["id"],
        name: json["name"],
    );

    Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
    };
}

class DefaultShiftDetail {
    final int? id;
    final String? name;
    final DateTime? startTime;
    final DateTime? endTime;

    DefaultShiftDetail({
        this.id,
        this.name,
        this.startTime,
        this.endTime,
    });

    factory DefaultShiftDetail.fromJson(String str) => DefaultShiftDetail.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory DefaultShiftDetail.fromMap(Map<String, dynamic> json) => DefaultShiftDetail(
        id: json["id"],
        name: json["name"],
        startTime: json["start_time"] == null ? null : DateTime.parse(json["start_time"]),
        endTime: json["end_time"] == null ? null : DateTime.parse(json["end_time"]),
    );

    Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "start_time": startTime?.toIso8601String(),
        "end_time": endTime?.toIso8601String(),
    };
}

class Department {
    final int? id;
    final String? name;

    Department({
        this.id,
        this.name,
    });

    factory Department.fromJson(String str) => Department.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory Department.fromMap(Map<String, dynamic> json) => Department(
        id: json["id"],
        name: json["name"],
    );

    Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
    };
}

class Position {
    final int? id;
    final String? name;

    Position({
        this.id,
        this.name,
    });

    factory Position.fromJson(String str) => Position.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory Position.fromMap(Map<String, dynamic> json) => Position(
        id: json["id"],
        name: json["name"],
    );

    Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
    };
}
