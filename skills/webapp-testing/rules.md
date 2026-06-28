# Web Application Testing Rules

## 1. Responsive Viewports
- Always test layouts on desktop (1280x800), tablet (768x1024), and mobile (375x667) screen sizes.
- Verify elements do not overflow the viewport boundary.

## 2. API Mocking
- Mock flaky third-party integrations (payments, map APIs, social logins) to keep test suites deterministic.
