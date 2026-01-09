# 📋 Spécification API : Détails du Véhicule (ItemDetails)

## 🔗 Endpoint et Méthode

**URL** : `POST /api/v1/getItemDetails`  
**Méthode** : `POST`  
**Body** : `{"item_id": "string"}`

**URL Complète** : `https://carvy.tech/api/v1/getItemDetails`

---

## 📦 Structure de la Réponse JSON

```json
{
  "status": 200,
  "message": "string",
  "error": null,
  "data": {
    "ItemDetails": {
      // ... Tous les champs ci-dessous
    }
  }
}
```

**⚠️ IMPORTANT** : La clé `ItemDetails` doit être **en PascalCase** (première lettre en majuscule) dans `data.ItemDetails`.

---

## 📋 Liste Complète des Champs Requis

### 1. 🔑 Champs Principaux (ItemDetails - Racine)

| Clé JSON | Type | Requis | Format | Exemple | Notes |
|----------|------|--------|--------|---------|-------|
| `item_id` | String/Number | ✅ | String (converti automatiquement) | `"123"` ou `123` | ID du véhicule |
| `title` | String | ✅ | String | `"Toyota Camry 2023"` | Titre du véhicule |
| `price` | String/Number | ✅ | String (converti automatiquement) | `"300"` ou `300` | Prix journalier |
| `description` | String | ⚠️ | String | `"Véhicule confortable..."` | Peut être null |
| `item_rating` | String/Number | ⚠️ | String (converti automatiquement) | `"4.5"` ou `4.5` | Note moyenne (0-5) |
| `status` | String | ✅ | String | `"1"` | `"0"` = Non publié, `"1"` = Publié |
| `item_type` | String | ✅ | String | `"CAR"` | Type d'article (CAR, etc.) |
| `front_image_url` | String | ⚠️ | URL complète | `"https://carvy.tech/uploads/image.jpg"` | Image principale |
| `mobile` | String | ⚠️ | String | `"+212600000000"` | Numéro de téléphone |

---

### 2. 📍 Informations de Localisation

| Clé JSON | Type | Requis | Format | Notes |
|----------|------|--------|--------|-------|
| `address` | String | ⚠️ | String | Adresse complète |
| `city` | String | ⚠️ | String | Nom de la ville |
| `state_region` | String | ⚠️ | String | État/Région |
| `zip_postal_code` | String | ⚠️ | String | Code postal |
| `latitude` | String/Number | ⚠️ | String (converti automatiquement) | Coordonnée latitude |
| `longitude` | String/Number | ⚠️ | String (converti automatiquement) | Coordonnée longitude |

---

### 3. 🖼️ Galerie d'Images

| Clé JSON | Type | Requis | Format | Notes |
|----------|------|--------|--------|-------|
| `gallery_image_urls` | Array<String> | ⚠️ | Liste d'URLs | **Peut être un tableau vide `[]`** |
| | | | | Chaque élément doit être une URL complète |
| | | | | Exemple: `["https://carvy.tech/image1.jpg", "https://carvy.tech/image2.jpg"]` |

**⚠️ IMPORTANT** :
- Si aucun élément : envoyer `[]` (tableau vide) ou omettre la clé
- Si la clé est absente, l'application utilisera un tableau vide par défaut
- **Format attendu** : `List<String>` avec URLs complètes

---

### 4. ⭐ Notes et Avis (Reviews)

| Clé JSON | Type | Requis | Format | Notes |
|----------|------|--------|--------|-------|
| `total_reviews` | Number/String | ⚠️ | Number ou String | Nombre total d'avis |
| | | | | Peut être `0` si aucun avis |
| `reviews` | Array<Object> | ⚠️ | Liste d'objets Reviews | **Peut être un tableau vide `[]`** |

#### Structure d'un objet Review :

```json
{
  "id": "string ou number (converti en String)",
  "booking_id": "string ou number (converti en String)",
  "guest_id": "string ou number (converti en String)",
  "guest_name": "string",
  "guest_profile_image": "string (URL)",
  "rating": "string (0-5)",
  "message": "string",
  "created_at": "string (date ISO)",
  "updated_at": "string (date ISO)"
}
```

**⚠️ IMPORTANT** :
- Si aucun avis : envoyer `[]` (tableau vide) ou omettre la clé
- `rating` doit être une String (ex: `"4"`, `"4.5"`)
- Les dates (`created_at`, `updated_at`) doivent être des Strings

---

