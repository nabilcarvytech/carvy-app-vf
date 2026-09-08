#!/usr/bin/env node
/**
 * A3 — Backfill vehicleLocation FK from location.city (text)
 *
 * Prod catalogue (VehicleLocation active, cityName asc):
 *   Casablanca  69b0c0bc779cb5b5056cd944
 *   Marrakech   69b0c1f6779cb5b5056cd9ea
 *   Rabat       69b0b9f7779cb5b5056cd705
 *   Salé        69512935eee94e05f0cd3212
 *
 * Usage (on server with Mongo access):
 *   node backend/scripts/backfill-vehicle-location-fk.js              # dry-run (default)
 *   node backend/scripts/backfill-vehicle-location-fk.js --execute  # apply writes
 *   node backend/scripts/backfill-vehicle-location-fk.js --rollback   # undo A2 list only
 *
 * Env:
 *   MONGODB_URI=mongodb+srv://...   (required)
 *   DB_NAME=carvy                   (optional, inferred from URI if omitted)
 */

const { MongoClient, ObjectId } = require('mongodb');

const CITY_MAP = [
  {
    cityName: 'Casablanca',
    vehicleLocationId: '69b0c0bc779cb5b5056cd944',
    regex: /^casablanca$/i,
  },
  {
    cityName: 'Marrakech',
    vehicleLocationId: '69b0c1f6779cb5b5056cd9ea',
    regex: /^marrakech$/i,
  },
  {
    cityName: 'Rabat',
    vehicleLocationId: '69b0b9f7779cb5b5056cd705',
    regex: /^rabat$/i,
  },
  {
    cityName: 'Salé',
    vehicleLocationId: '69512935eee94e05f0cd3212',
    regex: /^sal[eé]$/i,
  },
];

/** Known orphans from A2 audit — used for post-run verification. */
const A2_EXPECTED = [
  { _id: '69e0c4eaeab02219dd551c70', city: 'casablanca', target: '69b0c0bc779cb5b5056cd944' },
  { _id: '6a25ab1b0711149d9cf9308d', city: 'rabat', target: '69b0b9f7779cb5b5056cd705' },
  { _id: '6a224d9d59cd76ce158945f0', city: 'rabat', target: '69b0b9f7779cb5b5056cd705', note: 'isVerified:false — FK ok but invisible in item-search' },
  { _id: '6a0789a86f4ca96d2cc14505', city: 'rabat', target: '69b0b9f7779cb5b5056cd705' },
  { _id: '69e3df4beab02219dd5584af', city: 'rabat', target: '69b0b9f7779cb5b5056cd705' },
];

const PRICE_MIN = 10;
const PRICE_MAX = 500;

const args = process.argv.slice(2);
const EXECUTE = args.includes('--execute');
const ROLLBACK = args.includes('--rollback');

function oid(id) {
  return new ObjectId(id);
}

function resolveCity(cityText) {
  if (!cityText || typeof cityText !== 'string') return null;
  const trimmed = cityText.trim();
  return CITY_MAP.find((c) => c.regex.test(trimmed)) || null;
}

function inDefaultPriceRange(basePrice) {
  const n = Number(basePrice);
  return Number.isFinite(n) && n >= PRICE_MIN && n <= PRICE_MAX;
}

function pickDbName(uri) {
  const match = uri.match(/mongodb(\+srv)?:\/\/[^/]+\/([^?]+)/);
  return match?.[2] || process.env.DB_NAME || 'carvy';
}

async function findCandidates(collection) {
  const rows = [];

  for (const city of CITY_MAP) {
    const cursor = collection.find(
      {
        isActive: true,
        'location.city': city.regex,
        $or: [{ vehicleLocation: { $exists: false } }, { vehicleLocation: null }],
      },
      {
        projection: {
          _id: 1,
          'location.city': 1,
          vehicleLocation: 1,
          isVerified: 1,
          'pricing.basePrice': 1,
        },
      }
    );

    for await (const doc of cursor) {
      rows.push({
        _id: doc._id.toString(),
        cityText: doc.location?.city ?? '',
        targetCityName: city.cityName,
        targetOid: city.vehicleLocationId,
        isVerified: doc.isVerified === true,
        basePrice: doc.pricing?.basePrice ?? null,
        wouldAppearSearch10_500:
          doc.isVerified === true && inDefaultPriceRange(doc.pricing?.basePrice),
      });
    }
  }

  return rows;
}

