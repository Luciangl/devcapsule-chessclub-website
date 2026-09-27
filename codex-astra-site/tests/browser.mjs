import { chromium } from '@playwright/test';
import AxeBuilder from '@axe-core/playwright';
import assert from 'node:assert/strict';
import { readdir, mkdir } from 'node:fs/promises';
const base = process.env.SITE_URL || 'http://localhost:4323';
const artifacts = process.env.ARTIFACT_DIR || '/tmp/astra-browser';
await mkdir(artifacts, { recursive: true });
const browser = await chromium.launch({ args: ['--no-sandbox'] });
const context = await browser.newContext({ viewport: { width: 1440, height: 1000 } });
const page = await context.newPage();
const errors = [];
page.on('pageerror', (e) => errors.push(e.message));
async function visit(path) {
  const response = await page.goto(base + path);
  assert.equal(response.status(), 200, path);
  await page.evaluate(async () => {
    await document.fonts.ready;
    await Promise.all(
      [...document.querySelectorAll('img:not(#full-photo)')].map(async (image) => {
        image.loading = 'eager';
        try {
          await image.decode();
        } catch {}
      }),
    );
  });
}
const files = await readdir(new URL('../dist/', import.meta.url), { recursive: true });
const routes = files
  .filter((f) => f.endsWith('index.html'))
  .map((f) => '/' + f.replace(/index.html$/, ''));
const links = new Set();
for (const route of routes) {
  await visit(route);
  assert.equal(await page.locator('main h1').count(), 1, route + ' has one h1');
  assert.equal(await page.locator('html').getAttribute('lang'), 'ro');
  for (const href of await page
    .locator('a[href^="/"]')
    .evaluateAll((as) => as.map((a) => a.getAttribute('href'))))
    links.add(href.split('#')[0]);
  const images = await page
    .locator('img:not(#full-photo)')
    .evaluateAll((imgs) =>
      imgs.filter((i) => i.complete && i.naturalWidth === 0).map((i) => i.src),
    );
  assert.deepEqual(images, [], route + ' broken images');
}
for (const link of links) {
  assert.ok(routes.includes(link), `Internal link exists: ${link}`);
}
for (const width of [1440, 768, 390, 320]) {
  await page.setViewportSize({ width, height: 1000 });
  await visit('/');
  assert.ok(
    await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth),
    `home overflow ${width}`,
  );
  await page.screenshot({ path: `${artifacts}/home-${width}.png`, fullPage: true });
}
await page.setViewportSize({ width: 390, height: 844 });
await visit('/');
await page.getByRole('button', { name: 'Meniu' }).click();
assert.equal(await page.locator('#main-nav').isVisible(), true);
await page.keyboard.press('Escape');
assert.equal(await page.locator('#main-nav').isVisible(), false);
await page.getByRole('button', { name: 'Meniu' }).click();
await page.locator('#main-nav').getByRole('link', { name: 'Contact', exact: true }).click();
await page.getByRole('button', { name: 'Arată telefonul' }).click();
assert.equal(await page.locator('a[href="tel:+40758775206"]').count(), 1);
await page.getByRole('button', { name: 'Arată adresa de email' }).click();
assert.equal(await page.locator('a[href="mailto:smartsah@yahoo.com"]').count(), 1);
await visit('/galerie-foto/');
await page.locator('[data-album-filter="juniori-2016"]').click();
assert.equal(await page.locator('.gallery-button:visible').count(), 7);
await page.locator('.gallery-button:visible').first().click();
assert.equal(await page.locator('dialog').isVisible(), true);
const src = await page.locator('#full-photo').getAttribute('src');
await page.keyboard.press('ArrowRight');
assert.notEqual(await page.locator('#full-photo').getAttribute('src'), src);
await page.keyboard.press('Escape');
assert.equal(await page.locator('dialog').isVisible(), false);
assert.equal(await page.locator('.gallery-button:focus').count(), 1);
await visit('/noutati/');
if (await page.locator('[data-tag="blitz"]').count()) {
  await page.locator('[data-tag="blitz"]').click();
  const visible = await page.locator('[data-news-tags]:visible').all();
  for (const item of visible)
    assert.ok((await item.getAttribute('data-news-tags')).split(' ').includes('blitz'));
}
const violations = [];
const thirdPartyViolations = [];
for (const route of [
  '/',
  '/cursuri/',
  '/antrenori/',
  '/contact/',
  '/galerie-foto/',
  '/noutati/',
  '/arhiva/',
  '/lichess/',
]) {
  await visit(route);
  assert.ok(
    await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth),
    route + ' mobile overflow',
  );
  const result = await new AxeBuilder({ page })
    .withTags(['wcag2a', 'wcag2aa', 'wcag21aa'])
    .analyze();
  for (const violation of result.violations) {
    const owned = violation.nodes.filter((node) => node.target[0] !== 'iframe');
    const external = violation.nodes.filter((node) => node.target[0] === 'iframe');
    if (owned.length)
      violations.push({
        route,
        id: violation.id,
        nodes: owned.map((node) => ({ target: node.target, summary: node.failureSummary })),
      });
    if (external.length)
      thirdPartyViolations.push({
        route,
        id: violation.id,
        nodes: external.map((node) => node.target),
      });
  }
}
assert.deepEqual(errors, [], 'Browser runtime errors');
console.log(
  JSON.stringify(
    {
      routes: routes.length,
      internalLinks: links.size,
      violations,
      thirdPartyViolations,
      artifacts,
    },
    null,
    2,
  ),
);
await browser.close();
assert.deepEqual(violations, [], 'Accessibility checks');
