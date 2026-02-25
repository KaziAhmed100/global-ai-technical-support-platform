# System Architecture — Global AI Technical Support Platform

## 1. Architecture Overview
A modular architecture with strict separation between:
- Knowledge & policy content
- AI orchestration
- Integrations to systems of record
- Security controls and auditing

## 2. Components
### A) Web UI (Support Portal)
- Chat interface (questions, answers, citations)
- Ticket panel (create/update)
- Workflow runner UI (step-by-step)
- KB browser/editor (role-restricted)

### B) API Backend
- Auth + RBAC enforcement
- Conversation management
- Ticket endpoints
- KB endpoints
- Workflow endpoints
- Audit log writer

### C) AI Orchestrator (Guardrailed)
- Retrieves relevant KB articles (RAG)
- Produces answers constrained to KB + policy
- Produces “draft” actions requiring human confirmation
- Applies redaction rules to prompts/logs

### D) Knowledge Base Store
- Articles, versions, tags, approvals
- Embeddings index (for retrieval)
- Article access scopes

### E) Integration Layer (Connectors)
- Connector interface: `search()`, `getById()`, `healthCheck()`
- Read-only by default for MVP
- Optional action layer (future): requires approvals + extra controls

### F) Logging & Monitoring
- Immutable audit log
- Metrics (latency, usage, escalations)
- Admin dashboards

## 3. Typical Request Flow
1. User submits question.
2. Backend authenticates user, retrieves role scopes.
3. Orchestrator:
   - redacts sensitive input (if needed),
   - retrieves top KB sources permitted for the user,
   - drafts an answer grounded in sources.
4. Backend returns answer + citations.
5. Audit record written.

## 4. Guardrails
- “Answer only from approved KB sources” policy.
- If sources insufficient: respond with “insufficient info” + suggest escalation.
- Prevent disallowed data exposure (PII, secrets, system admin instructions to unauthorized roles).

## 5. Deployment (generic)
- Can be deployed on-prem or cloud.
- Separate environments: dev / test / prod.
- CI checks: secret scanning, linting, docs build.
