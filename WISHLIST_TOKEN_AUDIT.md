# 🔍 Audit Complet : Problème du Guest Token dans Wishlist

## 📋 Résumé Exécutif

**Problème** : Le backend Node.js reçoit un **Guest Token** même après que l'utilisateur soit connecté, ce qui se traduit par `User ID: undefined` et `role: guest` dans les logs backend.

## 1️⃣ Analyse du Flux d'Exécution

### Flux Complet : UI → Controller → HTTP Service

```
1. UI (Heart Icon onTap)
   └─> lib/utils/common_widget.dart (ligne 519)
       └─> wishListController.addTowishlist(list[index].id)

2. Controller
   └─> lib/controller/wish_list_controller.dart (ligne 79-87)
       └─> httpPost(Config.addtowishlist, {"item_id": "$itemId"})

3. HTTP Service
   └─> lib/helper/http_service.dart (ligne 381)
       └─> Construction des headers avec bearerToken
       └─> Envoi de la requête HTTP
```

## 2️⃣ Analyse du Code HTTP Service

### Dans `httpPost()` (ligne 1035-1044)

```dart
String apiBaseUrl = Config.baseurl;
var url = apiBaseUrl + path;

// ⚠️ PROBLÈME IDENTIFIÉ ICI
if (bearerToken.isEmpty) {
  bearerToken = await generateToken() ?? "";
}

var headers = {
  'Content-Type': 'application/json',
  "Authorization": "Bearer $bearerToken",  // ← Utilise le bearerToken existant
};
```

**Logique actuelle** :
- Si `bearerToken` est **vide** → Génère un nouveau token
- Si `bearerToken` est **NON vide** → **RÉUTILISE l'ancien token** (⚠️ BUG ICI)

### Dans `generateToken()` (ligne 1115-1143)

```dart
Map<String, dynamic> body = {
  "secret": Config.secretKey,
  "user_token": token  // ← Variable globale 'token' (user token)
};

// Si token est vide → Génère un GUEST bearer token
// Si token est valide → Génère un USER bearer token
```

## 3️⃣ Le Bug Identifié

### Scénario du Bug

1. **App démarre** → `bearerToken` est chargé depuis le stockage (ligne 55 de `work_space.dart`)
   ```dart
   String bearerToken = GetStorage().read("bearerToken") ?? "";
   ```

2. **Première requête HTTP** (avant login) → `token` (user token) est vide (`""`)
   - `generateToken()` est appelé avec `user_token: ""`
   - Backend génère un **GUEST bearer token**
   - Ce bearer token est sauvegardé dans `bearerToken` (variable globale) et dans le stockage

3. **Utilisateur se connecte** → `token` (user token) est mis à jour avec le vrai token utilisateur
   - **MAIS** `bearerToken` n'est **JAMAIS effacé** ❌
   - La variable globale `bearerToken` contient toujours l'ancien **GUEST bearer token**

4. **Requête Wishlist** (après login) → `httpPost()` est appelé
   - `bearerToken` n'est **PAS vide** (contient toujours le guest token)
   - La condition `if (bearerToken.isEmpty)` est **FALSE**
   - `generateToken()` n'est **JAMAIS appelé**
   - L'ancien **GUEST bearer token** est réutilisé dans le header `Authorization`

### Preuve du Bug

**Dans `auth_controller.dart`** (lignes 136, 245, 697, 789) :
- ✅ `token = loginModel.data!.token!` → Le user token est mis à jour
- ❌ **AUCUNE ligne** qui efface `bearerToken`
- ❌ **AUCUNE ligne** qui appelle `GetStorage().remove("bearerToken")`

**Résultat** : Le bearer token guest persiste même après le login.

## 4️⃣ Solution

### Option 1 : Effacer le Bearer Token lors du Login (RECOMMANDÉ)

Dans `lib/controller/auth_controller.dart`, ajouter après chaque assignation de `token` :

```dart
// Dans login() (ligne 136)
token = loginModel.data!.token!;
// AJOUTER :
GetStorage().remove("bearerToken");
bearerToken = ""; // Reset global variable

// Dans signUp() (ligne 245)
token = loginModel.data!.token!;
// AJOUTER :
GetStorage().remove("bearerToken");
bearerToken = ""; // Reset global variable

// Dans googleLogin() (ligne 697)
token = socialLoginModel.data!.token!;
// AJOUTER :
GetStorage().remove("bearerToken");
bearerToken = ""; // Reset global variable

// Dans appleLogin() (ligne 789)
token = socialLoginModel.data!.token!;
// AJOUTER :
GetStorage().remove("bearerToken");
bearerToken = ""; // Reset global variable
```

### Option 2 : Vérifier le User Token dans `httpPost`

Modifier `httpPost()` pour forcer la régénération si le user token a changé :

```dart
// Dans httpPost(), avant la condition if (bearerToken.isEmpty)
String? storedUserToken = GetStorage().read("raw_user_token");
if (storedUserToken != null && storedUserToken.isNotEmpty && token != storedUserToken) {
  // Le user token a changé (login récent), forcer la régénération
  bearerToken = "";
  GetStorage().remove("bearerToken");
}
```

## 5️⃣ Logs de Trace Ajoutés

Des logs de débogage ont été ajoutés dans `http_service.dart` pour tracer le problème :

- **Dans `httpPost()`** : Logs avant l'envoi de la requête
  - État du user token global
  - État du bearer token en cache
  - Si le bearer token est réutilisé ou régénéré

- **Dans `generateToken()`** : Logs lors de la génération
  - Le user_token utilisé pour la génération
  - Si c'est un guest token ou un user token

## 6️⃣ Conclusion

**Le bug est confirmé** : Le `bearerToken` n'est **jamais effacé** lors du login, donc l'ancien guest token est réutilisé pour toutes les requêtes authentifiées.

**Solution immédiate** : Ajouter le flush du bearer token dans tous les points d'authentification (login, signUp, googleLogin, appleLogin).

