# Secure Code Generation Rules

## Security Principles
- Never hardcode secrets
- Use environment variables for sensitive data
- Validate all inputs
- Sanitize outputs
- Use parameterized queries

## Secret Management
- Store secrets in .env file
- Never commit .env files
- Use .env.example as template
- Rotate secrets regularly

## Input Validation
- Validate all user inputs
- Check data types
- Enforce length limits
- Sanitize special characters

## Output Sanitization
- Escape HTML/XML in outputs
- Validate JSON structure
- Check file permissions
- Limit error message details

## Dependencies
- Keep dependencies updated
- Scan for vulnerabilities
- Use trusted sources
- Review dependency licenses

