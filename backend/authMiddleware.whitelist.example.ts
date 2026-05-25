/**
 * Exemple de correctif backend — à fusionner dans authMiddleware.ts (ou middleware global).
 *
 * Problème : après register (JWT émis, phoneVerified=false), l’app appelle
 * POST /api/v1/update-onesignal-id et reçoit 403.
 *
 * Solution : autoriser cette route avant vérification téléphone.
 */

function isAllowedPath(req: { path?: string; originalUrl?: string }): boolean {
  const path = (req.originalUrl ?? req.path ?? '').split('?')[0];

  const allowedPrefixes = [
  // ... routes existantes (login, register, verify-email-otp, etc.)
  ];

  const pushSyncPaths = [
    '/api/v1/update-onesignal-id',
    '/update-onesignal-id',
    '/api/update-onesignal-id',
  ];

  if (pushSyncPaths.some((p) => path === p || path.endsWith(p))) {
    return true;
  }

  return allowedPrefixes.some((p) => path.startsWith(p));
}

// Dans le middleware, avant le contrôle phoneVerified :
// if (isAllowedPath(req)) return next();
