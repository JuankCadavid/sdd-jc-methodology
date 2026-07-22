# Architecture Styles & the Robust-vs-Lite Matrix

Style is chosen **after** scenarios and tactics exist (Decision Spine step 3). A style is a vocabulary of components/connectors plus constraints; it earns its place by satisfying the scenario set at the lowest complexity that works.

## Style Catalog — when each one wins

| Style | Core idea | Choose when scenarios show… | Watch out |
|---|---|---|---|
| **Layered / N-tier** | Presentation / business / data separation, dependencies point down | Simple CRUD systems, small teams, uniform scaling | Layer skipping, "lasagna" of anemic layers |
| **Hexagonal (Ports & Adapters)** | Domain core surrounded by ports (interfaces) and adapters (tech) | Modifiability scenarios: swap DB/API/provider without touching business rules | Overkill for pure pipelines/scripts |
| **Clean Architecture** | Entities → Use Cases → Interface Adapters → Frameworks; Dependency Rule points inward, framework-independent domain | Long-lived products, testability scenarios (domain testable without infra), multiple delivery mechanisms | Ceremony on tiny services; don't create 4 layers for a webhook |
| **Modular Monolith** | One deployable, hard module boundaries (enforced imports), per-module data ownership | Team ≤ ~8, uniform availability target, fast iteration + future split option | Boundary erosion — enforce with lint/build rules |
| **Microservices** | Independently deployable services, own data, contract-based communication | Independent scaling of hot paths, >1 team per deployable cadence, divergent availability/regulatory isolation | Distributed monolith; needs observability + delivery maturity first |
| **Event-Driven** | Producers/consumers via broker; choreography or orchestration | Async workflows, spiky load absorption, audit trails, fan-out | Eventual consistency is an ADR; idempotency + DLQs mandatory |
| **Serverless** | Functions + managed services, scale-to-zero | Spiky/unpredictable load, cost scenarios favoring pay-per-use, small ops team | Cold starts vs latency measures; vendor coupling is an accepted ADR |
| **CQRS / Event Sourcing** | Split write/read models; state as event log | Read/write asymmetry proven by measures; audit/replay requirements | The most-regretted premature escalation; demand hard evidence |

Styles compose: a serverless system with a hexagonal core, or microservices where each service is internally clean, are normal outcomes. Name the composition in the TRD.

## Robust-vs-Lite Decision Matrix (expanded)

Score each axis from the scenario set; the tier is decided per axis, not globally — a lite structure with robust data is valid.

| Axis | LITE default | Escalate to ROBUST when (scenario evidence) | ADR must state |
|---|---|---|---|
| Structure | Modular monolith (hexagonal/clean inside) | Hot path needs independent scaling; team topology exceeds one deploy cadence | Split boundaries + contract ownership |
| Compute | Serverless (Lambda) or one managed runtime (ECS/App Runner) | Sustained high utilization (serverless cost crossover), long-running/stateful work, cold starts break latency measures | Cost crossover math, latency data |
| Data | One primary DB + cache | Polyglot proven by access patterns; regulatory isolation; write/read asymmetry | Consistency model per store |
| Async | Direct calls; one queue for the genuinely async | Multi-step sagas, streaming volumes, cross-service choreography | Failure/compensation model |
| Delivery | One pipeline, trunk-based, IaC from day one | Many services × environments; progressive delivery needed by availability scenarios | Promotion + rollback strategy |
| AI | Single agent, managed API | Multi-agent only when task decomposition is proven (see `agentic-ai.md`) | Token cost order-of-magnitude |

Anti-rule: never escalate two axes "while we're at it." Each escalation cites its own scenario.

## Reference Stack Mapping (AKILI default expertise: AWS + Node.js/TypeScript)

Use the project's declared stack and `## Skill Map` first. When the project is greenfield and the user's ecosystem applies, these are the calibrated defaults — deviations (Go for CPU-bound hot paths, Python for ML/data) go through an ADR:

| Concern | LITE | ROBUST |
|---|---|---|
| API/backend | Lambda + API Gateway (Node/TS), or NestJS on a single runtime | NestJS services on ECS/EKS; Go for measured hot paths; FastAPI for ML-adjacent services |
| Frontend | Next.js / Astro (content) on managed hosting | Next.js/Angular with edge rendering, feature-flagged progressive delivery |
| Relational data | Single MySQL (RDS) / managed Postgres | Aurora, read replicas, partitioning; Oracle when the org mandates it |
| NoSQL | DynamoDB single-table for known access patterns | DynamoDB + streams; MongoDB for document-flexible domains |
| Async | SQS (+ one DLQ) | EventBridge/SNS fan-out, Step Functions sagas, Kinesis streaming |
| AI/RAG | Bedrock (or OpenAI/Anthropic API) + S3 Vectors | Bedrock multi-model routing, OpenSearch vector store, dedicated inference |
| IaC | CDK/SAM, one stack per app | CDK multi-stack/multi-account, pipelines per service |

## Clean/Hexagonal Layer Mapping for Node.js/TypeScript

The Dependency Rule: source dependencies point inward only; the domain imports nothing from outer layers; data crossing boundaries is plain structures.

```
src/
  domain/          # entities, value objects, domain services, ports (interfaces) — zero framework imports
  application/     # use cases orchestrating domain; transaction boundaries; input/output DTOs
  infrastructure/  # adapters: repositories (MySQL/Dynamo/Mongo), external APIs, message producers
  interfaces/      # delivery: HTTP controllers/resolvers (NestJS/Fastify), CLI, queue consumers
```

- NestJS: modules per bounded context; providers implement domain ports; controllers stay thin (map transport ↔ use case DTOs).
- Serverless: each handler is an `interfaces/` adapter invoking a use case — business logic never lives in the handler file.
- Test consequence (testability tactic): domain + application test with in-memory port fakes, no infra needed.

## Style → Scenario Traceability Block (TRD requirement)

End the Architecture Overview with a compact table: `Scenario ID → Tactic → Style/axis decision it justified`. If a style decision has no scenario row, it is preference — delete it or find its scenario.
