# Guide de Test - Host/Owner Features (Fonctionnalités Non Mockées)

Ce document indique où trouver chaque fonctionnalité non mockée dans l'interface utilisateur pour faciliter les tests.

---

## Navigation de Base - Host Mode

**Comment accéder au mode Host:**
- Basculer vers le mode Host depuis l'écran principal
- La barre de navigation inférieure affiche: **Dashboard**, **Calendar**, **Orders**, **Inbox**, **Account**

---

## 1. Delete Item (Supprimer un Véhicule)

### 📍 Localisation 1: Host Dashboard
* **Path:** Host Mode → Tab "Dashboard" (premier onglet)
* **Action:** 
  1. Faire défiler vers le bas jusqu'à la section "My Posts" / "My Vehicles"
  2. Sur chaque carte de véhicule, cliquer sur le bouton **"Delete"** (bouton jaune à droite)
  3. Confirmer dans la boîte de dialogue
* **Current Status:** 🔴 **LIVE** (Appel HTTP actif à `Config.deleteItem`)
* **Fichier:** `dash_board_screen.dart:407`

### 📍 Localisation 2: Host Search Screen
* **Path:** Host Mode → Dashboard → Cliquer sur l'icône de recherche (en haut)
* **Action:**
  1. Rechercher un véhicule
  2. Sur chaque résultat, cliquer sur le bouton **"Delete"**
  3. Confirmer dans la boîte de dialogue
* **Current Status:** 🔴 **LIVE** (Appel HTTP actif à `Config.deleteItem`)
* **Fichier:** `hostsearch/host_search_screen.dart:64`

---

## 2. Get Cancel Reasons (Raisons d'Annulation)

### 📍 Localisation 1: Orders - Reject Button
* **Path:** Host Mode → Tab "Orders" → Tab "Upcoming" ou "Live"
* **Action:**
  1. Trouver une réservation avec le bouton **"Reject"** (rouge)
  2. Cliquer sur "Reject"
  3. Une bottom sheet s'ouvre avec les raisons d'annulation
* **Current Status:** 🔴 **LIVE** (Appel HTTP actif à `Config.getCancelReasons`)
* **Fichier:** `common_widget_host.dart:2004`

### 📍 Localisation 2: E-Receipt Screen - Cancel Button
* **Path:** Host Mode → Orders → Cliquer sur une réservation → E-Receipt Screen
* **Action:**
  1. Sur l'écran E-Receipt, cliquer sur le bouton **"Cancel"** (rouge en bas)
  2. Une bottom sheet s'ouvre avec les raisons d'annulation
* **Current Status:** 🔴 **LIVE** (Appel HTTP actif à `Config.getCancelReasons`)
* **Fichier:** `host_e_receipt.dart:117`

---

## 3. Update Delivery/Return Status (Mise à Jour Livraison/Retour)

### 📍 Localisation: Orders - Ongoing Bookings
* **Path:** Host Mode → Tab "Orders" → Tab "Live" (Ongoing)
* **Action:**
  1. Trouver une réservation en statut "Ongoing"
  2. Cliquer sur la carte de réservation pour ouvrir les détails
  3. Dans le bottom sheet, cliquer sur:
     - **"Mark as Delivered"** → Appelle `updateItemDeliveredStatus`
     - **"Mark as Returned"** → Appelle `updateItemReturnedStatus`
* **Current Status:** 🔴 **LIVE** (Appels HTTP actifs)
* **Fichiers:** 
  - `common_widget_host.dart:2190` (Delivered)
  - `common_widget_host.dart:2209` (Returned)

---

## 4. Get Item Details (Détails du Véhicule - Host Context)

### 📍 Localisation 1: Orders - View Vehicle Details
* **Path:** Host Mode → Tab "Orders" → N'importe quel tab (Upcoming/Live/Previous)
* **Action:**
  1. Cliquer sur une carte de réservation
  2. Dans le bottom sheet, cliquer sur **"View Vehicle Details"** ou l'icône de véhicule
  3. L'API est appelée pour charger les détails complets
* **Current Status:** 🔴 **LIVE** (Appel HTTP actif à `Config.getItemDetails`)
* **Fichier:** `common_widget_host.dart:2877, 3129, 3231` (3 occurrences)

---

## 5. Give Review By Host (Donner un Avis)

### 📍 Localisation: Orders - Previous/Completed Bookings
* **Path:** Host Mode → Tab "Orders" → Tab "Previous"
* **Action:**
  1. Trouver une réservation complétée (statut "Completed")
  2. Cliquer sur le bouton **"Add Review"** ou **"View Review"** (bleu)
  3. Une bottom sheet s'ouvre avec un formulaire de review
  4. Remplir la note (étoiles) et le message
  5. Cliquer sur "Submit"
* **Current Status:** 🔴 **LIVE** (Appel HTTP actif à `Config.giveReviewByHost`)
* **Fichier:** `common_widget_host.dart:4006`

---

## 6. E-Receipt Actions (Actions dans E-Receipt)

### 📍 Localisation: E-Receipt Screen
* **Path:** Host Mode → Tab "Orders" → Cliquer sur une réservation → E-Receipt Screen

