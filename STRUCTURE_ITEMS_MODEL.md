# Structure des Données du Modèle `Items` (Édition de Véhicule)

## Vue d'ensemble

Le modèle `Items` représente un véhicule dans l'application. Il est utilisé pour l'édition et l'affichage des détails d'un véhicule.

---

## Structure JSON attendue par l'API

```json
{
  "status": 200,
  "data": {
    "items": [
      {
        // Structure complète ci-dessous
      }
    ]
  }
}
```

---

## Champs Principaux du Modèle `Items`

### Identifiant
| Propriété Dart | Type | Clé JSON | Description |
|----------------|------|----------|-------------|
| `id` | `String?` | `_id` ou `id` | Identifiant unique du véhicule (MongoDB `_id` ou `id` standard) |

### Informations Générales
| Propriété Dart | Type | Clé JSON | Description |
|----------------|------|----------|-------------|
| `title` | `String?` | `title` | Titre du véhicule (ex: "BMW - X1") |
| `description` | `String?` | `description` | Description détaillée du véhicule |
| `price` | `String?` | `price` | Prix de location |
| `status` | `String?` | `status` | Statut du véhicule (actif, inactif, etc.) |

### Localisation
| Propriété Dart | Type | Clé JSON | Description |
|----------------|------|----------|-------------|
| `address` | `String?` | `address` | Adresse complète |
| `city` | `String?` | `city_name` | Nom de la ville |
| `stateRegion` | `String?` | `state_region` | État/Région |
| `zipPostalCode` | `String?` | `zip_postal_code` | Code postal |
| `country` | `String?` | `country` | Pays |
| `latitude` | `String?` | `latitude` | Latitude géographique |
| `longitude` | `String?` | `longitude` | Longitude géographique |
| `placeId` | `String?` | `place_id` | ID de lieu Google Places |

### Remises
| Propriété Dart | Type | Clé JSON | Description |
|----------------|------|----------|-------------|
| `weeklyDiscount` | `String?` | `weekly_discount` | Remise hebdomadaire (montant ou pourcentage) |
| `weeklyDiscountType` | `String?` | `weekly_discount_type` | Type de remise hebdomadaire ("amount" ou "percent") |
| `monthlyDiscount` | `String?` | `monthly_discount` | Remise mensuelle (montant ou pourcentage) |
| `monthlyDiscountType` | `String?` | `monthly_discount_type` | Type de remise mensuelle ("amount" ou "percent") |

### Catégories et Références
| Propriété Dart | Type | Clé JSON | Description |
|----------------|------|----------|-------------|
| `itemTypeId` | `String?` | `item_type_id` | ID du type de véhicule (SUV, Sedan, etc.) |
| `itemType` | `String?` | `item_type` | Nom du type de véhicule |
| `amenitiesId` | `String?` | `features_id` | ID des équipements/aménagements |
| `bookingPoliciesId` | `int?` | `booking_policies_id` | ID de la politique de réservation |

### Données Techniques (JSON Stringifié)
| Propriété Dart | Type | Clé JSON | Description |
|----------------|------|----------|-------------|
| `itemInfo` | `String?` | `item_info` | **JSON stringifié** contenant :<br>- `year` : Année du véhicule<br>- `odometer` : Kilométrage<br>- `type` : Type de véhicule<br>- `brand` : Marque<br>- `model` : Modèle |
| `metaData` | `String?` | `metaData` | Métadonnées supplémentaires (JSON stringifié) |

### Images
| Propriété Dart | Type | Clé JSON | Description |
|----------------|------|----------|-------------|
| `frontImage` | `FrontImage?` | `front_image` | Image principale (objet FrontImage) |
| `frontImageDoc` | `FrontImageDoc?` | `front_image_doc` | Document image principale (objet FrontImageDoc) |
| `gallery` | `List<Gallery>?` | `gallery` | Liste des images de la galerie |

### Dates et Disponibilité
| Propriété Dart | Type | Clé JSON | Description |
|----------------|------|----------|-------------|
| `availableDates` | `String?` | `available_dates` | Dates disponibles |
| `notAvailableDates` | `dynamic` | `not_available_dates` | Dates non disponibles |
| `bookedDates` | `List<BookedDates>?` | `booked_dates` | Liste des dates réservées |

### Informations Supplémentaires
| Propriété Dart | Type | Clé JSON | Description |
|----------------|------|----------|-------------|
| `itemRating` | `String?` | `item_rating` | Note du véhicule |
| `mobile` | `String?` | `mobile` | Numéro de téléphone |
| `personAllowed` | `String?` | `person_allowed` | Nombre de personnes autorisées |

---

## Structure de `itemInfo` (JSON Stringifié)

Le champ `itemInfo` est un **JSON stringifié** qui contient les informations techniques du véhicule :

