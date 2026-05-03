# dno-pipelines (coffee-break only)

Minimal [Konflux](https://konflux-ci.dev/docs/) component: one container image built from `components/coffee-break/` via Pipelines as Code (`.tekton/`).

## Before you onboard

In **both** `.tekton/coffee-break-*.yaml`, replace:

1. `changeme-tenant` in `metadata.namespace` and in `spec.params.output-image` (Quay path must match your workspace).
2. `build.appstudio.openshift.io/repo` with your Git clone URL (same pattern Konflux shows when importing the repo).
3. `appstudio.openshift.io/application` and `appstudio.openshift.io/component` labels if your Konflux Application/Component names differ from `coffee-break`.

Optional: pin `pipelineRef` to the pipeline bundle digest your Konflux release expects (UI: reset/update build pipeline, or copy from a freshly generated component).

## Layout

```
components/coffee-break/   # Dockerfile + Python sources (build context)
.tekton/                   # PaC PipelineRuns (push + pull_request)
```
