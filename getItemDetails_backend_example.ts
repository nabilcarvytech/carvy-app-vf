// ============================================
// EXEMPLE DE CODE BACKEND POUR getItemDetails
// ============================================
// 
// Ce fichier montre comment ajouter les logs de debug
// et mapper correctement les règles du véhicule dans votre contrôleur Node.js/Express.
//
// À intégrer dans votre contrôleur getItemDetails
//

// ========== EXEMPLE DE FONCTION getItemDetails ==========

export const getItemDetails = async (req: Request, res: Response) => {
  try {
    const { item_id } = req.body;

    if (!item_id) {
      return res.status(400).json({
        status: 400,
        message: "item_id is required",
      });
    }

    // Recherche du véhicule avec populate des règles
    const vehicle = await Vehicle.findById(item_id)
      .populate('rules') // Assure-toi que le champ s'appelle bien 'rules' dans ton schéma
      .lean();

    if (!vehicle) {
      return res.status(404).json({
        status: 404,
        message: "Vehicle not found",
      });
    }

    // ========== DEBUG RULES - AVANT MAPPING ==========
    console.log('🔍 [DEBUG RULES] Raw rules array:', vehicle.rules);
    console.log('🔍 [DEBUG RULES] Rules type:', typeof vehicle.rules);
    console.log('🔍 [DEBUG RULES] Rules is array?', Array.isArray(vehicle.rules));
    
    // Vérifie si le populate a fonctionné
    if (vehicle.rules && vehicle.rules.length > 0) {
      console.log('🔍 [DEBUG RULES] First rule content:', vehicle.rules[0]);
      console.log('🔍 [DEBUG RULES] First rule type:', typeof vehicle.rules[0]);
      console.log('🔍 [DEBUG RULES] First rule keys:', Object.keys(vehicle.rules[0] || {}));
    } else {
      console.log('⚠️ [DEBUG RULES] Rules array is empty or undefined!');
      console.log('⚠️ [DEBUG RULES] vehicle.rules value:', vehicle.rules);
    }
    // ========== FIN DEBUG RULES ==========

    // ========== MAPPING DES RÈGLES ==========
    // Convertit le tableau d'objets rules en tableau de strings
    let vehicleRules: string[] = [];
    
    if (vehicle.rules && Array.isArray(vehicle.rules)) {
      vehicleRules = vehicle.rules.map((r: any) => {
        // Si c'est un objet avec un champ 'name' ou 'description'
        if (typeof r === 'object' && r !== null) {
          return r.name || r.description || r.title || r.rule || '';
        }
        // Si c'est déjà une string
        if (typeof r === 'string') {
          return r;
        }
        // Fallback: convertir en string
        return String(r);
      }).filter((rule: string) => rule.trim() !== ''); // Enlève les règles vides
      
      console.log('✅ [DEBUG RULES] Mapped vehicleRules:', vehicleRules);
      console.log('✅ [DEBUG RULES] Mapped vehicleRules length:', vehicleRules.length);
    } else {
      console.log('⚠️ [DEBUG RULES] vehicle.rules is not an array or is null');
      vehicleRules = [];
    }
    // ========== FIN MAPPING DES RÈGLES ==========

    // Construction de la réponse JSON
    const responseData = {
      status: 200,
      message: "Vehicle details retrieved successfully",
      data: {
        ItemDetails: {
          item_id: vehicle._id?.toString() || "",
          title: vehicle.title || "",
          price: vehicle.price?.toString() || "",
          description: vehicle.description || "",
          
          // ... autres champs ...
          
          // ========== IMPORTANT: Ajouter vehicle_rules dans la réponse ==========
          vehicle_rules: vehicleRules, // Tableau de strings
          // ========== FIN vehicle_rules ==========
          
          cancellation_reason: cancellationReason || "",
          
          // ... autres champs ...
        },
      },
    };

    // ========== DEBUG FINAL - VÉRIFICATION DE LA RÉPONSE ==========
    console.log('🔍 [DEBUG RULES] Final response vehicle_rules:', responseData.data.ItemDetails.vehicle_rules);
    console.log('🔍 [DEBUG RULES] Final response vehicle_rules type:', typeof responseData.data.ItemDetails.vehicle_rules);
    console.log('🔍 [DEBUG RULES] Final response vehicle_rules is array?', Array.isArray(responseData.data.ItemDetails.vehicle_rules));
    // ========== FIN DEBUG FINAL ==========

    return res.status(200).json(responseData);

  } catch (error: any) {
    console.error('❌ [ERROR] getItemDetails error:', error);
    return res.status(500).json({
      status: 500,
      message: "Internal server error",
      error: error.message,
    });
  }
};

// ============================================
// NOTES IMPORTANTES:
// ============================================
//
// 1. Assure-toi que ton schéma Vehicle a bien un champ 'rules' qui référence 
//    une collection de règles (par exemple, un array de ObjectIds qui référence
//    une collection 'Rule' ou 'VehicleRule').
//
// 2. Le populate() doit correspondre au nom du champ dans ton schéma.
//    Si ton champ s'appelle différemment (ex: 'vehicleRules', 'rulesList'), 
//    adapte le populate() en conséquence.
//
// 3. La structure des objets de règles peut varier. Le code ci-dessus essaie
//    plusieurs propriétés communes : 'name', 'description', 'title', 'rule'.
//    Adapte selon la structure réelle de tes règles en base.
//
// 4. Le champ 'vehicle_rules' dans la réponse JSON DOIT être un tableau de strings
//    (string[]), pas un tableau d'objets. C'est ce que le modèle Flutter attend.
//
// 5. Si tes règles sont directement stockées comme un array de strings dans le document
//    Vehicle (sans populate), tu peux simplifier le mapping :
//
//    const vehicleRules = Array.isArray(vehicle.rules) 
//      ? vehicle.rules.map(r => String(r))
//      : [];
//

