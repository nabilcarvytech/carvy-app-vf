# Guide de Test - Host Module (Fonctionnalités Mockées)

Ce guide explique comment tester toutes les fonctionnalités mockées dans le module Host.

---

## 📅 1. Calendar Management

### Test 1.1: Calendar Common Screen (Calendrier Principal)

**Chemin UI:**
```
Host Mode → Bottom Navigation → Tab "Calendar" (ou icône calendrier)
```

**Actions à tester:**
1. **Vérifier la liste des véhicules:**
   - L'écran doit afficher un dropdown avec les véhicules mockés (Toyota Camry 2023, Tesla Model 3 2022)
   - Cliquer sur la flèche vers le bas pour voir la liste complète
   - Sélectionner un véhicule différent

2. **Vérifier l'affichage des dates dans le calendrier:**
   - **Dates disponibles (bleu/orange):** 2025-12-20 à 2025-12-24 avec prix affichés
   - **Dates non disponibles (rouge):** 2025-12-25 à 2025-12-27 (bloquées)
   - **Dates réservées (vert):** 2025-12-28 à 2025-12-29 (déjà bookées)

3. **Tester la sélection de dates:**
   - Sélectionner une plage de dates dans le calendrier
   - Le bouton "Edit" doit apparaître en bas à droite
   - Cliquer sur "Edit"
   - Un modal doit s'ouvrir pour définir le prix et le statut (Available/Not Available)

4. **Tester la soumission du calendrier:**
   - Dans le modal, cocher "Available" ou "Not Available"
   - Entrer un prix (si Available)
   - Cliquer sur "Submit"
   - ✅ **Résultat attendu:** Message "Calendar updated successfully" après 2 secondes
   - ✅ **Navigation:** Retour automatique au Dashboard Host

---

### Test 1.2: Edit Calendar Third Step (Calendrier lors de l'édition d'un véhicule)

**Chemin UI:**
```
Host Mode → Dashboard → Sélectionner un véhicule → "Edit" → 
Étapes du formulaire → Step 3 (Calendar)
```

**Actions à tester:**
1. **Vérifier le chargement des dates:**
   - Les dates mockées doivent s'afficher (même structure que Test 1.1)

2. **Tester la modification des dates:**
   - Sélectionner une nouvelle plage de dates
   - Cliquer sur "Edit"
   - Définir le prix et le statut
   - Cliquer sur "Submit"
   - ✅ **Résultat attendu:** Message "Calendar updated successfully"
   - ✅ **Navigation:** Retour à l'écran de calendrier (refresh)

---

## 💳 2. Add Payment Method

**Chemin UI:**
```
Host Mode → Bottom Navigation → Tab "Wallet" (ou "Finance") → 
"Payment Options" ou "Payment Method"
```

**Actions à tester:**
1. **Vérifier la liste des méthodes de paiement:**
   - L'écran doit afficher les méthodes disponibles (Bank Account, PayPal, etc.)
   - Chaque méthode doit avoir un statut : "(Not Configured)", "(Active)", ou "(Inactive)"

2. **Tester l'ajout d'une méthode de paiement:**
   - Cliquer sur l'icône "+" ou "Edit" à côté d'une méthode
   - Remplir le formulaire :
     - **Pour Bank Account:** Account Name, Bank Name, Branch Name, Account Number, IBAN, Swift Code
     - **Pour PayPal:** Email, Note
   - Cliquer sur "Save" ou "Submit"
   - ✅ **Résultat attendu:** Message "Bank account added successfully" après 2 secondes

3. **Tester l'activation/désactivation d'une méthode:**
   - Si une méthode est déjà configurée, un switch doit être visible
   - Activer/Désactiver le switch
   - ✅ **Résultat attendu:** Message "Payment method status updated successfully"
   - ✅ **UI Update:** Le statut doit changer entre "(Active)" et "(Inactive)"

---

## 🔍 3. Host Search (My Posts)

**Chemin UI:**
```
Host Mode → Bottom Navigation → Tab "Search" (ou icône de recherche)
```

**Actions à tester:**
1. **Vérifier la liste initiale:**
   - L'écran doit afficher 2 véhicules mockés :
     - Toyota Camry 2023
     - Tesla Model 3 2022
   - Chaque véhicule doit avoir une image, titre, description