async function findConflicts(collection) {
  const conflicts = [];

  for (const city of CITY_MAP) {
    const targetOid = oid(city.vehicleLocationId);
    const cursor = collection.find(
      {
        isActive: true,
        'location.city': city.regex,
        vehicleLocation: { $exists: true, $ne: null, $nin: [targetOid] },
      },
      {
        projection: {
          _id: 1,
          'location.city': 1,
          vehicleLocation: 1,
          isVerified: 1,
        },
      }
    );

    for await (const doc of cursor) {
      conflicts.push({
        _id: doc._id.toString(),
        cityText: doc.location?.city ?? '',
        expected: city.vehicleLocationId,
        actual: String(doc.vehicleLocation),
      });
    }
  }

  return conflicts;
}

function printTable(rows) {
  if (rows.length === 0) {
    console.log('  (none)');
    return;
  }
  console.table(rows);
}

function verifyA2Coverage(rows) {
  const foundIds = new Set(rows.map((r) => r._id));
  console.log('\n--- A2 expected orphans ---');
  for (const exp of A2_EXPECTED) {
    const ok = foundIds.has(exp._id);
    const flag = ok ? 'OK' : 'MISSING (already linked or inactive?)';
    console.log(`  ${exp._id}  ${exp.city} → ${exp.target}  [${flag}]${exp.note ? `  (${exp.note})` : ''}`);
  }
}

async function applyBackfill(collection, rows) {
  let updated = 0;
  for (const row of rows) {
    const result = await collection.updateOne(
      {
        _id: oid(row._id),
        $or: [{ vehicleLocation: { $exists: false } }, { vehicleLocation: null }],
      },
      { $set: { vehicleLocation: oid(row.targetOid) } }
    );
    if (result.modifiedCount === 1) updated += 1;
  }
  return updated;
}

async function rollbackA2(collection) {
  const ids = A2_EXPECTED.map((e) => oid(e._id));
  const result = await collection.updateMany(
    { _id: { $in: ids } },
    { $unset: { vehicleLocation: '' } }
  );
  return result.modifiedCount;
}

async function main() {
  const uri = process.env.MONGODB_URI;
  if (!uri) {
    console.error('ERROR: set MONGODB_URI');
    process.exit(1);
  }

  const client = new MongoClient(uri);
  await client.connect();
  const db = client.db(pickDbName(uri));
  const vehicles = db.collection('vehicles');

  try {
    if (ROLLBACK) {
      if (!EXECUTE) {
        console.log('ROLLBACK dry-run — would $unset vehicleLocation on A2 list:');
        console.log(A2_EXPECTED.map((e) => e._id).join('\n'));
        console.log('\nRe-run with --rollback --execute to apply.');
        return;
      }
      const n = await rollbackA2(vehicles);
      console.log(`Rollback done: ${n} document(s) updated.`);
      return;
    }

    const mode = EXECUTE ? 'EXECUTE' : 'DRY-RUN';
    console.log(`\n=== A3 backfill vehicleLocation [${mode}] ===\n`);

    const conflicts = await findConflicts(vehicles);
    if (conflicts.length) {
      console.log('CONFLICTS (vehicleLocation set but ≠ catalogue — NOT auto-updated):');
      printTable(conflicts);
    } else {
      console.log('Conflicts: none\n');
    }

    const candidates = await findCandidates(vehicles);
    console.log(`Candidates (${candidates.length}):`);
    printTable(candidates);

    const byCity = {};
    for (const row of candidates) {
      byCity[row.targetCityName] = (byCity[row.targetCityName] || 0) + 1;
    }
    console.log('\nCount by target city:', byCity);

    verifyA2Coverage(candidates);

    const visibleAfter = candidates.filter((r) => r.wouldAppearSearch10_500);
    console.log(`\nWould become visible in item-search (verified + price 10-500): ${visibleAfter.length}`);
    if (visibleAfter.length) printTable(visibleAfter);

    if (!EXECUTE) {
      console.log('\nNo writes (dry-run). Re-run with --execute to apply.');
      console.log('\nPost-apply validation (Rabat example):');
      console.log('  curl -X POST https://carvy.tech/api/v1/item-search \\');
      console.log('    -H "Content-Type: application/json" \\');
      console.log('    -d \'{"city":"Rabat","city_id":"69b0b9f7779cb5b5056cd705","price":"10-500","item_type":"0"}\'');
      return;
    }

    const updated = await applyBackfill(vehicles, candidates);
    console.log(`\nApply done: ${updated} document(s) updated.`);

    const remaining = await findCandidates(vehicles);
    console.log(`Remaining orphans after apply: ${remaining.length}`);
  } finally {
    await client.close();
  }
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
