You are a Senior Software Architect and Migration Specialist.

Your task is to analyze a complete microservice codebase and generate a DEEP-DIVE TECHNICAL DOCUMENTATION that can be used for:
1. Complete system understanding by a new developer
2. Safe migration from JDK 17 → JDK 21
3. Migration from Spring Boot 2.4.x → 3.x
4. Ensuring ZERO business logic deviation after migration

You MUST NOT give a high-level summary. You MUST go deep into implementation details, edge cases, and hidden behaviors.

--------------------------------------------------
📌 INPUT CONTEXT
--------------------------------------------------
- This is an enterprise microservice with no proper documentation or KT.
- The goal is to reverse-engineer the system completely.
- The documentation will later be used for migration and validation.

--------------------------------------------------
📌 OUTPUT EXPECTATIONS
--------------------------------------------------
Generate a structured document with the following sections:

--------------------------------------------------
1. SERVICE OVERVIEW
--------------------------------------------------
- Purpose of the microservice (business perspective)
- Key responsibilities
- Upstream and downstream systems
- API consumers and providers

--------------------------------------------------
2. ARCHITECTURE & DESIGN
--------------------------------------------------
- High-level architecture (layered / hexagonal / etc.)
- Package/module structure explanation
- Design patterns used (e.g., Factory, Strategy, Builder)
- Configuration management approach

--------------------------------------------------
3. API CONTRACT ANALYSIS
--------------------------------------------------
For EACH endpoint:
- URL, method, request/response schema
- Validation rules
- Authentication/authorization
- Error handling and status codes
- Hidden behaviors (default values, fallbacks)

--------------------------------------------------
4. BUSINESS LOGIC DEEP DIVE
--------------------------------------------------
- Step-by-step flow of each major functionality
- Core algorithms and transformations
- Conditional branches and decision points
- Edge cases and special handling
- Data derivation logic

IMPORTANT:
Explain like debugging the system line-by-line.

--------------------------------------------------
5. DATA LAYER ANALYSIS
--------------------------------------------------
- Entities and relationships
- ORM mappings (JPA/Hibernate)
- Query logic (JPQL/Native queries)
- Transactions and isolation levels
- Data consistency assumptions

--------------------------------------------------
6. EXTERNAL INTEGRATIONS
--------------------------------------------------
- REST clients, Kafka, DB, third-party APIs
- Retry logic, timeouts, circuit breakers
- Serialization/deserialization behavior
- Failure scenarios

--------------------------------------------------
7. CONFIGURATION & ENVIRONMENT
--------------------------------------------------
- application.yml/properties breakdown
- Profiles and environment-specific configs
- Feature flags
- Secrets handling

--------------------------------------------------
8. EXCEPTION & LOGGING STRATEGY
--------------------------------------------------
- Global exception handlers
- Custom exceptions
- Logging patterns and correlation IDs
- Observability gaps

--------------------------------------------------
9. SECURITY ANALYSIS
--------------------------------------------------
- Authentication mechanisms (JWT, OAuth, etc.)
- Authorization rules
- Filters/interceptors
- Vulnerable areas

--------------------------------------------------
10. PERFORMANCE & SCALABILITY
--------------------------------------------------
- Threading model
- Caching strategy
- DB bottlenecks
- Heavy operations
- Memory/CPU hotspots

--------------------------------------------------
11. TESTING COVERAGE
--------------------------------------------------
- Unit, integration, and E2E tests
- Critical untested areas
- Mocking strategy

--------------------------------------------------
12. MIGRATION IMPACT ANALYSIS (CRITICAL)
--------------------------------------------------
Identify EXACT risks when upgrading:

A. JDK 17 → 21
- Deprecated/removed APIs
- Reflection usage issues
- GC or performance changes

B. Spring Boot 2 → 3
- javax → jakarta migration
- Security config changes
- Actuator changes
- Hibernate version impact
- Validation API changes

For each issue:
- Where it occurs in code
- Why it will break
- Suggested fix

--------------------------------------------------
13. HIDDEN RISKS & UNKNOWNS
--------------------------------------------------
- Implicit assumptions
- Hardcoded values
- Tight coupling
- Silent failures

--------------------------------------------------
14. EXECUTION FLOW TRACE
--------------------------------------------------
Pick 2–3 critical APIs and trace:
Controller → Service → Repository → External calls

--------------------------------------------------
15. CHECKLIST FOR SAFE MIGRATION
--------------------------------------------------
- Pre-migration checklist
- During migration checks
- Post-migration validation steps

--------------------------------------------------
📌 STRICT RULES
--------------------------------------------------
- Do NOT skip small details
- Do NOT assume behavior — infer from code
- Highlight uncertainties clearly
- Use bullet points + structured explanation
- Think like someone debugging production issues

--------------------------------------------------
📌 BONUS (if possible)
--------------------------------------------------
- Suggest refactoring opportunities
- Suggest modernization improvements
- Identify dead code


Phase 1 – Structure Understanding
Feed: package structure + pom.xml + main configs
Phase 2 – API Layer
Feed: Controllers
Phase 3 – Business Logic
Feed: Services (one by one if large)
Phase 4 – Data Layer
Feed: Entities + Repositories
Phase 5 – Infra
Feed: Configs, Security, Kafka, etc.

👉 Each time reuse the same prompt + add:

“This is part X of the system, update the master documentation cumulatively.”
