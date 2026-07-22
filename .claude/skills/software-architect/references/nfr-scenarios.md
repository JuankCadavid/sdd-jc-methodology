# NFR Scenarios & Tactics

Non-functional requirements are captured as **quality-attribute scenarios** (SEI six-part format) and satisfied by **tactics** — named design decisions that control the system's response to a stimulus. This file is the scenario template plus the tactics menu per attribute.

## The Six-Part Scenario (the only valid NFR format)

| Part | Meaning | Example (performance) |
|---|---|---|
| **Source** | Who/what generates the stimulus | 500 concurrent end users |
| **Stimulus** | The condition arriving at the system | submit checkout requests |
| **Environment** | System state when it arrives | normal operation, peak season |
| **Artifact** | Component(s) affected | order API + payment integration |
| **Response** | What the system does | process and confirm the order |
| **Response measure** | The testable threshold | p95 latency ≤ 800 ms, error rate < 0.1% |

Rules:

- Write scenarios one-per-line in compact form: `[Source] → [Stimulus] on [Artifact] during [Environment] ⇒ [Response] measured by [Measure]`.
- Every scenario must be **architecturally significant** (shapes structure, not just code) and **testable** (the measure feeds `/akili-test`).
- Derive stimuli from PRD goals and real usage claims only. If the PRD lacks the number, ask or state the assumption explicitly.
- 3–7 scenarios per attribute that matters; zero for attributes marked "not architecturally significant here" (that marking is itself required output).

Example measures by attribute (calibrate to the project, don't copy blindly): availability — monthly downtime budget, RTO/RPO; performance — p95/p99 latency, throughput at N concurrent users; security — time to detect/revoke, blast radius of a leaked credential; modifiability — "add a payment provider touching ≤ 2 modules"; scalability — 10× load with linear cost, no redesign; cost — monthly ceiling per environment; observability — MTTD < X min for a failing dependency.

## Tactics Menu per Attribute

A tactic is chosen to satisfy a scenario, then implemented by styles/patterns (see `architecture-styles.md`, `design-patterns.md`). Cite the tactic by name in the TRD next to its scenario.

### Availability
- **Detect faults:** health checks/heartbeat, exception handling, timeouts.
- **Recover:** retry with backoff, failover/replicas, checkpoints + transaction log, graceful degradation, circuit breaker.
- **Prevent:** transactions (atomic rollback), bulkheads/isolation, removal from service for maintenance.

### Performance
- **Control resource demand:** increase computational efficiency, reduce overhead, manage event rate, bound queue sizes, bound execution times.
- **Manage resources:** introduce concurrency, maintain multiple copies (caching, read replicas, CDN), increase available resources (scale up/out).
- **Arbitrate resources:** scheduling/priority policies, rate limiting, backpressure.

### Security
Properties: confidentiality, integrity, non-repudiation, availability, auditability.
- **Resist:** authentication (tokens, certs, MFA), authorization (per-role/least privilege), encrypt in transit + at rest, validate inputs, limit exposure (private networking, minimal surface).
- **Detect:** intrusion/anomaly detection, request filtering, audit logging.
- **Recover:** state restoration, credential rotation/revocation, traceable audit trail for attack identification.

### Modifiability
- **Localize changes:** semantic coherence (high cohesion / low coupling), anticipate expected changes, generalize modules.
- **Prevent ripple:** encapsulation, intermediaries (facade, bridge, mediator, strategy, proxy, factory, repository), stable interfaces.
- **Defer binding:** configuration files, feature flags, runtime registration/plugins, polymorphism, dependency injection.

### Testability
- Interface/implementation separation, dependency injection for substitutable test doubles, specialized test interfaces, internal state monitoring, deterministic seams (clock/random injected).

### Usability (architectural slice only)
- Runtime: feedback, cancel/undo support. Design-time: separate UI from application logic (the same tactic as modifiability's semantic coherence — MVC and descendants).

### Scalability (cloud-era extension)
- Statelessness (externalize session/state), horizontal scaling + load balancing, partitioning/sharding, async decoupling via queues, autoscaling policies, cache hierarchies, read/write splitting.

### Observability (cloud-era extension)
- Structured logging with correlation IDs, RED/USE metrics, distributed tracing, health/readiness endpoints, alerting on symptoms (SLOs) not causes, dashboards per audience.

### Cost / FinOps (cloud-era extension)
- Serverless/scale-to-zero for spiky loads, right-sizing + reserved capacity for steady loads, tiered storage lifecycle, cache to cut egress/compute, model routing (small model first) for LLM workloads, budget alarms as deploy artifacts.

## Trade-off Table (always disclose)

Tactics conflict; the TRD must say which side won and why (this feeds `judgment-day`):

| Tension | Typical resolution note |
|---|---|
| Performance ↔ Modifiability | Layers/indirection add hops; keep them until a scenario measure fails, then flatten the measured path only |
| Security ↔ Performance/Usability | Encrypt and authenticate by default; budget the latency in the performance measures |
| Availability ↔ Cost | Replicas and multi-AZ cost money; the availability scenario's downtime budget justifies (or caps) the spend |
| Scalability ↔ Consistency | Prefer strong consistency until a scenario demands otherwise; eventual consistency is an ADR, never an accident |
| Cost ↔ everything | Every ROBUST escalation names its monthly cost order-of-magnitude |