2. **Tester la recherche:**
   - Taper "Toyota" dans la barre de recherche
   - ✅ **Résultat attendu:** La liste doit se filtrer (dans le mock, les 2 véhicules restent visibles)
   - Taper "Tesla"
   - ✅ **Résultat attendu:** La liste doit se filtrer

3. **Tester la suppression d'un véhicule:**
   - Cliquer sur l'icône "Delete" (poubelle) sur un véhicule
   - Confirmer la suppression dans le dialog
   - ✅ **Résultat attendu:** Message "Vehicle deleted successfully" après 1 seconde
   - ✅ **UI Update:** Le véhicule doit disparaître de la liste
   - ✅ **Refresh:** Après refresh (pull down), le véhicule réapparaît (car c'est du mock statique)

4. **Tester l'édition d'un véhicule:**
   - Cliquer sur l'icône "Edit" sur un véhicule
   - ✅ **Navigation:** Doit naviguer vers l'écran d'édition

5. **Tester les détails d'un véhicule:**
   - Cliquer sur la carte du véhicule
   - ✅ **Navigation:** Doit afficher les détails du véhicule

---

## ✅ Checklist de Vérification

### Calendar Management:
- [ ] La liste des véhicules s'affiche dans le dropdown
- [ ] Les dates disponibles s'affichent en bleu/orange avec prix
- [ ] Les dates non disponibles s'affichent en rouge
- [ ] Les dates réservées s'affichent en vert
- [ ] Le bouton "Edit" apparaît après sélection de dates
- [ ] Le modal de prix s'ouvre correctement
- [ ] La soumission retourne "Calendar updated successfully"
- [ ] La navigation fonctionne après soumission

### Payment Method:
- [ ] La liste des méthodes de paiement s'affiche
- [ ] Le formulaire d'ajout s'ouvre correctement
- [ ] La soumission retourne "Bank account added successfully"
- [ ] Le switch d'activation/désactivation fonctionne
- [ ] Le statut se met à jour après activation/désactivation

### Host Search:
- [ ] La liste initiale affiche 2 véhicules
- [ ] La recherche fonctionne (filtre la liste)
- [ ] La suppression fonctionne avec confirmation
- [ ] L'édition navigue vers l'écran d'édition
- [ ] Les détails du véhicule s'affichent

---

## 🐛 Problèmes Potentiels et Solutions

### Problème 1: "Calendar dates not showing"
**Solution:** Vérifier que `Config.getItemDates` est bien mocké dans `calendar_common_screen.dart` ligne 85-86

### Problème 2: "Payment method not saving"
**Solution:** Vérifier que `Config.addPaymentMethod` est bien mocké dans `payment_method_screen.dart` ligne 178

### Problème 3: "Search returns empty list"
**Solution:** Vérifier que `Config.myItems` est bien mocké dans `host_search_screen.dart` ligne 47

### Problème 4: "Delete item not working"
**Solution:** Vérifier que `Config.deleteItem` est bien mocké dans `host_search_screen.dart` ligne 65

---

## 📝 Notes Importantes

1. **Tous les mocks utilisent `Future.delayed`** pour simuler la latence réseau (1-2 secondes)
2. **Les données sont statiques** : après un refresh, les données reviennent à leur état initial
3. **Les contrats API sont documentés** dans `API_CONTRACTS.md` sous `## Host - Calendar & Finance`
4. **Après implémentation Node.js** : Supprimer tous les commentaires `// ========== MOCK DATA ==========` et décommenter les appels HTTP réels

---

## 🎯 Points de Test Critiques

1. ✅ **Aucun appel HTTP réel** ne doit être fait (vérifier dans les logs réseau)
2. ✅ **Tous les messages de succès** doivent s'afficher correctement
3. ✅ **La navigation** doit fonctionner après chaque action
4. ✅ **Les données mockées** doivent être cohérentes avec les modèles Dart
5. ✅ **Les erreurs de parsing** ne doivent pas apparaître (vérifier la console)

---

**Date de création:** $(date)
**Dernière mise à jour:** Après migration Calendar & Payment Method

