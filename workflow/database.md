# Database Workflow

## Overview
Database operations and schema management for Whatbox scripts.

## Principles
- Use migrations for all schema changes
- Never modify production schemas directly
- Always backup before destructive operations
- Use transactions for multi-step operations

## Best Practices
- Index frequently queried columns
- Use connection pooling
- Implement retry logic for transient failures
- Log all database operations

## Script Integration
Each script should:
- Define its own database schema if needed
- Use environment variables for connection strings
- Implement proper error handling
- Include rollback mechanisms

