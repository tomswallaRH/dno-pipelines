# dno-pipelines — Konflux component `dno-pipelines-f97fa`

Minimal [Konflux](https://konflux-ci.dev/docs/) build: image from `components/coffee-break/`, Pipelines as Code under [`.tekton/`](.tekton/).

Configured for workspace [**sfathii-tenant**](https://konflux-ui.apps.kflux-prd-rh02.0fk9.p1.openshiftapps.com/ns/sfathii-tenant/applications/coffee-break/components/dno-pipelines-f97fa/), application **coffee-break**, component **dno-pipelines-f97fa** (Git: [`tomswallaRH/dno-pipelines`](https://github.com/tomswallaRH/dno-pipelines)).

## PaC files

| File | Purpose |
|------|---------|
| `.tekton/dno-pipelines-f97fa-push.yaml` | Push to `main` → build + push |
| `.tekton/dno-pipelines-f97fa-pull-request.yaml` | PRs targeting `main` → build |

Registry path for this component matches the UI: `quay.io/redhat-user-workloads/sfathii-tenant/dno-pipelines-f97fa:…` (tenant + component only).

## Integration test (optional)

`integration/pipelines/coffee-break-verify-hello-world.yaml` targets snapshot component **`dno-pipelines-f97fa`**. Register via UI or `integration/IntegrationTestScenario.example.yaml`.

## Layout

```
components/coffee-break/   # Dockerfile (prints Hello World when run)
.tekton/                   # PaC PipelineRuns for dno-pipelines-f97fa
integration/pipelines/     # Optional integration Pipeline
```
