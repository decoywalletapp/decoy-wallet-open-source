import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Parsed credentials are never used as evidence of the recipient's intent.
class AuthLinkRequest {
  AuthLinkRequest._(
      this.type, this.tokenHash, this.refreshToken, this.accessToken);

  final OtpType type;
  final String? tokenHash;
  final String? refreshToken;
  final String? accessToken;
  bool get isRecovery => type == OtpType.recovery;

  static const _credentialNames = {
    'token_hash',
    'tokenHash',
    'token',
    'refresh_token',
    'refreshToken',
    'access_token',
    'accessToken',
  };

  static Map<String, List<String>> _parameters(Uri uri) {
    final result = <String, List<String>>{};
    void add(Map<String, List<String>> values) {
      for (final entry in values.entries) {
        result.putIfAbsent(entry.key, () => []).addAll(entry.value);
      }
    }

    add(uri.queryParametersAll);
    if (uri.fragment.isNotEmpty) {
      final fragment = uri.fragment.startsWith('?')
          ? uri.fragment.substring(1)
          : uri.fragment;
      add(Uri(query: fragment).queryParametersAll);
    }
    return result;
  }

  static bool hasPayload(Uri uri) {
    try {
      return _parameters(uri).entries.any((entry) =>
          _credentialNames.contains(entry.key) &&
          entry.value.any((value) => value.isNotEmpty));
    } on FormatException {
      // A malformed callback must not be treated as an ordinary login.
      return _credentialNames.any((name) => uri.toString().contains(name));
    }
  }

  factory AuthLinkRequest.parse(Uri uri) {
    final values = _parameters(uri);
    String? one(List<String> names) {
      final found = names.expand((name) => values[name] ?? <String>[]).toSet();
      if (found.length > 1) {
        throw const AuthException(
            'This sign-in link contains conflicting values.');
      }
      final value = found.isEmpty ? null : found.single;
      return value == null || value.isEmpty ? null : value;
    }

    final typeName = (one(['type']) ?? 'signup').toLowerCase();
    final type = const {
      'signup': OtpType.signup,
      'magiclink': OtpType.magiclink,
      'recovery': OtpType.recovery,
      'invite': OtpType.invite,
      'email_change': OtpType.emailChange,
    }[typeName];
    if (type == null)
      throw const AuthException('This sign-in link is not supported.');
    final hash = one(['token_hash', 'tokenHash', 'token']);
    final refresh = one(['refresh_token', 'refreshToken']);
    final access = one(['access_token', 'accessToken']);
    if ((hash != null && (refresh != null || access != null)) ||
        (hash == null && refresh == null)) {
      throw const AuthException(
          'This sign-in link is incomplete or ambiguous.');
    }
    return AuthLinkRequest._(type, hash, refresh, access);
  }

  String get fingerprint => sha256
      .convert(utf8.encode(jsonEncode([
        type.name,
        tokenHash,
        refreshToken,
        accessToken,
      ])))
      .toString();

  @override
  String toString() => 'AuthLinkRequest(redacted)';
}

class AcceptedAuthLink {
  const AcceptedAuthLink(this.request, this.session, this.generation);
  final AuthLinkRequest request;
  final Session session;
  final int generation;
  String get userId => session.user.id;
}

class _RecoveryIntent {
  const _RecoveryIntent(this.email, this.createdAt);
  final String email;
  final DateTime createdAt;
}

/// Verifies in an isolated HTTP exchange, then commits only an intended account.
/// A second GoTrue client is not isolated on web: it can broadcast auth events.
class AuthLinkService {
  AuthLinkService({
    required this.auth,
    required this.authUrl,
    required this.anonKey,
    http.Client Function()? clientFactory,
    DateTime Function()? now,
  })  : _clientFactory = clientFactory ?? http.Client.new,
        _now = now ?? DateTime.now;

  final GoTrueClient auth;
  final String authUrl;
  final String anonKey;
  final http.Client Function() _clientFactory;
  final DateTime Function() _now;
  final _inFlight = <String, Future<AcceptedAuthLink?>>{};
  final _completed = <String>{};
  int _generation = 0;
  _RecoveryIntent? _recoveryIntent;

  void cancelPending() {
    _generation++;
    _recoveryIntent = null;
  }

  /// Keep only successful, locally initiated recovery intent, never link data.
  /// Memory-only state falls back to confirmation after an app restart.
  Future<void> sendPasswordResetEmail(String email,
      {String? redirectTo}) async {
    cancelPending();
    final generation = _generation;
    final startingSession = auth.currentSession;
    final submittedEmail = email.trim();
    if (submittedEmail.isEmpty) {
      throw const AuthException('Missing email');
    }
    await auth.resetPasswordForEmail(submittedEmail, redirectTo: redirectTo);
    if (generation == _generation &&
        startingSession == null &&
        identical(auth.currentSession, startingSession)) {
      _recoveryIntent = _RecoveryIntent(submittedEmail.toLowerCase(), _now());
    }
  }

  bool _isCurrentRecoveryIntent(_RecoveryIntent? intent) {
    if (intent == null || !identical(intent, _recoveryIntent)) return false;
    final age = _now().difference(intent.createdAt);
    return !age.isNegative && age < const Duration(minutes: 15);
  }

