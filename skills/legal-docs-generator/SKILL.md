---
name: legal-docs-generator
description: Generate Privacy Policies, Terms of Service, and other legal documents with 7-level verification.
---

# Legal Documentation Generator with 7-Level Verification

A comprehensive skill for generating Privacy Policies, Terms of Service, Terms & Conditions, Usage Policies, and Copyright Notices with **7-level legal verification** to ensure zero loopholes and full compliance.

## When to Use This Skill

- Creating Privacy Policy, Terms of Service, Terms & Conditions
- Generating Usage Policies and Copyright Notices
- Requiring rigorous legal verification (7-level gates)
- Building legally compliant apps/APIs
- Ensuring zero loopholes in legal documents
- Need both Markdown and HTML versions
- SocialPostDownloader, postDownloader API, or similar projects

## What This Skill Does

### 7-Level Verification Framework

Each document goes through **7 sequential verification stages**:

1. **Completeness Check** — All required sections present, no gaps
2. **Legal Compliance Check** — Adheres to GDPR, CCPA, DMCA, copyright law
3. **Platform Compliance Check** — Meets App Store, Google Play, API guidelines
4. **Content Loophole Check** — Identifies vague language, ambiguities, contradictions
5. **Liability & Risk Check** — Verifies liability limitations, indemnification, disclaimers
6. **Enforceability Check** — Ensures language is legally binding and defensible
7. **Final Legal Sign-Off** — Green/Red flag with detailed rationale

### Documents Generated

1. **Privacy Policy** — Data collection, processing, user rights, GDPR/CCPA compliance
2. **Terms of Service** — Usage rights, restrictions, IP ownership, account rules
3. **Terms & Conditions** — Legal obligations, warranties, liability limitations
4. **Usage Policy** — Prohibited activities, content policies, compliance rules
5. **Copyright Notice** — Copyright holder, usage rights, legal footer

### Output Formats

- **Markdown** — For in-app display, documentation
- **HTML** — For web display, static pages
- **API Endpoints** — Ready-to-serve versions for backend

## Usage

### Quick Start

```bash
npx skills add aravindhan/legal-docs-generator -g -y
```

Then use via slash command:

```
/legal-docs-generator --app-name "SocialPostDownloader" --company "Your Company" --jurisdiction "US,EU"
```

### Advanced Usage with Full Verification

```
/legal-docs-generator \
  --app-name "SocialPostDownloader" \
  --company "Your Company" \
  --company-email "legal@company.com" \
  --jurisdiction "US,EU,UK" \
  --data-processing true \
  --third-party-api true \
  --user-content true \
  --payment true \
  --verification-level 7 \
  --output-formats "markdown,html" \
  --include-api-endpoints true
```

### Verification Stages

The skill automatically runs through all 7 verification levels and provides:

- ✅ **PASS** — Green flag with confidence score
- ⚠️ **CONDITIONAL PASS** — Green with caveats and recommended amendments
- ❌ **FAIL** — Red flag with specific loopholes and fixes required

## Key Features

### Zero Loophole Detection

- Identifies vague liability disclaimers
- Detects contradictory language
- Flags missing indemnification clauses
- Catches inadequate IP protection language
- Verifies GDPR/CCPA right-to-deletion language

### Platform-Specific Compliance

- ✅ Apple App Store guidelines
- ✅ Google Play Store guidelines
- ✅ API terms compliance
- ✅ Export control (DMCA, EAR)
- ✅ Third-party integration rules

### Jurisdiction Support

- 🇺🇸 United States (federal + California, NY, Texas)
- 🇪🇺 EU (GDPR)
- 🇬🇧 UK (UK GDPR, common law)
- 🇨🇦 Canada (PIPEDA)
- 🇦🇺 Australia (Privacy Act)

## Output Example

Each document includes:

1. **Executive Summary** — Key points at a glance
2. **Full Legal Text** — Complete, legally binding language
3. **Verification Report** — 7-level verification results
4. **Amendment Notes** — Specific changes recommended
5. **Markdown Version** — For documentation/in-app display
6. **HTML Version** — For web rendering
7. **API Endpoint Template** — Ready to deploy

## Integration Examples

### React Native / Expo App

Display in Settings screen:

```javascript
import PrivacyPolicy from './legal/privacy-policy.md';

<ScrollView>
  <MarkdownRenderer content={PrivacyPolicy} />
</ScrollView>
```

### Fastify/Hono API

Serve as endpoints:

```javascript
app.get('/legal/privacy-policy', (req, res) => {
  res.send(privacyPolicyHTML);
});

app.get('/legal/terms', (req, res) => {
  res.send(termsOfServiceHTML);
});
```

### Static Site

Serve as pages:

```
/legal/privacy-policy.html
/legal/terms-of-service.html
/legal/terms-and-conditions.html
```

## Support

For questions about specific legal requirements:

- GDPR compliance → EU data protection authority guidance
- CCPA compliance → California Attorney General
- Apple guidelines → App Store Review Guidelines
- Google Play → Google Play Policies
- API terms → Platform-specific developer agreements

---

**Last Updated:** 2026-04-07  
**Verification Level:** 7-Stage Legal Review  
**Compliance:** GDPR, CCPA, DMCA, App Store, Google Play
