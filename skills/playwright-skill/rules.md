# Playwright Automation Rules

## 1. Locator Strategy
- Banish fragile CSS/XPath selectors. Prioritize user-facing locators: `page.getByRole()`, `page.getByText()`, `page.getByPlaceholder()`.
- Use test ids (`data-testid`) only when user-facing locators are dynamic or ambiguous.

## 2. No Hardcoded Sleeps
- Never use `page.waitForTimeout()`.
- Rely exclusively on auto-waiting assertions (`expect(locator).toBeVisible()`) or explicit condition waiters (`page.waitForSelector()`, `page.waitForResponse()`).

## 3. Page Object Model (POM)
- Structure all complex user interactions inside Page Object classes to enforce DRY.
