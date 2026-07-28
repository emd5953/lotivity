import { expect, test, type Page } from '@playwright/test';

/** Walks the full profile-creation flow, leaving the app on For You. */
async function completeOnboarding(page: Page) {
  await page.goto('/welcome');

  await page.getByRole('button', { name: 'Continue with Google' }).click();

  await page.getByLabel('Name').fill('Rosa Delgado');
  await page.getByLabel('Date of birth').fill('1990-04-12');
  await page.getByRole('button', { name: 'Next' }).click();

  // Account type is pre-suggested from the DOB, so Next is already live.
  await expect(page.getByRole('radio', { name: 'General adult' })).toHaveAttribute(
    'aria-checked',
    'true',
  );
  await page.getByRole('button', { name: 'Next' }).click();

  await page.getByRole('checkbox', { name: 'Colombian' }).click();
  await page.getByRole('button', { name: 'Next' }).click();

  await page.getByRole('checkbox', { name: 'Spanish' }).click();
  await page.getByRole('button', { name: 'Next' }).click();

  await page.getByRole('checkbox', { name: 'Christian' }).click();
  await page.getByRole('checkbox', { name: 'Latin' }).click();
  await page.getByRole('button', { name: 'Next' }).click();

  await page.getByRole('button', { name: 'Skip' }).click();

  for (const interest of ['Running', 'Music', 'Cooking', 'Dance', 'Art', 'Reading']) {
    await page.getByRole('checkbox', { name: interest, exact: false }).first().click();
  }
  await page.getByRole('button', { name: 'Next' }).click();

  await expect(page.getByText('Rendering your community…')).toBeVisible();
  await page.waitForURL('**/for-you', { timeout: 10_000 });
}

test('onboarding lands on a personalized For You feed', async ({ page }) => {
  await completeOnboarding(page);

  await expect(page.getByRole('heading', { name: 'Hey, Rosa' })).toBeVisible();
  await expect(page.getByText('Millennial')).toBeVisible();

  // Cards must explain themselves (FR-FEED-3).
  const cards = page.getByRole('listitem');
  await expect(cards.first()).toBeVisible();
  await expect(page.getByText(/Because you follow|mi away/).first()).toBeVisible();
});

test('the exactly-six gate blocks and then releases', async ({ page }) => {
  await page.goto('/welcome');
  await page.getByRole('button', { name: 'Continue with Google' }).click();
  await page.getByLabel('Name').fill('Test User');
  await page.getByLabel('Date of birth').fill('1990-04-12');
  await page.getByRole('button', { name: 'Next' }).click();
  await page.getByRole('button', { name: 'Next' }).click(); // account type
  await page.getByRole('button', { name: 'Next' }).click(); // heritage
  await page.getByRole('button', { name: 'Next' }).click(); // languages
  await page.getByRole('button', { name: 'Next' }).click(); // culture
  await page.getByRole('button', { name: 'Next' }).click(); // relationship

  const next = page.getByRole('button', { name: 'Next' });
  await expect(next).toBeDisabled();

  for (const interest of ['Running', 'Music', 'Cooking', 'Dance', 'Art']) {
    await page.getByRole('checkbox', { name: interest, exact: false }).first().click();
  }
  await expect(page.getByText('Choose 1 more.')).toBeVisible();
  await expect(next).toBeDisabled();

  await page.getByRole('checkbox', { name: 'Reading', exact: false }).first().click();
  await expect(next).toBeEnabled();
});

test('a refresh mid-onboarding resumes with data intact', async ({ page }) => {
  await page.goto('/welcome');
  await page.getByRole('button', { name: 'Continue with Google' }).click();
  await page.getByLabel('Name').fill('Marcus Bell');
  await page.getByLabel('Date of birth').fill('1978-02-02');
  await page.getByRole('button', { name: 'Next' }).click();

  await page.reload();

  await expect(page.getByRole('radio', { name: 'Gen X' })).toHaveCount(0);
  await page.getByRole('button', { name: 'Back' }).click();
  await expect(page.getByLabel('Name')).toHaveValue('Marcus Bell');
  await expect(page.getByLabel('Date of birth')).toHaveValue('1978-02-02');
});

test('map radius and filters change the visible count', async ({ page }) => {
  await completeOnboarding(page);
  await page.getByRole('link', { name: 'Map' }).click();

  const count = page.getByText(/within \d+ mi/);
  await expect(count).toBeVisible();
  const atTwoMiles = await count.textContent();

  // Widen the radius: 2 mi → 10 mi.
  const slider = page.getByLabel(/Radius/);
  await slider.fill('4');
  await expect(count).not.toHaveText(atTwoMiles ?? '');

  // Narrowing the filter set must reduce the count.
  const widened = await count.textContent();
  await page.getByRole('checkbox', { name: /^Clubs/ }).click();
  await page.getByRole('checkbox', { name: /^Food/ }).click();
  await page.getByRole('checkbox', { name: /^Workshops/ }).click();
  await expect(count).not.toHaveText(widened ?? '');
});
