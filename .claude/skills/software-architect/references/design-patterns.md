# Design Patterns — Selection, Principles, and the Tactic→Pattern Bridge

Patterns enter a design only at Decision Spine step 4: bound to a named problem, implementing a chosen tactic, with the simpler alternative stated. Catalog basis: the Refactoring.Guru catalog (Alexander Shvets) — 22 of the 23 GoF patterns (Interpreter omitted).

## Design Principles (the review checklist above any pattern)

1. **Encapsulate what varies** — isolate the changing part behind a boundary before reaching for a pattern name.
2. **Program to an interface, not an implementation.**
3. **Favor composition over inheritance.**
4. **SOLID:** Single Responsibility · Open/Closed · Liskov Substitution · Interface Segregation · Dependency Inversion (the Dependency Rule of clean/hexagonal is DIP at architecture scale).

If a principle solves it, stop there — a pattern nobody needs is complexity (MUDA).

## Selection Table — problem → pattern

### Creational (object creation)
| You need to… | Pattern | Note |
|---|---|---|
| Decouple client from concrete classes it instantiates | **Factory Method** | First stop; evolves into the ones below |
| Create families of related objects consistently | **Abstract Factory** | Often composed of factory methods |
| Build complex objects step-by-step (many optional params) | **Builder** | Kills telescoping constructors |
| Clone configured objects instead of rebuilding | **Prototype** | |
| Exactly one instance, controlled access | **Singleton** | In DI ecosystems (NestJS), prefer container-scoped providers |

### Structural (composition)
| You need to… | Pattern | Note |
|---|---|---|
| Make an incompatible interface fit (legacy, 3rd-party SDK) | **Adapter** | The workhorse of hexagonal `infrastructure/` |
| Vary abstraction and implementation independently (2 dimensions) | **Bridge** | Prevents class explosion (e.g. notification kind × channel) |
| Part-whole trees treated uniformly | **Composite** | |
| Add responsibilities dynamically without subclassing | **Decorator** | Middleware/interceptors are this |
| One simple door to a complex subsystem | **Facade** | Use-case classes often act as facades |
| Share heavy immutable state across many instances | **Flyweight** | Rare in business apps |
| Control access: lazy, cache, guard, remote | **Proxy** | Repositories with caching layers |

### Behavioral (interaction & responsibility)
| You need to… | Pattern | Note |
|---|---|---|
| Pass a request through potential handlers | **Chain of Responsibility** | Validation/auth pipelines |
| Requests as objects (queue, log, undo, retry) | **Command** | Natural fit for queue-driven work |
| Traverse a collection without exposing structure | **Iterator** | Built into JS/TS; rarely hand-rolled |
| Centralize chatty peer-to-peer communication | **Mediator** | Orchestrators, event buses in-process |
| Snapshot/restore state without breaking encapsulation | **Memento** | |
| Notify dependents on state change (pub/sub) | **Observer** | In-process events; at system scale → event-driven style |
| Behavior changes with internal state (kill state conditionals) | **State** | Order/workflow lifecycles |
| Interchangeable algorithms behind one interface | **Strategy** | Pricing rules, retry policies, LLM model routing |
| Algorithm skeleton with overridable steps | **Template Method** | Prefer Strategy (composition) when possible |
| Add operations across a class hierarchy without touching it | **Visitor** | Last resort; heavy coupling to hierarchy |

## Tactic → Pattern Bridge (connects step 2 to step 4)

| Tactic (from `nfr-scenarios.md`) | Patterns that implement it |
|---|---|
| Prevent ripple / intermediary | Facade, Bridge, Mediator, Proxy, Adapter |
| Defer binding | Strategy, Abstract Factory, Dependency Injection (DIP), plugin registration |
| Encapsulation / swap providers | Adapter + port interfaces (hexagonal), Bridge |
| Retry / failover / degradation | Command (retryable units), Proxy (circuit breaker), Chain of Responsibility (fallbacks) |
| Caching / multiple copies | Proxy (cache-aside), Flyweight |
| Rate limiting / arbitration | Decorator or Proxy on the entry port; Command queues |
| Audit / undo / replay | Command + Memento; at system scale → event sourcing (ADR!) |
| Workflow state control | State, Template Method → Strategy |
| Test doubles / seams | All port-based patterns (Adapter, Strategy) via DIP |

## Justification Format (what lands in the document)

For each pattern decision, one compact line in Design Decisions:

`[Problem] → [Pattern] implementing [Tactic] for [Scenario ID] — simpler alternative rejected: [X, reason]`

Evolution guidance: start with the simplest member of a family (Factory Method before Abstract Factory; Strategy before a full plugin system) and record the trigger that would justify upgrading. Patterns are design-level reuse — cheaper than framework lock-in, more durable than copied code.
