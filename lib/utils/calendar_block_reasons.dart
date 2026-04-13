/// Raisons de blocage calendrier (aligné sur la version web).
class CalendarBlockReasons {
  CalendarBlockReasons._();

  static const String defaultReason = 'Autre - Autre raison';

  static const List<String> options = [
    'Maintenance - Entretien, vidange, réparation',
    'Réservation externe - Client direct, téléphone, autre plateforme',
    'Usage personnel - Besoin du propriétaire',
    'Sinistre - Accident, expertise assurance',
    defaultReason,
  ];
}
