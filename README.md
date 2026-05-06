# dno-automation-services

Konflux automation manifests and Pipelines-as-Code templates for this repository.

## Repository layout

| Path | Purpose |
|------|---------|
| `.tekton/` | PaC `PipelineRun` templates for push and pull request builds. |
| `applications/` | Application-level manifests and supporting resources. |
| `Containerfile` | Default container build definition used by PaC templates. |
