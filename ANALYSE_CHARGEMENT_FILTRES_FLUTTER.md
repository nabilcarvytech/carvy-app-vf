# 📊 ANALYSE : Chargement des Données de Filtres depuis le Backend

## 🎯 Vue d'ensemble

L'écran de filtres Flutter charge dynamiquement les données depuis le backend via 5 endpoints distincts. Ces appels sont déclenchés automatiquement lors de l'ouverture de l'écran de filtres.

---

## 📱 Contrôleur Flutter

**Fichier :** `lib/controller/search_controller.dart`

**Classe :** `SearchControllerHome` (étend `GetxController`)

---

## 🚀 Fonction d'Initialisation

### Fonction principale : `filterApiBasedOnModule()`

**Localisation :** `lib/controller/search_controller.dart` (ligne 452)

```dart
void filterApiBasedOnModule() {
  getAminitiesvehicle();      // 1. Caractéristiques (Amenities)
  getMakeApi();               // 2. Marques (Makes)
  getOdometersvehicle();      // 3. Kilométrages (Odometers)
  getFuelTypesForFilter();    // 4. Types de carburant (Fuel Types)
  getTransmissionsForFilter(); // 5. Transmissions
  update();
}
```

**Quand est-elle appelée ?**

Cette fonction est appelée dans `initState()` de l'écran de filtres :

**Fichier :** `lib/view/search/vehicle/vehicle_filter.dart` (ligne 85)

```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    // ... initialisation des valeurs par défaut ...
    filterController.filterApiBasedOnModule(); // ← Appel ici
    filterController.dataChangedBasedOnModuleid();
  });
}
```

---

## 🔌 Endpoints API Utilisés

### 1. **Caractéristiques (Amenities)**

**Endpoint :** `GET /api/v1/amenities`

**Fonction Flutter :** `getAminitiesvehicle()` (ligne 461)

**Appel :**
```dart
final response = await httpGet(Config.amenities, {});
```

**Config :** `Config.amenities = 'amenities'`

**URL complète :** `{baseurl}/amenities` → `http://10.0.2.2:5000/api/v1/amenities`

**Paramètres envoyés :** Aucun (objet vide `{}`)

**Structure JSON attendue :**
```json
{
  "status": 200,
  "message": "Amenities retrieved successfully",
  "error": "",
  "data": {
    "amenities": [
      {
        "id": 1,
        "name": "Airbags",
        "image": "https://example.com/amenities/airbags.png"
      },
      {
        "id": 2,
        "name": "GPS",
        "image": "https://example.com/amenities/gps.png"
      }
    ]
  }
}
```

**Modèle Flutter :** `AmenitiesModel`
- `status` (num?)
- `message` (String?)
- `error` (String?)
- `data.amenities[]` (List<Amenities>)
  - `id` (num?)
  - `name` (String?)
  - `image` (String?)

**Cache local :** `GetStorage().read("vehicleAminities")`

---

### 2. **Marques (Makes / Brand Types)**

**Endpoint :** `GET /api/v1/vehicle-reference/makes`

**Fonction Flutter :** `getMakeApi()` (ligne 527)

**Appel :**
```dart
final response = await httpGet(
  Config.makeType, 
  {"type_id": "$globalItemType"}
);
```

**Config :** `Config.makeType = 'vehicle-reference/makes'`

**URL complète :** `{baseurl}/vehicle-reference/makes?type_id={globalItemType}`

**Paramètres envoyés :**
- `type_id` (String) : ID du type de véhicule (ex: "1", "2", etc.)

**Structure JSON attendue :**
```json
{
  "status": 200,
  "message": "Makes retrieved successfully",
  "error": "",
  "data": {
    "makes": [
      {
        "_id": "507f1f77bcf86cd799439011",
        "id": "507f1f77bcf86cd799439011",
        "name": "Toyota",
        "makeName": "Toyota",
        "description": "Description de la marque",
        "status": "1",
        "created_at": "2024-01-01T00:00:00.000Z",
        "updated_at": "2024-01-01T00:00:00.000Z",
        "deleted_at": null,
        "image": "toyota.png",
        "imageURL": "https://example.com/images/toyota.png",
        "media": []
      },
      {
        "_id": "507f1f77bcf86cd799439012",
        "id": "507f1f77bcf86cd799439012",
        "name": "Honda",
        "makeName": "Honda",
        "description": "Description de la marque",
        "status": "1",
        "imageURL": "https://example.com/images/honda.png"
      }
    ]
  }
}
```

**Modèle Flutter :** `CarMakes`
- `status` (int?)
- `message` (String?)
- `error` (String?)
- `data.makes[]` (List<Makes>)
  - `_id` ou `id` (String) - **PRIORITÉ à `_id` (MongoDB)**
  - `name` ou `makeName` (String)
  - `description` (String?)
  - `status` (String?)
  - `created_at` (String?)
  - `updated_at` (String?)
  - `deleted_at` (String?)
  - `image` (String?)
  - `imageURL` (String?)
  - `media` (List<dynamic>?)

**Cache local :** `GetStorage().read("vehiclemake")`

