---
name: security-audit
description: Runs systematic audits for common web security vulnerabilities (OWASP Top 10, SQL injection, XSS, CSRF, insecure unserialization, command injection, and JWT misuse).
---
# Security Auditing & Static Analysis Playbook

This skill instructs the agent to audit backend codebases for common security vulnerabilities and enforce modern defensive coding practices.

## Target Triggers
- `/security-audit`
- `"run vulnerability scan"`
- `"perform security audit"`

## Auditing Guidelines

### 1. OWASP Top 10 Checks
- **Broken Access Control**: Ensure endpoint auth checks exist and verify user permissions for specific resource IDs (no IDOR - Insecure Direct Object References).
- **Cryptographic Failures**: Check that secrets (API keys, salts, JWT secrets) are loaded strictly from environment variables or vault tools, never hardcoded. Verifybcrypt/argon2 usage for passwords.
- **Injection**: Verify that all SQL/NoSQL queries use parameterized queries/prepared statements or safe ORM binds. Look for raw string interpolation in queries.
- **Insecure Design & Security Misconfiguration**: Check CORS headers, security headers (Helmet), cookie flags (`HttpOnly`, `Secure`, `SameSite`).
- **Vulnerable and Outdated Components**: Audit package dependencies for known CVEs (using `npm audit`, `pip-audit`, etc.).

### 2. Static Analysis Tools
- If Semgrep or CodeQL are available in the path, propose running them.
- Look at security issues flagged in recent IDE feedback or linting.

### 3. JWT & Session Hardening
- Check that JWT signature verification is implemented and token expiry is enforced.
- Verify that keys are rotated or loaded securely.
- Ensure authentication middlewares are properly applied to protected routes.

## Recommended Action Plan
1. Scan endpoints for direct parameter bindings (e.g. `req.body.id` directly in database queries).
2. Scan for raw shell executions (`exec`, `spawn`, `os.system`) with unvalidated inputs.
3. Review cookie and session creation configs for security flags.
4. Run standard vulnerability scan tools (e.g., `npm audit`, `yarn audit`, or `cargo audit` as appropriate).
