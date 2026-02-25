# Security & Governance (Generic)

## RBAC
- Permissions determine which KB scopes can be retrieved and whether workflows can be executed.
- Supervisors approve KB updates; agents cannot publish directly.

## AI Guardrails
- Answers must be grounded in approved KB sources.
- If sources are insufficient: system must escalate or request more context.
- Redaction: prevent PII/secrets from being stored in messages/logs.

## Auditing
- Log every question, KB articles used, and any workflow steps performed.
- Provide exportable audit reports for compliance review.

## Safe Operations
- Read-only integrations first.
- Any write action requires explicit user confirmation + elevated permissions + logging.
