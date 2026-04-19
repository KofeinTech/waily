# Security Rules

## Secrets

- Never commit secrets, API keys, tokens, passwords, .env files, certificates, or signing keys
- All credentials in GitHub Actions secrets (per-repo)
- If a secret is accidentally committed, rotate it immediately -- the old value is compromised even after revert

## Denied File Patterns

Never read, display, or reference: `.env*`, `*.key`, `*.pem`, `*.p12`, `*.jks`, `**/credentials*`, `**/secrets*`, `**/service-account*.json`. Blocked at org level via managed permissions.

## OWASP Awareness

1. **Injection** -- parameterized queries only, never concatenate user input into SQL/commands/HTML
2. **Broken Auth** -- bcrypt/argon2 for passwords, enforce token expiry
3. **Data Exposure** -- never log sensitive data, never return full error stacks to clients
4. **Input Validation** -- validate all input with strong typing (Pydantic, Freezed, FluentValidation)
5. **Logging** -- log security events (login attempts, permission changes, data access)

## Dependencies

- Keep updated, prefer well-maintained packages, check health before adding

## Incident Response

1. Do NOT push fixes publicly until the vulnerability is understood
2. Create Jira ticket in IMP with label `security`, assign to CEO
3. Rotate exposed credentials first, then investigate
4. Document issue, root cause, and fix in the ticket
