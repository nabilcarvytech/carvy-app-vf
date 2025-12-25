# API Contracts - Node.js Backend

Ce document contient les contrats JSON que le nouveau backend Node.js doit respecter pour chaque fonctionnalité migrée.

---

## Host - Vehicle Management

### Endpoint: my-items

**Method:** POST

**Request Body (What Flutter sends):**

```json
{
  "offset": "0"
}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "My items retrieved successfully",
  "error": "",
  "data": {
    "host_status": "1",
    "checkLimit": 10,
    "offset": 2,
    "limit": "10",
    "items": [
      {
        "id": 101,
        "title": "Toyota Camry 2023",
        "description": "Clean and comfortable sedan perfect for city driving",
        "item_rating": "4.5",
        "mobile": "+1234567890",
        "status": "1",
        "person_allowed": "5",
        "price": "50.00",
        "address": "123 Main Street, Los Angeles",
        "state_region": "California",
        "zip_postal_code": "90001",
        "city_name": "Los Angeles",
        "country": "USA",
        "latitude": "34.0522",
        "longitude": "-118.2437",
        "weekly_discount": "10",
        "weekly_discount_type": "percent",
        "monthly_discount": "15",
        "monthly_discount_type": "percent",
        "item_type_id": "1",
        "features_id": "[1,2,3]",
        "place_id": "ChIJE9on3F3HwoAR9AhGJW_fL-I",
        "booking_policies_id": 1,
        "item_type": "Sedan",
        "front_image": {
          "id": 1,
          "model_type": "Item",
          "model_id": "101",
          "uuid": "abc123",
          "collection_name": "front_image",
          "name": "camry-front",
          "file_name": "camry-front.jpg",
          "mime_type": "image/jpeg",
          "disk": "public",
          "conversions_disk": "public",
          "size": "500000",
          "order_column": "1",
          "created_at": "2024-01-01T00:00:00.000Z",
          "updated_at": "2024-01-01T00:00:00.000Z",
          "url": "https://example.com/host-camry-front.jpg",
          "thumbnail": "https://example.com/host-camry-front-thumb.jpg",
          "preview": "https://example.com/host-camry-front-preview.jpg",
          "original_url": "https://example.com/host-camry-front-original.jpg",
          "preview_url": "https://example.com/host-camry-front-preview.jpg"
        },
        "front_image_doc": null,
        "gallery": [
          {
            "id": 1,
            "model_type": "Item",
            "model_id": "101",
            "uuid": "gallery1",
            "collection_name": "gallery",
            "name": "camry-gallery-1",
            "file_name": "camry-gallery-1.jpg",
            "mime_type": "image/jpeg",
            "disk": "public",
            "conversions_disk": "public",
            "size": "400000",
            "order_column": "1",
            "created_at": "2024-01-01T00:00:00.000Z",
            "updated_at": "2024-01-01T00:00:00.000Z",
            "url": "https://example.com/host-camry-gallery-1.jpg",
            "thumbnail": "https://example.com/host-camry-gallery-1-thumb.jpg",
            "preview": "https://example.com/host-camry-gallery-1-preview.jpg",
            "original_url": "https://example.com/host-camry-gallery-1-original.jpg",
            "preview_url": "https://example.com/host-camry-gallery-1-preview.jpg"
          }
        ],
        "available_dates": null,
        "not_available_dates": null,
        "booked_dates": null,
        "item_info": "{\"host_id\":\"1\",\"service_type\":\"booking\",\"review_data\":[],\"features_data\":[],\"gallery_image_urls\":[]}",
        "metaData": "{}"
      },
      {
        "id": 102,
        "title": "Tesla Model 3 2022",
        "description": "Electric vehicle with autopilot features",
        "item_rating": "4.8",
        "mobile": "+1234567890",
        "status": "1",
        "person_allowed": "5",
        "price": "80.00",
        "address": "456 Market Street, San Francisco",
        "state_region": "California",
        "zip_postal_code": "94102",
        "city_name": "San Francisco",
        "country": "USA",
        "latitude": "37.7749",
        "longitude": "-122.4194",
        "weekly_discount": "12",
        "weekly_discount_type": "percent",
        "monthly_discount": "18",
        "monthly_discount_type": "percent",
        "item_type_id": "2",
        "features_id": "[4,5,6]",
        "place_id": "ChIJIQBpAG2ahYAR_6128GcTUEo",
        "booking_policies_id": 2,
        "item_type": "Electric",
        "front_image": {
          "id": 2,
          "model_type": "Item",
          "model_id": "102",
          "uuid": "def456",
          "collection_name": "front_image",
          "name": "tesla-front",
          "file_name": "tesla-front.jpg",
          "mime_type": "image/jpeg",
          "disk": "public",
          "conversions_disk": "public",
          "size": "600000",
          "order_column": "1",
          "created_at": "2024-01-01T00:00:00.000Z",
          "updated_at": "2024-01-01T00:00:00.000Z",
          "url": "https://example.com/host-tesla-front.jpg",
          "thumbnail": "https://example.com/host-tesla-front-thumb.jpg",
          "preview": "https://example.com/host-tesla-front-preview.jpg",
          "original_url": "https://example.com/host-tesla-front-original.jpg",
          "preview_url": "https://example.com/host-tesla-front-preview.jpg"
        },
        "front_image_doc": null,
        "gallery": [
          {
            "id": 2,
            "model_type": "Item",
            "model_id": "102",
            "uuid": "gallery2",
            "collection_name": "gallery",
            "name": "tesla-gallery-1",
            "file_name": "tesla-gallery-1.jpg",
            "mime_type": "image/jpeg",
            "disk": "public",
            "conversions_disk": "public",
            "size": "450000",
            "order_column": "1",
            "created_at": "2024-01-01T00:00:00.000Z",
            "updated_at": "2024-01-01T00:00:00.000Z",
            "url": "https://example.com/host-tesla-gallery-1.jpg",
            "thumbnail": "https://example.com/host-tesla-gallery-1-thumb.jpg",
            "preview": "https://example.com/host-tesla-gallery-1-preview.jpg",
            "original_url": "https://example.com/host-tesla-gallery-1-original.jpg",
            "preview_url": "https://example.com/host-tesla-gallery-1-preview.jpg"
          }
        ],
        "available_dates": null,
        "not_available_dates": null,
        "booked_dates": null,
        "item_info": "{\"host_id\":\"1\",\"service_type\":\"booking\",\"review_data\":[],\"features_data\":[],\"gallery_image_urls\":[]}",
        "metaData": "{}"
      }
    ]
  }
}
```