### 5. 🏨 Informations du Propriétaire/Vendor (Host)

| Clé JSON | Type | Requis | Format | Notes |
|----------|------|--------|--------|-------|
| `host_id` | String/Number | ⚠️ | String (converti automatiquement) | ID du propriétaire |
| `host_player_id` | String | ⚠️ | String | ID du joueur (pour notifications push) |
| `host_first_name` | String | ⚠️ | String | Prénom du propriétaire |
| `host_last_name` | String | ⚠️ | String | Nom du propriétaire |
| `host_email` | String | ⚠️ | String | Email du propriétaire |
| `host_phone` | String | ⚠️ | String | Téléphone du propriétaire |
| `host_profile_image` | String | ⚠️ | URL complète | Photo de profil du propriétaire |

**⚠️ IMPORTANT** : Tous ces champs peuvent être `null` si les informations ne sont pas disponibles, mais il est recommandé de toujours les inclure.

---

### 6. 🎨 Caractéristiques et Équipements (Amenities)

| Clé JSON | Type | Requis | Format | Notes |
|----------|------|--------|--------|-------|
| `amenities` | Array<Object> | ⚠️ | Liste d'objets Amenities | **Peut être un tableau vide `[]`** |

#### Structure d'un objet Amenity :

```json
{
  "id": "string ou number (converti en String)",
  "name": "string",
  "image_url": "string (URL)"
}
```

**⚠️ IMPORTANT** :
- Si aucun équipement : envoyer `[]` (tableau vide) ou omettre la clé
- Si la clé est absente, l'application utilisera un tableau vide par défaut

---

### 7. 🚗 Informations Détaillées du Véhicule (`item_info` - Chaîne JSON)

**⚠️ TRÈS IMPORTANT** : `item_info` doit être une **chaîne JSON stringifiée** (pas un objet JSON).

| Clé JSON | Type | Requis | Format | Notes |
|----------|------|--------|--------|-------|
| `item_info` | String | ✅ | JSON stringifié | Contient toutes les infos du véhicule |

#### Structure de `item_info` (après parsing JSON) :

```json
{
  "type": "CAR",
  "service_type": "string",
  "rules": ["string1", "string2"],
  "vehicleType": "string",
  "make_type": "string",
  "model": "string",
  "year": "string ou number",
  "transmission": "string",
  "odometer": "string ou number",
  "description": "string",
  "license_plate": "string",
  "min_rental_days": "string ou number",
  "insurance_coverage": "string",
  "min_age": "string ou number",
  "smoking_status": "string",
  "international_travel_status": "string",
  "is_verified": "boolean ou string",
  "is_featured": "boolean ou string",
  "fuel_type": "string",
  "number_of_seats": "string ou number",
  "booking_policies_id": "string ou number",
  "weekly_discount": "string ou number",
  "weekly_discount_type": "string",
  "monthly_discount": "string ou number",
  "monthly_discount_type": "string",
  "cancellation_reason_title": "string",
  "cancellation_reason_description": ["string1", "string2"] ou "string",
  "features_data": [
    {
      "id": "string",
      "name": "string",
      "image_url": "string"
    }
  ],
  "host_id": "string ou number",
  "host_first_name": "string",
  "host_last_name": "string",
  "host_email": "string",
  "host_phone": "string",
  "host_player_id": "string",
  "host_profile_image": "string",
  "gallery_image_urls": ["url1", "url2"],
  "review_data": "object ou null",
  "total_reviews": "number",
  "doorStep_price": "string ou number"
}
```

**⚠️ CLÉS IMPORTANTES DANS `item_info`** :
- `type` : **OBLIGATOIRE** - Sera écrasé par `item_type` de la racine lors du parsing
- `vehicleType` : **OBLIGATOIRE** - Utilisé dans le badge gris (affiche "null" si absent)
- `license_plate` : Plaque d'immatriculation (utilisée pour affichage)
- `features_data` : **Peut être un tableau vide `[]`** ou absent
- `rules` : **Peut être un tableau vide `[]`** ou absent

**Exemple de `item_info` stringifié** :
```json
{
  "item_info": "{\"type\":\"CAR\",\"vehicleType\":\"Sedan\",\"make_type\":\"Toyota\",\"model\":\"Camry\",\"year\":2023,\"license_plate\":\"ABC-123\",\"fuel_type\":\"Petrol\",\"number_of_seats\":5,\"transmission\":\"Automatic\",\"features_data\":[{\"id\":\"1\",\"name\":\"GPS\",\"image_url\":\"https://...\"}]}"
}
```

