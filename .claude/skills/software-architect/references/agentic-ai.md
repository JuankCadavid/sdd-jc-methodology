# Agentic AI Architecture — Patterns & Component Decisions

For systems embedding LLM/agent behavior. The Decision Spine applies unchanged: token cost, latency, and accuracy are **quality-attribute scenarios** like any other — write measures first, then pick the pattern. The Robust-vs-Lite gate is strictest here because agent complexity multiplies token spend.

## Pattern Catalog — cheapest that meets the measure wins

### Single-agent (LITE — the default)
| Pattern | Idea | Choose when |
|---|---|---|
| **Single Agent** | One model + tools + system prompt, end-to-end | Start here. Most assistant/automation features |
| **ReAct loop** | Think → act → observe until done | Dynamic environments, multi-step tool use; accuracy > latency |

### Multi-agent (ROBUST — each needs a scenario)
| Pattern | Idea | Choose when | Cost profile |
|---|---|---|---|
| **Sequential** | Linear pipeline, output → input | Fixed repeatable stages (ingest → classify → draft) | Low |
| **Parallel** | Independent subagents, results synthesized | Decomposable subtasks; latency reduction | Medium |
| **Loop** | Repeat until exit condition | Iterative refinement; **hard termination guard required** | Runaway risk |
| **Review-Critique** | Generator + critic gate | High-accuracy output (audited code, compliance text) | +1 model call per cycle |
| **Coordinator** | Central agent routes to specialists dynamically | Adaptive triage; heterogeneous requests | High (routing calls) |
| **Hierarchical** | Recursive decomposition tree | Open-ended research-class problems | Very high |
| **Swarm** | Peer-to-peer agents, no orchestrator | Almost never justified in products | Highest |

### Cross-cutting
- **Human-in-the-Loop** — approval pauses at defined points; mandatory for high-stakes/irreversible actions (a security tactic, not an option).
- **Custom logic orchestration** — deterministic code decides the flow, agents fill steps; prefer this over agent-decides-everything when the workflow is known (cheaper, testable, debuggable).

Escalation rule: Single Agent → add tools → ReAct → Sequential/Custom logic → one specialized multi-agent pattern. Each step is an ADR citing the measure the previous step failed.

## Component Decision Axes

| Axis | LITE | ROBUST | Decision driver (scenario) |
|---|---|---|---|
| Model access | Managed API: Bedrock, OpenAI, Anthropic | Multi-model routing; fine-tuned/self-hosted | Cost/latency measures; data-residency security scenarios |
| Model choice | One capable default model | Router: small model first, escalate on confidence | Cost ceiling per request |
| Tools | Few function tools in-process | MCP servers / API-gateway-governed tools | Tool reuse across agents; governance requirements |
| Memory (short) | In-context only | Externalized session state (Redis/DynamoDB) | Horizontal scaling scenario — any multi-instance deploy forces this |
| Memory (long) / RAG | S3 Vectors + Bedrock KB, single index | OpenSearch vector store, hybrid search, reranking | Corpus size, recall measures, filter complexity |
| Runtime | Lambda / managed agent runtime | Containers (ECS/EKS) for long-running or stateful agents | Execution time limits, streaming needs |
| Guardrails | Provider-level (Bedrock Guardrails) + input validation | Dedicated eval/guard pipeline, red-team suite | Security & compliance scenarios |

AWS-first defaults (per AKILI expertise): Bedrock for orchestration/models, S3 Vectors for lite RAG, OpenSearch for robust retrieval, Step Functions for deterministic orchestration of agent steps; OpenAI/Anthropic APIs when the project's ecosystem or model requirements dictate.

## LLM-Specific NFR Scenarios (write these explicitly)

- **Cost:** `1000 requests/day → agent pipeline ⇒ ≤ $X/month; alarm at 80%` — token budget is a response measure.
- **Latency:** p95 including model calls; streaming-first for user-facing paths.
- **Accuracy/quality:** eval-set pass rate ≥ X% before deploy; regression evals in CI.
- **Safety/security:** prompt-injection resistance on tool-using paths (treat all retrieved/user content as untrusted input to tools); PII redaction before external model calls; auditable trace of every tool invocation (non-repudiation tactic).
- **Availability:** provider outage behavior — degrade to smaller model / cached answers / honest failure (graceful-degradation tactic + circuit breaker on the provider port).
- **Determinism boundary:** which steps must be reproducible (temperature 0, seeded, or code) vs creative — record as variability.

## Architecture Rules for LLM Systems

1. The model provider sits behind a **port** (hexagonal): swapping Bedrock ↔ OpenAI ↔ Anthropic touches one adapter — this is the modifiability tactic that pays for itself first.
2. Prompts and model config are **versioned artifacts** (config/defer-binding tactic), not string literals in code.
3. Every agent action is **observable**: correlation ID from user request through every model/tool call (traces are also the audit log).
4. Multi-agent is a distributed system: apply the same rigor — idempotency, timeouts, budgets-as-bulkheads (max tokens/steps per request).
5. In the C4 container view, model providers and vector stores are external systems/containers with labeled protocols; the trust boundary between them and user data is drawn explicitly.
