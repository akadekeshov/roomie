import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/errors/app_exception.dart';

enum SocialProvider {
  google,
  facebook,
}

class SocialAuthPayload {
  const SocialAuthPayload({
    required this.provider,
    this.idToken,
    this.accessToken,
    this.email,
    this.name,
    this.avatarUrl,
  });

  final SocialProvider provider;
  final String? idToken;
  final String? accessToken;
  final String? email;
  final String? name;
  final String? avatarUrl;
}

class SocialAuthService {
  SocialAuthService();
  static const String _googleServerClientId =
      '80014759944-dvvpaeu311fdaiut9rhe84205143hl68.apps.googleusercontent.com';

  Future<SocialAuthPayload> signIn(SocialProvider provider) async {
    switch (provider) {
      case SocialProvider.google:
        return _signInWithGoogle();
      case SocialProvider.facebook:
        return _signInWithFacebook();
    }
  }

  Future<SocialAuthPayload> _signInWithGoogle() async {
    final google = GoogleSignIn(
      scopes: const ['email', 'profile'],
      serverClientId: _googleServerClientId,
    );
    await google.signOut();

    final account = await google.signIn();
    if (account == null) {
      throw const AppException(
        code: AppErrorCode.unknown,
        message: '���� ����� Google ������.',
      );
    }

    final auth = await account.authentication;
    if (auth.idToken == null && auth.accessToken == null) {
      throw const AppException(
        code: AppErrorCode.unknown,
        message: 'Google �� ������ �����. ��������� OAuth ���������.',
      );
    }

    return SocialAuthPayload(
      provider: SocialProvider.google,
      idToken: auth.idToken,
      accessToken: auth.accessToken,
      email: account.email,
      name: account.displayName,
      avatarUrl: account.photoUrl,
    );
  }

  Future<SocialAuthPayload> _signInWithFacebook() async {
    await FacebookAuth.instance.logOut();

    final result = await FacebookAuth.instance.login(
      permissions: const ['email', 'public_profile'],
    );

    if (result.status == LoginStatus.cancelled) {
      throw const AppException(
        code: AppErrorCode.unknown,
        message: '���� ����� Facebook ������.',
      );
    }

    if (result.status != LoginStatus.success || result.accessToken == null) {
      throw AppException(
        code: AppErrorCode.unknown,
        message: result.message ?? '�� ������� ��������� ���� ����� Facebook.',
      );
    }

    final profile = await FacebookAuth.instance.getUserData(
      fields: 'name,email,picture.width(512)',
    );

    final picture = (profile['picture'] as Map?)?.cast<String, dynamic>();
    final pictureData = (picture?['data'] as Map?)?.cast<String, dynamic>();

    return SocialAuthPayload(
      provider: SocialProvider.facebook,
      accessToken: result.accessToken!.tokenString,
      email: profile['email'] as String?,
      name: profile['name'] as String?,
      avatarUrl: pictureData?['url'] as String?,
    );
  }
}