---

### 8. 📅 Dates Disponibles

| Clé JSON | Type | Requis | Format | Notes |
|----------|------|--------|--------|-------|
| `available_dates` | Array<Object> | ⚠️ | Liste d'objets AvailableDates | **Peut être un tableau vide `[]`** |

#### Structure d'un objet AvailableDate :

```json
{
  "date": "string (format date)",
  "price": "string ou number"
}
```

**⚠️ IMPORTANT** :
- Si aucune date : envoyer `[]` (tableau vide) ou omettre la clé
- `price` peut être une String ou Number (sera converti en String)

---

### 9. 📜 Règles du Véhicule

| Clé JSON | Type | Requis | Format | Notes |
|----------|------|--------|--------|-------|
| `vehicle_rules` | Array<String> | ⚠️ | Liste de Strings | **Peut être un tableau vide `[]`** |
| | | | | Format accepté : `["Règle 1", "Règle 2"]` |
| | | | | OU objets avec `description` ou `rule` : `[{"description": "Règle 1"}]` |

**⚠️ IMPORTANT** :
- Si aucune règle : envoyer `[]` (tableau vide) ou omettre la clé
- Si la clé est absente, l'application utilisera un tableau vide par défaut
- Format supporté :
  - Tableau de Strings : `["Règle 1", "Règle 2"]` ✅
  - Tableau d'objets : `[{"description": "Règle 1"}, {"rule": "Règle 2"}]` ✅

---

### 10. ❌ Règles d'Annulation

| Clé JSON | Type | Requis | Format | Notes |
|----------|------|--------|--------|-------|
| `cancellation_rules` | Array<String> | ⚠️ | Liste de Strings | **Peut être un tableau vide `[]`** |
| `cancellation_reason` | Dynamic | ⚠️ | String, Array, ou Object | Raison d'annulation |

**⚠️ IMPORTANT** :
- `cancellation_rules` : Si aucune règle, envoyer `[]` (tableau vide) ou omettre
- `cancellation_reason` : Peut être de n'importe quel type (sera conservé tel quel)

---

### 11. 💰 Remises et Tarification

| Clé JSON | Type | Requis | Format | Notes |
|----------|------|--------|--------|-------|
| `weekly_discount` | String/Number | ⚠️ | String (converti automatiquement) | Remise hebdomadaire |
| `weekly_discount_type` | String | ⚠️ | String | Type de remise (`"percentage"`, `"fixed"`) |
| `monthly_discount` | String/Number | ⚠️ | String (converti automatiquement) | Remise mensuelle |
| `monthly_discount_type` | String | ⚠️ | String | Type de remise (`"percentage"`, `"fixed"`) |
| `deposit_value` | String/Number | ⚠️ | String (converti automatiquement) | Valeur du dépôt |
| `deposit_manager` | String | ⚠️ | String | Gestionnaire du dépôt |

---

### 12. 👥 Autres Informations

