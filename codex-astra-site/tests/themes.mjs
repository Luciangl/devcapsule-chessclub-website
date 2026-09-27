import { chromium } from '@playwright/test';
import AxeBuilder from '@axe-core/playwright';
import assert from 'node:assert/strict';
import { mkdir } from 'node:fs/promises';
const base = process.env.SITE_URL || 'http://localhost:4324';
const artifacts = process.env.ARTIFACT_DIR || '/tmp/astra-themes';
await mkdir(artifacts, { recursive: true });
const browser = await chromium.launch({ args: ['--no-sandbox'] });
const context = await browser.newContext({ viewport: { width: 1440, height: 1000 } });
const page = await context.newPage();
const errors = [];
page.on('pageerror', (e) => errors.push(e.message));
await page.goto(base);
assert.equal(await page.locator('html').getAttribute('data-theme'), 'astra');
const options = await page
  .locator('#desktop-palette option')
  .evaluateAll((options) => options.map((o) => o.value));
assert.equal(options.length, 6);
await page.locator('#desktop-palette').focus();
await page.keyboard.press('Home');
await page.keyboard.press('ArrowDown');
assert.equal(
  await page.locator('html').getAttribute('data-theme'),
  'solarized',
  'Native dropdown supports keyboard selection',
);
const font = await page.locator('.topline').evaluate((e) => ({
  size: parseFloat(getComputedStyle(e).fontSize),
  weight: Number(getComputedStyle(e).fontWeight),
}));
assert.ok(font.size >= 14 && font.weight >= 600, JSON.stringify(font));
const palettes = [];
for (const id of options) {
  await page.goto(base);
  await page.locator('#desktop-palette').selectOption(id);
  assert.equal(await page.locator('html').getAttribute('data-theme'), id);
  assert.equal(await page.evaluate(() => localStorage.getItem('smartgalati-astra-theme')), id);
  const background = await page
    .locator('html')
    .evaluate((e) => getComputedStyle(e).backgroundColor);
  palettes.push(background);
  await page.reload();
  assert.equal(await page.locator('#desktop-palette').inputValue(), id);
  for (const route of ['/', '/contact/', '/galerie-foto/']) {
    await page.goto(base + route);
    assert.equal(await page.locator('html').getAttribute('data-theme'), id);
    const audit = await new AxeBuilder({ page })
      .withTags(['wcag2a', 'wcag2aa', 'wcag21aa'])
      .analyze();
    assert.deepEqual(
      audit.violations.map((v) => ({
        id: v.id,
        nodes: v.nodes.map((n) => ({ target: n.target, summary: n.failureSummary })),
      })),
      [],
      id + route,
    );
  }
  await page.goto(base);
  await page.evaluate(async () => {
    await document.fonts.ready;
    await Promise.all(
      [...document.images].map(async (image) => {
        image.loading = 'eager';
        await image.decode().catch(() => {});
      }),
    );
  });
  await page.screenshot({ path: `${artifacts}/${id}-desktop.png`, fullPage: true });
  for (const width of [320, 390, 768, 1024, 1440]) {
    await page.setViewportSize({ width, height: 900 });
    assert.ok(
      await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth),
      id + ' overflow ' + width,
    );
  }
}
assert.equal(new Set(palettes).size, 6, 'All six schemes have distinct backgrounds');
await page.setViewportSize({ width: 390, height: 844 });
await page.getByRole('button', { name: 'Meniu' }).click();
await page.locator('#mobile-palette').selectOption('solarized');
assert.equal(await page.locator('#desktop-palette').inputValue(), 'solarized');
await page.keyboard.press('Escape');
assert.equal(await page.locator('#main-nav').isVisible(), false);
await page.screenshot({ path: `${artifacts}/solarized-mobile.png`, fullPage: true });
const second = await context.newPage();
await second.goto(base);
await page.evaluate(() => localStorage.setItem('smartgalati-astra-theme', 'nord'));
await second.waitForFunction(() => document.documentElement.dataset.theme === 'nord');
await page.evaluate(() => localStorage.setItem('smartgalati-astra-theme', 'invalid-palette'));
await page.reload();
assert.equal(await page.locator('html').getAttribute('data-theme'), 'astra');
const blocked = await browser.newContext({ viewport: { width: 1440, height: 1000 } });
await blocked.addInitScript(() => {
  Object.defineProperty(window, 'localStorage', {
    get() {
      throw new DOMException('Storage blocked', 'SecurityError');
    },
  });
});
const noStorage = await blocked.newPage();
await noStorage.goto(base);
assert.equal(await noStorage.locator('html').getAttribute('data-theme'), 'astra');
await noStorage.locator('#desktop-palette').selectOption('latte');
assert.equal(await noStorage.locator('html').getAttribute('data-theme'), 'latte');
// The head bootstrap restores the theme even while the body module is unavailable.
const early = await browser.newContext();
await early.addInitScript(() => localStorage.setItem('smartgalati-astra-theme', 'gruvbox'));
await early.route('**/*.js', (route) => route.abort());
const earlyPage = await early.newPage();
await earlyPage.goto(base);
assert.equal(await earlyPage.locator('html').getAttribute('data-theme'), 'gruvbox');
assert.deepEqual(errors, []);
console.log(
  JSON.stringify(
    {
      themes: options,
      contrastPagesPerTheme: 3,
      viewports: [320, 390, 768, 1024, 1440],
      persistence: true,
      storageFallback: true,
      crossTab: true,
      earlyRestore: true,
      artifacts,
    },
    null,
    2,
  ),
);
await browser.close();
