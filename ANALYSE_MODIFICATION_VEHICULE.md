# 📊 ANALYSE COMPLÈTE : Modification de Véhicule

## 🎯 Vue d'ensemble

Le système de modification de véhicule permet au vendeur de modifier les détails d'un véhicule existant. Le processus se déroule en plusieurs étapes avec des écrans dédiés et des appels API spécifiques.

---

## 📱 Architecture et Flux

### 1. **Point d'entrée - Navigation vers l'édition**

#### Fichiers concernés :
- `lib/view/host/dash_board_screen.dart` (ligne 1157-1298)
- `lib/view/host/hostsearch/host_search_screen.dart` (ligne 312-483)

#### Flux de navigation :

```dart
// Depuis le dashboard ou la recherche
onEdit: () async {
  showLoading();
  
  // 1. Récupérer l'ID du véhicule
  final vehicle = vehiclesList[index];
  String? vehicleId = vehicle.id?.toString();
  
  // 2. Vérifier la validité de l'ID
  if (hasValidId) {
    // 3. Récupérer les détails complets depuis le serveur
    var detailedVehicle = await addItemsHostController.fetchVehicleDetails(vehicleId!);
    
    if (detailedVehicle != null) {
      // 4. Stocker le véhicule
      addItemsHostController.item = detailedVehicle;
      
      // 5. Pré-remplir le formulaire
      await addItemsHostController.populateFields(detailedVehicle);
      
      // 6. Naviguer vers l'écran d'édition
      Get.to(EditVehicleHomeScreen(
        vehicleId: vehicleId,
        mode: ScreenMode.edit,
      ));
    }
  }
}
```

---

## 🔌 APIs Utilisées

### 1. **GET /api/v1/vehicles/:id** - Récupération des détails du véhicule

**Endpoint :** `Config.getVehicleDetails = 'vehicles'`

**Méthode :** GET

**URL complète :** `{baseurl}/vehicles/{vehicleId}` → `http://10.0.2.2:5000/api/v1/vehicles/{vehicleId}`

**Fonction Flutter :** `fetchVehicleDetails(String vehicleId)` (ligne 2455-2756)