> ⚠️ **NOTE Node.js**: ce contrat doit rester cohérent avec `MyItemsModel` (liste de `items`, champs `offset`, `checkLimit`, `host_status` avec underscore, `limit`). Chaque `item` doit contenir TOUS les champs requis par `Items.fromJson()`, notamment `front_image` (objet `FrontImage` complet), `gallery` (liste d'objets `Gallery`), `item_info` (JSON string), et tous les autres champs pour éviter les erreurs "Null check operator".  

---

### Endpoint: insert-item

**Method:** POST

**Request Body (What Flutter sends):**

```json
{
  "item_type_id": "1",
  "features_id": "[1,2,3]",
  "place_id": "ChIJE9on3F3HwoAR9AhGJW_fL-I",
  "title": "Toyota Camry 2023",
  "description": "Clean and comfortable sedan.",
  "price": "50.00",
  "address": "123 Main Street",
  "weekly_discount": "10",
  "weekly_discount_type": "percent",
  "monthly_discount": "15",
  "monthly_discount_type": "percent",
  "zip_postal_code": "90001",
  "country": "USA",
  "state_region": "California",
  "city_name": "Los Angeles",
  "booking_policies_id": "1",
  "platitude": "34.0522",
  "plongitude": "-118.2437",
  "metaData": {}
}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Vehicle saved successfully",
  "error": "",
  "data": {
    "insertItemHost": {
      "id": 1001,
      "title": "Toyota Camry 2023",
      "price": "50.00",
      "item_type_id": "1"
    }
  }
}
```

> ⚠️ **NOTE Node.js**: l’ID retourné dans `data.insertItemHost.id` est utilisé côté Flutter comme `itemHostId` pour les étapes suivantes (upload images, calendrier, etc.).  

---

### Endpoint: get-all-categories (Host Vehicle Types)

**Method:** GET / POST

**Request Body (What Flutter sends):**

```json
{}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Vehicle types retrieved successfully",
  "error": "",
  "data": {
    "itemTypes": [
      { "id": 1, "name": "SUV", "description": "SUV vehicles", "status": "1" },
      { "id": 2, "name": "Sedan", "description": "Sedan vehicles", "status": "1" },
      { "id": 3, "name": "Hatchback", "description": "Hatchback vehicles", "status": "1" }
    ]
  }
}
```

> ⚠️ **NOTE Node.js**: ce contrat est partagé avec d’autres écrans (Home & Search). Garder la même structure pour `itemTypes`.  

---

### Endpoint: get-makes-model (Host Makes & Models - All Types)

**Method:** GET

**Request Parameters (What Flutter sends):**

```json
{}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Makes and models retrieved successfully",
  "error": "",
  "data": {
    "makes": [
      {
        "id": 1,
        "name": "Toyota",
        "description": "Toyota vehicles",
        "status": "1",
        "models": [
          { "id": 11, "name": "Camry", "description": "", "status": "1" },
          { "id": 12, "name": "Corolla", "description": "", "status": "1" }
        ]
      },
      {
        "id": 2,
        "name": "BMW",
        "description": "BMW vehicles",
        "status": "1",
        "models": [
          { "id": 21, "name": "X5", "description": "", "status": "1" },
          { "id": 22, "name": "3 Series", "description": "", "status": "1" }
        ]
      }
    ]
  }
}
```

> ⚠️ **NOTE Node.js**: ce contrat est aligné sur `GetMakeModel` (`data.makes[]` + `models[]`).  

---

### Endpoint: get-makes-model (Host Makes & Models - Filtered by type_id)

**Method:** GET

**Request Parameters (What Flutter sends):**

```json
{
  "type_id": "1"
}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Makes and models retrieved successfully",
  "error": "",
  "data": {
    "makes": [
      {
        "id": 1,
        "name": "Toyota",
        "description": "Toyota vehicles",
        "status": "1",
        "models": [
          { "id": 11, "name": "Camry", "description": "", "status": "1" },
          { "id": 12, "name": "Corolla", "description": "", "status": "1" }
        ]
      }
    ]
  }
}
```

> ⚠️ **NOTE Node.js**: quand `type_id` est envoyé, ne retourner que les marques compatibles avec ce type. Flutter utilise cette réponse pour filtrer `Make` et `Model` en fonction du `Vehicle Type` sélectionné.  

---

### Endpoint: your-locations (Host Regions)

**Method:** GET

**Request Parameters (What Flutter sends):**

```json
{}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Locations retrieved successfully",
  "error": "",
  "data": {
    "Locations": [
      {
        "id": 1,
        "city_name": "Rabat",
        "description": "Rabat, Morocco",
        "latitude": "34.020882",
        "longitude": "-6.841650",
        "country_code": "MA",
        "image": "https://example.com/locations/rabat.jpg"
      },
      {
        "id": 2,
        "city_name": "Casablanca",
        "description": "Casablanca, Morocco",
        "latitude": "33.573110",
        "longitude": "-7.589843",
        "country_code": "MA",
        "image": "https://example.com/locations/casablanca.jpg"
      },
      {
        "id": 3,
        "city_name": "Marrakesh",
        "description": "Marrakesh, Morocco",
        "latitude": "31.629473",
        "longitude": "-7.981084",
        "country_code": "MA",
        "image": "https://example.com/locations/marrakesh.jpg"
      },
      {
        "id": 4,
        "city_name": "Los Angeles",
        "description": "Los Angeles, California, USA",
        "latitude": "34.0522",
        "longitude": "-118.2437",
        "country_code": "US",
        "image": "https://example.com/locations/la.jpg"
      },
      {
        "id": 5,
        "city_name": "San Francisco",
        "description": "San Francisco, California, USA",
        "latitude": "37.7749",
        "longitude": "-122.4194",
        "country_code": "US",
        "image": "https://example.com/locations/sf.jpg"
      }
    ]
  }
}
```

> ⚠️ **NOTE Node.js**: ce contrat est aligné sur `LocationsHostModel` (`data.Locations[]` avec **L majuscule**). Le modèle Dart cherche `json['Locations']` (pas `locations`). Champs requis : `id`, `city_name`, `description`, `latitude`, `longitude`, `country_code`, `image`. Flutter affiche `city_name` dans le dropdown **Region** et utilise `latitude` / `longitude` pour positionner la carte.  

---

### Endpoint: get-cancellation-policies (Host Cancellation Policies)

**Method:** GET

**Request Parameters (What Flutter sends):**

```json
{}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Cancellation policies retrieved successfully",
  "error": "",
  "data": {
    "cancellation_policies": [
      {
        "id": 1,
        "name": "Normal Policy",
        "description": "Standard cancellation policy with moderate refund terms",
        "type": "normal",
        "value": "50",
        "status": "1",
        "created_at": "2024-01-01T00:00:00.000Z",
        "updated_at": "2024-01-01T00:00:00.000Z"
      },
      {
        "id": 2,
        "name": "Super Policy",
        "description": "Premium cancellation policy with flexible refund terms",
        "type": "super",
        "value": "80",
        "status": "1",
        "created_at": "2024-01-01T00:00:00.000Z",
        "updated_at": "2024-01-01T00:00:00.000Z"
      },
      {
        "id": 3,
        "name": "Flexible Policy",
        "description": "Most flexible cancellation policy with full refund options",
        "type": "flexible",
        "value": "100",
        "status": "1",
        "created_at": "2024-01-01T00:00:00.000Z",
        "updated_at": "2024-01-01T00:00:00.000Z"
      }
    ]
  }
}
```

> ⚠️ **NOTE Node.js**: ce contrat est aligné sur `CancellationPoliciesModel` (`data.cancellation_policies[]`). Champs requis : `id`, `name`, `description`, `type`, `value`, `status`, `created_at`, `updated_at`. Flutter affiche ces politiques dans la section "Cancellation Policies" avec un bouton "View" pour chaque politique.  

---

### Endpoint: get-item-rules (Host Booking Rules)

**Method:** GET

**Request Parameters (What Flutter sends):**

```json
{}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Item rules retrieved successfully",
  "error": "",
  "data": {
    "booking_rules": [
      {
        "id": 1,
        "rule_name": "It is forbidden to lend, rent, or sublease the car to a third party.",
        "status": "1",
        "created_at": "2024-01-01T00:00:00.000Z",
        "updated_at": "2024-01-01T00:00:00.000Z"
      },
      {
        "id": 2,
        "rule_name": "The vehicle must be returned with the same fuel level as at pickup.",
        "status": "1",
        "created_at": "2024-01-01T00:00:00.000Z",
        "updated_at": "2024-01-01T00:00:00.000Z"
      },
      {
        "id": 3,
        "rule_name": "Smoking and eating inside the car are not allowed.",
        "status": "1",
        "created_at": "2024-01-01T00:00:00.000Z",
        "updated_at": "2024-01-01T00:00:00.000Z"
      },
      {
        "id": 4,
        "rule_name": "The vehicle must be returned on the agreed date, time, and location.",
        "status": "1",
        "created_at": "2024-01-01T00:00:00.000Z",
        "updated_at": "2024-01-01T00:00:00.000Z"
      }
    ]
  }
}
```

> ⚠️ **NOTE Node.js**: ce contrat est aligné sur `AddRulesModel` (`data.booking_rules[]`). Champs requis : `id`, `rule_name` (⚠️ **pas `name`**), `status`, `created_at`, `updated_at`. Flutter affiche ces règles dans la section "Adding Rules" avec des checkboxes pour sélection multiple.  

---

### Endpoint: amenities (Host Vehicle Amenities)

**Method:** GET

**Request Parameters (What Flutter sends):**

```json
{}
```

**Expected Response (What Node.js MUST return):**

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
      },
      {
        "id": 3,
        "name": "Air conditioning",
        "image": "https://example.com/amenities/ac.png"
      },
      {
        "id": 4,
        "name": "Bluetooth",
        "image": "https://example.com/amenities/bluetooth.png"
      },
      {
        "id": 5,
        "name": "Parking sensors",
        "image": "https://example.com/amenities/parking-sensors.png"
      },
      {
        "id": 6,
        "name": "USB Port",
        "image": "https://example.com/amenities/usb.png"
      },
      {
        "id": 7,
        "name": "Backup Camera",
        "image": "https://example.com/amenities/camera.png"
      },
      {
        "id": 8,
        "name": "Sunroof",
        "image": "https://example.com/amenities/sunroof.png"
      }
    ]
  }
}
```

> ⚠️ **NOTE Node.js**: ce contrat est aligné sur `AmenitiesModel` (`data.amenities[]` avec `id`, `name`, `image`). Flutter affiche ces amenities dans la liste "Do you offer any standout amenities?" et permet la sélection multiple via checkboxes.  

---

### Endpoint: edit-item

**Method:** POST

**Request Body (What Flutter sends):**

```json
{
  "id": "1001",
  "item_type_id": "1",
  "features_id": "[1,2,3]",
  "place_id": "ChIJE9on3F3HwoAR9AhGJW_fL-I",
  "title": "Toyota Camry 2023 - Updated",
  "description": "Updated description.",
  "price": "55.00",
  "address": "123 Main Street",
  "platitude": "34.0522",
  "plongitude": "-118.2437",
  "weekly_discount": "10",
  "weekly_discount_type": "percent",
  "monthly_discount": "15",
  "monthly_discount_type": "percent",
  "zip_postal_code": "90001",
  "country": "USA",
  "state_region": "California",
  "city_name": "Los Angeles",
  "booking_policies_id": "1",
  "metaData": {}
}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Vehicle saved successfully",
  "error": "",
  "data": {
    "editItemHost": {
      "id": 1001,
      "title": "Toyota Camry 2023 - Updated",
      "price": "55.00",
      "item_type_id": "1"
    }
  }
}
```

> ⚠️ **NOTE Node.js**: pour l’édition, Flutter se base surtout sur `status` / `message`. Le bloc `data.editItemHost` permet d’avoir une confirmation côté backend mais peut être enrichi si besoin.  

---

### Endpoint: add-update-item-image

**Method:** POST

**Request Body (What Flutter sends):**

```json
{
  "id": "1001",
  "front_image": "base64-front-image",
  "front_image_doc": "base64-doc-image",
  "gallery_image": "base64img1##base64img2##base64img3",
  "gallery_image_delete": "[5,6]"
}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Images saved successfully",
  "error": "",
  "data": {
    "id": "1001",
    "front_image_uploaded": true,
    "documents_image_uploaded": true,
    "gallery_image_count": 3
  }
}
```

> ⚠️ **NOTE Node.js**: dans l’app actuelle, on ne consomme que `status` / `message`, mais retourner ces champs dans `data` est utile pour le débogage et de futures évolutions (compter les images, etc.).  

---

### Endpoint: deleteItem

**Method:** POST

**Request Body (What Flutter sends):**

```json
{
  "id": "1001"
}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Vehicle deleted successfully",
  "error": "",
  "data": {
    "id": "1001",
    "deleted": true
  }
}
```

> ⚠️ **NOTE Node.js**: l’UI se base sur `status` / `message` pour afficher le succès et recharger la liste (`onRefresh`). Le champ `data.deleted` peut être utilisé pour du logging côté backend.  

---

## Feature: BOOKING MANAGEMENT - Update Item Returned Status

### Endpoint: update-item-returned-status

**Method:** POST

**Request Body (What Flutter sends):**

```json
{
  "booking_id": "1234567890",
  "is_item_returned": "1",
  "drop_otp": "5678"
}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Item returned status updated successfully",
  "error": "",
  "data": {
    "booking_extension": {
      "booking_id": "1234567890",
      "is_item_returned": "1",
      "drop_otp": "5678",
      "is_item_delivered": "1",
      "is_item_received": "1"
    }
  }
}
```

> ⚠️ **NOTE Node.js**: le code Flutter lit `data.booking_extension.is_item_returned` (string `"1"` / `"0"`) pour savoir si l’item est bien retourné. Garder cette structure, et conserver les flags `is_item_delivered` / `is_item_received` pour rester cohérent avec les autres flows.  

---

## Feature: BOOKING MANAGEMENT - Digital Signature

### Endpoint: get-digital-signature

**Method:** GET

**Request Parameters (What Flutter sends):**

```json
{
  "booking_id": "1234567890"
}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "success": 200,
  "message": "Digital signature data retrieved successfully",
  "data": {
    "booking_id": "1234567890",
    "user_signed": 1,
    "vendor_signed": 1,
    "user_signature_url": {
      "url": "https://example.com/signatures/user_signature.png",
      "thumb": "https://example.com/signatures/user_signature_thumb.png",
      "preview": "https://example.com/signatures/user_signature_preview.png"
    },
    "vendor_signature_url": {
      "url": "https://example.com/signatures/vendor_signature.png",
      "thumb": "https://example.com/signatures/vendor_signature_thumb.png",
      "preview": "https://example.com/signatures/vendor_signature_preview.png"
    }
  }
}
```

> ⚠️ **NOTE Node.js**: ce contrat est aligné sur `SignatureDataResponse` :  
> - `success` (int), `message` (string)  
> - `data.booking_id` (string), `data.user_signed` / `data.vendor_signed` (int 0/1)  
> - `data.user_signature_url` et `data.vendor_signature_url` sont des objets avec `url`, `thumb`, `preview` (tous string, jamais null).  

---

## Feature: BOOKING MANAGEMENT - Update Item Delivered Status

### Endpoint: update-item-delivered-status

**Method:** POST

**Request Body (What Flutter sends):**

```json
{
  "booking_id": "1234567890",
  "is_item_delivered": "1"
}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Item delivered status updated successfully",
  "error": "",
  "data": {
    "booking_extension": {
      "booking_id": "1234567890",
      "is_item_delivered": "1",
      "is_item_received": "1",
      "is_item_returned": "0"
    }
  }
}
```

> ⚠️ **NOTE Node.js**: le code Flutter lit `data.booking_extension.is_item_delivered` (string `"1"` / `"0"`) pour l’état de livraison. Garder la même structure que pour `update-item-received-status` et `update-item-returned-status` afin d’avoir un flow cohérent.  

---



## Feature: BOOKING MANAGEMENT - Update Item Received Status

### Endpoint: update-item-received-status

**Method:** POST

**Request Body (What Flutter sends):**

```json
{
  "booking_id": "1234567890",
  "is_item_received": "1",
  "pick_otp": "1234"
}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Item received status updated successfully",
  "error": "",
  "data": {
    "booking_extension": {
      "booking_id": "1234567890",
      "is_item_received": "1",
      "pick_otp": "1234",
      "is_item_delivered": "1",
      "is_item_returned": "0"
    }
  }
}
```

> ⚠️ **NOTE Node.js**: le code Flutter lit `data.booking_extension.is_item_received` (string `"1"` / `"0"`) pour décider si l’étape suivante (return) doit être affichée. Garder cette structure et ces types.  

---

## Feature: HOST CALENDAR - Item Dates

### Endpoint: get-item-dates

**Method:** GET

**Request Parameters (What Flutter sends):**

```json
{
  "item_id": "101"
}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Item dates retrieved successfully",
  "error": "",
  "data": {
    "ItemDates": {
      "price": "50.00",
      "available_dates": [
        { "date": "2024-12-18", "price": "50.00" },
        { "date": "2024-12-19", "price": "50.00" },
        { "date": "2024-12-23", "price": "55.00" }
      ],
      "not_available_dates": [
        { "date": "2024-12-20", "price": "0.00" },
        { "date": "2024-12-21", "price": "0.00" }
      ],
      "booked_dates": [
        { "date": "2024-12-25", "price": "60.00" },
        { "date": "2024-12-26", "price": "60.00" }
      ]
    }
  }
}
```

> ⚠️ **NOTE Node.js**: ce contrat doit rester cohérent avec `CalendarItemId` :  
> - `data.ItemDates.price` (string)  
> - `data.ItemDates.available_dates[]` avec `date` (YYYY-MM-DD) et `price`  
> - `data.ItemDates.not_available_dates[]` idem  
> - `data.ItemDates.booked_dates[]` idem.  

---

## Feature: PAYMENTS & WALLET

### Endpoint: get-user-wallet

**Method:** POST

**Request Body (What Flutter sends):**

```json
{
}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Wallet data retrieved successfully",
  "error": "",
  "data": {
    "wallet_balance": "150.00"
  }
}
```

> ⚠️ **NOTE Node.js**: ce contrat doit rester cohérent avec le modèle Dart `WalletModel` (`data.wallet_balance` string, ex. `"0.00"`).  

---

## Feature: BOOKING PROCESS - Item Booking Dates

### Endpoint: itemBookingDate

**Method:** POST

**Request Body (What Flutter sends):**

```json
{
  "id": "101"
}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Item booking dates retrieved successfully",
  "error": "",
  "data": {
    "itemBookingDate": [
      {
        "check_in": "2024-12-20",
        "check_out": "2024-12-22"
      },
      {
        "check_in": "2024-12-28",
        "check_out": "2025-01-02"
      }
    ]
  }
}
```

> ⚠️ **NOTE Node.js**: ce contrat doit rester cohérent avec le modèle Dart `BookdDate` (`Data.itemBookingDate[]` avec `check_in` / `check_out` en string format `YYYY-MM-DD`).  

---

## Feature: BOOKING PROCESS - Booking Payment Success

### Endpoint: booking-payment-success

**Method:** POST

**Request Body (What Flutter sends):**

```json
{
  "booking_id": "1234567890"
}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Payment verified successfully",
  "error": "",
  "data": {
    "booking_id": "1234567890",
    "payment_status": "success",
    "booking_status": "confirmed"
  }
}
```

> ⚠️ **NOTE Node.js**: même si aujourd’hui le code Flutter ne lit que la non-nullité de la réponse, il est recommandé de renvoyer `payment_status` et `booking_status` (`success` / `failed`, `confirmed` / `pending` / `cancelled`) pour pouvoir faire évoluer facilement l’UI plus tard.  

---

## Feature: BOOKING MANAGEMENT - Upload Per Booking Images (Interior Photos)

### Endpoint: upload-per-booking-images

**Method:** POST

**Request Body (What Flutter sends):**

```json
{
  "booking_id": "1234567890",
  "per_booking_images": "base64image1##base64image2##base64image3"
}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "success": 200,
  "message": "Images uploaded successfully",
  "error": "",
  "data": {
    "booking_id": "1234567890",
    "uploaded_images_count": 3
  }
}
```

> ⚠️ **NOTE Node.js**: le code Flutter contrôle simplement `response['success'] == 200` et affiche `response['message']`. Le champ `per_booking_images` est une chaîne contenant plusieurs images encodées en base64, séparées par `"##"`. Le backend Node.js pourra si besoin stocker les URLs réelles en base de données, mais il doit au minimum respecter ce format de réponse.  

---



## Feature: HOME & NAVIGATION

### Endpoint: get-makes

**Method:** POST

**Request Body (What Flutter sends):**

```json
{}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Makes retrieved successfully",
  "error": "",
  "data": {
    "makes": [
      {
        "id": 1,
        "name": "Toyota",
        "description": "Toyota vehicles",
        "status": "1",
        "created_at": "2024-01-01 10:00:00",
        "updated_at": "2024-01-01 10:00:00",
        "deleted_at": "",
        "image": "https://example.com/toyota.png",
        "imageURL": "https://example.com/toyota.png",
        "media": []
      },
      {
        "id": 2,
        "name": "Honda",
        "description": "Honda vehicles",
        "status": "1",
        "created_at": "2024-01-01 10:00:00",
        "updated_at": "2024-01-01 10:00:00",
        "deleted_at": "",
        "image": "https://example.com/toyota.png",
        "imageURL": "https://example.com/honda.png",
        "media": []
      },
      {
        "id": 3,
        "name": "BMW",
        "description": "BMW vehicles",
        "status": "1",
        "created_at": "2024-01-01 10:00:00",
        "updated_at": "2024-01-01 10:00:00",
        "deleted_at": "",
        "image": "https://example.com/toyota.png",
        "imageURL": "https://example.com/bmw.png",
        "media": []
      }
    ]
  }
}
```

---

### Endpoint: get-all-categories

**Method:** POST / GET

**Request Body (What Flutter sends):**

```json
{}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Categories retrieved successfully",
  "error": "",
  "data": {
    "itemTypes": [
      {
        "id": 1,
        "name": "Sedan",
        "description": "Sedan vehicles",
        "status": "1",
        "image": "https://example.com/sedan.png"
      },
      {
        "id": 2,
        "name": "SUV",
        "description": "SUV vehicles",
        "status": "1",
        "image": "https://example.com/suv.png"
      },
      {
        "id": 3,
        "name": "Hatchback",
        "description": "Hatchback vehicles",
        "status": "1",
        "image": "https://example.com/hatchback.png"
      },
      {
        "id": 4,
        "name": "Coupe",
        "description": "Coupe vehicles",
        "status": "1",
        "image": "https://example.com/coupe.png"
      }
    ]
  }
}
```

---

### Endpoint: nearbyItems

**Method:** POST

**Request Body (What Flutter sends):**

```json
{
  "offset": "0",
  "item_type": "1"
}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Nearby items retrieved successfully",
  "error": "",
  "data": {
    "items": [
      {
        "id": 101,
        "name": "Toyota Camry 2023",
        "item_rating": "4.5",
        "mobile": "+1234567890",
        "person_allowed": "5",
        "address": "123 Main Street",
        "state_region": "California",
        "city": "Los Angeles",
        "zip_postal_code": "90001",
        "price": "50.00",
        "latitude": "34.0522",
        "longitude": "-118.2437",
        "status": "1",
        "item_type_id": "1",
        "image": "https://example.com/camry.jpg",
        "item_info": "{}",
        "is_in_wishlist": false,
        "item_type": "Sedan",
        "distance": "2.5"
      },
      {
        "id": 102,
        "name": "Honda CR-V 2023",
        "item_rating": "4.7",
        "mobile": "+1234567891",
        "person_allowed": "7",
        "address": "456 Oak Avenue",
        "state_region": "California",
        "city": "San Francisco",
        "zip_postal_code": "94102",
        "price": "65.00",
        "latitude": "37.7749",
        "longitude": "-122.4194",
        "status": "1",
        "item_type_id": "2",
        "image": "https://example.com/crv.jpg",
        "item_info": "{}",
        "is_in_wishlist": false,
        "item_type": "SUV",
        "distance": "5.2"
      }
    ],
    "offset": 0
  }
}
```

---

### Endpoint: getCurrencyDetails

**Method:** POST

**Request Body (What Flutter sends):**

```json
{}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "currency_name": "US Dollar",
      "currency_code": "USD",
      "value_against_default_currency": "1.00",
      "currency_symbol": "$"
    },
    {
      "id": 2,
      "currency_name": "Euro",
      "currency_code": "EUR",
      "value_against_default_currency": "0.92",
      "currency_symbol": "€"
    },
    {
      "id": 3,
      "currency_name": "British Pound",
      "currency_code": "GBP",
      "value_against_default_currency": "0.79",
      "currency_symbol": "£"
    }
  ]
}
```

---

### Endpoint: home-data

**Method:** GET

**Request Body (What Flutter sends):**

```json
{}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Home data retrieved successfully",
  "error": "",
  "data": {
    "itemTypes": [
      {
        "id": 1,
        "name": "Sedan",
        "description": "Sedan vehicles",
        "status": "1",
        "image": "https://example.com/sedan.png"
      },
      {
        "id": 2,
        "name": "SUV",
        "description": "SUV vehicles",
        "status": "1",
        "image": "https://example.com/suv.png"
      }
    ],
    "nearby_items": [
      {
        "id": 101,
        "name": "Toyota Camry 2023",
        "item_rating": "4.5",
        "mobile": "+1234567890",
        "person_allowed": "5",
        "address": "123 Main Street",
        "state_region": "California",
        "city": "Los Angeles",
        "zip_postal_code": "90001",
        "price": "50.00",
        "latitude": "34.0522",
        "longitude": "-118.2437",
        "status": "1",
        "item_type_id": "1",
        "image": "https://example.com/camry.jpg",
        "item_info": "{}",
        "is_in_wishlist": false,
        "item_type": "Sedan",
        "distance": "2.5"
      }
    ],
    "featured_items": [
      {
        "id": 201,
        "name": "BMW 3 Series 2023",
        "item_rating": "4.8",
        "mobile": "+1234567892",
        "person_allowed": "5",
        "address": "789 Luxury Lane",
        "state_region": "California",
        "city": "Beverly Hills",
        "zip_postal_code": "90210",
        "price": "120.00",
        "latitude": "34.0736",
        "longitude": "-118.4004",
        "status": "1",
        "item_type_id": "1",
        "image": "https://example.com/bmw3.jpg",
        "item_info": "{}",
        "is_in_wishlist": false,
        "item_type": "Sedan",
        "distance": "10.3"
      }
    ],
    "most_viewed_items": [
      {
        "id": 301,
        "name": "Tesla Model 3",
        "item_rating": "4.9",
        "mobile": "+1234567893",
        "person_allowed": "5",
        "address": "321 Electric Avenue",
        "state_region": "California",
        "city": "Palo Alto",
        "zip_postal_code": "94301",
        "price": "150.00",
        "latitude": "37.4419",
        "longitude": "-122.1430",
        "status": "1",
        "item_type_id": "1",
        "image": "https://example.com/tesla.jpg",
        "item_info": "{}",
        "is_in_wishlist": false,
        "item_type": "Sedan",
        "distance": "25.7"
      }
    ],
    "new_arrival_items": [
      {
        "id": 401,
        "name": "Mercedes-Benz C-Class 2024",
        "item_rating": "4.7",
        "mobile": "+1234567894",
        "person_allowed": "5",
        "address": "555 Premium Drive",
        "state_region": "California",
        "city": "Santa Monica",
        "zip_postal_code": "90401",
        "price": "130.00",
        "latitude": "34.0195",
        "longitude": "-118.4912",
        "status": "1",
        "item_type_id": "1",
        "image": "https://example.com/mercedes.jpg",
        "item_info": "{}",
        "is_in_wishlist": false,
        "item_type": "Sedan",
        "distance": "15.2"
      }
    ],
    "locations": [
      {
        "id": 1,
        "city_name": "Los Angeles",
        "description": "Los Angeles, California",
        "image": "https://example.com/la.jpg",
        "latitude": "34.0522",
        "longitude": "-118.2437"
      },
      {
        "id": 2,
        "city_name": "San Francisco",
        "description": "San Francisco, California",
        "image": "https://example.com/sf.jpg",
        "latitude": "37.7749",
        "longitude": "-122.4194"
      }
    ],
    "makes": [
      {
        "id": 1,
        "name": "Toyota",
        "description": "Toyota vehicles",
        "status": "1",
        "created_at": "2024-01-01 10:00:00",
        "updated_at": "2024-01-01 10:00:00",
        "deleted_at": "",
        "image": "https://example.com/toyota.png",
        "imageURL": "https://example.com/toyota.png",
        "media": []
      }
    ]
  }
}
```

---

### Endpoint: featuredItems

**Method:** POST

**Request Body (What Flutter sends):**

```json
{
  "offset": "0"
}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Featured items retrieved successfully",
  "error": "",
  "data": {
    "items": [
      {
        "id": 201,
        "name": "BMW 3 Series 2023",
        "item_rating": "4.8",
        "mobile": "+1234567892",
        "person_allowed": "5",
        "address": "789 Luxury Lane",
        "state_region": "California",
        "city": "Beverly Hills",
        "zip_postal_code": "90210",
        "price": "120.00",
        "latitude": "34.0736",
        "longitude": "-118.4004",
        "status": "1",
        "item_type_id": "1",
        "image": "https://example.com/bmw3.jpg",
        "item_info": "{}",
        "is_in_wishlist": false,
        "item_type": "Sedan",
        "distance": "0"
      }
    ],
    "offset": 0
  }
}
```

---

### Endpoint: get-user-items

**Method:** GET

**Request Body (What Flutter sends):**

```json
{
  "userid": "123",
  "offset": "0"
}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "User items retrieved successfully",
  "error": "",
  "data": {
    "items": [
      {
        "id": 501,
        "name": "User Vehicle 1",
        "item_rating": "4.6",
        "mobile": "+1234567895",
        "person_allowed": "5",
        "address": "100 User Street",
        "state_region": "California",
        "city": "San Diego",
        "zip_postal_code": "92101",
        "price": "75.00",
        "latitude": "32.7157",
        "longitude": "-117.1611",
        "status": "1",
        "item_type_id": "1",
        "image": "https://example.com/user1.jpg",
        "item_info": "{}",
        "is_in_wishlist": false,
        "item_type": "Sedan",
        "distance": "0"
      }
    ],
    "offset": 0
  }
}
```

---

### Endpoint: getItemsByLocation

**Method:** POST

**Request Body (What Flutter sends):**

```json
{
  "location_id": "1",
  "offset": "0"
}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Location items retrieved successfully",
  "error": "",
  "data": {
    "items": [
      {
        "id": 601,
        "name": "Location Vehicle 1",
        "item_rating": "4.4",
        "mobile": "+1234567896",
        "person_allowed": "5",
        "address": "200 Location Blvd",
        "state_region": "California",
        "city": "Sacramento",
        "zip_postal_code": "95814",
        "price": "60.00",
        "latitude": "38.5816",
        "longitude": "-121.4944",
        "status": "1",
        "item_type_id": "2",
        "image": "https://example.com/location1.jpg",
        "item_info": "{}",
        "is_in_wishlist": false,
        "item_type": "SUV",
        "distance": "0"
      }
    ],
    "offset": 0
  }
}
```

---

---

## Feature: SEARCH & FILTERING

### Endpoint: amenities

**Method:** GET

**Request Body (What Flutter sends):**

```json
{}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Amenities retrieved successfully",
  "error": "",
  "data": {
    "amenities": [
      {
        "id": 1,
        "name": "GPS Navigation",
        "image": "https://example.com/gps.png"
      },
      {
        "id": 2,
        "name": "Bluetooth",
        "image": "https://example.com/bluetooth.png"
      },
      {
        "id": 3,
        "name": "USB Port",
        "image": "https://example.com/usb.png"
      },
      {
        "id": 4,
        "name": "Air Conditioning",
        "image": "https://example.com/ac.png"
      },
      {
        "id": 5,
        "name": "Backup Camera",
        "image": "https://example.com/camera.png"
      },
      {
        "id": 6,
        "name": "Sunroof",
        "image": "https://example.com/sunroof.png"
      }
    ]
  }
}
```

---

### Endpoint: vechile-odometer

**Method:** GET

**Request Body (What Flutter sends):**

```json
{}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Odometer ranges retrieved successfully",
  "error": "",
  "data": {
    "getodometer": [
      {"id": 1, "odometer": "0-10000"},
      {"id": 2, "odometer": "10000-25000"},
      {"id": 3, "odometer": "25000-50000"},
      {"id": 4, "odometer": "50000-75000"},
      {"id": 5, "odometer": "75000-100000"},
      {"id": 6, "odometer": "100000+"}
    ]
  }
}
```

---

### Endpoint: get-vehicle-fuel-types

**Method:** GET

**Request Body (What Flutter sends):**

```json
{}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Fuel types retrieved successfully",
  "error": "",
  "data": {
    "fuel_types": [
      {"id": 1, "fuel_type": "Gasoline"},
      {"id": 2, "fuel_type": "Diesel"},
      {"id": 3, "fuel_type": "Electric"},
      {"id": 4, "fuel_type": "Hybrid"},
      {"id": 5, "fuel_type": "Plug-in Hybrid"}
    ]
  }
}
```

---

### Endpoint: odometer-manual

**Method:** GET

**Request Body (What Flutter sends):**

```json
{}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Transmissions retrieved successfully",
  "error": "",
  "data": {
    "options": [
      {"option": "manual"},
      {"option": "automatic"}
    ]
  }
}
```

---

### Endpoint: get-makes (with type_id filter)

**Method:** GET

**Request Body (What Flutter sends):**

```json
{
  "type_id": "0"
}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Makes retrieved successfully",
  "error": "",
  "data": {
    "makes": [
      {
        "id": 1,
        "name": "Toyota",
        "description": "Toyota vehicles",
        "status": "1",
        "created_at": "2024-01-01 10:00:00",
        "updated_at": "2024-01-01 10:00:00",
        "deleted_at": "",
        "image": "https://example.com/toyota.png",
        "imageURL": "https://example.com/toyota.png",
        "media": []
      },
      {
        "id": 2,
        "name": "Honda",
        "description": "Honda vehicles",
        "status": "1",
        "created_at": "2024-01-01 10:00:00",
        "updated_at": "2024-01-01 10:00:00",
        "deleted_at": "",
        "image": "https://example.com/toyota.png",
        "imageURL": "https://example.com/honda.png",
        "media": []
      },
      {
        "id": 3,
        "name": "BMW",
        "description": "BMW vehicles",
        "status": "1",
        "created_at": "2024-01-01 10:00:00",
        "updated_at": "2024-01-01 10:00:00",
        "deleted_at": "",
        "image": "https://example.com/toyota.png",
        "imageURL": "https://example.com/bmw.png",
        "media": []
      },
      {
        "id": 4,
        "name": "Mercedes-Benz",
        "description": "Mercedes-Benz vehicles",
        "status": "1",
        "created_at": "2024-01-01 10:00:00",
        "updated_at": "2024-01-01 10:00:00",
        "deleted_at": "",
        "image": "https://example.com/toyota.png",
        "imageURL": "https://example.com/mercedes.png",
        "media": []
      },
      {
        "id": 5,
        "name": "Tesla",
        "description": "Tesla vehicles",
        "status": "1",
        "created_at": "2024-01-01 10:00:00",
        "updated_at": "2024-01-01 10:00:00",
        "deleted_at": "",
        "image": "https://example.com/toyota.png",
        "imageURL": "https://example.com/tesla.png",
        "media": []
      }
    ]
  }
}
```

---

### Endpoint: item-search

**Method:** POST

**Request Body (What Flutter sends):**

```json
{
  "title": "",
  "price": "0.0-1000.0",
  "facility": "[]",
  "limit": "10",
  "offset": "0",
  "Slatitude": "34.0522",
  "Slongitude": "-118.2437",
  "check_in": "2024-12-16",
  "check_out": "2024-12-18",
  "city": "Los Angeles",
  "zip_code": "",
  "country": "",
  "state": "",
  "central_Latitude": "34.0522",
  "central_longitude": "-118.2437",
  "radius": "10",
  "search_on_map": "0",
  "sort": "nearest_location",
  "meta": "{\"make_type\":\"[]\"}",
  "odometer": "[]",
  "start_time": "12:00 AM",
  "end_time": "11:59 PM",
  "modelYear": "[]",
  "fuel_type": [1, 2],
  "transmission": ["manual", "automatic"]
}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Search completed successfully",
  "error": "",
  "data": {
    "items": [
      {
        "id": 701,
        "name": "Search Result Vehicle 1",
        "item_rating": "4.6",
        "mobile": "+1234567897",
        "person_allowed": "5",
        "address": "300 Search Street",
        "state_region": "California",
        "city": "Los Angeles",
        "zip_postal_code": "90002",
        "price": "55.00",
        "latitude": "34.0522",
        "longitude": "-118.2437",
        "status": "1",
        "item_type_id": "1",
        "image": "https://example.com/search1.jpg",
        "item_info": "{}",
        "is_in_wishlist": false,
        "item_type": "Sedan",
        "distance": "3.1"
      },
      {
        "id": 702,
        "name": "Search Result Vehicle 2",
        "item_rating": "4.8",
        "mobile": "+1234567898",
        "person_allowed": "7",
        "address": "400 Filter Avenue",
        "state_region": "California",
        "city": "San Francisco",
        "zip_postal_code": "94103",
        "price": "70.00",
        "latitude": "37.7749",
        "longitude": "-122.4194",
        "status": "1",
        "item_type_id": "2",
        "image": "https://example.com/search2.jpg",
        "item_info": "{}",
        "is_in_wishlist": false,
        "item_type": "SUV",
        "distance": "6.5"
      },
      {
        "id": 703,
        "name": "Search Result Vehicle 3",
        "item_rating": "4.7",
        "mobile": "+1234567899",
        "person_allowed": "5",
        "address": "500 Query Boulevard",
        "state_region": "California",
        "city": "San Diego",
        "zip_postal_code": "92102",
        "price": "80.00",
        "latitude": "32.7157",
        "longitude": "-117.1611",
        "status": "1",
        "item_type_id": "1",
        "image": "https://example.com/search3.jpg",
        "item_info": "{}",
        "is_in_wishlist": false,
        "item_type": "Sedan",
        "distance": "9.2"
      }
    ],
    "offset": 3
  }
}
```

**Notes importantes pour item-search:**
- **`fuel_type`** est un array de nombres (IDs) : `[1, 2, 3]`
- **`transmission`** est un array de strings : `["manual", "automatic"]`
- **`sort`** peut être : `"nearest_location"`, `"highest_rated"`, ou `"cheapest_price"`
- **`search_on_map`** est `"1"` si la recherche est basée sur la carte, `"0"` sinon
- **`meta`** est un JSON stringifié contenant `{"make_type": "[]"}` ou des valeurs de marques

---

## Feature: VEHICLE DETAILS

### Endpoint: getItemDetails

**Method:** POST

**Request Body (What Flutter sends):**

```json
{
  "item_id": "101"
}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Item details retrieved successfully",
  "error": "",
  "data": {
    "ItemDetails": {
      "item_id": 101,
      "title": "Toyota Camry 2023 - Premium Sedan",
      "price": "50.00",
      "description": "Experience luxury and comfort in this premium Toyota Camry 2023. Perfect for city drives and long trips. Fully equipped with modern amenities and safety features.",
      "bedrooms": "",
      "beds": "",
      "bathroom": "",
      "item_sqft": "",
      "item_rating": "4.5",
      "mobile": "+1234567890",
      "status": "1",
      "person_allowed": "5",
      "address": "123 Main Street",
      "state_region": "California",
      "zip_postal_code": "90001",
      "latitude": "34.0522",
      "longitude": "-118.2437",
      "is_verified": "1",
      "is_featured": "1",
      "weekly_discount": "10",
      "weekly_discount_type": "percentage",
      "monthly_discount": "15",
      "monthly_discount_type": "percentage",
      "item_type": "Sedan",
      "cancellation_reason": "",
      "bed_type": "",
      "city": "Los Angeles",
      "amenities": [
        {
          "id": 1,
          "name": "GPS Navigation",
          "image_url": "https://example.com/gps.png"
        },
        {
          "id": 2,
          "name": "Bluetooth",
          "image_url": "https://example.com/bluetooth.png"
        },
        {
          "id": 3,
          "name": "USB Port",
          "image_url": "https://example.com/usb.png"
        },
        {
          "id": 4,
          "name": "Air Conditioning",
          "image_url": "https://example.com/ac.png"
        },
        {
          "id": 5,
          "name": "Backup Camera",
          "image_url": "https://example.com/camera.png"
        }
      ],
      "available_dates": [
        {
          "date": "2024-12-16",
          "price": "50.00"
        },
        {
          "date": "2024-12-17",
          "price": "50.00"
        },
        {
          "date": "2024-12-18",
          "price": "55.00"
        },
        {
          "date": "2024-12-19",
          "price": "55.00"
        },
        {
          "date": "2024-12-20",
          "price": "60.00"
        }
      ],
      "host_id": "1001",
      "host_player_id": "player_12345",
      "host_first_name": "John",
      "host_last_name": "Doe",
      "host_email": "john.doe@example.com",
      "host_phone": "+1234567890",
      "host_profile_image": "https://example.com/profile.jpg",
      "front_image_url": "https://example.com/camry-front.jpg",
      "gallery_image_urls": [
        "https://example.com/camry-1.jpg",
        "https://example.com/camry-2.jpg",
        "https://example.com/camry-3.jpg",
        "https://example.com/camry-4.jpg"
      ],
      "reviews": [
        {
          "id": 1,
          "booking_id": "2001",
          "guest_id": "3001",
          "guest_name": "Jane Smith",
          "guest_profile_image": "https://example.com/guest1.jpg",
          "rating": "5",
          "message": "Excellent vehicle! Very clean and comfortable. Highly recommend!",
          "created_at": "2024-12-01 10:00:00",
          "updated_at": "2024-12-01 10:00:00"
        },
        {
          "id": 2,
          "booking_id": "2002",
          "guest_id": "3002",
          "guest_name": "Michael Johnson",
          "guest_profile_image": "https://example.com/guest2.jpg",
          "rating": "4",
          "message": "Great car, smooth ride. Would rent again.",
          "created_at": "2024-11-28 14:30:00",
          "updated_at": "2024-11-28 14:30:00"
        },
        {
          "id": 3,
          "booking_id": "2003",
          "guest_id": "3003",
          "guest_name": "Sarah Williams",
          "guest_profile_image": "https://example.com/guest3.jpg",
          "rating": "5",
          "message": "Perfect for our family trip. The host was very responsive.",
          "created_at": "2024-11-25 09:15:00",
          "updated_at": "2024-11-25 09:15:00"
        }
      ],
      "total_reviews": 3,
      "item_data": "{}",
      "item_info": "{\"make_type\":\"Toyota\",\"model\":\"Camry\",\"year\":\"2023\",\"transmission\":\"automatic\",\"fuel_type\":\"gasoline\",\"odometer\":\"15000\",\"color\":\"White\",\"seat_capacity\":\"5\"}",
      "is_in_wishlist": false
    }
  }
}
```

**Notes importantes pour getItemDetails:**
- **`item_info`** est une chaîne JSON stringifiée contenant les détails spécifiques du véhicule (make, model, year, transmission, etc.)
- **`gallery_image_urls`** est un array de strings (URLs des images)
- **`front_image_url`** est l'image principale du véhicule
- **`available_dates`** est un array d'objets contenant les dates disponibles et leurs prix
- **`amenities`** est un array d'objets contenant les équipements disponibles
- **`reviews`** est un array d'objets contenant les avis des utilisateurs
- Les champs vides pour les propriétés non-véhicules (bedrooms, beds, bathroom, etc.) sont des chaînes vides `""`

---

## Feature: BOOKING AVAILABILITY

### Endpoint: check-booking-availability

**Method:** POST

**Request Body (What Flutter sends):**

```json
{
  "item_id": "101",
  "check_in": "2024-12-16",
  "check_out": "2024-12-18",
  "start_time": "12:00 AM",
  "end_time": "11:30 AM"
}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Booking availability checked successfully",
  "error": "",
  "data": {
    "next_start_time": "12:00 AM",
    "next_end_time": "11:30 AM",
    "availability": {
      "next_start_time": "12:00 AM",
      "next_end_time": "11:30 AM",
      "is_available": true
    },
    "bookingOverlapDetails": []
  }
}
```

**Notes importantes pour check-booking-availability:**
- **`status`** peut être `200` (disponible) ou `422` (conflit de réservation)
- **`next_start_time`** et **`next_end_time`** doivent être au format 12h (ex: "12:00 AM", "11:30 PM")
- Si `status` est `422`, le champ **`bookingOverlapDetails`** contiendra une liste des réservations en conflit
- **`is_available`** doit être un booléen (`true` ou `false`)
- **`error`** est une chaîne qui peut être vide en cas de succès

---

## Feature: BOOKING PRICING

### Endpoint: get-item-prices

**Method:** POST

**Request Body (What Flutter sends):**

```json
{
  "item_id": "101",
  "check_in": "2024-12-16",
  "check_out": "2024-12-18",
  "coupon_code": "",
  "wallet_amount": "0",
  "start_time": "12:00 AM",
  "end_time": "11:30 AM",
  "doorStep_price": "0"
}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Item prices retrieved successfully",
  "error": "",
  "data": {
    "discount_type": "",
    "prices": [
      {
        "date": "2024-12-16",
        "price": "50.00",
        "status": "Available"
      },
      {
        "date": "2024-12-17",
        "price": "50.00",
        "status": "Available"
      }
    ],
    "price_before_discount": "100.00",
    "price_per_day": "50.00",
    "total_days": "2",
    "discount_price": "0.00",
    "coupon_discount": "0.00",
    "price_after_discount": "100.00",
    "service_charge": "10.00",
    "cleaning_charge": "5.00",
    "coupon_code": "",
    "tax": "12.50",
    "wallet_amount": "0.00",
    "remaining_wallet_balance": "0.00",
    "gross_price": "127.50",
    "duration": 2,
    "security_deposit": "100.00",
    "distance": "0",
    "label": ""
  }
}
```

**Notes importantes pour get-item-prices:**
- **`prices`** est un array d'objets contenant le prix pour chaque date de la période de réservation
- **`total_days`** doit correspondre au nombre de nuits calculé entre `check_in` et `check_out`
- **`price_per_day`** est le prix par jour de base
- **`price_before_discount`** = `price_per_day * total_days`
- **`gross_price`** = `price_after_discount + service_charge + cleaning_charge + tax`
- **`coupon_code`** sera une chaîne vide si aucun coupon n'est appliqué
- **`wallet_amount`** correspond au montant utilisé depuis le portefeuille
- **`discount_price`**, **`coupon_discount`** peuvent être "0.00" si aucun rabais n'est appliqué
- **`duration`** doit être un nombre entier (nombre de jours)
- **`distance`** est une chaîne qui peut être "0" si non applicable

---

## Feature: BOOKING CREATION

### Endpoint: book-item

**Method:** POST

**Request Body (What Flutter sends):**

```json
{
  "item_id": "101",
  "check_in": "2024-12-16",
  "check_out": "2024-12-18",
  "total_day": "2",
  "per_day": "50.00",
  "book_for": "",
  "base_price": "100.00",
  "service_charge": "10.00",
  "security_money": "10.00",
  "iva_tax": "12.50",
  "total": "127.50",
  "currency_code": "MAD",
  "payment_method": "stripe",
  "wall_amt": "0.00",
  "host_id": "1001",
  "total_guest": "1",
  "coupon_code": "",
  "discount_price": "0.00",
  "coupon_discount": "0.00",
  "discount_type": "",
  "cleaning_charges": "5.00",
  "start_time": "12:00 AM",
  "end_time": "11:30 AM",
  "onlinepayment": "Active",
  "doorStep_price": "0",
  "doorStep_address": "",
  "meta": ""
}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Booking created successfully",
  "error": "",
  "data": {
    "booking_id": 1234567890,
    "payment_url": "https://checkout.stripe.com/pay/cs_test_abc123",
    "booking_status": "pending"
  }
}
```

**Notes importantes pour book-item:**
- **`item_id`** et **`host_id`** doivent être valides et existants dans la base de données
- **`booking_id`** doit être un nombre entier unique généré pour chaque réservation
- **`payment_url`** est l'URL du processus de paiement (Stripe, PayPal, etc.) qui sera ouvert dans un WebView
- **`booking_status`** peut être "pending", "confirmed", "cancelled", etc.
- Si `item_id` ou `host_id` est invalide, l'API doit retourner un `status` d'erreur (ex: 400, 422) avec un `error` descriptif
- **`total`** doit correspondre au montant total calculé (incluant tous les frais)
- **`wall_amt`** est le montant utilisé depuis le portefeuille de l'utilisateur
- **`doorStep_address`** est une chaîne JSON si `doorStep_price` n'est pas "0", sinon une chaîne vide

**⚠️ IMPORTANT - Comportement de navigation après paiement:**
- Dans la version actuelle mockée, `payment_url` contient "cs_test_mock" pour simuler un succès de paiement
- Le code Flutter dans `payment_screen.dart` (`_handleNavigation()`) détecte cette URL mockée et navigue automatiquement vers la page de succès
- **AVEC LE BACKEND NODE.JS:** Le `payment_url` sera une vraie URL Stripe qui, après traitement du paiement, redirigera vers une URL contenant `"payment_success"` dans son chemin
- Cette URL de redirection réelle déclenchera automatiquement la navigation vers `BookingSuccessPage` puis vers "My Bookings"
- **Action requise après implémentation Node.js:** Supprimer la logique de détection mockée ("cs_test_mock") dans `_handleNavigation()` car elle ne sera plus nécessaire - la vraie URL Stripe redirigera vers `payment_success`

---

## Feature: BOOKING RECORDS

### Endpoint: booking-record

**Method:** POST

**Request Body (What Flutter sends):**

```json
{
  "type": "upcoming",
  "offset": "0",
  "token": "user_token",
  "module_id": "2",
  "default_currency_code": "MAD",
  "selected_currency_code": "MAD",
  "item_type": "1",
  "latitude": "34.0522",
  "longitude": "-118.2437",
  "time_zone": "+00:00",
  "lang": "en"
}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Bookings retrieved successfully",
  "error": "",
  "data": {
    "Bookings": [
      {
        "id": 1234567890,
        "itemid": "101",
        "userid": "1",
        "host_id": "1001",
        "check_in": "2025-12-16",
        "check_out": "2025-12-18",
        "status": "Pending",
        "total_day": "2",
        "per_day": "50.00",
        "book_for": "",
        "base_price": "100.00",
        "cleaning_charge": "5.00",
        "guest_charge": "0.00",
        "service_charge": "10.00",
        "security_money": "100.00",
        "iva_tax": "12.50",
        "total_guest": "1",
        "doorstep_price": "0",
        "total": "127.50",
        "admin_commission": "10.00",
        "vendor_commision": "90.00",
        "currency_code": "MAD",
        "cancellation_reasion": "",
        "cancelled_charge": "",
        "transaction": "",
        "payment_method": "stripe",
        "payment_status": "Paid",
        "image": "https://example.com/camry.jpg",
        "item_title": "Toyota Camry 2023",
        "item_data": "[{\"address\":\"123 Main Street, Los Angeles, CA 90001\",\"latitude\":\"34.0522\",\"longitude\":\"-118.2437\",\"image\":\"https://example.com/camry.jpg\",\"item_info\":\"{\\\"host_id\\\":\\\"1001\\\",\\\"make_type\\\":\\\"Toyota\\\",\\\"model\\\":\\\"Camry\\\",\\\"year\\\":\\\"2023\\\",\\\"service_type\\\":\\\"booking\\\"}\",\"item_type\":\"Sedan\"}]",
        "wall_amt": "0.00",
        "note": "",
        "rating": "4.5",
        "cancelled_by": "",
        "created_at": "2024-12-15 10:00:00",
        "updated_at": "2024-12-15 10:05:00",
        "review_status": "0",
        "review_rating": "",
        "review": "",
        "host_name": "John Doe",
        "host_number": "+1234567890",
        "host_email": "john.doe@example.com",
        "host_phone_country": "+1",
        "user_name": "User Test",
        "user_number": "+212694492918",
        "user_phone_country": "+212",
        "user_email": "user@example.com",
        "module": "2",
        "token": "",
        "start_time": "00:00",
        "end_time": "11:30",
        "booking_meta": "",
        "is_item_delivered": 0,
        "is_item_received": 0,
        "is_item_returned": 0,
        "is_item_delivered_button": "",
        "is_item_returned_button": "",
        "is_received_button": "",
        "pick_otp": "",
        "drop_otp": "",
        "doorStep_address": "",
        "booking_vehicle_images": null,
        "signature_image": null
      }
    ],
    "offset": 10,
    "limit": 10
  }
}
```

**Notes importantes pour booking-record:**
- **`type`** peut être : `"upcoming"`, `"ongoing"`, `"previous"`, ou `"cancelled"`
- **`offset`** est utilisé pour la pagination
- **`status`** dans chaque booking doit correspondre au type demandé :
  - `"upcoming"` → status: `"Pending"`
  - `"ongoing"` → status: `"Ongoing"`
  - `"previous"` → status: `"Completed"`
  - `"cancelled"` → status: `"Cancelled"`
- **`item_data`** est une chaîne JSON stringifiée qui DOIT être un **array** contenant un objet avec TOUS les champs requis par `ItemDetails.fromJson()` :
  - Champs de base : `item_id`, `title`, `price`, `description`, `bedrooms`, `beds`, `bathroom`, `item_sqft`, `item_rating`, `mobile`, `status`, `person_allowed`, `address`, `state_region`, `zip_postal_code`, `latitude`, `longitude`, `is_verified`, `is_featured`, `city`, `item_type`, `bed_type`, `cancellation_reason`
  - Champs de discount : `weekly_discount`, `weekly_discount_type`, `monthly_discount`, `monthly_discount_type`
  - Arrays : `amenities` (array d'objets avec `id`, `name`, `image_url`), `available_dates` (array), `reviews` (array), `gallery_image_urls` (array de strings)
  - Champs host : `host_id`, `host_player_id`, `host_first_name`, `host_last_name`, `host_email`, `host_phone`, `host_profile_image`
  - Champs images : `front_image_url`, `gallery_image_urls` (array)
  - Autres : `total_reviews` (num), `item_data` (string, peut être vide), `item_info` (string JSON), `is_in_wishlist` (bool)
- **`image`** est l'URL de l'image principale du véhicule
- **`item_title`** est le nom/titre du véhicule
- ⚠️ **IMPORTANT** : `item_data` doit être un array JSON (commence par `[`), pas un objet JSON. L'objet à l'intérieur de l'array doit correspondre exactement à la structure attendue par `ItemDetails.fromJson()` pour éviter les erreurs lors du parsing dans `EReceiptScreen`
- **`offset`** dans la réponse indique l'offset pour la prochaine page de résultats
- **`limit`** indique le nombre maximum de résultats par page

---

## Feature: CANCELLATION

### Endpoint: get-cancel-reasons

**Method:** GET

**Request Parameters (What Flutter sends):**

```json
{
  "userType": "user"
}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Cancel reasons retrieved successfully",
  "error": "",
  "data": {
    "reasons": [
      {
        "order_cancellation_id": 1,
        "reason": "Change of plans",
        "user_type": "user",
        "status": "1",
        "created_at": "2024-01-01 10:00:00",
        "updated_at": "2024-01-01 10:00:00"
      },
      {
        "order_cancellation_id": 2,
        "reason": "Found a better option",
        "user_type": "user",
        "status": "1",
        "created_at": "2024-01-01 10:00:00",
        "updated_at": "2024-01-01 10:00:00"
      },
      {
        "order_cancellation_id": 3,
        "reason": "Unexpected circumstances",
        "user_type": "user",
        "status": "1",
        "created_at": "2024-01-01 10:00:00",
        "updated_at": "2024-01-01 10:00:00"
      }
    ]
  }
}
```

**Notes importantes pour get-cancel-reasons:**
- **`userType`** peut être `"user"` ou `"host"` selon le type d'utilisateur qui demande les raisons d'annulation
- **`reasons`** est un array d'objets contenant les raisons d'annulation disponibles
- **`order_cancellation_id`** est l'ID unique de la raison d'annulation
- **`reason`** est le texte de la raison d'annulation affiché à l'utilisateur
- **`status`** doit être `"1"` pour les raisons actives

---

### Endpoint: cancel-booking-by-user

**Method:** POST

**Request Body (What Flutter sends):**

```json
{
  "booking_id": "1234567890",
  "cancellation_reasion": "1"
}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Booking cancelled successfully",
  "error": "",
  "data": {}
}
```

**Notes importantes pour cancel-booking-by-user:**
- **`booking_id`** est l'ID de la réservation à annuler (envoyé comme string dans le body)
- **`cancellation_reasion`** est l'ID de la raison d'annulation sélectionnée (note: il y a une faute de frappe dans le nom du champ - "reasion" au lieu de "reason" - mais cela doit être respecté pour la compatibilité avec le code Flutter existant)
- La réponse doit avoir `status: 200` et un `message` de succès
- Le champ `data` peut être un objet vide `{}`

---

## Host - Dashboard & Orders

### Endpoint: get-vendor-dashboard-record

**Method:** POST

**Request Body (What Flutter sends):**

```json
{}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Dashboard data retrieved successfully",
  "error": "",
  "data": {
    "data": {
      "total_sales": "5000.00",
      "today_orders": "5",
      "new_products": "3",
      "pending_orders": "2",
      "confirmedOrders": "8",
      "cancelledOrders": "1",
      "weekly_total_bookings": "25",
      "weekly_total_earnings": "3500.00",
      "weekly_income_report": {
        "monday": 450.50,
        "tuesday": 520.75,
        "wednesday": 380.25,
        "thursday": 600.00,
        "friday": 750.30,
        "saturday": 420.20,
        "sunday": 378.00
      }
    }
  }
}
```

> ⚠️ **NOTE Node.js**: ce contrat doit rester cohérent avec `DashBoardHost` et `DashboardData`. Le champ `weekly_income_report` est utilisé pour générer les graphiques hebdomadaires dans le dashboard. Tous les champs numériques peuvent être des strings ou des nombres.

---

### Endpoint: vendor-booking-record

**Method:** POST

**Request Body (What Flutter sends):**

```json
{
  "type": "upcoming",
  "offset": "0"
}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Vendor bookings retrieved successfully",
  "error": "",
  "data": {
    "Bookings": [
      {
        "id": 1234567890,
        "itemid": "101",
        "userid": "1",
        "host_id": "1001",
        "check_in": "2025-12-16",
        "check_out": "2025-12-18",
        "status": "Pending",
        "total_day": "2",
        "per_day": "50.00",
        "book_for": "",
        "base_price": "100.00",
        "cleaning_charge": "5.00",
        "guest_charge": "0.00",
        "service_charge": "10.00",
        "security_money": "100.00",
        "iva_tax": "12.50",
        "total_guest": "1",
        "doorstep_price": "0",
        "total": "127.50",
        "admin_commission": "10.00",
        "vendor_commision": "90.00",
        "currency_code": "MAD",
        "cancellation_reasion": "",
        "cancelled_charge": "",
        "transaction": "",
        "payment_method": "stripe",
        "payment_status": "Paid",
        "image": "https://example.com/camry.jpg",
        "item_title": "Toyota Camry 2023",
        "item_data": "[{\"item_id\":101,\"title\":\"Toyota Camry 2023\",\"price\":\"50.00\",\"description\":\"\",\"bedrooms\":\"\",\"beds\":\"\",\"bathroom\":\"\",\"item_sqft\":\"\",\"item_rating\":\"4.5\",\"mobile\":\"+1234567890\",\"status\":\"1\",\"person_allowed\":\"5\",\"address\":\"123 Main Street, Los Angeles, CA 90001\",\"state_region\":\"California\",\"zip_postal_code\":\"90001\",\"latitude\":\"34.0522\",\"longitude\":\"-118.2437\",\"is_verified\":\"1\",\"is_featured\":\"1\",\"weekly_discount\":\"10\",\"weekly_discount_type\":\"percentage\",\"monthly_discount\":\"15\",\"monthly_discount_type\":\"percentage\",\"item_type\":\"Sedan\",\"cancellation_reason\":\"\",\"bed_type\":\"\",\"city\":\"Los Angeles\",\"amenities\":[{\"id\":1,\"name\":\"GPS Navigation\",\"image_url\":\"https://example.com/gps.png\"},{\"id\":2,\"name\":\"Bluetooth\",\"image_url\":\"https://example.com/bluetooth.png\"}],\"available_dates\":[],\"host_id\":\"1001\",\"host_player_id\":\"player_12345\",\"host_first_name\":\"John\",\"host_last_name\":\"Doe\",\"host_email\":\"john.doe@example.com\",\"host_phone\":\"+1234567890\",\"host_profile_image\":\"https://example.com/profile.jpg\",\"front_image_url\":\"https://example.com/camry.jpg\",\"gallery_image_urls\":[\"https://example.com/camry-1.jpg\",\"https://example.com/camry-2.jpg\"],\"reviews\":[],\"total_reviews\":0,\"item_data\":\"\",\"item_info\":\"{\\\"host_id\\\":\\\"1001\\\",\\\"make_type\\\":\\\"Toyota\\\",\\\"model\\\":\\\"Camry\\\",\\\"year\\\":\\\"2023\\\",\\\"service_type\\\":\\\"booking\\\"}\",\"is_in_wishlist\":false}]",
        "wall_amt": "0.00",
        "note": "",
        "rating": "4.5",
        "cancelled_by": "",
        "created_at": "2024-12-15T10:00:00",
        "updated_at": "2024-12-15T10:00:00",
        "review_status": "0",
        "review_rating": "",
        "review": "",
        "host_name": "John Doe",
        "host_number": "+1234567890",
        "host_email": "john.doe@example.com",
        "host_phone_country": "+1",
        "user_name": "User Test",
        "user_number": "+212694492918",
        "user_phone_country": "+212",
        "user_email": "user@example.com",
        "module": "2",
        "token": "",
        "start_time": "00:00",
        "end_time": "11:30",
        "booking_meta": "",
        "is_item_delivered": 0,
        "is_item_received": 0,
        "is_item_returned": 0,
        "is_item_delivered_button": "",
        "is_item_returned_button": "",
        "is_received_button": "",
        "pick_otp": "",
        "drop_otp": "",
        "doorStep_address": "",
        "booking_vehicle_images": null,
        "signature_image": null
      }
    ],
    "offset": 10,
    "limit": 10
  }
}
```

> ⚠️ **NOTE Node.js**: 
>- **`type`** peut être : `"upcoming"`, `"ongoing"`, `"previous"`, ou `"Cancelled"` (case-insensitive, mais normalisé en minuscule sauf "Cancelled")
>- **`status`** dans chaque booking doit correspondre au type demandé :
>  - `"upcoming"` → status: `"Pending"`
>  - `"ongoing"` → status: `"Ongoing"`
>  - `"previous"` → status: `"Completed"`
>  - `"Cancelled"` ou `"cancelled"` → status: `"Cancelled"`
>- **`Bookings`** (avec majuscule) est la clé attendue par `BookingModel.fromJson()`
>- **`item_data`** doit être un array JSON stringifié (commence par `[`) contenant un objet complet `ItemDetails`
>- **`offset`** dans la réponse indique l'offset pour la prochaine page (-1 si pas de page suivante)

**🔴 CHAMPS DE REVIEW (Pour l'affichage du bouton "Add Review"):**

Les champs suivants sont **CRUCIAUX** pour déterminer l'affichage et le comportement du bouton "Add Review" dans l'onglet "Complete" (Previous Orders):

- **`review_status`**: 
  - `"0"` ou `null` → Le booking n'a pas encore de review du Host → Affiche le bouton "Add Review"
  - `"1"` → Le booking a déjà une review du Host → Affiche le bouton "View Review" (bleu)
  
- **`review_rating`**: 
  - String contenant la note (1-5) si `review_status == "1"`, sinon `""` ou `null`
  
- **`review`**: 
  - String contenant le message de la review si `review_status == "1"`, sinon `""` ou `null`

**Exemple de réponse pour un booking avec review:**
```json
{
  "review_status": "1",
  "review_rating": "5",
  "review": "Great customer! Very respectful and punctual."
}
```

**Exemple de réponse pour un booking sans review:**
```json
{
  "review_status": "0",
  "review_rating": "",
  "review": ""
}
```

**⚠️ IMPORTANT:** Après qu'un Host soumette une review via `give-review-by-host`, le backend doit mettre à jour ces champs dans la base de données pour que lors du prochain appel à `vendor-booking-record` (type: "previous"), le booking affiche "View Review" au lieu de "Add Review".

**🔴 CONDITIONS D'AFFICHAGE DE TOUS LES BOUTONS D'ACTION (Host Orders):**

Pour que les boutons d'action soient correctement affichés dans chaque onglet, le backend Node.js doit respecter les conditions suivantes dans la réponse de `vendor-booking-record`:

### 1. **Bouton "Reject" (Cancel Booking)**
- **Visible dans:** Onglet "Upcoming" uniquement
- **Conditions:**
  - `status == "Pending"` OU `status == "Declined"`
  - `listType == "UpComing"`
- **Champs requis:**
  - `status`: `"Pending"` ou `"Declined"`
- **Action:** Ouvre un modal pour sélectionner une raison d'annulation, puis appelle `cancel-booking-by-host`

### 2. **Bouton "Confirm" (Confirm Booking)**
- **Visible dans:** Onglet "Upcoming" uniquement
- **Conditions:**
  - `status == "Pending"`
  - `listType == "UpComing"`
- **Champs requis:**
  - `status`: `"Pending"`
- **Action:** Appelle `confirm-booking-by-host` pour confirmer la réservation

### 3. **Bouton "Mark as Delivered"**
- **Visible dans:** Onglet "Upcoming" uniquement
- **Conditions:**
  - `status == "Confirmed"`
  - `listType == "UpComing"`
  - `is_item_delivered == 0` (pas encore livré)
  - `is_item_delivered_button == "yes"` (bouton activé)
- **Champs requis:**
  - `is_item_delivered`: `0` (pas livré) ou `1` (livré)
  - `is_item_delivered_button`: `"yes"` (afficher le bouton) ou `"no"` (cacher le bouton)
  - `pick_otp`: String contenant l'OTP de pickup (ex: `"1234"`)
- **Action:** 
  - Si Digital Signature est active, demande la signature avant de marquer comme livré
  - Appelle `update-item-delivered-status` avec `is_item_delivered: "1"`
- **Après action:** Le backend doit mettre à jour `is_item_delivered` à `1` et `is_item_delivered_button` à `"no"`

### 4. **Bouton "Mark as Returned"**
- **Visible dans:** Onglet "Previous" (Complete) uniquement
- **Conditions:**
  - `status == "Completed"`
  - `listType == "Previous"`
  - `is_item_returned == 0` (pas encore retourné)
  - `is_item_returned_button == "yes"` (bouton activé)
  - `is_item_delivered == 1` (déjà livré)
- **Champs requis:**
  - `is_item_returned`: `0` (pas retourné) ou `1` (retourné)
  - `is_item_returned_button`: `"yes"` (afficher le bouton) ou `"no"` (cacher le bouton)
  - `is_item_delivered`: `1` (doit être livré avant de pouvoir être retourné)
  - `drop_otp`: String contenant l'OTP de drop (ex: `"5678"`)
- **Action:** Appelle `update-item-returned-status` avec `is_item_returned: "1"`
- **Après action:** Le backend doit mettre à jour `is_item_returned` à `1` et `is_item_returned_button` à `"no"`

### 5. **Bouton "Add Review" / "View Review"**
- **Visible dans:** Onglet "Previous" (Complete) uniquement
- **Conditions:**
  - `status == "Completed"`
  - `listType == "Previous"`
  - `review_status == "0"` ou `null` → Affiche "Add Review"
  - `review_status == "1"` → Affiche "View Review" (bleu)
- **Champs requis:**
  - `review_status`: `"0"` (pas de review), `"1"` (review existe), ou `null`
  - `review_rating`: String (1-5) si review existe, sinon `""`
  - `review`: String (message) si review existe, sinon `""`
- **Action:** 
  - Si `review_status == "0"` → Ouvre un modal pour ajouter une review
  - Si `review_status == "1"` → Ouvre un modal en lecture seule pour voir la review
  - Appelle `give-review-by-host` pour soumettre une nouvelle review

### 6. **Bouton "Receipt" (E-Receipt)**
- **Visible dans:** Tous les onglets (Upcoming, Live, Previous, Cancelled)
- **Conditions:** Toujours visible (pas de condition spécifique)
- **Action:** Navigue vers l'écran E-Receipt pour afficher le reçu de la réservation

### 7. **Bouton "Chat"**
- **Visible dans:** Tous les onglets
- **Conditions:** Toujours visible (utilise Firebase, pas d'API Laravel)
- **Action:** Ouvre le chat Firebase avec l'utilisateur

**📋 RÉSUMÉ DES CHAMPS REQUIS DANS `vendor-booking-record`:**

```json
{
  "status": "Pending" | "Confirmed" | "Ongoing" | "Completed" | "Cancelled" | "Declined",
  "is_item_delivered": 0 | 1,
  "is_item_delivered_button": "yes" | "no" | "",
  "is_item_returned": 0 | 1,
  "is_item_returned_button": "yes" | "no" | "",
  "is_item_received": 0 | 1,
  "is_received_button": "yes" | "no" | "",
  "pick_otp": "1234" | "",
  "drop_otp": "5678" | "",
  "review_status": "0" | "1" | null,
  "review_rating": "1" | "2" | "3" | "4" | "5" | "",
  "review": "message text" | ""
}
```

**⚠️ LOGIQUE NODE.JS RECOMMANDÉE:**

```javascript
// Exemple de logique pour déterminer les boutons
function determineButtonVisibility(booking, listType) {
  // Bouton "Mark as Delivered"
  if (listType === "UpComing" && booking.status === "Confirmed") {
    if (booking.is_item_delivered === 0) {
      booking.is_item_delivered_button = "yes";
    } else {
      booking.is_item_delivered_button = "no";
    }
  } else {
    booking.is_item_delivered_button = "";
  }

  // Bouton "Mark as Returned"
  if (listType === "Previous" && booking.status === "Completed") {
    if (booking.is_item_delivered === 1 && booking.is_item_returned === 0) {
      booking.is_item_returned_button = "yes";
    } else {
      booking.is_item_returned_button = "no";
    }
  } else {
    booking.is_item_returned_button = "";
  }

  // Bouton "Add Review"
  if (listType === "Previous" && booking.status === "Completed") {
    booking.review_status = booking.hasHostReview ? "1" : "0";
    if (booking.hasHostReview) {
      booking.review_rating = booking.hostReview.rating.toString();
      booking.review = booking.hostReview.message;
    } else {
      booking.review_rating = "";
      booking.review = "";
    }
  }
}
```

**📝 EXEMPLES DE RÉPONSES JSON PAR TYPE DE BOOKING:**

### Exemple 1: Booking "Upcoming" avec status "Pending" (Affiche "Confirm" et "Reject")
```json
{
  "status": "Pending",
  "is_item_delivered": 0,
  "is_item_delivered_button": "",
  "is_item_returned": 0,
  "is_item_returned_button": "",
  "pick_otp": "",
  "drop_otp": "",
  "review_status": "0",
  "review_rating": "",
  "review": ""
}
```

### Exemple 2: Booking "Upcoming" avec status "Confirmed" (Affiche "Mark as Delivered")
```json
{
  "status": "Confirmed",
  "is_item_delivered": 0,
  "is_item_delivered_button": "yes",
  "is_item_returned": 0,
  "is_item_returned_button": "",
  "pick_otp": "1234",
  "drop_otp": "",
  "review_status": "0",
  "review_rating": "",
  "review": ""
}
```

### Exemple 3: Booking "Ongoing" (Pas de boutons d'action)
```json
{
  "status": "Ongoing",
  "is_item_delivered": 1,
  "is_item_delivered_button": "no",
  "is_item_returned": 0,
  "is_item_returned_button": "",
  "pick_otp": "1234",
  "drop_otp": "",
  "review_status": "0",
  "review_rating": "",
  "review": ""
}
```

### Exemple 4: Booking "Previous" avec "Mark as Returned" disponible
```json
{
  "status": "Completed",
  "is_item_delivered": 1,
  "is_item_delivered_button": "no",
  "is_item_returned": 0,
  "is_item_returned_button": "yes",
  "pick_otp": "1234",
  "drop_otp": "5678",
  "review_status": "0",
  "review_rating": "",
  "review": ""
}
```

### Exemple 5: Booking "Previous" avec "Add Review" disponible
```json
{
  "status": "Completed",
  "is_item_delivered": 1,
  "is_item_delivered_button": "no",
  "is_item_returned": 1,
  "is_item_returned_button": "no",
  "pick_otp": "1234",
  "drop_otp": "5678",
  "review_status": "0",
  "review_rating": "",
  "review": ""
}
```

### Exemple 6: Booking "Previous" avec "View Review" (review déjà soumise)
```json
{
  "status": "Completed",
  "is_item_delivered": 1,
  "is_item_delivered_button": "no",
  "is_item_returned": 1,
  "is_item_returned_button": "no",
  "pick_otp": "1234",
  "drop_otp": "5678",
  "review_status": "1",
  "review_rating": "5",
  "review": "Great customer! Very respectful and punctual."
}
```

### Exemple 7: Booking "Cancelled" (Pas de boutons d'action)
```json
{
  "status": "Cancelled",
  "is_item_delivered": 0,
  "is_item_delivered_button": "",
  "is_item_returned": 0,
  "is_item_returned_button": "",
  "pick_otp": "",
  "drop_otp": "",
  "review_status": "0",
  "review_rating": "",
  "review": ""
}
```

---

### Endpoint: confirm-booking-by-host

**Method:** POST

**Request Body (What Flutter sends):**

```json
{
  "booking_id": "1234567890"
}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Booking confirmed successfully",
  "error": "",
  "data": {
    "booking_id": "1234567890",
    "status": "Confirmed"
  }
}
```

> ⚠️ **NOTE Node.js**: Après confirmation, le statut du booking doit être mis à jour à `"Confirmed"` dans la base de données.

---

### Endpoint: cancel-booking-by-host

**Method:** POST

**Request Body (What Flutter sends):**

```json
{
  "booking_id": "1234567890",
  "cancellation_reasion": "Vehicle not available"
}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Booking cancelled successfully",
  "error": "",
  "data": {
    "booking_id": "1234567890",
    "status": "Declined",
    "cancellation_reason": "Vehicle not available"
  }
}
```

> ⚠️ **NOTE Node.js**: 
>- Après annulation, le statut du booking doit être mis à jour à `"Declined"` dans la base de données
>- **`cancellation_reasion`** (avec faute d'orthographe) est le nom du champ dans la requête Flutter, mais Node.js peut normaliser en `cancellation_reason` dans la réponse

---

### Endpoint: get-cancel-reasons (Host Usage)

**Method:** GET

**Request Parameters (What Flutter sends):**

```json
{
  "userType": "host"
}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Cancel reasons retrieved successfully",
  "error": "",
  "data": {
    "reasons": [
      {
        "order_cancellation_id": 1,
        "reason": "Vehicle unavailable",
        "user_type": "host",
        "status": "1",
        "created_at": "2024-01-01 10:00:00",
        "updated_at": "2024-01-01 10:00:00"
      },
      {
        "order_cancellation_id": 2,
        "reason": "Guest behavior suspicion",
        "user_type": "host",
        "status": "1",
        "created_at": "2024-01-01 10:00:00",
        "updated_at": "2024-01-01 10:00:00"
      },
      {
        "order_cancellation_id": 3,
        "reason": "Unexpected maintenance",
        "user_type": "host",
        "status": "1",
        "created_at": "2024-01-01 10:00:00",
        "updated_at": "2024-01-01 10:00:00"
      },
      {
        "order_cancellation_id": 4,
        "reason": "Double booking error",
        "user_type": "host",
        "status": "1",
        "created_at": "2024-01-01 10:00:00",
        "updated_at": "2024-01-01 10:00:00"
      }
    ]
  }
}
```

> ⚠️ **NOTE Node.js**: 
>- Ce endpoint est utilisé par le Host pour obtenir la liste des raisons d'annulation disponibles lorsqu'il souhaite annuler une réservation
>- **`userType: "host"`** doit retourner uniquement les raisons spécifiques au Host (différentes de celles pour les utilisateurs)
>- **`reasons`** est un array d'objets contenant les raisons d'annulation disponibles pour le Host
>- **`order_cancellation_id`** est l'ID unique de la raison d'annulation
>- **`reason`** est le texte de la raison d'annulation affiché dans le modal de sélection
>- **`status`** doit être `"1"` pour les raisons actives
>- Ce endpoint est appelé depuis `common_widget_host.dart` (bouton "Reject") et `host_e_receipt.dart` (bouton "Cancel")

---

## Host - Order Status

### Endpoint: update-item-delivered-status

**Method:** POST

**Request Body (What Flutter sends):**

```json
{
  "booking_id": "1234567890",
  "is_item_delivered": "1"
}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Vehicle marked as delivered successfully",
  "error": "",
  "data": {
    "booking_extension": {
      "booking_id": "1234567890",
      "is_item_delivered": "1",
      "is_item_received": "1",
      "is_item_returned": "0"
    }
  }
}
```

> ⚠️ **NOTE Node.js**: 
>- Ce endpoint est utilisé par le Host pour marquer un véhicule comme "livré" au client
>- **`is_item_delivered`** doit être mis à `"1"` dans la base de données après succès
>- **`booking_extension`** contient les informations d'extension de la réservation, incluant les statuts de livraison/réception/retour
>- La réponse doit inclure `booking_extension` avec tous les statuts pour permettre à Flutter de mettre à jour l'UI correctement
>- Ce endpoint est appelé depuis `common_widget_host.dart` (méthode `updateItemDeliverStatus`)

---

### Endpoint: update-item-returned-status

**Method:** POST

**Request Body (What Flutter sends):**

```json
{
  "booking_id": "1234567890",
  "is_item_returned": "1"
}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Vehicle marked as returned successfully",
  "error": "",
  "data": {
    "booking_extension": {
      "booking_id": "1234567890",
      "is_item_returned": "1",
      "is_item_delivered": "1",
      "is_item_received": "1",
      "drop_otp": ""
    }
  }
}
```

> ⚠️ **NOTE Node.js**: 
>- Ce endpoint est utilisé par le Host pour marquer un véhicule comme "retourné" par le client
>- **`is_item_returned`** doit être mis à `"1"` dans la base de données après succès
>- **`booking_extension`** contient les informations d'extension de la réservation, incluant les statuts de livraison/réception/retour
>- **`drop_otp`** peut être inclus si un OTP est généré pour le retour (peut être vide)
>- La réponse doit inclure `booking_extension` avec tous les statuts pour permettre à Flutter de mettre à jour l'UI correctement
>- Ce endpoint est appelé depuis `common_widget_host.dart` (méthode `updateItemReturnedStatus`)

---

## Host - Reviews & Details

### Endpoint: getItemDetails (Host Context)

**Method:** POST

**Request Body (What Flutter sends):**

```json
{
  "item_id": "101"
}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Item details retrieved successfully",
  "error": "",
  "data": {
    "ItemDetails": {
      "item_id": 101,
      "title": "Toyota Camry 2023 - Premium Sedan",
      "price": "50.00",
      "description": "Experience luxury and comfort in this premium Toyota Camry 2023. Perfect for city drives and long trips. Fully equipped with modern amenities and safety features.",
      "bedrooms": "",
      "beds": "",
      "bathroom": "",
      "item_sqft": "",
      "item_rating": "4.5",
      "mobile": "+1234567890",
      "status": "1",
      "person_allowed": "5",
      "address": "123 Main Street",
      "state_region": "California",
      "zip_postal_code": "90001",
      "latitude": "34.0522",
      "longitude": "-118.2437",
      "is_verified": "1",
      "is_featured": "1",
      "weekly_discount": "10",
      "weekly_discount_type": "percentage",
      "monthly_discount": "15",
      "monthly_discount_type": "percentage",
      "item_type": "Sedan",
      "cancellation_reason": "",
      "bed_type": "",
      "city": "Los Angeles",
      "amenities": [
        {
          "id": 1,
          "name": "GPS Navigation",
          "image_url": "https://example.com/gps.png"
        },
        {
          "id": 2,
          "name": "Bluetooth",
          "image_url": "https://example.com/bluetooth.png"
        },
        {
          "id": 3,
          "name": "USB Port",
          "image_url": "https://example.com/usb.png"
        },
        {
          "id": 4,
          "name": "Air Conditioning",
          "image_url": "https://example.com/ac.png"
        },
        {
          "id": 5,
          "name": "Backup Camera",
          "image_url": "https://example.com/camera.png"
        }
      ],
      "available_dates": [
        {"date": "2024-12-16", "price": "50.00"},
        {"date": "2024-12-17", "price": "50.00"},
        {"date": "2024-12-18", "price": "55.00"}
      ],
      "host_id": "1001",
      "host_player_id": "player_12345",
      "host_first_name": "John",
      "host_last_name": "Doe",
      "host_email": "john.doe@example.com",
      "host_phone": "+1234567890",
      "host_profile_image": "https://example.com/profile.jpg",
      "front_image_url": "https://example.com/camry-front.jpg",
      "gallery_image_urls": [
        "https://example.com/camry-1.jpg",
        "https://example.com/camry-2.jpg",
        "https://example.com/camry-3.jpg"
      ],
      "reviews": [],
      "total_reviews": 0,
      "item_data": "{}",
      "item_info": "{\"make_type\":\"Toyota\",\"model\":\"Camry\",\"year\":\"2023\",\"transmission\":\"automatic\",\"fuel_type\":\"gasoline\",\"odometer\":\"15000\",\"color\":\"White\",\"seat_capacity\":\"5\",\"host_id\":\"1001\",\"service_type\":\"booking\"}",
      "is_in_wishlist": false
    }
  }
}
```

> ⚠️ **NOTE Node.js**: 
>- **`ItemDetails`** (avec majuscule) est la clé attendue par `ItemDetailsModel.fromJson()`
>- Ce endpoint est utilisé par le Host pour obtenir les détails complets d'un véhicule avant d'effectuer certaines actions (annulation, review, etc.)
>- **`item_info`** doit être une chaîne JSON stringifiée contenant les informations techniques du véhicule
>- **`amenities`** est un array d'objets avec `id`, `name`, et `image_url`
>- **`available_dates`** est un array d'objets avec `date` et `price`
>- Ce endpoint est appelé depuis `common_widget_host.dart` dans plusieurs contextes (avant annulation, avant review, etc.)

---

### Endpoint: give-review-by-host

**Method:** POST

**Request Body (What Flutter sends):**

```json
{
  "rating": "5",
  "message": "Great customer! Very respectful and punctual.",
  "booking_id": "1234567890"
}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Review submitted successfully",
  "error": "",
  "data": {
    "review_id": 9876543210,
    "booking_id": "1234567890",
    "rating": "5",
    "message": "Great customer! Very respectful and punctual."
  }
}
```

> ⚠️ **NOTE Node.js**: 
>- Ce endpoint permet au Host de laisser une review sur un client après une réservation
>- **`rating`** doit être un nombre entre 1 et 5 (envoyé comme string)
>- **`message`** est le commentaire textuel de la review
>- **`booking_id`** identifie la réservation concernée
>- Après succès, Flutter met à jour localement `reviewStatus`, `reviewRating`, et `review` dans l'objet booking
>- Ce endpoint est appelé depuis `common_widget_host.dart` (méthode de review du Host)

**🔴 CONDITIONS D'AFFICHAGE DU BOUTON "ADD REVIEW" (Host Orders - Previous/Completed):**

Pour que le bouton "Add Review" soit affiché dans l'onglet "Complete" (Previous Orders), le backend Node.js doit respecter les conditions suivantes dans la réponse de `vendor-booking-record` (type: "previous"):

1. **Statut du Booking:**
   - Le booking doit avoir `status: "Completed"` pour apparaître dans l'onglet "Previous"

2. **Champ `reviewStatus` dans le Booking:**
   - **Si `reviewStatus == "0"` ou `reviewStatus == null`** → Le bouton "Add Review" est affiché (couleur du thème)
   - **Si `reviewStatus == "1"`** → Le bouton "View Review" est affiché (couleur bleue) - la review existe déjà

3. **Champs requis pour l'affichage:**
   - `reviewStatus`: `"0"` (pas de review), `"1"` (review existante), ou `null` (pas de review)
   - `reviewRating`: String contenant la note (1-5) si review existe, sinon `""` ou `null`
   - `review`: String contenant le message de la review si elle existe, sinon `""` ou `null`

4. **Logique côté Node.js:**
   ```javascript
   // Exemple de logique pour déterminer reviewStatus
   if (booking.hasHostReview) {
     booking.reviewStatus = "1";
     booking.reviewRating = booking.hostReview.rating.toString();
     booking.review = booking.hostReview.message;
   } else {
     booking.reviewStatus = "0"; // ou null
     booking.reviewRating = "";
     booking.review = "";
   }
   ```

5. **Comportement du bouton:**
   - **Bouton "Add Review"** (`reviewStatus == "0"` ou `null`):
     - Couleur: Couleur du thème (orange/primary)
     - Action: Ouvre un modal pour ajouter une review
   - **Bouton "View Review"** (`reviewStatus == "1"`):
     - Couleur: Bleue
     - Action: Ouvre un modal en lecture seule pour voir la review existante

6. **Important:**
   - Le bouton "Add Review" est **UNIQUEMENT** visible dans l'onglet "Complete" (Previous Orders)
   - Le bouton n'est **PAS** visible dans les onglets "Upcoming", "Live", ou "Cancelled"
   - Après soumission d'une review via `give-review-by-host`, le backend doit mettre à jour `reviewStatus` à `"1"` pour ce booking

---

## Host - Wallet

### Endpoint: get-vendor-wallet

**Method:** POST

**Request Body (What Flutter sends):**

```json
{}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Wallet balance retrieved successfully",
  "error": "",
  "data": {
    "walletBalance": "1250.00",
    "pendingToWithdrawl": "150.00",
    "totalWithdrawled": "5000.00",
    "totalEarning": "6400.00",
    "refunded": "0.00",
    "incoming_amount": "1250.00"
  }
}
```

> ⚠️ **NOTE Node.js**: ce contrat doit rester cohérent avec `VendorWallet` et `Data`. Tous les montants sont des strings représentant des valeurs décimales.

---

### Endpoint: get-vendor-wallet-transactions

**Method:** POST

**Request Body (What Flutter sends):**

```json
{
  "offset": "0"
}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Wallet transactions retrieved successfully",
  "error": "",
  "data": {
    "WalletTransactionsDetails": [
      {
        "id": 1,
        "vendor_id": "1001",
        "booking_id": "101",
        "payout_id": "0",
        "amount": "250.00",
        "type": "credit",
        "description": "Vendor commission for booking #101",
        "created_at": "2024-12-15T10:00:00",
        "updated_at": "2024-12-15T10:00:00"
      },
      {
        "id": 2,
        "vendor_id": "1001",
        "booking_id": "102",
        "payout_id": "0",
        "amount": "300.00",
        "type": "credit",
        "description": "Vendor commission for booking #102",
        "created_at": "2024-12-12T10:00:00",
        "updated_at": "2024-12-12T10:00:00"
      },
      {
        "id": 3,
        "vendor_id": "1001",
        "booking_id": "103",
        "payout_id": "1",
        "amount": "200.00",
        "type": "debit",
        "description": "Payout request #1",
        "created_at": "2024-12-10T10:00:00",
        "updated_at": "2024-12-10T10:00:00"
      }
    ],
    "offset": 4
  }
}
```

> ⚠️ **NOTE Node.js**: 
>- **`WalletTransactionsDetails`** (avec majuscule) est la clé attendue par `GetVendorWalletTransactions.fromJson()`
>- **`type`** peut être `"credit"` (entrée d'argent) ou `"debit"` (sortie d'argent)
>- **`payout_id`** est `"0"` pour les transactions de commission, sinon l'ID du payout
>- **`offset`** dans la réponse indique l'offset pour la prochaine page (-1 si pas de page suivante)

---

### Endpoint: get-vendor-earings

**Method:** POST

**Request Body (What Flutter sends):**

```json
{
  "offset": "0",
  "limit": "10",
  "startDate": "2024-12-01",
  "endDate": "2024-12-31"
}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Vendor earnings retrieved successfully",
  "error": "",
  "data": {
    "VendorBookings": [
      {
        "id": 101,
        "check_in": "2024-12-15",
        "status": "Completed",
        "vendor_commission": "250.00",
        "admin_commission": "50.00",
        "base_price": "300.00",
        "doorstep_price": "0.00",
        "coupon_discount": "0.00",
        "total": "300.00"
      },
      {
        "id": 102,
        "check_in": "2024-12-12",
        "status": "Completed",
        "vendor_commission": "300.00",
        "admin_commission": "60.00",
        "base_price": "360.00",
        "doorstep_price": "0.00",
        "coupon_discount": "0.00",
        "total": "360.00"
      }
    ],
    "offset": 3,
    "totalBookings": 12,
    "totalEarnings": 6400.0
  }
}
```

> ⚠️ **NOTE Node.js**: 
>- **`VendorBookings`** (avec majuscule) est la clé attendue par `VendorEarning.fromJson()`
>- **`offset`** dans la réponse indique l'offset pour la prochaine page (-1 si pas de page suivante)
>- **`totalBookings`** et **`totalEarnings`** sont des totaux globaux pour la période sélectionnée

---

### Endpoint: insert-payout

**Method:** POST

**Request Body (What Flutter sends):**

```json
{
  "amount": "200.00",
  "currency": "MAD",
  "active_payout_method_id": "1"
}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Payout request submitted successfully",
  "error": "",
  "data": {
    "payout": {
      "vendorid": "1001",
      "amount": "200.00",
      "currency": "MAD",
      "payment_method": "Bank Account",
      "account_number": "1234567890",
      "booking_Ids": "0",
      "payout_status": "Pending",
      "created_at": "2024-12-20T10:00:00",
      "updated_at": "2024-12-20T10:00:00",
      "id": 17
    }
  }
}
```

> ⚠️ **NOTE Node.js**: Après création, le statut du payout doit être `"Pending"` par défaut. Le `id` doit être un identifiant unique généré par le backend.

---

### Endpoint: get-payout-transactions

**Method:** POST

**Request Body (What Flutter sends):**

```json
{
  "offset": "0"
}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Payout transactions retrieved successfully",
  "error": "",
  "data": {
    "payout_transactions": [
      {
        "id": 1,
        "vendorid": "1001",
        "amount": "200.00",
        "currency": "MAD",
        "vendor_name": "John Doe",
        "payment_method": "Bank Account",
        "account_number": "1234567890",
        "payout_status": "Success",
        "booking_Ids": "101,102",
        "created_at": "2024-12-15T10:00:00",
        "updated_at": "2024-12-15T10:00:00",
        "payout_proof_url": "https://example.com/payout-proof-1.jpg"
      },
      {
        "id": 2,
        "vendorid": "1001",
        "amount": "300.00",
        "currency": "MAD",
        "vendor_name": "John Doe",
        "payment_method": "Stripe",
        "account_number": "acct_123456",
        "payout_status": "Pending",
        "booking_Ids": "103",
        "created_at": "2024-12-18T10:00:00",
        "updated_at": "2024-12-18T10:00:00",
        "payout_proof_url": null
      }
    ],
    "offset": 2
  }
}
```

> ⚠️ **NOTE Node.js**: 
>- **`payout_status`** peut être `"Pending"`, `"Success"`, ou `"Failed"`
>- **`payout_proof_url`** est l'URL de la preuve de paiement (peut être `null` si pas encore disponible)
>- **`booking_Ids`** est une chaîne de caractères contenant les IDs de booking séparés par des virgules (ou `"0"` si aucun)
>- **`offset`** dans la réponse indique l'offset pour la prochaine page (-1 si pas de page suivante)

---

## Host - Calendar & Finance

### Endpoint: get-item-dates (Host Calendar)

**Method:** GET

**Request Parameters (What Flutter sends):**

```json
{
  "item_id": "101"
}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Item dates retrieved successfully",
  "error": "",
  "data": {
    "ItemDates": {
      "price": "50.00",
      "available_dates": [
        {"date": "2025-12-20", "price": "50.00"},
        {"date": "2025-12-21", "price": "50.00"},
        {"date": "2025-12-22", "price": "55.00"},
        {"date": "2025-12-23", "price": "55.00"},
        {"date": "2025-12-24", "price": "60.00"}
      ],
      "not_available_dates": [
        {"date": "2025-12-25"},
        {"date": "2025-12-26"},
        {"date": "2025-12-27"}
      ],
      "booked_dates": [
        {"date": "2025-12-28", "price": "60.00"},
        {"date": "2025-12-29", "price": "60.00"}
      ]
    }
  }
}
```

> ⚠️ **NOTE Node.js**: 
>- **`ItemDates`** (avec majuscule) est la clé attendue par `CalendarItemId.fromJson()`
>- **`available_dates`** est un array d'objets avec `date` (format `YYYY-MM-DD`) et `price` (string)
>- **`not_available_dates`** est un array d'objets avec uniquement `date` (format `YYYY-MM-DD`)
>- **`booked_dates`** est un array d'objets avec `date` et `price` (string)
>- **`price`** au niveau racine de `ItemDates` est le prix par défaut du véhicule
>- Les dates dans `available_dates` et `booked_dates` peuvent avoir des prix différents du prix par défaut
>- Les dates dans `not_available_dates` sont bloquées (non disponibles pour réservation)
>- Les dates dans `booked_dates` sont déjà réservées (affichées en vert dans le calendrier)
>- Les dates dans `available_dates` sont disponibles pour réservation (affichées avec le prix dans le calendrier)

---

### Endpoint: add-edit-calender

**Method:** POST

**Request Body (What Flutter sends):**

```json
{
  "id": "101",
  "availability_dates": "[\"[{\\\"date\\\":\\\"2025-12-20\\\",\\\"status\\\":\\\"Available\\\",\\\"price\\\":\\\"50.00\\\"},{\\\"date\\\":\\\"2025-12-21\\\",\\\"status\\\":\\\"Available\\\",\\\"price\\\":\\\"50.00\\\"}]\",\"[{\\\"date\\\":\\\"2025-12-22\\\",\\\"status\\\":\\\"Available\\\",\\\"price\\\":\\\"55.00\\\"}]\"]"
}
```

**Note:** Le champ `availability_dates` est une chaîne JSON stringifiée contenant un array de chaînes JSON, où chaque chaîne représente un array de dates avec leur statut et prix.

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Calendar updated successfully",
  "error": "",
  "data": {
    "id": "101",
    "updated": true
  }
}
```

