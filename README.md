# dno-automation-services — Konflux layout

This repository is **dno-automation-services**: Konflux automation (applications, components, Tekton pipelines, and Pipelines as Code triggers).

Structure follows **Application → Component → image**, with Tekton as an implementation detail and **Pipelines as Code** only under `.tekton/`.

## Concepts

| Term | Meaning |
|------|---------|
| **Application** | Logical product boundary in Konflux (here: `coffee`). See `applications/coffee/README.md`. |
| **Component** | Buildable unit: source + `Containerfile` producing one container image (`coffee-break` under `applications/coffee/components/coffee-break/`). Declared in Konflux via `Component` CR; `component.yaml` mirrors the spec in Git. |
| **Pipeline** | Tekton `Pipeline` YAML under `applications/<app>/pipelines/`. **CI triggers** live only in **`.tekton/`** as PaC `PipelineRun` templates that invoke the Konflux **docker-build-oci-ta** bundle with the same `path-context` and `Containerfile` as the repo pipeline spec. |

## Directory layout

- `applications/coffee/` — application boundary: `README.md`, `components/`, `pipelines/`, `integration/`.
- `applications/coffee/components/coffee-break/` — source (`src/`), `Containerfile`, `component.yaml`, `.dockerignore`.
- `applications/coffee/pipelines/coffee-break-pipeline.yaml` — reference pipeline (clone → buildah → push) for this component.
- `applications/coffee/integration/` — integration `Pipeline` and example `IntegrationTestScenario`.
- `.tekton/` — PaC: `coffee-break-on-push.yaml`, `coffee-break-on-pr.yaml`.

## How a push becomes a `PipelineRun`

1. Konflux **Pipelines as Code** is registered for `https://github.com/tomswallaRH/dno-pipelines` (or your fork). After renaming this GitHub repo to **dno-automation-services**, update URLs in `component.yaml`, `.tekton/*.yaml`, and `IntegrationTestScenario.example.yaml`.
2. On **push** or **pull_request** to `main`, PaC evaluates `.tekton/*.yaml` CEL rules.
3. Changes under `applications/coffee/components/coffee-break/**` (or the PaC file) instantiate a **`PipelineRun`** labeled Application `coffee`, Component `coffee-break`.
4. The run uses **bundle** pipeline `docker-build-oci-ta` with `path-context: applications/coffee/components/coffee-break` and `dockerfile: Containerfile`, matching `coffee-break-pipeline.yaml` and `component.yaml`.

Adjust `namespace`, `output-image`, `build.appstudio.openshift.io/repo`, and `component.yaml` for your tenant and registry.

## Integration test

Register **IntegrationTestScenario** with `pathInRepo: applications/coffee/integration/verify-hello.yaml` (see `applications/coffee/integration/IntegrationTestScenario.example.yaml`).
