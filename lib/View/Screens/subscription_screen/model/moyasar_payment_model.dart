class MoyasarPaymentPreparation {
  final String publishableApiKey;
  final int amount;
  final String currency;
  final String description;
  final String callbackUrl;
  final String givenId;
  final String checkoutUrl;
  final Map<String, dynamic> metadata;

  const MoyasarPaymentPreparation({
    required this.publishableApiKey,
    required this.amount,
    required this.currency,
    required this.description,
    required this.callbackUrl,
    required this.givenId,
    required this.checkoutUrl,
    required this.metadata,
  });

  factory MoyasarPaymentPreparation.fromJson(Map<String, dynamic> json) {
    final metadata = json['metadata'];
    return MoyasarPaymentPreparation(
      checkoutUrl: json['checkoutUrl'] ?? '',
      publishableApiKey: json['publishableApiKey']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      currency: json['currency']?.toString() ?? 'SAR',
      description: json['description']?.toString() ?? '',
      callbackUrl: json['callbackUrl']?.toString() ?? '',
      givenId: json['givenId']?.toString() ?? '',
      metadata: metadata is Map
          ? Map<String, dynamic>.from(metadata)
          : <String, dynamic>{},
    );
  }

  bool get isValid =>
      publishableApiKey.isNotEmpty &&
      amount > 0 &&
      description.isNotEmpty &&
      callbackUrl.isNotEmpty &&
      givenId.isNotEmpty;
}
