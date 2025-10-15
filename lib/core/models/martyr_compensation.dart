class MartyrCompensation {
  int? id;
  int casualtyId;
  DateTime? compensationDate;
  double? amount;
  String? paymentMethod;
  String? recipientName;
  String? payingEntity;
  String? materialItems;
  double? estimatedValue;
  String? notes;
  String? compensationType;
  String? paymentReceiptNumber;

  MartyrCompensation({
    this.id,
    required this.casualtyId,
    this.compensationDate,
    this.amount,
    this.paymentMethod,
    this.recipientName,
    this.payingEntity,
    this.materialItems,
    this.estimatedValue,
    this.notes,
    this.compensationType,
    this.paymentReceiptNumber,
  });

  factory MartyrCompensation.fromJson(Map<String, dynamic> json) {
    return MartyrCompensation(
      id: json['id'],
      casualtyId: json['casualty_id'],
      compensationDate: json['compensation_date'] != null 
          ? DateTime.parse(json['compensation_date']) 
          : null,
      amount: json['amount'] != null 
          ? double.parse(json['amount'].toString()) 
          : null,
      paymentMethod: json['payment_method'],
      recipientName: json['recipient_name'],
      payingEntity: json['paying_entity'],
      materialItems: json['material_items'],
      estimatedValue: json['estimated_value'] != null 
          ? double.parse(json['estimated_value'].toString()) 
          : null,
      notes: json['notes'],
      compensationType: json['compensation_type'],
      paymentReceiptNumber: json['payment_receipt_number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'casualty_id': casualtyId,
      'compensation_date': compensationDate?.toIso8601String(),
      'amount': amount,
      'payment_method': paymentMethod,
      'recipient_name': recipientName,
      'paying_entity': payingEntity,
      'material_items': materialItems,
      'estimated_value': estimatedValue,
      'notes': notes,
      'compensation_type': compensationType,
      'payment_receipt_number': paymentReceiptNumber,
    };
  }
}