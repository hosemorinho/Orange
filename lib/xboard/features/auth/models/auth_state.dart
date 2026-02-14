import 'package:fl_clash/xboard/domain/domain.dart';

/// Auth error type enum to replace magic string markers
enum AuthErrorType {
  none,
  tokenExpired,
  networkError,
  serverError,
  unknown,
}

/// 通用UI状态
class UIState {
  final bool isLoading;
  final String? errorMessage;
  final DateTime? lastUpdated;

  const UIState({
    this.isLoading = false,
    this.errorMessage,
    this.lastUpdated,
  });

  UIState copyWith({
    bool? isLoading,
    String? errorMessage,
    DateTime? lastUpdated,
  }) {
    return UIState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  UIState clearError() {
    return copyWith(errorMessage: null);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UIState &&
        other.isLoading == isLoading &&
        other.errorMessage == errorMessage &&
        other.lastUpdated == lastUpdated;
  }

  @override
  int get hashCode {
    return isLoading.hashCode ^
        errorMessage.hashCode ^
        lastUpdated.hashCode;
  }
}

/// 用户认证状态
class UserAuthState {
  final bool isAuthenticated;
  final bool isInitialized;
  final String? email;
  final bool isLoading;
  final String? errorMessage;
  final AuthErrorType errorType;
  final DomainUser? userInfo;
  final DomainSubscription? subscriptionInfo;

  const UserAuthState({
    this.isAuthenticated = false,
    this.isInitialized = false,
    this.email,
    this.isLoading = false,
    this.errorMessage,
    this.errorType = AuthErrorType.none,
    this.userInfo,
    this.subscriptionInfo,
  });

  UserAuthState copyWith({
    bool? isAuthenticated,
    bool? isInitialized,
    String? email,
    bool? isLoading,
    String? errorMessage,
    AuthErrorType? errorType,
    DomainUser? userInfo,
    DomainSubscription? subscriptionInfo,
  }) {
    return UserAuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isInitialized: isInitialized ?? this.isInitialized,
      email: email ?? this.email,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      errorType: errorType ?? this.errorType,
      userInfo: userInfo ?? this.userInfo,
      subscriptionInfo: subscriptionInfo ?? this.subscriptionInfo,
    );
  }

  UserAuthState clearError() {
    return UserAuthState(
      isAuthenticated: isAuthenticated,
      isInitialized: isInitialized,
      email: email,
      isLoading: isLoading,
      errorMessage: null,
      errorType: AuthErrorType.none,
      userInfo: userInfo,
      subscriptionInfo: subscriptionInfo,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserAuthState &&
        other.isAuthenticated == isAuthenticated &&
        other.isInitialized == isInitialized &&
        other.email == email &&
        other.isLoading == isLoading &&
        other.errorMessage == errorMessage &&
        other.errorType == errorType &&
        other.userInfo == userInfo &&
        other.subscriptionInfo == subscriptionInfo;
  }

  @override
  int get hashCode {
    return isAuthenticated.hashCode ^
        isInitialized.hashCode ^
        email.hashCode ^
        isLoading.hashCode ^
        errorMessage.hashCode ^
        errorType.hashCode ^
        userInfo.hashCode ^
        subscriptionInfo.hashCode;
  }
}

