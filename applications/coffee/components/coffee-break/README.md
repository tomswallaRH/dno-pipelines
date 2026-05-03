# Component: `coffee-break`

Buildable unit for Konflux **Application** `coffee`: one OCI image from `src/` and root **`Containerfile`**.

## Build flow

1. **Konflux / PaC (default)** — Push or PR to `main` triggers `.tekton/coffee-break-on-*.yaml`. The `PipelineRun` uses catalog pipeline **`docker-build-oci-ta`**: fetch Git at `{{revision}}`, build with **`Containerfile`**, push to **`output-image`** (see PaC params: `path-context` + `dockerfile`).

2. **Repo pipeline spec** — `applications/coffee/pipelines/coffee-break-pipeline.yaml` describes the same logical steps (clone → buildah `bud` on this directory → `push`) for traceability and optional direct `PipelineRun` use.

3. **Cluster registration** — `component.yaml` ties **application** `coffee`, **Git URL**, **context** `applications/coffee/components/coffee-break`, and **containerImage** to what Konflux shows in the UI.

## Image output

- **Push builds:** image ref from PaC `output-image` (e.g. `quay.io/redhat-user-workloads/<tenant>/coffee/coffee-break:{{revision}}`).
- **PR builds:** same registry path with PR-specific tag (e.g. `on-pr-{{revision}}`), often with shorter retention (`image-expires-after`).

Runtime: container runs `python /app/app.py` as `nobody`; stdout must include **`Hello World`** for `integration/verify-hello.yaml` to pass.