  bool hasCompleted(Uri uri) {
    try {
      return _completed.contains(AuthLinkRequest.parse(uri).fingerprint);
    } on FormatException {
      return false;
    } on AuthException {
      return false;
    }
  }

  bool isCurrent(AcceptedAuthLink result) =>
      result.generation == _generation &&
      identical(auth.currentSession, result.session);

  Future<AcceptedAuthLink?> accept(
    Uri uri, {
    required Future<String?> Function() requestEmail,
    required bool Function() mayContinue,
  }) {
    final request = AuthLinkRequest.parse(uri);
    final key = request.fingerprint;
    if (_completed.contains(key)) return Future.value(null);
    final existing = _inFlight[key];
    if (existing != null) return existing;
    final generation = ++_generation;
    final result = _accept(request, generation,
        requestEmail: requestEmail, mayContinue: mayContinue);
    _inFlight[key] = result;
    return result.whenComplete(() => _inFlight.remove(key));
  }

  Future<AcceptedAuthLink?> _accept(
    AuthLinkRequest request,
    int generation, {
    required Future<String?> Function() requestEmail,
    required bool Function() mayContinue,
  }) async {
    final startingSession = auth.currentSession;
    final startingUser = startingSession?.user.id;
    final recoveryIntent = startingUser == null &&
            request.isRecovery &&
            _isCurrentRecoveryIntent(_recoveryIntent)
        ? _recoveryIntent
        : null;
    bool current() =>
        generation == _generation &&
        mayContinue() &&
        identical(auth.currentSession, startingSession) &&
        (recoveryIntent == null || _isCurrentRecoveryIntent(recoveryIntent));
    if (!current()) return null;
    final expectedEmail = startingUser == null
        ? recoveryIntent?.email ?? (await requestEmail())?.trim().toLowerCase()
        : null;
    if (!current() ||
        (startingUser == null &&
            (expectedEmail == null || expectedEmail.isEmpty))) return null;

    final client = _clientFactory();
    try {
      final headers = {
        'apikey': anonKey,
        'Authorization': 'Bearer $anonKey',
        'Content-Type': 'application/json',
      };
      final http.Response response;
      if (request.tokenHash != null) {
        response = await client
            .post(
              Uri.parse('$authUrl/verify'),
              headers: headers,
              body: jsonEncode({
                'token_hash': request.tokenHash,
                'type': request.type == OtpType.emailChange
                    ? 'email_change'
                    : request.type.name
              }),
            )
            .timeout(const Duration(seconds: 20));
      } else {
        response = await client
            .post(
              Uri.parse('$authUrl/token?grant_type=refresh_token'),
              headers: headers,
              body: jsonEncode({'refresh_token': request.refreshToken}),
            )
            .timeout(const Duration(seconds: 20));
      }
      if (!current()) return null;
      final session = AuthResponse.fromJson(_readResponse(response)).session;
      if (session == null ||
          session.isExpired ||
          session.user.id.isEmpty ||
          session.accessToken.isEmpty ||
          (session.refreshToken?.isEmpty ?? true)) {
        throw const AuthException(
            'This sign-in link is no longer valid. Request a new link.');
      }
      if (request.accessToken != null) {
        final userResponse = await client.get(Uri.parse('$authUrl/user'),
            headers: {
              ...headers,
              'Authorization': 'Bearer ${request.accessToken}'
            }).timeout(const Duration(seconds: 20));
        if (!current()) return null;
        if (User.fromJson(_readResponse(userResponse))?.id != session.user.id) {
          throw const AuthException(
              'This sign-in link contains conflicting accounts.');
        }
      }
      if (startingUser != null
          ? session.user.id != startingUser
          : session.user.email?.trim().toLowerCase() != expectedEmail) {
        throw const AuthException(
            'This link does not match your account. Sign in normally or request a new link.');
      }
      if (!current()) return null;
      _recoveryIntent = null;
      // setInitialSession publishes synchronously, with no second network wait
      // between the final identity/lifecycle check and the shared-session write.
      final commit = auth.setInitialSession(jsonEncode(session.toJson()));
      final committedSession = auth.currentSession;
      await commit;
      if (generation != _generation ||
          committedSession == null ||
          !identical(auth.currentSession, committedSession) ||
          !mayContinue()) {
        return null;
      }
      // Preserve the sign-in/recovery event expected by existing subscribers.
      // ignore: invalid_use_of_internal_member
      auth.notifyAllSubscribers(request.isRecovery
          ? AuthChangeEvent.passwordRecovery
          : AuthChangeEvent.signedIn);
      _completed.add(request.fingerprint);
      return AcceptedAuthLink(request, committedSession, generation);
    } finally {
      client.close();
    }
  }

  Map<String, dynamic> _readResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const AuthException(
          'This sign-in link could not be verified. Request a new link.');
    }
    final value = jsonDecode(response.body);
    if (value is! Map<String, dynamic>) {
      throw const AuthException('This sign-in link could not be verified.');
    }
    return value;
  }
}