### Action 1: Cancel Booking
* **Action:**
  1. Sur l'écran E-Receipt, cliquer sur le bouton **"Cancel"** (rouge)
  2. Sélectionner une raison d'annulation
  3. Confirmer l'annulation
* **Current Status:** 🔴 **LIVE** (Appel HTTP actif à `Config.cancelBookingByHost`)
* **Fichier:** `host_e_receipt.dart:186`

### Action 2: Confirm Booking
* **Action:**
  1. Sur l'écran E-Receipt d'une réservation "Pending"
  2. Cliquer sur le bouton **"Confirm"** (vert/bleu)
  3. Confirmer l'acceptation
* **Current Status:** 🔴 **LIVE** (Appel HTTP actif à `Config.confirmBookingByHost`)
* **Fichier:** `host_e_receipt.dart:325`

---

## 7. Calendar Management (Gestion du Calendrier)

### 📍 Localisation: Calendar Tab
* **Path:** Host Mode → Tab "Calendar" (deuxième onglet)

### Action 1: Load My Items (Charger les Véhicules)
* **Action:**
  1. Ouvrir le tab "Calendar"
  2. L'écran charge automatiquement la liste des véhicules
* **Current Status:** 🔴 **LIVE** (Appel HTTP actif à `Config.myItems`)
* **Fichier:** `calender/calendar_common_screen.dart:72`

### Action 2: Get Item Dates (Charger les Dates)
* **Action:**
  1. Dans le tab "Calendar", sélectionner un véhicule
  2. Le calendrier se charge avec les dates disponibles/indisponibles
* **Current Status:** 🔴 **LIVE** (Appel HTTP actif à `Config.getItemDates`)
* **Fichier:** `calender/calendar_common_screen.dart:85`

### Action 3: Add/Edit Calendar (Sauvegarder le Calendrier)
* **Path:** Calendar Tab → Sélectionner des dates → Cliquer sur "Save" ou "Update"
* **Action:**
  1. Marquer des dates comme disponibles/indisponibles
  2. Cliquer sur le bouton de sauvegarde
* **Current Status:** 🔴 **LIVE** (Appel HTTP actif à `Config.addEditCalender`)
* **Fichiers:** 
  - `calender/calendar_common_screen.dart:253`
  - `calender/edit_calander_third_step_common.dart:155`

### Action 4: Edit Calendar - Get Item Dates
* **Path:** Calendar Tab → Edit Mode → Step 3
* **Action:**
  1. En mode édition, aller à l'étape 3 du calendrier
  2. Les dates sont chargées automatiquement
* **Current Status:** 🔴 **LIVE** (Appel HTTP actif à `Config.getItemDates`)
* **Fichier:** `calender/edit_calander_third_step_common.dart:174`

---

## 8. Add Payment Method (Ajouter une Méthode de Paiement)

### 📍 Localisation: Wallet - Payment Methods
* **Path:** Host Mode → Account Tab → Financial Report → Wallet Tab → Cliquer sur "Add Payment Method" ou "Manage Payment Methods"
* **Action:**
  1. Aller dans Wallet
  2. Cliquer sur "Add Payment Method" ou "Manage Payment Methods"
  3. Remplir le formulaire (Bank Account, Stripe, etc.)
  4. Cliquer sur "Save" ou "Add"
* **Current Status:** 🔴 **LIVE** (Appel HTTP actif à `Config.addPaymentMethod`)
* **Fichier:** `wallet/payment_method_screen.dart:178`

---

## Résumé des Chemins de Test

| # | Fonctionnalité | Écran Principal | Action Spécifique | Status |
|---|----------------|----------------|-------------------|--------|
| 1 | Delete Item | Dashboard / Search | Bouton "Delete" sur carte véhicule | 🔴 LIVE |
| 2 | Get Cancel Reasons | Orders / E-Receipt | Bouton "Reject" ou "Cancel" | 🔴 LIVE |
| 3 | Update Delivery | Orders → Live | "Mark as Delivered" | 🔴 LIVE |
| 3 | Update Return | Orders → Live | "Mark as Returned" | 🔴 LIVE |
| 4 | Get Item Details | Orders | "View Vehicle Details" | 🔴 LIVE |
| 5 | Give Review | Orders → Previous | Bouton "Add Review" | 🔴 LIVE |
| 6 | Cancel Booking (E-Receipt) | E-Receipt | Bouton "Cancel" | 🔴 LIVE |
| 6 | Confirm Booking (E-Receipt) | E-Receipt | Bouton "Confirm" | 🔴 LIVE |
| 7 | Calendar - My Items | Calendar Tab | Chargement automatique | 🔴 LIVE |
| 7 | Calendar - Get Dates | Calendar Tab | Sélection véhicule | 🔴 LIVE |
| 7 | Calendar - Save | Calendar Tab | Bouton "Save" | 🔴 LIVE |
| 8 | Add Payment Method | Wallet | Formulaire de paiement | 🔴 LIVE |

---

## Notes Importantes

- **Tous les appels HTTP actifs** doivent être mockés pour permettre le fonctionnement offline
- Les **appels Google Maps API** (géocodage) dans `add_items_host_controller.dart` sont **intentionnellement laissés actifs** car ils sont nécessaires pour la fonctionnalité de localisation
- Après le mock, tester chaque fonctionnalité pour s'assurer qu'elle fonctionne avec les données statiques