> ⚠️ **NOTE Node.js**: 
>- Le champ `availability_dates` dans la requête est une chaîne JSON complexe (double stringification)
>- Le backend doit parser cette chaîne pour extraire les dates disponibles et non disponibles
>- Les dates avec `status: "Available"` doivent être marquées comme disponibles avec leur prix
>- Les dates avec `status: "Not Available"` doivent être marquées comme bloquées
>- Après succès, le backend doit mettre à jour les dates du calendrier pour ce véhicule
>- Le champ `id` est l'ID du véhicule (`item_id`)

---

### Endpoint: add-payment-method

**Method:** POST

**Request Body (What Flutter sends):**

```json
{
  "payout_methods": [
    {
      "payout_method_id": 1,
      "is_active": 1,
      "account_name": "John Doe",
      "bank_name": "Bank of America",
      "branch_name": "Main Branch",
      "account_number": "1234567890",
      "iban": "US64SVBKUS6S3300958879",
      "swift_code": "BOFAUS3N"
    },
    {
      "payout_method_id": 2,
      "is_active": 0,
      "email": "john.doe@example.com",
      "note": "PayPal account"
    }
  ],
  "active_payout_method_id": 1
}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Bank account added successfully",
  "error": "",
  "data": {
    "payout_methods": [
      {
        "id": 1,
        "payout_method": "Bank Account",
        "details": {
          "id": 1,
          "is_active": 1,
          "account_name": "John Doe",
          "bank_name": "Bank of America",
          "branch_name": "Main Branch",
          "account_number": "1234567890",
          "iban": "US64SVBKUS6S3300958879",
          "swift_code": "BOFAUS3N",
          "email": null,
          "note": null
        }
      },
      {
        "id": 2,
        "payout_method": "PayPal",
        "details": {
          "id": 2,
          "is_active": 0,
          "account_name": null,
          "bank_name": null,
          "branch_name": null,
          "account_number": null,
          "iban": null,
          "swift_code": null,
          "email": "john.doe@example.com",
          "note": "PayPal account"
        }
      }
    ],
    "active_payout_method_id": 1
  }
}
```

