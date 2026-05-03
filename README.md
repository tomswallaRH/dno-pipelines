# dno-pipelines (coffee-break only)

Minimal [Konflux](https://konflux-ci.dev/docs/) component: one container image built from `components/coffee-break/` via Pipelines as Code (`.tekton/`).

## Before you onboard

In **both** `.tekton/coffee-break-*.yaml`, replace:

1. `changeme-tenant` in `metadata.namespace` and in `spec.params.output-image` (Quay path must match your workspace).
2. `build.appstudio.openshift.io/repo` with your Git clone URL (same pattern Konflux shows when importing the repo).
3. `appstudio.openshift.io/application` and `appstudio.openshift.io/component` labels if your Konflux Application/Component names differ from `coffee-break`.

Optional: pin `pipelineRef` to the pipeline bundle digest your Konflux release expects (UI: reset/update build pipeline, or copy from a freshly generated component).

## Integration test (optional)

After a successful component build, Konflux can run an integration test from `integration/pipelines/coffee-break-verify-hello-world.yaml`: it reads the built image from the **SNAPSHOT**, runs a one-off Pod, prints **container logs** to the task log, and fails if `Hello World` is missing.

Register it once: Application → **Integration tests** → add scenario with your repo URL, branch, and path `integration/pipelines/coffee-break-verify-hello-world.yaml` (see `integration/IntegrationTestScenario.example.yaml` for the same fields).

## Layout

```
components/coffee-break/   # Dockerfile only (Hello World when the image runs)
.tekton/                   # PaC build (push + pull_request) — unchanged by integration
integration/pipelines/     # Konflux integration Pipeline (SNAPSHOT → run image → verify logs)
```

You can still run the pushed image locally (`podman run …`) to see `Hello World` without integration tests.