```json
{
  "year": "2020",
  "odometer": "50000",
  "type": "SUV",
  "brand": "BMW",
  "model": "X1"
}
```

**Important** : Ces données sont stockées sous forme de **chaîne JSON** et doivent être parsées avec `json.decode()` pour être utilisées.

---

## Structures Imbriquées

### `FrontImage` (Image Principale)
```dart
{
  "id" ou "_id": String,
  "model_type": String,
  "model_id": dynamic,
  "url": String,
  "thumbnail": String,
  "preview": String,
  "original_url": String,
  "preview_url": String,
  "created_at": String,
  "updated_at": String
}
```

### `Gallery` (Images de la Galerie)
```dart
{
  "id" ou "_id": String,
  "model_type": String,
  "model_id": dynamic,
  "url": String,
  "thumbnail": String,
  "preview": String,
  "original_url": String,
  "preview_url": String,
  "created_at": String,
  "updated_at": String
}
```

### `BookedDates` (Dates Réservées)
```dart
{
  "date": String,
  "price": String
}
```

---

## Exemple Complet de Réponse API

```json
{
  "status": 200,
  "data": {
    "items": [
      {
        "_id": "507f1f77bcf86cd799439011",
        "title": "BMW - X1",
        "description": "Véhicule confortable et spacieux",
        "price": "50",
        "address": "123 Rue Example",
        "city_name": "Paris",
        "state_region": "Île-de-France",
        "zip_postal_code": "75001",
        "country": "France",
        "latitude": "48.8566",
        "longitude": "2.3522",
        "place_id": "ChIJD7fiBh9u5kcRYJSMaMOCCwQ",
        "weekly_discount": "10",
        "weekly_discount_type": "percent",
        "monthly_discount": "15",
        "monthly_discount_type": "percent",
        "item_type_id": "1",
        "item_type": "SUV",
        "features_id": "1,2,3",
        "booking_policies_id": 1,
        "item_info": "{\"year\":\"2020\",\"odometer\":\"50000\",\"type\":\"SUV\",\"brand\":\"BMW\",\"model\":\"X1\"}",
        "metaData": "{\"transmission\":\"automatic\",\"fuel\":\"diesel\"}",
        "front_image": {
          "id": "img123",
          "url": "https://example.com/image.jpg",
          "thumbnail": "https://example.com/thumb.jpg"
        },
        "gallery": [
          {
            "id": "img124",
            "url": "https://example.com/image2.jpg"
          }
        ],
        "available_dates": "2024-01-01,2024-01-02",
        "not_available_dates": null,
        "booked_dates": [
          {
            "date": "2024-01-15",
            "price": "60"
          }
        ],
        "item_rating": "4.5",
        "mobile": "+33123456789",
        "person_allowed": "5",
        "status": "active"
      }
    ]
  }
}
```

---

## Champs Utilisés dans l'Édition de Véhicule

Pour l'édition de véhicule, les champs les plus importants sont :

1. **Identifiant** : `id` (pour charger les données)
2. **Informations de base** : `title`, `description`, `price`
3. **Localisation** : `address`, `city`, `stateRegion`, `zipPostalCode`, `country`, `latitude`, `longitude`, `placeId`
4. **Type de véhicule** : `itemTypeId`, `itemType`
5. **Données techniques** : `itemInfo` (contient `year`, `odometer`, `brand`, `model`)
6. **Remises** : `weeklyDiscount`, `weeklyDiscountType`, `monthlyDiscount`, `monthlyDiscountType`
7. **Images** : `frontImage`, `gallery`
8. **Dates** : `availableDates`, `notAvailableDates`, `bookedDates`

---

## Notes Importantes

1. **`itemInfo` est un JSON stringifié** : Il doit être décodé avec `json.decode()` avant utilisation
2. **Les IDs peuvent être `_id` ou `id`** : Le parsing gère les deux cas (priorité à `_id` pour MongoDB)
3. **Tous les champs sont optionnels** (`String?`) : Le modèle gère les valeurs `null` sans crash
4. **Les dates sont stockées en String** : Conversion nécessaire si manipulation de dates
5. **`notAvailableDates` est `dynamic`** : Peut être `null`, `String`, ou un objet complexe

---

## Mapping dans `populateFields`

Lors de l'édition, `populateFields` extrait les données depuis `itemInfo` décodé :

```dart
// itemInfo est décodé depuis le JSON stringifié
Map<String, dynamic> itemInfoDescription = json.decode(vehicle.itemInfo ?? '{}');

// Extraction des données
selectedYear = itemInfoDescription["year"]?.toString();
selectedOdometerId.value = itemInfoDescription["odometer"]?.toString();
```

---

## Sources

- Fichier : `lib/model/my_items_model.dart`
- Classe principale : `Items` (lignes 97-378)
- Méthode de parsing : `Items.fromJson()` (lignes 177-247)