**Note importante :** Le modèle Flutter accepte `_id` (MongoDB) ou `id` (SQL), avec priorité à `_id`.

---

### 3. **Kilométrages (Odometers)**

**Endpoint :** `GET /api/v1/vechile-odometer`

**Fonction Flutter :** `getOdometersvehicle()` (ligne 477)

**Appel :**
```dart
final response = await httpGet(Config.vechileOdometer, {});
```

**Config :** `Config.vechileOdometer = 'vechile-odometer'`

**URL complète :** `{baseurl}/vechile-odometer` → `http://10.0.2.2:5000/api/v1/vechile-odometer`

**Paramètres envoyés :** Aucun (objet vide `{}`)

**Structure JSON attendue :**
```json
{
  "status": 200,
  "message": "Odometers retrieved successfully",
  "error": "",
  "data": {
    "getodometer": [
      {
        "_id": "507f1f77bcf86cd799439011",
        "id": 1,
        "odometer": "0-10,000 km",
        "odometerSpeed": "0-10,000 km",
        "name": "0-10,000 km"
      },
      {
        "_id": "507f1f77bcf86cd799439012",
        "id": 2,
        "odometer": "10,001-50,000 km",
        "odometerSpeed": "10,001-50,000 km",
        "name": "10,001-50,000 km"
      },
      {
        "_id": "507f1f77bcf86cd799439013",
        "id": 3,
        "odometer": "50,001-100,000 km",
        "odometerSpeed": "50,001-100,000 km",
        "name": "50,001-100,000 km"
      }
    ]
  }
}
```

**Modèle Flutter :** `Odometer`
- `status` (num?)
- `message` (String?)
- `error` (String?)
- `data.odometerList[]` (List<Getodometer>)
  - `_id` ou `id` (int?) - **PRIORITÉ à `_id` (MongoDB)**
  - `odometer` ou `odometerSpeed` ou `name` (String)

**Cache local :** `GetStorage().read("vehicleOdometer")`

**Note importante :** Le modèle Flutter cherche `getodometer` dans `data`, mais stocke dans `odometerList`. Le mapping accepte `odometer`, `odometerSpeed`, ou `name` pour le libellé.

---

### 4. **Types de Carburant (Fuel Types)**

**Endpoint :** `GET /api/v1/get-vehicle-fuel-types`

**Fonction Flutter :** `getFuelTypesForFilter()` (ligne 494)

**Appel :**
```dart
final response = await httpGet(Config.fuelType, {});
```

**Config :** `Config.fuelType = 'get-vehicle-fuel-types'`

**URL complète :** `{baseurl}/get-vehicle-fuel-types` → `http://10.0.2.2:5000/api/v1/get-vehicle-fuel-types`

**Paramètres envoyés :** Aucun (objet vide `{}`)

**Structure JSON attendue :**
```json
{
  "status": 200,
  "message": "Fuel types retrieved successfully",
  "error": "",
  "data": {
    "fuel_types": [
      {
        "_id": "507f1f77bcf86cd799439011",
        "id": "507f1f77bcf86cd799439011",
        "fuel_type": "Essence",
        "name": "Essence"
      },
      {
        "_id": "507f1f77bcf86cd799439012",
        "id": "507f1f77bcf86cd799439012",
        "fuel_type": "Diesel",
        "name": "Diesel"
      },
      {
        "_id": "507f1f77bcf86cd799439013",
        "id": "507f1f77bcf86cd799439013",
        "fuel_type": "Électrique",
        "name": "Électrique"
      },
      {
        "_id": "507f1f77bcf86cd799439014",
        "id": "507f1f77bcf86cd799439014",
        "fuel_type": "Hybride",
        "name": "Hybride"
      }
    ]
  }
}
```

**Modèle Flutter :** `FuelTypeModel`
- `status` (int)
- `message` (String)
- `error` (String?)
- `data.fuel_types[]` (List<FuelType>)
  - `_id` ou `id` (String?) - **PRIORITÉ à `_id` (MongoDB)**
  - `fuel_type` ou `name` (String)

**Cache local :** `GetStorage().read("fuelTypesFilter")`

**Note importante :** Le modèle Flutter cherche `data.fuel_types` (avec un "s") et accepte `fuel_type` ou `name` pour le libellé.

---

### 5. **Transmissions**

**Endpoint :** `GET /api/v1/odometer-manual`

**Fonction Flutter :** `getTransmissionsForFilter()` (ligne 511)

**Appel :**
```dart
final response = await httpGet(Config.odometermannual, {});
```

**Config :** `Config.odometermannual = 'odometer-manual'`

**URL complète :** `{baseurl}/odometer-manual` → `http://10.0.2.2:5000/api/v1/odometer-manual`

**Paramètres envoyés :** Aucun (objet vide `{}`)

**Structure JSON attendue :**
```json
{
  "status": 200,
  "message": "Transmissions retrieved successfully",
  "error": "",
  "data": {
    "options": [
      {
        "option": "Manual"
      },
      {
        "option": "Automatic"
      },
      {
        "option": "manuelle"
      },
      {
        "option": "automatique"
      }
    ]
  }
}
```

