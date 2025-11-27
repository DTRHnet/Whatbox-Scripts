# Self-Correction Rules

## Error Handling
- Catch all exceptions
- Log error details
- Attempt automatic recovery
- Escalate only if recovery impossible

## Recovery Strategies
1. Retry with exponential backoff
2. Fallback to alternative methods
3. Use cached data if available
4. Revert to last known good state

## Validation
- Validate inputs before processing
- Check environment variables
- Verify file permissions
- Test connections before use

## Correction Process
1. Identify error
2. Log error context
3. Attempt correction
4. Verify correction success
5. Continue execution
6. Document correction in logs

