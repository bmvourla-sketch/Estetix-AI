/// Failure codes the transform pipeline can surface to the UI.
enum AiTransformFailureCode {
  /// The Edge Function rejected the request because the wallet has too few
  /// tokens (the `deduct_token` RPC raised `INSUFFICIENT_TOKEN_BALANCE`).
  insufficientTokens,

  /// The transform failed for any other reason (AI provider error, network,
  /// storage upload, …).
  transformFailed,

  /// The Edge Function returned a payload the client could not parse.
  unexpectedPayload,
}

/// Domain-level failure thrown by `AiTransformRepository` implementations.
///
/// Presentation code (the notifier) maps [code] to a UI error state, so it
/// never depends on the data layer or on transport details.
class AiTransformFailure implements Exception {
  const AiTransformFailure(this.code, [this.message]);

  final AiTransformFailureCode code;

  /// Optional server/debug message.
  final String? message;

  @override
  String toString() => message ?? code.name;
}
