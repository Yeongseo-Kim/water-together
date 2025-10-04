// lib/models/water_amount.dart
enum WaterAmount {
  sip('한모금', 50),
  halfCup('반컵', 150),
  fullCup('한컵', 300);

  const WaterAmount(this.displayName, this.mlAmount);

  final String displayName;
  final int mlAmount;
}