| Clé JSON | Type | Requis | Format | Notes |
|----------|------|--------|--------|-------|
| `person_allowed` | String/Number | ⚠️ | String (converti automatiquement) | Nombre de personnes autorisées |
| `is_verified` | String/Boolean | ⚠️ | String (converti automatiquement) | `"1"` ou `true` = Vérifié |
| `is_featured` | String/Boolean | ⚠️ | String (converti automatiquement) | `"1"` ou `true` = En vedette |
| `is_in_wishlist` | Boolean | ⚠️ | Boolean | `true` si dans la wishlist de l'utilisateur |
| `bedrooms` | String | ⚠️ | String | Nombre de chambres (pour autres types d'items) |
| `beds` | String | ⚠️ | String | Nombre de lits (pour autres types d'items) |
| `bathroom` | String | ⚠️ | String | Nombre de salles de bain (pour autres types d'items) |
| `item_sqft` | String | ⚠️ | String | Superficie (pour autres types d'items) |
| `bed_type` | String | ⚠️ | String | Type de lit (pour autres types d'items) |
| `item_data` | String | ⚠️ | String | Données supplémentaires |

---

## 📊 Formats de Données

### Types de Données Acceptés

1. **String** : Chaîne de caractères (ex: `"Toyota"`, `"300"`)
2. **Number** : Nombre (ex: `300`, `4.5`) - Sera converti automatiquement en String
3. **Boolean** : Booléen (ex: `true`, `false`) - Pour certains champs comme `is_in_wishlist`
4. **Array** : Tableau (ex: `[]`, `["item1", "item2"]`)
5. **Object** : Objet JSON (ex: `{}`, `{"key": "value"}`)

### Conversion Automatique

L'application Flutter convertit automatiquement :
- `Number` → `String` pour les champs String (ex: `price`, `item_rating`)
- `String` → `Number` pour les champs Number (ex: `total_reviews`)
- `Boolean` → `String` pour certains champs (ex: `is_verified`, `is_featured`)

**✅ Recommandation** : Envoyer les données dans le format attendu (String pour String, Number pour Number) pour éviter les problèmes de conversion.

---

## ⚠️ Règles Importantes pour les Listes/Arrays

### ✅ Tableaux Vides Acceptés
Les tableaux suivants **PEUVENT** être envoyés vides `[]` :
- `gallery_image_urls` : `[]` ✅
- `reviews` : `[]` ✅
- `amenities` : `[]` ✅
- `available_dates` : `[]` ✅
- `vehicle_rules` : `[]` ✅
- `cancellation_rules` : `[]` ✅
- `features_data` (dans `item_info`) : `[]` ✅
- `rules` (dans `item_info`) : `[]` ✅

### ❌ Clés Absentes Acceptées
Si un tableau est vide, vous pouvez :
1. **Option 1** : Envoyer la clé avec un tableau vide `[]` ✅
2. **Option 2** : Omettre complètement la clé ✅

**⚠️ ATTENTION** : Ne jamais envoyer `null` pour une liste. Utiliser `[]` ou omettre la clé.

---

## 🔍 Exemple de Réponse Complète

```json
{
  "status": 200,
  "message": "Item details retrieved successfully",
  "error": null,
  "data": {
    "ItemDetails": {
      "item_id": "123",
      "title": "Toyota Camry 2023",
      "price": "300",
      "description": "Véhicule confortable et spacieux",
      "item_rating": "4.5",
      "status": "1",
      "item_type": "CAR",
      "front_image_url": "https://carvy.tech/uploads/camry.jpg",
      "mobile": "+212600000000",
      "address": "123 Rue Example, Casablanca",
      "city": "Casablanca",
      "state_region": "Casablanca-Settat",
      "zip_postal_code": "20000",
      "latitude": "33.5731",
      "longitude": "-7.5898",
      "gallery_image_urls": [
        "https://carvy.tech/uploads/image1.jpg",
        "https://carvy.tech/uploads/image2.jpg"
      ],
      "total_reviews": 5,
      "reviews": [
        {
          "id": "1",
          "booking_id": "100",
          "guest_id": "50",
          "guest_name": "John Doe",
          "guest_profile_image": "https://carvy.tech/uploads/profile.jpg",
          "rating": "5",
          "message": "Excellent véhicule !",
          "created_at": "2024-01-15T10:00:00Z",
          "updated_at": "2024-01-15T10:00:00Z"
        }
      ],
      "host_id": "10",
      "host_player_id": "player123",
      "host_first_name": "Ahmed",
      "host_last_name": "Bensaid",
      "host_email": "ahmed@example.com",
      "host_phone": "+212600000000",
      "host_profile_image": "https://carvy.tech/uploads/host.jpg",
      "amenities": [
        {
          "id": "1",
          "name": "GPS",
          "image_url": "https://carvy.tech/uploads/gps.png"
        },
        {
          "id": "2",
          "name": "Climatisation",
          "image_url": "https://carvy.tech/uploads/ac.png"
        }
      ],
      "vehicle_rules": [
        "Interdiction de fumer",
        "Interdiction d'animaux",
        "Conduire prudemment"
      ],
      "cancellation_rules": [
        "Annulation gratuite jusqu'à 24h avant",
        "50% de remboursement si annulé moins de 24h avant"
      ],
      "cancellation_reason": null,
      "weekly_discount": "10",
      "weekly_discount_type": "percentage",
      "monthly_discount": "15",
      "monthly_discount_type": "percentage",
      "deposit_value": "500",
      "deposit_manager": "admin",
      "is_verified": "1",
      "is_featured": "0",
      "is_in_wishlist": false,
      "available_dates": [
        {
          "date": "2024-01-20",
          "price": "300"
        },
        {
          "date": "2024-01-21",
          "price": "300"
        }
      ],
      "item_info": "{\"type\":\"CAR\",\"vehicleType\":\"Sedan\",\"make_type\":\"Toyota\",\"model\":\"Camry\",\"year\":2023,\"license_plate\":\"ABC-123\",\"fuel_type\":\"Petrol\",\"number_of_seats\":5,\"transmission\":\"Automatic\",\"odometer\":\"50000\",\"min_rental_days\":1,\"min_age\":21,\"smoking_status\":\"No\",\"international_travel_status\":\"Allowed\",\"is_verified\":true,\"is_featured\":false,\"booking_policies_id\":\"1\",\"weekly_discount\":\"10\",\"weekly_discount_type\":\"percentage\",\"monthly_discount\":\"15\",\"monthly_discount_type\":\"percentage\",\"cancellation_reason_title\":null,\"cancellation_reason_description\":[],\"features_data\":[{\"id\":\"1\",\"name\":\"GPS\",\"image_url\":\"https://carvy.tech/uploads/gps.png\"},{\"id\":\"2\",\"name\":\"Climatisation\",\"image_url\":\"https://carvy.tech/uploads/ac.png\"}],\"rules\":[],\"host_id\":\"10\",\"host_first_name\":\"Ahmed\",\"host_last_name\":\"Bensaid\",\"host_email\":\"ahmed@example.com\",\"host_phone\":\"+212600000000\",\"host_player_id\":\"player123\",\"host_profile_image\":\"https://carvy.tech/uploads/host.jpg\",\"gallery_image_urls\":[\"https://carvy.tech/uploads/image1.jpg\",\"https://carvy.tech/uploads/image2.jpg\"],\"review_data\":null,\"total_reviews\":5,\"doorStep_price\":\"50\"}"
    }
  }
}
```

---

## ✅ Checklist pour le Backend Node.js

### Champs OBLIGATOIRES (ne doivent jamais être null/absent)
- [ ] `status` : `200` (Number ou String)
- [ ] `data.ItemDetails.item_id` : String ou Number
- [ ] `data.ItemDetails.title` : String
- [ ] `data.ItemDetails.price` : String ou Number
- [ ] `data.ItemDetails.status` : String (`"0"` ou `"1"`)
- [ ] `data.ItemDetails.item_type` : String
- [ ] `data.ItemDetails.item_info` : String (JSON stringifié)

### Champs dans `item_info` OBLIGATOIRES
- [ ] `type` : String (ex: `"CAR"`)
- [ ] `vehicleType` : String (⚠️ Affiche "null" dans le badge si absent)

### Champs Recommandés (peuvent être null/vides mais recommandés)
- [ ] `front_image_url` : String (URL)
- [ ] `gallery_image_urls` : Array<String> (peut être `[]`)
- [ ] `item_rating` : String ou Number
- [ ] `total_reviews` : Number (peut être `0`)
- [ ] `host_id`, `host_first_name`, `host_last_name`, etc.

### Listes Vides Acceptées
- [ ] `gallery_image_urls` : `[]` ✅
- [ ] `reviews` : `[]` ✅
- [ ] `amenities` : `[]` ✅
- [ ] `available_dates` : `[]` ✅
- [ ] `vehicle_rules` : `[]` ✅
- [ ] `cancellation_rules` : `[]` ✅
- [ ] `features_data` (dans `item_info`) : `[]` ✅
- [ ] `rules` (dans `item_info`) : `[]` ✅

### Format JSON Stringifié pour `item_info`
- [ ] `item_info` doit être une **String JSON** (pas un objet)
- [ ] Utiliser `JSON.stringify(itemInfoObject)` côté backend

---

## 🐛 Problèmes Courants à Éviter

1. **❌ `item_info` comme objet** : Doit être une String JSON, pas un objet
2. **❌ `vehicleType` absent dans `item_info`** : Cause l'affichage "null" dans le badge
3. **❌ Listes avec `null`** : Utiliser `[]` ou omettre la clé
4. **❌ `ItemDetails` en camelCase** : Doit être en PascalCase (`ItemDetails`)
5. **❌ Conversion de types incorrecte** : Respecter les types attendus (String pour String, Number pour Number)

---

## 📝 Notes Finales

- **Tous les champs marqués `⚠️` peuvent être `null` ou absents**, mais l'application les gère avec des valeurs par défaut.
- **Les listes peuvent être vides `[]` ou omises** - les deux sont acceptés.
- **Les types Number et String sont interchangeables** pour la plupart des champs (conversion automatique).
- **`item_info` DOIT être une chaîne JSON stringifiée** - C'est critique pour éviter les erreurs de parsing.