**Modèle Flutter :** `Transmission`
- `status` (int?)
- `message` (String?)
- `error` (String?)
- `data.options[]` (List<Options>)
  - `option` (String?) - accessible via `name` getter

**Cache local :** `GetStorage().read("transmissionFilter")`

**Note importante :** Le modèle Flutter cherche `data.options[]` et chaque option a un champ `option` qui est accessible via le getter `name`.

---

## 📋 Résumé des Endpoints

| # | Endpoint | Méthode | Paramètres | Cache Key |
|---|----------|---------|------------|-----------|
| 1 | `/api/v1/amenities` | GET | Aucun | `vehicleAminities` |
| 2 | `/api/v1/vehicle-reference/makes` | GET | `type_id` (query) | `vehiclemake` |
| 3 | `/api/v1/vechile-odometer` | GET | Aucun | `vehicleOdometer` |
| 4 | `/api/v1/get-vehicle-fuel-types` | GET | Aucun | `fuelTypesFilter` |
| 5 | `/api/v1/odometer-manual` | GET | Aucun | `transmissionFilter` |

---

## 🔄 Stratégie de Cache

Tous les endpoints utilisent **GetStorage** pour mettre en cache les réponses :

1. **Vérification du cache :** Avant chaque appel API, Flutter vérifie si les données sont déjà en cache.
2. **Appel API :** Si le cache est vide, un appel GET est effectué.
3. **Mise en cache :** La réponse est stockée dans GetStorage avec une clé spécifique.
4. **Utilisation du cache :** Si le cache existe, les données sont chargées depuis le cache sans appel API.

**Exemple de code :**
```dart
var vehicleAminities = GetStorage().read("vehicleAminities");
if (vehicleAminities == null) {
  // Appel API
  final response = await httpGet(Config.amenities, {});
  if (response != null) {
    GetStorage().write("vehicleAminities", response);
    amenitiesModelVehicle = AmenitiesModel.fromJson(response);
  }
} else {
  // Utilisation du cache
  amenitiesModelVehicle = AmenitiesModel.fromJson(vehicleAminities);
}
```

---

## 🎯 Points Importants pour le Backend

### 1. **Structure de Réponse Standard**

Tous les endpoints doivent retourner cette structure :

```json
{
  "status": 200,
  "message": "Success message",
  "error": "",
  "data": {
    // Structure spécifique selon l'endpoint
  }
}
```

### 2. **Support MongoDB et SQL**

Les modèles Flutter sont conçus pour supporter **MongoDB** (`_id`) et **SQL** (`id`), avec priorité à `_id` :

```dart
// Exemple dans Makes.fromJson()
id = json['_id']?.toString() ?? json['id']?.toString() ?? '';
```

### 3. **Noms de Champs Flexibles**

Certains modèles acceptent plusieurs noms de champs :
- **Makes :** `name` ou `makeName`
- **Odometer :** `odometer` ou `odometerSpeed` ou `name`
- **FuelType :** `fuel_type` ou `name`

### 4. **Paramètre `type_id` pour Makes**

L'endpoint `/api/v1/vehicle-reference/makes` reçoit un paramètre de requête `type_id` qui correspond au type de véhicule (`globalItemType`). Le backend doit filtrer les marques selon ce type.

---

## 📝 Notes Techniques

1. **Base URL :** `http://10.0.2.2:5000/api/v1/` (développement local)
2. **Méthode HTTP :** Tous les appels sont des **GET**
3. **Authentification :** Non requise pour ces endpoints (données publiques)
4. **Gestion d'erreurs :** Flutter gère les erreurs via le champ `error` dans la réponse
5. **Loading states :** Chaque fonction met à jour `isLoadingVehicle.value` pour l'UI

---

## ✅ Checklist pour le Backend

- [ ] Implémenter `GET /api/v1/amenities` avec structure `{status, message, error, data: {amenities: [...]}}`
- [ ] Implémenter `GET /api/v1/vehicle-reference/makes?type_id={id}` avec structure `{status, message, error, data: {makes: [...]}}`
- [ ] Implémenter `GET /api/v1/vechile-odometer` avec structure `{status, message, error, data: {getodometer: [...]}}`
- [ ] Implémenter `GET /api/v1/get-vehicle-fuel-types` avec structure `{status, message, error, data: {fuel_types: [...]}}`
- [ ] Implémenter `GET /api/v1/odometer-manual` avec structure `{status, message, error, data: {options: [...]}}`
- [ ] S'assurer que tous les IDs supportent `_id` (MongoDB) et `id` (SQL)
- [ ] Filtrer les marques par `type_id` pour l'endpoint makes
- [ ] Retourner `status: 200` en cas de succès
- [ ] Retourner `error: ""` en cas de succès (chaîne vide)

---

**Date d'analyse :** 2024  
**Fichiers analysés :**
- `lib/controller/search_controller.dart`
- `lib/view/search/vehicle/vehicle_filter.dart`
- `lib/model/amenities_model.dart`
- `lib/model/make_type_model.dart`
- `lib/model/odometer_model.dart`
- `lib/model/fuel_type_model.dart`
- `lib/model/transmission_model.dart`
- `lib/api/config.dart`
