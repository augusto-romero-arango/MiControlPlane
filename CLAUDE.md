# CLAUDE.md — MiControlPlane

Instrucciones para Claude Code en este proyecto.

## Principios de respuesta

- Comunícate siempre en **español**.
- **Cita fuentes verificables** al afirmar una best practice o recomendación técnica — documentación oficial, ADR del marco (Mefisto) o del proyecto, libro, RFC. Si es conocimiento general sin fuente, dilo. Nunca presentes opinión como hecho.

## Qué es este proyecto

**MiControlPlane** es la **reconstrucción greenfield de un Control Plane de tenants** (onboarding, provisioning, billing, identidad y registro de tenants), construido íntegramente con el harness **Mefisto** (EDA + Event Sourcing + Azure Functions).

- **Stack del marco**: .NET 10, C#, Azure Functions isolated worker, Marten (event store) + Wolverine (mediador) sobre PostgreSQL, Azure Service Bus (un topic por evento), xUnit v3 + `Cosmos.EventSourcing.Testing.Utilities`, Terraform, GitHub Actions.
- **Remote**: `https://github.com/augusto-romero-arango/MiControlPlane` (usuario personal, **no** la organización Cosmos).

## Doble propósito del ejercicio

Este repo persigue dos intenciones simultáneas:

1. **Probar Mefisto en greenfield**, asumiendo un usuario **sin proyectos de referencia**.
2. **Mejorar Mefisto** detectando dónde no se basta a sí mismo.

Reglas de trabajo que se derivan:

- La **fuente primaria** es lo que **Mefisto documenta de sí mismo**: su `README.md`, su `CLAUDE.md`, sus **ADRs** (`docs/adr/`), sus comandos (`commands/`), agentes (`agents/`) y scripts (`scripts/`) — todo dentro del repo clonado en `../eda-evsourcing-azure-harness` y/o el plugin instalado.
- **No se usa `Bitakora.ControlAsistencia` como plantilla silenciosa.** Si para resolver algo hubo que mirar Bitakora, hay que: (a) **evidenciarlo**, (b) **verificar en el repo de Mefisto** si Mefisto ya lo resolvía, y (c) si **no lo resolvía**, **alertar al usuario** para mejorar Mefisto (idealmente como draft `estado:borrador` en el repo del harness).
- Cada vez que el camino documentado de Mefisto sea insuficiente para un greenfield, se registra como **gap de Mefisto**.

## Cosmos.ControlPlane = software legado (visión de producto)

Tomamos el **ControlPlane de Cosmos** (en `../ControlPlane`) como **referencia de producto / software legado** a reconstruir. De él **rescatamos**:

- Los **bounded contexts**: `Onboarding` (saga orquestadora), `TenantProvisioning`, `UserManagement`, `Billing`, `TenantManagement`.
- Los **eventos de dominio** y **casos de uso / funciones** propuestos (p. ej. `StartTenantOnboarding`, `CreateAdminUser`, `CreateBillingAccount`, `TenantProvisioned`, `TenantCreated`).

**Las decisiones de arquitectura de Mefisto PREVALECEN** sobre lo que haga Cosmos.ControlPlane. Cosmos define *qué* (funciones, mensajes, flujos); Mefisto define *cómo* (estructura, nombres, topología). Ejemplos donde Mefisto manda aunque el legado diga lo contrario:

| Tema | Cosmos.ControlPlane (legado) | Mefisto (prevalece) |
|---|---|---|
| Service Bus | 1 topic por contexto + `CorrelationFilter` | **1 topic por evento**, kebab-case pasado; subs `{consumidor}-escucha-{productor}` (ADR-0001) |
| Nombres de funciones | `NotifyAdminUserAssigned`, etc. | HTTP `[Function("ComandoEnInfinitivo")]`; reacciones `[Function("{Acción}Cuando{Evento}")]` (ADR-0006) |
| Hosting | varias Function Apps por plan | **un App Service Plan dedicado por dominio**, B1, worker=1, `DurabilityMode.Solo` (ADR-0020) |

## Harness integrado (Mefisto)

Este proyecto consume el plugin `mefisto@augusto-romero-arango-harness`. El marketplace y la habilitación del plugin están declarados en `.claude/settings.json` (commiteado). Skills, agentes, scripts y ADRs vienen del plugin, no de este repo.

- **Repositorio del harness**: https://github.com/augusto-romero-arango/eda-evsourcing-azure-harness
- **Verificar**: `/mefisto:show-flow` o `/mefisto:work-status` deben responder sin error. (`/plugin update mefisto` para traer cambios.)
- **Catálogo de skills y agentes, y el contrato del consumidor**: documentados por el propio Mefisto (su `README.md` y `CLAUDE.md`). No se duplican aquí: se consultan en la fuente.

### Tokens del harness (resolución para agentes y skills)

Valores que consumen los agentes/skills cuando ven `<RootNamespace>`, `<SolutionFile>`, `<ProjectDisplayName>`. La fuente operativa para scripts es `.claude/harness.config.json`.

- **RootNamespace**: `MiControlPlane`
- **SolutionFile**: `MiControlPlane.slnx`
- **ProjectDisplayName**: `MiControlPlane`

### Estructura esperada (contrato del consumidor)

- `src/MiControlPlane.Contracts/` — contratos de eventos públicos y value objects compartidos
- `src/MiControlPlane.{Dominio}/` — Function App por dominio
- `tests/MiControlPlane.{Dominio}.Tests/` — pruebas por dominio
- `infra/environments/{env}/` — infraestructura Terraform
- `docs/adr/` — ADRs propios del proyecto (los del marco viven en el plugin)
- `docs/bitacora/` y `docs/eda/` — bitácora/field-notes y modelo de dominio

> Estado actual: greenfield. Solo existen `CLAUDE.md` y `.claude/` (config). El resto de la estructura se crea con `/scaffold` y los pipelines cuando se implemente.

## Azure: suscripción Augusto (guardrail)

**Todo el trabajo de Azure ocurre en la suscripción `Augusto`. Nunca en `Azure Cosmos`.**

- **Augusto** (usar): `50fc1901-9723-4971-9d63-b3f1a015e8b8`
- **Azure Cosmos** (NO tocar): `3c2daa54-52cc-452e-b6e5-d4cf021575a1`

Antes de cualquier operación `az`/Terraform, fijar la suscripción: `az account set --subscription Augusto`. Recursos del proyecto: prefijo `rg-micontrolplane`, App Insights `micontrolplane-dev-ai`, tfstate `stmcptfstatedev` (ver `.claude/harness.config.json`).

## Flujo de entrega

- **Nunca trabajar contra `main` directo.** Toda edición se hace en rama nueva y se entrega vía Pull Request hacia `main`.
- Si la rama activa es `main`, crear una con `git switch -c <slug>` (`feat/…`, `fix/…`, `docs/…`, `chore/…`) antes de editar.
- Al terminar: `git push -u origin <rama>` + `gh pr create`. Los PRs que cierran un issue incluyen `Closes #<n>`.

## Fuentes de verdad

No asumas; lee:

- **Arquitectura del marco**: ADRs de Mefisto (`../eda-evsourcing-azure-harness/docs/adr/` o el plugin instalado).
- **Detalle de un skill/agente/pipeline**: su archivo en el plugin (`commands/`, `agents/`, `scripts/`).
- **Visión de producto (legado)**: `../ControlPlane`.
- **Config operativa**: `.claude/harness.config.json` y `.claude/settings.json`.