**Paramètres :**
- `vehicleId` : ID du véhicule (dans l'URL)

**Réponse attendue :**
```json
{
  "status": 200,
  "message": "Vehicle retrieved successfully",
  "data": {
    "items": [
      {
        "_id": "vehicle_id",
        "title": "BMW - X1",
        "description": "...",
        "price": "200.00",
        "type": "type_id",
        "specs": {
          "brand": "brand_id",
          "model": "model_id",
          "transmission": "Automatic",
          "year": 2023,
          "mileage": "odometer_id"
        },
        "pricing": {
          "basePrice": 200.00,
          "deposit": {
            "value": 500.00,
            "managedBy": "CARVY"
          }
        },
        "location": {
          "type": "Point",
          "coordinates": [longitude, latitude],
          "city": "Rabat"
        },
        "features": ["feature_id1", "feature_id2"],
        "images": ["url1", "url2"],
        "itemInfo": "{...}", // JSON stringifié
        "metaData": "{...}", // JSON stringifié
        "front_image": {...},
        "gallery": [...]
      }
    ]
  }
}
```

**Gestion des erreurs :**
- ID invalide (null, vide, trop court, temporaire)
- Réponse vide ou malformée
- Parsing JSON échoué

---

### 2. **PUT /api/v1/edit-item/:id** - Mise à jour du véhicule

**Endpoint :** `Config.editItem = 'edit-item'`

**Méthode :** PUT

**URL complète :** `{baseurl}/edit-item/{vehicleId}` → `http://10.0.2.2:5000/api/v1/edit-item/{vehicleId}`

**Fonction Flutter :** `updateMethod()` (ligne 3089-3273)

**Body envoyé :**
```json
{
  "id": "vehicle_id",
  "type": "type_id",
  "category": "SUV",
  "specs": {
    "brand": "brand_id",
    "model": "model_id",
    "transmission": "Automatic",
    "year": 2023
  },
  "pricing": {
    "basePrice": 200.00,
    "deposit": {
      "value": 500.00,
      "managedBy": "CARVY"
    }
  },
  "location": {
    "type": "Point",
    "coordinates": [longitude, latitude],
    "city": "Rabat"
  },
  "features": ["feature_id1", "feature_id2"],
  "images": ["url1", "url2"], // URLs des images existantes conservées
  "title": "BMW - X1",
  "description": "...",
  "address": "123 Main Street",
  "zip_postal_code": "10000",
  "country": "Morocco",
  "state_region": "Rabat-Salé-Kénitra",
  "weekly_discount": "10",
  "weekly_discount_type": "percent",
  "monthly_discount": "15",
  "monthly_discount_type": "percent",
  "booking_policies_id": "1"
}
```

**Réponse attendue :**
```json
{
  "status": 200,
  "message": "Vehicle updated successfully",
  "error": "",
  "data": {
    "editItemHost": {
      "id": "vehicle_id",
      "title": "BMW - X1",
      "price": "200.00"
    }
  },
  "requiresRevalidation": false // Optionnel : si true, le véhicule doit être re-validé
}
```

**Gestion des erreurs :**
- ID manquant
- Données invalides
- Erreur serveur

---

### 3. **POST /api/v1/add-update-item-image** - Mise à jour des images

**Endpoint :** `Config.addEditItemImage = 'add-update-item-image'`

**Méthode :** POST

**URL complète :** `{baseurl}/add-update-item-image` → `http://10.0.2.2:5000/api/v1/add-update-item-image`

**Fonction Flutter :** `updateUploadImage(ScreenMode mode)` (ligne 3275-3323)

**Body envoyé :**
```json
{
  "id": "vehicle_id",
  "front_image": "base64_encoded_image", // Nouvelle image principale (base64) ou ""
  "front_image_doc": "base64_encoded_doc", // Nouvelle image document (base64) ou ""
  "gallery_image": "base64img1##base64img2##base64img3", // Nouvelles images galerie séparées par ##
  "gallery_image_delete": "[url1, url2]" // URLs des images à supprimer
}
```

**Réponse attendue :**
```json
{
  "status": 200,
  "message": "Images saved successfully",
  "error": "",
  "data": {
    "id": "vehicle_id",
    "front_image_uploaded": true,
    "documents_image_uploaded": true,
    "gallery_image_count": 3
  }
}
```

---

## 📋 Écrans et Navigation

### 1. **EditVehicleHomeScreen** - Écran principal d'édition

**Fichier :** `lib/view/host/vehiclehost/editvehicle/edit_vehicle_home_screen.dart`

**Fonctionnalités :**
- Affiche 3 étapes principales :
  - **Step #1** : Décrire le véhicule (détails, caractéristiques, etc.)
  - **Step #2** : Mettre en scène (upload photos)
  - **Step #3** : Préparer le véhicule (calendrier et disponibilité)

**Navigation :**
- Step #1 → `EditVehicleFirstSectionScreen`
- Step #2 → `UploadImageScreen(mode: ScreenMode.edit)`
- Step #3 → `EditCalenderOnThirdStepCommon`

**État de chargement :**
- Vérifie si les listes de référence sont chargées
- Charge les types de véhicules si nécessaire
- Charge les marques/modèles si le type est sélectionné

---

### 2. **EditVehicleFirstSectionScreen** - Formulaire de détails

**Fichier :** `lib/view/host/vehiclehost/editvehicle/edit_vehicle_first_section_screen.dart`

**Contenu :**
- TabBar avec 6 onglets :
  1. **VehicleTypeScreen** : Type, marque, modèle, année, transmission, carburant, sièges, kilométrage
  2. **VehcileDescriptionScreen** : Description, plaque, jours minimum, âge minimum, assurance
  3. **VehiclePriceScreen** : Prix, remises hebdomadaires/mensuelles
  4. **LocationScreenHost** : Adresse, ville, coordonnées GPS
  5. **VehicleFeaturesScreen** : Caractéristiques (amenities)
  6. **VehcileRulesScreen** : Règles du véhicule, politique d'annulation

**Mode :** `ScreenMode.edit` - Les écrans détectent ce mode pour pré-remplir les champs

---

## 🔄 Fonctions Clés du Controller

### 1. **fetchVehicleDetails(String vehicleId)**

**Localisation :** `lib/controller/add_items_host_controller.dart` (ligne 2455-2756)

**Rôle :** Récupère les détails complets d'un véhicule depuis l'API

**Processus :**
1. Validation de l'ID (vérifie null, vide, trop court, temporaire)
2. Appel GET `/api/v1/vehicles/:id`
3. Parsing de la réponse (structure `items[]`)
4. Conversion en objet `Items`
5. Appel automatique de `populateFields()` pour pré-remplir le formulaire

**Gestion des erreurs :**
- Mapping manuel si le parsing échoue
- Extraction manuelle des champs critiques (year, mileage, model_id)
- Fallback sur les données locales si l'API échoue

---

### 2. **populateFields(Items vehicle)**

**Localisation :** `lib/controller/add_items_host_controller.dart` (ligne 957-2449)

**Rôle :** Pré-remplit tous les champs du formulaire avec les données du véhicule

**Processus détaillé :**

#### A. Initialisation
- Sauvegarde de l'ID : `currentVehicleId = vehicle.id`
- Stockage du véhicule : `item = vehicle`
- Nettoyage des contrôleurs : `cleanTextController()`
- Activation du loader : `isLoadingEdit.value = true`

#### B. Chargement des listes de référence
- Types de véhicules : `getDataItemType()` → `vehicleListItemType`
- Caractéristiques : `getDataAmenties()` → `vehicleListAmenities`
- Marques/Modèles : `getVehicleDataMakeModel()` → `listMakesType`, `listModelType`

#### C. Mapping du type de véhicule
- Priorité 1 : `vehicle.toJson()['type']` (ID MongoDB)
- Priorité 2 : `itemInfo['type']` (depuis JSON stringifié)
- Priorité 3 : `vehicle.itemTypeId` (fallback)
- Matching intelligent : recherche par ID ou par nom dans `vehicleListItemType`

#### D. Remplissage des TextEditingController
- `textEditingControllerEditTitle.text = vehicle.title`
- `textEditingControllerEditDesc.text = vehicle.description`
- `textEditingControllerEditPrice.text = vehicle.price`
- `textEditingControllerEditAddress.text = vehicle.address`
- `textEditingControllerEditCity.text = vehicle.city`
- `textEditingControllerEditZip.text = vehicle.zipPostalCode`
- `textEditingControllerEditState.text = vehicle.stateRegion`
- `textEditingControllerEditCountry.text = vehicle.country`
- `textEditingControllerEditWeekDiscount.text = vehicle.weeklyDiscount`
- `textEditingControllerEditMonthDiscount.text = vehicle.monthlyDiscount`

#### E. Parsing des données MongoDB imbriquées
- Parsing de `itemInfo` (JSON stringifié) → `vehicleDataMap`
- Parsing de `metaData` (JSON stringifié) → fusion avec `vehicleDataMap`
- Extraction depuis `specs` :
  - `brand` → `selectedMake`
  - `model` → `selectedModel`
  - `transmission` → `selectTransmission`
  - `year` → `selectedYear`, `selectedVechicleYear`
  - `mileage` / `odometer` → `selectedOdometerId`
- Extraction depuis `pricing` :
  - `basePrice` → `textEditingControllerEditPrice`
  - `deposit.value` → `textEditingControllerEditSecurityMoney`
- Extraction depuis `location` :
  - `coordinates[0]` → `selectedLong.value`
  - `coordinates[1]` → `selectedLat.value`
  - `city` → `textEditingControllerEditCity`

#### F. Mapping des caractéristiques (Features)
- Parsing de `features` (array d'IDs)
- Matching avec `vehicleListAmenities`
- Sélection : `selectedAmenitiesList = [id1, id2, ...]`

#### G. Mapping des images
- Image principale : `item.frontImage?.url` → `existingFrontImageUrls`
- Galerie : `item.gallery[]` → `existingGalleryImageUrls`
- Initialisation des listes pour la gestion des suppressions

#### H. Mapping des règles et politiques
- Parsing de `vehicleRules` → `selectedRulesList`
- Parsing de `cancellationPolicies` → `selectedRadio`

#### I. Finalisation
- Désactivation du loader : `isLoadingEdit.value = false`
- Mise à jour de l'UI : `update()`

---

### 3. **updateMethod()**

**Localisation :** `lib/controller/add_items_host_controller.dart` (ligne 3089-3273)

**Rôle :** Envoie les modifications du véhicule au serveur

**Processus :**

#### A. Construction du payload
```dart
itemEditMap = {
  "type": selectedVehicleType,
  "category": categoryName, // Nom du type (ex: "SUV")
  "specs": {
    "brand": selectedMake,
    "model": selectedModel,
    "transmission": selectTransmission,
    "year": selectedVechicleYear
  },
  "pricing": {
    "basePrice": double.tryParse(textEditingControllerEditPrice.text),
    "deposit": {
      "value": double.tryParse(textEditingControllerEditSecurityMoney.text),
      "managedBy": "CARVY"
    }
  },
  "location": {
    "type": "Point",
    "coordinates": [longitude, latitude],
    "city": textEditingControllerEditCity.text
  },
  "features": selectedAmenitiesList.map((id) => id.toString()).toList(),
  "images": currentImagesList, // URLs des images conservées
  "title": textEditingControllerEditTitle.text,
  "description": textEditingControllerEditDesc.text,
  "address": textEditingControllerEditAddress.text,
  "zip_postal_code": textEditingControllerEditZip.text,
  "country": textEditingControllerEditCountry.text,
  "state_region": textEditingControllerEditState.text,
  "weekly_discount": textEditingControllerEditWeekDiscount.text,
  "weekly_discount_type": selectedWeeklyDiscountType,
  "monthly_discount": textEditingControllerEditMonthDiscount.text,
  "monthly_discount_type": selectedMonthlyDiscountType,
  "booking_policies_id": selectedRadio.toString()
}
```

#### B. Gestion des images
- Images existantes conservées : `currentImagesList` (exclut celles dans `listDeleteImages`)
- Nouvelles images : gérées séparément via `updateUploadImage()`

#### C. Appel API
- Méthode : PUT
- URL : `${Config.editItem}/${currentVehicleId}`
- Body : `itemEditMap`

#### D. Gestion de la réponse
- Succès (status 200/201) :
  - Affiche message de succès
  - Gère `requiresRevalidation` si présent
  - Nettoie le cache : `removeDashBoardData()`, `removeMyPostData()`
  - Navigue vers le dashboard : `Get.offAll(BottomHost)`
- Erreur :
  - Affiche message d'erreur
  - Log détaillé

---

### 4. **updateUploadImage(ScreenMode mode)**

**Localisation :** `lib/controller/add_items_host_controller.dart` (ligne 3275-3323)

**Rôle :** Met à jour les images du véhicule (principale, document, galerie)

**Body envoyé :**
```dart
{
  "id": vehicleId,
  "front_image": frontImageBase64 ?? "", // Base64 ou "" si pas de nouvelle image
  "front_image_doc": frontImageBase64fordoec ?? "",
  "gallery_image": galleryImageBase64List.join("##"), // Nouvelles images séparées par ##
  "gallery_image_delete": listDeleteImages.toString() // URLs des images supprimées
}
```

**Gestion :**
- Nouvelles images : converties en base64
- Images supprimées : URLs dans `listDeleteImages`
- Images existantes conservées : gérées dans `updateMethod()`

---

## 📊 Structure des Données

### Modèle Items (my_items_model.dart)

**Propriétés principales :**
- `id` : ID du véhicule
- `title` : Titre (ex: "BMW - X1")
- `description` : Description
- `price` : Prix
- `address`, `city`, `stateRegion`, `zipPostalCode`, `country` : Localisation
- `latitude`, `longitude` : Coordonnées GPS
- `itemTypeId` : ID du type de véhicule
- `itemType` : Nom du type (ex: "SUV")
- `itemInfo` : JSON stringifié contenant les specs détaillées
- `metaData` : JSON stringifié contenant les métadonnées
- `frontImage` : Objet `FrontImage` avec `url`, `thumbnail`
- `gallery` : Liste d'objets `Gallery` avec `url`, `thumbnail`
- `weeklyDiscount`, `weeklyDiscountType` : Remise hebdomadaire
- `monthlyDiscount`, `monthlyDiscountType` : Remise mensuelle
- `bookingPoliciesId` : ID de la politique de réservation

### Structure itemInfo (JSON stringifié)

```json
{
  "type": "type_id",
  "makeType": "brand_id",
  "model": "model_id",
  "year": 2023,
  "transmission": "Automatic",
  "odometer": "odometer_id",
  "fuelType": "fuel_type_id",
  "seatCapicity": 5,
  "platNumber": "12000-A-1",
  "minRentalDays": 1,
  "ageRistriction": 21,
  "insuranceCoverage": 500,
  "description": "...",
  "featuresData": [...],
  "cancellationReason": "policy_id",
  "cancellationReasonDescription": [...],
  "vehicleRules": [...]
}
```

---

## 🔍 Points d'Attention et Complexités

### 1. **Gestion des IDs MongoDB vs IDs Locaux**
- Le backend Node.js utilise des IDs MongoDB (`_id`)
- Les listes de référence locales peuvent utiliser des IDs différents (int vs String)
- Matching intelligent nécessaire pour faire correspondre les IDs

### 2. **Parsing des Données Imbriquées**
- Les données peuvent être dans `itemInfo` (JSON stringifié) ou `metaData`
- Structure MongoDB avec objets imbriqués (`specs`, `pricing`, `location`)
- Fallback multiple si une source échoue

### 3. **Gestion des Images**
- Images existantes : URLs réseau
- Nouvelles images : XFile → Base64
- Images supprimées : tracking dans `listDeleteImages`
- Upload séparé des images et des données

### 4. **État de Chargement**
- `isLoadingEdit` : empêche l'affichage des dropdowns vides
- Chargement asynchrone des listes de référence
- Mise à jour progressive de l'UI avec `update()`

### 5. **Validation des Données**
- Vérification de l'ID avant chaque appel API
- Validation des champs requis
- Gestion des erreurs de parsing

---

## 🚀 Flux Complet de Modification

```
1. Utilisateur clique sur "Modifier" dans le dashboard
   ↓
2. Vérification de l'ID du véhicule
   ↓
3. Appel fetchVehicleDetails(vehicleId)
   ↓
4. API GET /api/v1/vehicles/:id
   ↓
5. Parsing de la réponse → Items
   ↓
6. Appel populateFields(vehicle)
   ↓
7. Chargement des listes de référence
   ↓
8. Pré-remplissage de tous les champs
   ↓
9. Navigation vers EditVehicleHomeScreen
   ↓
10. Utilisateur modifie les données
    ↓
11. Utilisateur sauvegarde (Step #1)
    ↓
12. Appel updateMethod()
    ↓
13. API PUT /api/v1/edit-item/:id
    ↓
14. Succès → Navigation vers dashboard
    ↓
15. (Optionnel) Utilisateur modifie les images (Step #2)
    ↓
16. Appel updateUploadImage()
    ↓
17. API POST /api/v1/add-update-item-image
    ↓
18. Succès → Retour à EditVehicleHomeScreen
```

---

## 📝 Notes Importantes

1. **L'ID doit être sauvegardé** : `currentVehicleId` est utilisé pour tous les appels API de mise à jour
2. **Les images sont gérées séparément** : Les données et les images sont envoyées via 2 endpoints différents
3. **Le mode ScreenMode.edit** : Permet aux écrans de détecter qu'on est en mode édition
4. **Le cache est nettoyé** : Après une modification réussie, le cache du dashboard est supprimé
5. **Re-validation possible** : Le backend peut demander une re-validation si `requiresRevalidation = true`

---

## 🔧 Endpoints API Résumés

| Endpoint | Méthode | Rôle | Paramètres |
|----------|---------|------|------------|
| `/api/v1/vehicles/:id` | GET | Récupérer les détails | `vehicleId` dans l'URL |
| `/api/v1/edit-item/:id` | PUT | Mettre à jour le véhicule | `vehicleId` dans l'URL, body avec toutes les données |
| `/api/v1/add-update-item-image` | POST | Mettre à jour les images | Body avec images base64 et URLs à supprimer |

---

## ✅ Checklist de Modification

- [ ] ID du véhicule valide
- [ ] Données récupérées depuis l'API
- [ ] Formulaire pré-rempli correctement
- [ ] Listes de référence chargées
- [ ] Tous les champs mappés correctement
- [ ] Images existantes chargées
- [ ] Modifications sauvegardées
- [ ] Images mises à jour (si modifiées)
- [ ] Cache nettoyé
- [ ] Navigation vers dashboard

---

**Date de création :** $(date)
**Dernière mise à jour :** $(date)