> ⚠️ **NOTE Node.js**: 
>- **`payout_methods`** est un array d'objets contenant les méthodes de paiement configurées
>- Pour "Bank Account", les champs requis sont : `account_name`, `bank_name`, `branch_name`, `account_number`, `iban`, `swift_code`
>- Pour "PayPal" ou autres méthodes électroniques, les champs requis sont : `email`, `note`
>- **`is_active`** détermine si la méthode est active (1) ou inactive (0)
>- **`active_payout_method_id`** est l'ID de la méthode de paiement actuellement active
>- Le backend doit valider que seule une méthode peut être active à la fois
>- Après succès, Flutter met à jour `getPaymentTypeModel` avec la nouvelle structure

---

## User - Booking Management

### Endpoint: booking-record

**Method:** POST

**Request Body (What Flutter sends):**

```json
{
  "type": "upcoming",
  "offset": "0"
}
```

> **Note:** Le paramètre `type` peut être : `"upcoming"`, `"ongoing"`, `"previous"`, ou `"Cancelled"`.

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Bookings retrieved successfully",
  "error": "",
  "data": {
    "Bookings": [
      {
        "id": 1234567890,
        "itemid": "101",
        "userid": "1",
        "host_id": "1001",
        "check_in": "2025-12-16",
        "check_out": "2025-12-18",
        "status": "Pending",
        "total_day": "2",
        "per_day": "50.00",
        "book_for": "",
        "base_price": "100.00",
        "cleaning_charge": "5.00",
        "guest_charge": "0.00",
        "service_charge": "10.00",
        "security_money": "100.00",
        "iva_tax": "12.50",
        "total_guest": "1",
        "doorstep_price": "0",
        "total": "127.50",
        "admin_commission": "10.00",
        "vendor_commision": "90.00",
        "currency_code": "MAD",
        "cancellation_reasion": "",
        "cancelled_charge": "",
        "transaction": "",
        "payment_method": "stripe",
        "payment_status": "Paid",
        "image": "https://example.com/camry.jpg",
        "item_title": "Toyota Camry 2023",
        "item_data": "[{\"item_id\":101,\"title\":\"Toyota Camry 2023\",\"price\":\"50.00\",\"description\":\"Clean and comfortable sedan\",\"address\":\"123 Main Street, Los Angeles, CA 90001\",\"state_region\":\"California\",\"zip_postal_code\":\"90001\",\"latitude\":\"34.0522\",\"longitude\":\"-118.2437\",\"item_rating\":\"4.5\",\"mobile\":\"+1234567890\",\"status\":\"1\",\"person_allowed\":\"5\",\"item_type\":\"Sedan\",\"city\":\"Los Angeles\",\"item_info\":\"{\\\"host_id\\\":\\\"1001\\\",\\\"make_type\\\":\\\"Toyota\\\",\\\"model\\\":\\\"Camry\\\",\\\"year\\\":\\\"2023\\\",\\\"service_type\\\":\\\"booking\\\"}\"}]",
        "wall_amt": "0.00",
        "note": "",
        "rating": "4.5",
        "cancelled_by": "",
        "created_at": "2025-12-15T10:00:00",
        "updated_at": "2025-12-15T10:00:00",
        "review_status": "0",
        "review_rating": "",
        "review": "",
        "host_name": "John Doe",
        "host_number": "+1234567890",
        "host_email": "john.doe@example.com",
        "host_phone_country": "+1",
        "user_name": "User Test",
        "user_number": "+212694492918",
        "user_phone_country": "+212",
        "user_email": "user@example.com",
        "module": "2",
        "token": "",
        "start_time": "00:00",
        "end_time": "11:30",
        "booking_meta": "",
        "is_item_delivered": 0,
        "is_item_received": 0,
        "is_item_returned": 0,
        "is_item_delivered_button": "",
        "is_item_returned_button": "",
        "is_received_button": "",
        "pick_otp": "",
        "drop_otp": "",
        "doorStep_address": "",
        "booking_vehicle_images": null,
        "signature_image": null
      }
    ],
    "offset": 10,
    "limit": 10
  }
}
```

> ⚠️ **NOTE Node.js**: 
>- Le champ `item_data` est une chaîne JSON stringifiée d'un **tableau** contenant les détails de l'item (pas un objet simple).
>- Le statut `status` varie selon le type : `"Pending"` (upcoming), `"Ongoing"` (ongoing), `"Completed"` (previous), `"Cancelled"` (cancelled).
>- Le champ `offset` est utilisé pour la pagination. Retourner `-1` si aucune autre page n'est disponible.
>- Les dates `check_in` et `check_out` sont au format `YYYY-MM-DD`.

---

### Endpoint: booking-payment-success

**Method:** POST

**Request Body (What Flutter sends):**

```json
{
  "booking_id": "1234567890"
}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Payment verified successfully",
  "error": "",
  "data": {
    "booking_id": "1234567890",
    "payment_status": "success",
    "bookingpayment": "success"
  }
}
```

> ⚠️ **NOTE Node.js**: 
>- Cet endpoint est appelé périodiquement par Flutter pour vérifier le statut du paiement après redirection depuis le processeur de paiement (Stripe, etc.).
>- Le champ `bookingpayment` doit être `"success"` pour que Flutter considère le paiement comme réussi.
>- Le backend doit vérifier le statut réel du paiement avec le processeur de paiement.

---

## User - Actions

### Endpoint: get-cancel-reasons

**Method:** GET

**Request Parameters (What Flutter sends):**

```json
{
  "userType": "user"
}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Cancel reasons retrieved successfully",
  "error": "",
  "data": {
    "Reasons": [
      {
        "id": "1",
        "reason": "Change of plans",
        "status": "1"
      },
      {
        "id": "2",
        "reason": "Found a better option",
        "status": "1"
      },
      {
        "id": "3",
        "reason": "Unexpected circumstances",
        "status": "1"
      },
      {
        "id": "4",
        "reason": "Vehicle not as described",
        "status": "1"
      },
      {
        "id": "5",
        "reason": "Host unresponsive",
        "status": "1"
      }
    ]
  }
}
```

> ⚠️ **NOTE Node.js**: 
>- Le paramètre `userType` peut être `"user"` ou `"host"` pour retourner des raisons différentes selon le contexte.
>- Le champ `status` doit être `"1"` pour les raisons actives.
>- Les raisons sont affichées dans un modal bottom sheet pour que l'utilisateur puisse sélectionner une raison lors de l'annulation.

---

### Endpoint: cancel-booking-by-user

**Method:** POST

**Request Body (What Flutter sends):**

```json
{
  "booking_id": "1234567890",
  "cancellation_reasion": "1"
}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Booking cancelled successfully",
  "error": "",
  "data": {
    "booking_id": "1234567890",
    "cancellation_reason": "1",
    "status": "Cancelled"
  }
}
```

> ⚠️ **NOTE Node.js**: 
>- Le champ `cancellation_reasion` (notez l'orthographe avec un seul 's') contient l'ID de la raison d'annulation sélectionnée.
>- Le backend doit mettre à jour le statut de la réservation à `"Cancelled"` et enregistrer la raison.
>- Le backend doit calculer et appliquer les frais d'annulation selon la politique de cancellation du véhicule.
>- Après succès, Flutter met à jour localement la liste des réservations pour refléter l'annulation.

---

### Endpoint: get-wishlist

**Method:** POST

**Request Body (What Flutter sends):**

```json
{}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Wishlist retrieved successfully",
  "error": "",
  "data": {
    "items": [
      {
        "id": 101,
        "name": "Toyota Camry 2023",
        "item_rating": "4.5",
        "mobile": "+1234567890",
        "status": "1",
        "person_allowed": "5",
        "price": "50.00",
        "address": "123 Main Street, Los Angeles",
        "state_region": "California",
        "zip_postal_code": "90001",
        "city": "Los Angeles",
        "latitude": "34.0522",
        "longitude": "-118.2437",
        "item_type_id": "1",
        "image": "https://example.com/camry-front.jpg",
        "item_info": "{\"host_id\":\"1\",\"service_type\":\"booking\",\"make_type\":\"Toyota\",\"model\":\"Camry\",\"year\":\"2023\",\"transmission\":\"Automatic\",\"seat_capicity\":\"5\",\"host_first_name\":\"John\",\"review_data\":[],\"features_data\":[],\"gallery_image_urls\":[]}",
        "is_in_wishlist": true,
        "item_type": "Sedan",
        "distance": "0"
      },
      {
        "id": 102,
        "name": "Tesla Model 3 2022",
        "item_rating": "4.8",
        "mobile": "+1234567890",
        "status": "1",
        "person_allowed": "5",
        "price": "80.00",
        "address": "456 Market Street, San Francisco",
        "state_region": "California",
        "zip_postal_code": "94102",
        "city": "San Francisco",
        "latitude": "37.7749",
        "longitude": "-122.4194",
        "item_type_id": "2",
        "image": "https://example.com/tesla-front.jpg",
        "item_info": "{\"host_id\":\"1\",\"service_type\":\"booking\",\"make_type\":\"Tesla\",\"model\":\"Model 3\",\"year\":\"2022\",\"transmission\":\"Automatic\",\"seat_capicity\":\"5\",\"host_first_name\":\"Jane\",\"review_data\":[],\"features_data\":[],\"gallery_image_urls\":[]}",
        "is_in_wishlist": true,
        "item_type": "Electric",
        "distance": "0"
      }
    ]
  }
}
```

> ⚠️ **NOTE Node.js**: 
>- Le backend doit retourner uniquement les véhicules ajoutés à la wishlist de l'utilisateur connecté.
>- **Structure critique** : Le modèle `Items.fromJson()` attend des champs spécifiques :
>  - `"name"` (pas `"title"`) : Le nom du véhicule
>  - `"image"` (string URL, pas un objet `"front_image"`) : URL directe de l'image principale
>  - `"city"` (pas `"city_name"`) : Nom de la ville
>  - `"is_in_wishlist"` (bool) : Indique si l'item est dans la wishlist (doit être `true` pour tous les items retournés)
>  - `"item_info"` (string JSON) : Doit contenir `make_type`, `model`, `year`, `transmission`, `seat_capicity`, `host_first_name` pour que l'UI fonctionne correctement
>  - `"distance"` (string) : Distance depuis l'utilisateur (peut être `"0"` si non applicable)
>- La structure des items est identique à celle utilisée dans `item-search` et `home-data`.
>- Le champ `front_image` doit être un objet avec toutes les propriétés d'image, pas juste une URL string.
>- Le champ `item_info` est une chaîne JSON stringifiée contenant les informations supplémentaires du véhicule.

---

### Endpoint: add-to-wishlist

**Method:** POST

**Request Body (What Flutter sends):**

```json
{
  "item_id": "101"
}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Item added to wishlist successfully",
  "error": "",
  "data": "success"
}
```

> ⚠️ **NOTE Node.js**: 
>- L'endpoint doit ajouter l'item à la wishlist de l'utilisateur connecté.
>- Le champ `data` peut être une string `"success"` ou un objet vide `{}`.
>- Après succès, Flutter met à jour localement le statut `is_in_wishlist` de l'item.

---

### Endpoint: remove-from-wishlist

**Method:** POST

**Request Body (What Flutter sends):**

```json
{
  "item_id": "101"
}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Item removed from wishlist successfully",
  "error": "",
  "data": "success"
}
```

> ⚠️ **NOTE Node.js**: 
>- L'endpoint doit retirer l'item de la wishlist de l'utilisateur connecté.
>- Le champ `data` peut être une string `"success"` ou un objet vide `{}`.
>- Après succès, Flutter met à jour localement le statut `is_in_wishlist` de l'item à `false`.

---

## Chat & Social Login

### Endpoint: conversations

**Method:** POST

**Request Body (What Flutter sends):**

```json
{
  "property_id": "101",
  "booking_id": "1234567890"
}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Conversations retrieved successfully",
  "error": "",
  "data": {
    "conversations": [
      {
        "id": "1",
        "conversation_id": "conv_123",
        "property_id": "101",
        "booking_id": "1234567890",
        "user_id": "1",
        "host_id": "1001",
        "last_message": "Hello, I have a question about the vehicle",
        "last_message_time": "2025-12-15T10:00:00Z",
        "unread_count": "2",
        "created_at": "2025-12-10T10:00:00Z"
      }
    ]
  }
}
```

> ⚠️ **NOTE Node.js**: 
>- Retourne la liste des conversations pour un `property_id` et `booking_id` donnés.
>- Le champ `unread_count` indique le nombre de messages non lus.
>- `last_message_time` est au format ISO 8601.

---

### Endpoint: latestmessage

**Method:** POST

**Request Body (What Flutter sends):**

```json
{
  "conversation_id": "conv_123",
  "offset": "0"
}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Latest messages retrieved successfully",
  "error": "",
  "data": {
    "latest_message": [
      {
        "Name": "John Doe",
        "Message": "Hello, I have a question about the vehicle",
        "senderid": "1001",
        "frontImage": "https://example.com/profile.jpg"
      },
      {
        "Name": "User Test",
        "Message": "Hi, what would you like to know?",
        "senderid": "1",
        "frontImage": "https://example.com/user.jpg"
      }
    ],
    "offset": 10
  }
}
```

> ⚠️ **NOTE Node.js**: 
>- Les clés JSON utilisent des majuscules (`Name`, `Message`) pour correspondre au modèle Dart `LatestMessage`.
>- Le champ `senderid` identifie l'expéditeur (user_id ou host_id).
>- Le champ `offset` est utilisé pour la pagination. Retourner `-1` si aucune autre page n'est disponible.

---

### Endpoint: social-login

**Method:** POST

**Request Body (What Flutter sends):**

```json
{
  "displayName": "John Doe",
  "email": "john.doe@example.com",
  "id": "google_123456",
  "profile_image": "https://example.com/profile.jpg",
  "login_type": "google",
  "identityToken": "eyJhbGciOiJSUzI1NiIs...",
  "authorizationCode": "4/0AY0e-g7..."
}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Social login successful",
  "error": "",
  "data": {
    "id": 1,
    "first_name": "John",
    "last_name": "Doe",
    "email": "john.doe@example.com",
    "phone": "+1234567890",
    "phone_country": "+1",
    "profile_image": "https://example.com/profile.jpg",
    "token": "mock_social_token_1234567890",
    "module_id": "2",
    "user_type": "user",
    "is_verified": "1",
    "created_at": "2025-12-15T10:00:00Z",
    "updated_at": "2025-12-15T10:00:00Z"
  }
}
```

> ⚠️ **NOTE Node.js**: 
>- Le `login_type` peut être `"google"`, `"facebook"`, `"apple"`, etc.
>- Le backend doit vérifier l'`identityToken` et l'`authorizationCode` avec le fournisseur OAuth.
>- Si l'utilisateur n'existe pas, créer un nouveau compte. Sinon, retourner les données existantes.
>- Le `token` retourné est utilisé pour les requêtes authentifiées suivantes.
>- La structure de réponse doit correspondre à `LoginModel` (identique à `user-email-login`).

---

## User - Reviews & Details

### Endpoint: getItemDetails (User Context)

**Method:** POST

**Request Body (What Flutter sends):**

```json
{
  "item_id": "101"
}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Item details retrieved successfully",
  "error": "",
  "data": {
    "ItemDetails": {
      "item_id": 101,
      "title": "Toyota Camry 2023",
      "price": "50.00",
      "description": "Clean and comfortable sedan",
      "item_rating": "4.5",
      "status": "1"
    }
  }
}
```

> ⚠️ **NOTE Node.js**: 
>- Cet endpoint est appelé depuis le contexte utilisateur (My Bookings) pour obtenir des détails basiques de l'item.
>- La structure complète de `ItemDetails` est identique à celle documentée dans la section "Vehicle Details".
>- Le backend peut retourner une version simplifiée ou complète selon le contexte.

---

### Endpoint: give-review-by-user

**Method:** POST

**Request Body (What Flutter sends):**

```json
{
  "rating": "5",
  "message": "Excellent vehicle! Very clean and comfortable.",
  "booking_id": "1234567890"
}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Review added successfully",
  "error": "",
  "data": {
    "booking_id": "1234567890",
    "rating": "5",
    "message": "Excellent vehicle! Very clean and comfortable.",
    "review_status": "1"
  }
}
```

> ⚠️ **NOTE Node.js**: 
>- Le `rating` est une string représentant un nombre entre 1 et 5.
>- Le `message` est le texte de l'avis de l'utilisateur.
>- Le `review_status` doit être `"1"` pour indiquer que l'avis a été soumis avec succès.
>- Après succès, Flutter met à jour localement le statut de la réservation pour afficher l'avis.

---

## Support Tickets

### Endpoint: get-reply-threads

**Method:** GET

**Request Parameters (What Flutter sends):**

```json
{
  "thread_id": "123"
}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Reply threads retrieved successfully",
  "error": "",
  "data": {
    "replyThreads": [
      {
        "id": 1,
        "thread_id": "123",
        "user_id": "1",
        "is_admin_reply": "0",
        "message": "Hello, I need help with my booking",
        "created_at": "2025-12-13T10:00:00Z",
        "updated_at": "2025-12-13T10:00:00Z",
        "reply_status": "1"
      },
      {
        "id": 2,
        "thread_id": "123",
        "user_id": "0",
        "is_admin_reply": "1",
        "message": "Thank you for contacting us. How can we assist you?",
        "created_at": "2025-12-14T10:00:00Z",
        "updated_at": "2025-12-14T10:00:00Z",
        "reply_status": "1"
      }
    ]
  }
}
```

> ⚠️ **NOTE Node.js**: 
>- Le champ `is_admin_reply` est `"1"` pour les réponses de l'admin, `"0"` pour les messages de l'utilisateur.
>- Le champ `user_id` est `"0"` pour les messages admin, sinon l'ID de l'utilisateur.
>- Les messages sont généralement triés par `created_at` (plus récent en premier).
>- Le champ `reply_status` indique si le message est actif (`"1"`) ou supprimé (`"0"`).

---

### Endpoint: reply-to-support-ticket

**Method:** POST

**Request Body (What Flutter sends):**

```json
{
  "thread_id": "123",
  "message": "I have a question about the cancellation policy"
}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Reply sent successfully",
  "error": "",
  "data": {
    "reply": {
      "id": 1234567890,
      "thread_id": "123",
      "user_id": "1",
      "is_admin_reply": "0",
      "message": "I have a question about the cancellation policy",
      "created_at": "2025-12-15T10:00:00Z",
      "updated_at": "2025-12-15T10:00:00Z",
      "reply_status": "1"
    }
  }
}
```

> ⚠️ **NOTE Node.js**: 
>- Le backend doit créer un nouveau message dans le thread spécifié.
>- Le `id` retourné est l'ID du nouveau message créé.
>- Le `user_id` doit correspondre à l'utilisateur connecté.
>- Après succès, Flutter insère le nouveau message en haut de la liste (`list.insert(0, replyThreadsData)`).

---

### Endpoint: close-support-ticket

**Method:** POST

**Request Body (What Flutter sends):**

```json
{
  "thread_id": "123"
}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Ticket closed successfully",
  "error": "",
  "data": {
    "thread_id": "123",
    "status": "0"
  }
}
```

> ⚠️ **NOTE Node.js**: 
>- Le backend doit mettre à jour le statut du thread à `"0"` (fermé).
>- Le champ `status` dans la réponse doit être `"0"` pour indiquer que le ticket est fermé.
>- Après succès, Flutter navigue vers `TicketFirstScreen` pour afficher la liste mise à jour.

---

## Additional Endpoints - Final Mocking Phase

### Endpoint: get-item-reviews

**Method:** POST

**Request Body (What Flutter sends):**

```json
{
  "item_id": "101",
  "offset": "0"
}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Item reviews retrieved successfully",
  "error": "",
  "data": {
    "reviews": [
      {
        "id": 1,
        "booking_id": "101",
        "item_id": "101",
        "item_name": "Toyota Camry 2023",
        "guest_id": "1",
        "guest_name": "John Doe",
        "guest_image": "https://example.com/profile1.jpg",
        "rating": "5",
        "message": "Excellent vehicle! Very clean and comfortable. Highly recommend!",
        "created_at": "2025-01-10T10:00:00.000Z",
        "updated_at": "2025-01-10T10:00:00.000Z"
      }
    ],
    "offset": 3
  }
}
```

> ⚠️ **NOTE Node.js**:
> - Le `item_id` est l'ID du véhicule pour lequel on récupère les avis.
> - Le `offset` est utilisé pour la pagination.
> - Les `reviews` contiennent les avis des utilisateurs avec leur note, message, et informations de profil.

---

### Endpoint: upload-signature

**Method:** POST

**Request Body (What Flutter sends):**

```json
{
  "booking_id": "101",
  "signature_type": "user",
  "signature_image": "base64_encoded_image_string"
}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "success": 200,
  "message": "Signature uploaded successfully",
  "error": "",
  "data": {
    "booking_id": "101",
    "signature_type": "user",
    "signature_url": "https://example.com/signatures/101_user.png"
  }
}
```

> ⚠️ **NOTE Node.js**:
> - Le `signature_type` peut être "user" ou "vendor".
> - L'image est envoyée en base64 et doit être stockée côté serveur.
> - La réponse doit inclure l'URL de la signature uploadée.

---

### Endpoint: delete-account

**Method:** POST

**Request Body (What Flutter sends):**

```json
{}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Account deleted successfully",
  "error": ""
}
```

> ⚠️ **NOTE Node.js**:
> - Cette action supprime définitivement le compte de l'utilisateur.
> - Aucun paramètre n'est nécessaire car l'utilisateur est identifié par le token d'authentification.

---

### Endpoint: get-host-status

**Method:** POST

**Request Body (What Flutter sends):**

```json
{}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Host status retrieved successfully",
  "error": "",
  "data": {
    "host_status": "1"
  }
}
```

> ⚠️ **NOTE Node.js**:
> - `host_status` peut être:
>   - `"0"` = L'utilisateur n'a pas encore fait de demande pour devenir host
>   - `"1"` = Le statut host est approuvé
>   - `"2"` = La demande est en attente d'approbation
> - Cette information détermine si l'utilisateur peut accéder aux fonctionnalités host.

---

### Endpoint: static-page

**Method:** GET

**Request Parameters (What Flutter sends):**

```json
{
  "id": "1"
}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Static page retrieved successfully",
  "error": "",
  "data": {
    "StaticPage": {
      "id": 1,
      "name": "Terms and Condition",
      "content": "<h1>Terms of Service for Users & Privacy Policy</h1><p>By using Carvy, you agree to our terms of service and privacy policy...</p>",
      "status": "1",
      "created_at": "2024-01-01T00:00:00.000Z",
      "updated_at": "2024-01-01T00:00:00.000Z",
      "deleted_at": null
    }
  }
}
```

> ⚠️ **NOTE Node.js**:
> - Le `id` correspond à l'ID de la page statique (Terms, Privacy, About Us, etc.).
> - Le `content` contient le HTML de la page à afficher.
> - Les différents IDs correspondent à différentes pages:
>   - `"1"` = Terms and Condition / Terms of Service for Users & Privacy Policy
>   - `"2"` = About Us
>   - `"4"` = Get Help
>   - `"5"` = Give Us Feedback
>   - `"11"` = Terms of Service for Vehicle Owner
>   - `"32"` = Booking Agreement
>   - Et d'autres pour les traductions multilingues.

---

### Endpoint: edit-profile

**Method:** POST

**Request Body (What Flutter sends):**

```json
{
  "first_name": "John",
  "last_name": "Doe",
  "email": "john.doe@example.com",
  "phone": "1234567890",
  "phone_country": "+1",
  "default_country": "US",
  "intro": "I am a car enthusiast",
  "langauge": "English",
  "country": "United States",
  "birthdate": "1990-01-01",
  "identity_image": "base64_encoded_image_string"
}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Profile updated successfully",
  "error": "",
  "data": {
    "user": {
      "id": 1,
      "first_name": "John",
      "middle": null,
      "last_name": "Doe",
      "email": "john.doe@example.com",
      "phone": "1234567890",
      "phone_country": "+1",
      "default_country": "US",
      "intro": "I am a car enthusiast",
      "langauge": "English",
      "country": "United States",
      "wallet": null,
      "otp_value": "0",
      "token": "user_auth_token",
      "reset_token": null,
      "verified": "1",
      "phone_verify": "1",
      "email_verify": "1",
      "login_type": "email",
      "birthdate": "1990-01-01",
      "social_id": null,
      "status": "1",
      "created_at": "2024-01-01T00:00:00.000Z",
      "updated_at": "2025-01-15T10:00:00.000Z",
      "deleted_at": null,
      "package_id": null,
      "fcm": null,
      "device_id": null,
      "identity_image": {
        "url": "https://example.com/identity.jpg"
      },
      "profile_image": null,
      "media": []
    }
  }
}
```

> ⚠️ **NOTE Node.js**:
> - Tous les champs sont optionnels sauf ceux requis par la validation.
> - L'`identity_image` est envoyée en base64 et doit être stockée côté serveur.
> - La réponse doit retourner l'objet `user` complet avec toutes les informations mises à jour.

---

### Endpoint: check-email

**Method:** POST

**Request Body (What Flutter sends):**

```json
{
  "email": "john.doe@example.com"
}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "OTP sent to email successfully",
  "error": "",
  "data": {
    "email": "john.doe@example.com",
    "otp": "123456"
  }
}
```

> ⚠️ **NOTE Node.js**:
> - Cette endpoint vérifie si l'email existe et envoie un OTP.
> - L'OTP doit être généré et envoyé par email.
> - L'OTP est retourné dans la réponse pour permettre la vérification dans l'app (en mode développement/test).

---

### Endpoint: upload-profile-image

**Method:** POST

**Request Body (What Flutter sends):**

```json
{
  "profile_image": "base64_encoded_image_string"
}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Profile image uploaded successfully",
  "error": "",
  "data": {
    "profile_image": {
      "url": "https://example.com/profile.jpg",
      "thumbnail": "https://example.com/profile-thumb.jpg",
      "preview": "https://example.com/profile-preview.jpg"
    }
  }
}
```

> ⚠️ **NOTE Node.js**:
> - L'image est envoyée en base64 et doit être stockée côté serveur.
> - La réponse doit inclure l'URL de l'image ainsi que les URLs des versions thumbnail et preview.

---

### Endpoint: fcm-update

**Method:** GET

**Request Parameters (What Flutter sends):**

```json
{
  "fcm": "firebase_cloud_messaging_token",
  "player_id": "onesignal_player_id"
}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "FCM token updated successfully",
  "error": ""
}
```

> ⚠️ **NOTE Node.js**:
> - Cette endpoint met à jour le token FCM et le player ID OneSignal pour les notifications push.
> - Aucune réponse complexe n'est nécessaire, juste un statut de succès.

---

### Endpoint: get-user-profile (Public Profile)

**Method:** GET

**Request Parameters (What Flutter sends):**

```json
{
  "userid": "1001"
}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "User profile retrieved successfully",
  "error": "",
  "data": {
    "name": "John Doe",
    "profile_image": "https://example.com/profile.jpg",
    "profile_background": "https://example.com/background.jpg",
    "intro_text": "Experienced host with 5 years of hosting",
    "total_reviews_on_items": 25,
    "average_rating_on_items": 4.5,
    "years_of_hosting": "5",
    "languages": "English, French",
    "livecity": "Los Angeles",
    "age": "35",
    "join_in": "2020-01-01",
    "verified_identity": "1",
    "verified_email": "1",
    "verified_phone": "1"
  }
}
```

> ⚠️ **NOTE Node.js**:
> - Cette endpoint récupère le profil public d'un utilisateur (host).
> - Le `userid` est l'ID de l'utilisateur dont on veut voir le profil.
> - Les informations retournées sont publiques et peuvent être vues par tous les utilisateurs.

---

### Endpoint: get-vendor-item-reviews (Public Profile)

**Method:** GET

**Request Parameters (What Flutter sends):**

```json
{
  "userid": "1001",
  "offset": "0"
}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Vendor item reviews retrieved successfully",
  "error": "",
  "data": {
    "reviews": [
      {
        "item_id": "101",
        "item_name": "Toyota Camry 2023",
        "guest_response": {
          "guest_name": "Alice Johnson",
          "guest_rating": "5",
          "guest_message": "Excellent vehicle! Very clean and comfortable.",
          "guest_profile": "https://example.com/guest1.jpg",
          "guest_id": "10"
        },
        "host_response": {
          "host_name": "John Doe",
          "host_rating": "5",
          "host_message": "Great guest! Highly recommend.",
          "host_profile": "https://example.com/host.jpg",
          "host_id": "1001"
        },
        "created_at": "2025-01-10T10:00:00.000Z"
      }
    ],
    "offset": 1
  }
}
```

> ⚠️ **NOTE Node.js**:
> - Cette endpoint récupère les avis sur les véhicules d'un host spécifique.
> - Le `userid` est l'ID du host.
> - Les `reviews` contiennent à la fois les réponses des guests et des hosts.
> - Le `offset` est utilisé pour la pagination.

---

### Endpoint: get-user-items (Public Profile)

**Method:** GET

**Request Parameters (What Flutter sends):**

```json
{
  "userid": "1001"
}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "User items retrieved successfully",
  "error": "",
  "data": {
    "items": [
      {
        "id": 101,
        "name": "Toyota Camry 2023",
        "item_rating": "4.5",
        "mobile": "+1234567890",
        "status": "1",
        "person_allowed": "5",
        "price": "50.00",
        "address": "123 Main Street, Los Angeles",
        "state_region": "California",
        "zip_postal_code": "90001",
        "city": "Los Angeles",
        "latitude": "34.0522",
        "longitude": "-118.2437",
        "item_type_id": "1",
        "image": "https://example.com/camry-front.jpg",
        "item_info": "{\"host_id\":\"1001\",\"service_type\":\"booking\",\"make_type\":\"Toyota\",\"model\":\"Camry\",\"year\":\"2023\",\"transmission\":\"Automatic\",\"seat_capicity\":\"5\",\"host_first_name\":\"John\",\"review_data\":[],\"features_data\":[],\"gallery_image_urls\":[]}",
        "is_in_wishlist": false,
        "item_type": "Sedan",
        "distance": "0"
      }
    ],
    "offset": 0
  }
}
```

> ⚠️ **NOTE Node.js**:
> - Cette endpoint récupère la liste des véhicules d'un host spécifique pour affichage sur son profil public.
> - Le `userid` est l'ID du host.
> - Les `items` doivent correspondre au modèle `ItemModel` utilisé dans l'app Flutter.

---

## Additional Endpoints - Final Mocking Phase (Part 2)

### Endpoint: email-sms-notification

**Method:** POST

**Request Body (What Flutter sends):**

```json
{
  "type": "email",
  "value": "1"
}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Notification settings updated successfully",
  "error": ""
}
```

> ⚠️ **NOTE Node.js**:
> - Le `type` peut être `"email"`, `"sms"`, ou `"push"`.
> - Le `value` peut être `"1"` (activé) ou `"0"` (désactivé).
> - Cette endpoint met à jour les préférences de notification de l'utilisateur.

---

### Endpoint: get-kyc-details

**Method:** POST

**Request Body (What Flutter sends):**

```json
{}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "KYC details retrieved successfully",
  "error": "",
  "data": {
    "kyc_images": {
      "driver_license_front_image": null,
      "driver_license_back_image": null,
      "other_identity_front_image": null,
      "other_identity_back_image": null
    },
    "kyc_reference_data": {
      "reference_primary_mobile_no": "",
      "reference_primary_country_code": "+212",
      "reference_primary_country_short_code": "MA",
      "reference_secondary_mobile_no": "",
      "reference_secondary_country_code": "+212",
      "reference_secondary_country_short_code": "MA"
    },
    "kyc_status": "pending"
  }
}
```

> ⚠️ **NOTE Node.js**:
> - Le `kyc_status` peut être `"pending"`, `"approved"`, ou `"rejected"`.
> - Les images KYC sont stockées en base64 ou comme URLs.
> - Les données de référence contiennent les numéros de téléphone des références primaires et secondaires.

---

### Endpoint: add-kyc-for-customer

**Method:** POST

**Request Body (What Flutter sends):**

```json
{
  "driver_license_front_image": "base64_encoded_image_string",
  "driver_license_back_image": "base64_encoded_image_string",
  "other_identity_front_image": "base64_encoded_image_string",
  "other_identity_back_image": "base64_encoded_image_string",
  "reference_primary_mobile_no": "1234567890",
  "reference_primary_country_code": "+212",
  "reference_primary_country_short_code": "MA",
  "reference_secondary_mobile_no": "0987654321",
  "reference_secondary_country_code": "+212",
  "reference_secondary_country_short_code": "MA"
}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "KYC submitted successfully",
  "error": ""
}
```

> ⚠️ **NOTE Node.js**:
> - Toutes les images sont envoyées en base64 et doivent être stockées côté serveur.
> - Les références primaires et secondaires sont obligatoires.
> - Après soumission, le statut KYC doit être mis à jour à `"pending"` pour révision.

---

### Endpoint: get-general-settings

**Method:** GET

**Request Parameters (What Flutter sends):**

```json
{}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "General settings retrieved successfully",
  "error": "",
  "data": {
    "metaData": {
      "general_name": "Carvy",
      "general_email": "support@carvy.com",
      "general_default_currency": "MAD",
      "general_default_language": "en",
      "general_logo": "https://example.com/logo.png",
      "general_favicon": "https://example.com/favicon.png",
      "personalization_row_per_page": "10",
      "personalization_min_search_price": "0",
      "personalization_max_search_price": "1000",
      "personalization_date_separator": "/",
      "personalization_date_format": "dd/mm/yyyy",
      "personalization_time_zone": "UTC",
      "personalization_money_format": "symbol",
      "general_minimum_price": "10",
      "general_maximum_price": "500",
      "feesetup_guest_service_charge": "5",
      "feesetup_iva_tax": "10",
      "feesetup_accomodation_tax": "0",
      "onlinepayment": "1",
      "general_default_phone_country": "+212",
      "general_default_country_code": "MA",
      "app_item_type": "1",
      "app_popular_region": "1",
      "app_near_you": "1",
      "app_make": "1",
      "app_most_viewed": "1",
      "app_become_lend": "1",
      "app_show_distance": "1",
      "app_user_digital_signature": "1",
      "app_booking_vehicle_images": "1",
      "app_user_kyc": "1"
    }
  }
}
```

> ⚠️ **NOTE Node.js**:
> - Cette endpoint retourne toutes les configurations générales de l'application.
> - Les valeurs `"1"` indiquent que la fonctionnalité est activée, `"0"` qu'elle est désactivée.
> - Ces paramètres contrôlent l'affichage et le comportement de l'application.

---

### Endpoint: get-payout-type

**Method:** GET

**Request Parameters (What Flutter sends):**

```json
{}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Payout types retrieved successfully",
  "error": "",
  "data": {
    "payout_methods": [
      {
        "id": 1,
        "name": "Bank Account"
      },
      {
        "id": 2,
        "name": "PayPal"
      },
      {
        "id": 3,
        "name": "Stripe"
      }
    ]
  }
}
```

> ⚠️ **NOTE Node.js**:
> - Cette endpoint retourne la liste des types de méthodes de paiement disponibles pour les retraits.
> - Chaque type a un `id` unique et un `name` descriptif.

---

### Endpoint: get-payout-method

**Method:** POST

**Request Body (What Flutter sends):**

```json
{}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Payout methods retrieved successfully",
  "error": "",
  "data": {
    "payout_methods": [
      {
        "id": 1,
        "payout_method": "Bank Account",
        "details": {
          "id": 1,
          "is_active": 0,
          "account_name": null,
          "bank_name": null,
          "branch_name": null,
          "account_number": null,
          "iban": null,
          "swift_code": null,
          "email": null,
          "note": null,
          "user_id": null,
          "created_at": null,
          "updated_at": null
        }
      },
      {
        "id": 2,
        "payout_method": "PayPal",
        "details": {
          "id": 2,
          "is_active": 0,
          "account_name": null,
          "bank_name": null,
          "branch_name": null,
          "account_number": null,
          "iban": null,
          "swift_code": null,
          "email": null,
          "note": null,
          "user_id": null,
          "created_at": null,
          "updated_at": null
        }
      }
    ]
  }
}
```

> ⚠️ **NOTE Node.js**:
> - Cette endpoint retourne les méthodes de paiement configurées par l'utilisateur.
> - Le `is_active` indique si la méthode est actuellement active (`1`) ou inactive (`0`).
> - Les `details` contiennent les informations spécifiques à chaque méthode (compte bancaire, PayPal, etc.).

---

### Endpoint: update-payout-method (addPaymentMethod in add_bank_account_controller)

**Method:** POST

**Request Body (What Flutter sends):**

```json
{
  "payout_methods": [
    {
      "payout_method_id": 1,
      "is_active": 1,
      "account_name": "John Doe",
      "bank_name": "Example Bank",
      "branch_name": "Main Branch",
      "account_number": "1234567890",
      "iban": "MOCKIBAN123",
      "swift_code": "MOCKSWIFT"
    }
  ],
  "active_payout_method_id": 1
}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Payment method updated successfully",
  "error": "",
  "data": {
    "payout_methods": [
      {
        "id": 1,
        "payout_method": "Bank Account",
        "details": {
          "id": 1,
          "is_active": 1,
          "account_name": "John Doe",
          "bank_name": "Example Bank",
          "branch_name": "Main Branch",
          "account_number": "1234567890",
          "iban": "MOCKIBAN123",
          "swift_code": "MOCKSWIFT",
          "email": null,
          "note": null,
          "user_id": "1",
          "created_at": "2025-01-15T10:00:00.000Z",
          "updated_at": "2025-01-15T10:00:00.000Z"
        }
      }
    ]
  }
}
```

> ⚠️ **NOTE Node.js**:
> - Cette endpoint met à jour ou ajoute une méthode de paiement pour les retraits.
> - Le `active_payout_method_id` indique quelle méthode est actuellement active.
> - Pour les comptes bancaires, inclure `account_name`, `bank_name`, `branch_name`, `account_number`, `iban`, `swift_code`.
> - Pour PayPal ou autres méthodes, inclure `email` et `note`.

---

### Endpoint: save-door-step-address

**Method:** POST

**Request Body (What Flutter sends):**

```json
{
  "house_floor_number": "2",
  "building_block_number": "A",
  "landmark": "Near Central Park",
  "full_address": "123 Main Street, Los Angeles, CA 90001",
  "city": "Los Angeles",
  "state": "California",
  "country": "United States",
  "postal_code": "90001",
  "doorstep_latitude": "34.0522",
  "doorstep_longitude": "-118.2437"
}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Doorstep address saved successfully",
  "error": ""
}
```

> ⚠️ **NOTE Node.js**:
> - Cette endpoint sauvegarde l'adresse de livraison à domicile (doorstep) de l'utilisateur.
> - Les coordonnées GPS (`doorstep_latitude`, `doorstep_longitude`) sont obligatoires.
> - L'adresse complète est utilisée pour la livraison de véhicules.

---

### Endpoint: get-door-step-address

**Method:** POST

**Request Body (What Flutter sends):**

```json
{}
```

**Expected Response (What Node.js MUST return):**

```json
{
  "status": 200,
  "message": "Doorstep address retrieved successfully",
  "error": "",
  "data": {
    "door_step_address": {
      "house_floor_number": "2",
      "building_block_number": "A",
      "landmark": "Near Central Park",
      "full_address": "123 Main Street, Los Angeles, CA 90001",
      "city": "Los Angeles",
      "state": "California",
      "country": "United States",
      "postal_code": "90001",
      "doorstep_latitude": "34.0522",
      "doorstep_longitude": "-118.2437"
    }
  }
}
```

> ⚠️ **NOTE Node.js**:
> - Cette endpoint récupère l'adresse de livraison à domicile sauvegardée de l'utilisateur.
> - Si aucune adresse n'est sauvegardée, retourner `null` dans `door_step_address`.
> - Les coordonnées GPS sont utilisées pour calculer la distance et les frais de livraison.

---

## Notes importantes

1. **Tous les endpoints doivent retourner un statut HTTP 200** pour les réponses réussies.
2. **Le champ `status` dans le JSON** doit être `200` pour les succès, ou un autre code pour les erreurs.
3. **Le champ `offset`** est utilisé pour la pagination et doit être retourné dans les réponses de listes.
4. **Les images** peuvent être des URLs complètes ou des chemins relatifs selon votre configuration.
5. **Les champs optionnels** : Les valeurs `null` doivent être remplacées par des valeurs par défaut (`""` pour les strings, `"{}"` pour les objets JSON, `"0"` pour les distances, URLs d'images par défaut pour les images) pour éviter les erreurs de null check dans Flutter.
6. **Le format des dates** doit être `"YYYY-MM-DD HH:mm:ss"` pour les champs `created_at`, `updated_at`, etc.
7. **Pour `item-search`**, les filtres `fuel_type` et `transmission` sont des arrays qui peuvent être vides `[]` si aucun filtre n'est sélectionné.

