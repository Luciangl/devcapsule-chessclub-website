import test from 'node:test';
import assert from 'node:assert/strict';
import { isArchived, articleUrl } from '../src/lib/archive.mjs';
test('rolling two-year boundary is UTC calendar based, exact boundary stays current', () => {
  const now = new Date('2026-09-27T18:37:00Z');
  assert.equal(isArchived(new Date('2024-09-26'), now), true);
  assert.equal(isArchived(new Date('2024-09-27'), now), false);
  assert.equal(isArchived(new Date('2024-09-28'), now), false);
});
test('leap-day cutoff clamps to last valid day', () => {
  assert.equal(isArchived(new Date('2022-02-27'), new Date('2024-02-29')), true);
  assert.equal(isArchived(new Date('2022-02-28'), new Date('2024-02-29')), false);
});
test('archive URLs contain year and current URLs stay under news', () => {
  const now = new Date('2026-09-27');
  assert.equal(
    articleUrl({ id: 'story', data: { date: new Date('2023-05-10') } }, now),
    '/arhiva/2023/story/',
  );
  assert.equal(
    articleUrl({ id: 'story', data: { date: new Date('2025-05-10') } }, now),
    '/noutati/story/',
  );
});
