# dno-automation-services — Konflux CI layout

This repository holds **Konflux** (Red Hat Konflux / `appstudio`) automation for the **coffee** application: component source, Tekton pipeline contracts, **Pipelines-as-Code** (`.tekton/`) build triggers, and integration test pipelines.

**Canonical Git remote:** `https://github.com/tomswallaRH/dno-automation-services`  
Keep the same HTTPS URL in `component.yaml`, `.tekton/*.yaml` (`build.appstudio.openshift.io/repo`), and any `IntegrationTestScenario` git resolver params so Konflux, PaC, and integration tests resolve the same repository.

## Application vs Component

| Concept | Role in Konflux |
|--------|------------------|
| **Application** | Product boundary (here: `coffee`). Groups components, build policies, and integration scenarios in the UI and APIs. |
| **Component** | One buildable unit: Git source + `Containerfile` → one OCI image. Declared with `kind: Component` (`applications/coffee/components/coffee-break/component.yaml`). Konflux builds push to `spec.containerImage` (tag chosen per pipeline run). |

**Relationship:** An Application owns many Components. Each Component has its own repo path, image repository, and PaC `PipelineRun` templates under `.tekton/` that target that component’s paths.

## Repository layout

| Path | Purpose |
|------|---------|
| `applications/coffee/` | Application docs, `components/`, `pipelines/`, `integration/`. |
| `applications/coffee/components/coffee-break/` | Source, `Containerfile`, `component.yaml`. |
| `applications/coffee/pipelines/coffee-break-pipeline.yaml` | Tekton `Pipeline` describing clone → buildah → push for this component (contract aligned with PaC params). |
| `applications/coffee/integration/` | Integration `Pipeline` + example `IntegrationTestScenario`. |
| `.tekton/` | PaC: push and pull-request `PipelineRun` templates for `coffee-break`. |

## How CI runs

1. GitHub sends push / pull_request webhooks to **Pipelines-as-Code** (cluster-side listener — not `EventListener` CRs in this repo).
2. PaC matches `.tekton/coffee-break-on-push.yaml` or `coffee-break-on-pr.yaml` via CEL (branch `main`, paths under the component or pipeline contract).
3. Each match starts a `PipelineRun` that runs the Konflux catalog pipeline **`docker-build-oci-ta`** with `git-url` / `revision` from the event, `path-context` = `applications/coffee/components/coffee-break`, and `dockerfile` = `Containerfile`, matching `coffee-break-pipeline.yaml` defaults.
4. **Integration:** register a scenario pointing at `applications/coffee/integration/verify-hello.yaml`; it runs the snapshot image for component `coffee-break`.

Replace `namespace`, `output-image` registry prefix, and `serviceAccountName` in `.tekton/` with your Konflux tenant values if they differ from the examples.

## Tekton Triggers API note

Konflux does **not** require in-repo `triggers.tekton.dev` `TriggerTemplate` / `TriggerBinding` / `EventListener` manifests. PaC **`PipelineRun` templates** in `.tekton/` are the supported way to trigger builds from Git; the headers in those files map PaC behavior to the classic Triggers concepts for readers coming from raw Tekton.
