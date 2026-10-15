// ============================================
// EXEMPLE DE CODE BACKEND POUR getItemDetails
// ============================================
//
// Ce fichier montre comment peupler les règles véhicule
// (rules / customRules) et renvoyer des libellés explicites
// plutôt que des ObjectIds MongoDB.
//
// À intégrer dans votre contrôleur getItemDetails (Node.js / Express / Mongoose).
//

const extractRuleLabel = (r: any): string => {
  if (r == null) return '';
  if (typeof r === 'string') {
    // Un ObjectId brut n'est pas un libellé affichable.
    if (/^[0-9a-fA-F]{24}$/.test(r.trim())) return '';
    return r.trim();
  }
  if (typeof r === 'object') {
    const label =
      r.title ||
      r.name ||
      r.rule_name ||
      r.ruleName ||
      r.description ||
      r.text ||
      r.rule ||
      r.label ||
      '';
    return String(label).trim();
  }
  return '';
};

const mapRulesToLabels = (rules: any): string[] => {
  if (!Array.isArray(rules)) return [];
  return rules
    .map(extractRuleLabel)
    .filter((label: string) => label.length > 0);
};

export const getItemDetails = async (req: Request, res: Response) => {
  try {
    const { item_id } = req.body;

    if (!item_id) {
      return res.status(400).json({
        status: 400,
        message: "item_id is required",
      });
    }

    // Peupler les références de règles pour renvoyer titre / nom / description.
    const vehicle = await Vehicle.findById(item_id)
      .populate('rules')
      .populate('customRules')
      .lean();

    if (!vehicle) {
      return res.status(404).json({
        status: 404,
        message: "Vehicle not found",
      });
    }

    const vehicleRules = [
      ...mapRulesToLabels(vehicle.rules),
      ...mapRulesToLabels(vehicle.customRules),
    ];

    const responseData = {
      status: 200,
      message: "Vehicle details retrieved successfully",
      data: {
        ItemDetails: {
          item_id: vehicle._id?.toString() || "",
          title: vehicle.title || "",
          price: vehicle.price?.toString() || "",
          description: vehicle.description || "",

          // Tableau de strings (libellés), jamais d'ObjectIds.
          vehicle_rules: vehicleRules,
          rules: vehicle.rules,
          customRules: vehicle.customRules,
        },
      },
    };

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

// NOTES:
// 1. Adapter le nom des champs (rules / customRules) au schéma Vehicle.
// 2. Si les règles sont déjà des strings en base, mapRulesToLabels les conserve
//    sauf si ce sont des ObjectIds 24 hex.
// 3. L'app Flutter mappe aussi les IDs restants via /api/vehicle-reference/rules.
