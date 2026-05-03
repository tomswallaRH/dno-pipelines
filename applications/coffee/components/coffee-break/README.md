# Component: `coffee-break`

Buildable **Konflux Component** for Application **`coffee`**: Python app in `src/` built from the directory-level **`Containerfile`**.

## Build process

1. **Konflux / PaC (default path)**  
   Push or PR to `main` matches `.tekton/coffee-break-on-*.yaml`. The controller creates a `PipelineRun` that runs **`docker-build-oci-ta`**: clone at `{{revision}}`, build with **`Containerfile`** inside **`applications/coffee/components/coffee-break`**, push to **`output-image`**.

2. **Repo Tekton contract**  
   `applications/coffee/pipelines/coffee-break-pipeline.yaml` describes the same logical steps (clone → `buildah bud`/`push` on this directory) for documentation and for runs that reference this `Pipeline` directly.

3. **Registration**  
   `component.yaml` ties **application** `coffee`, **Git URL** / **revision** `main`, **context** `applications/coffee/components/coffee-break`, **dockerfileUrl** `Containerfile`, and **`spec.containerImage`** (image repository without tag).

## Image output

| Event | Tag pattern (see `.tekton/`) | Notes |
|-------|------------------------------|--------|
| Push to `main` | `…/coffee-break:{{revision}}` | `revision` = commit SHA; image repo prefix matches `spec.containerImage`. |
| Pull request | `…/coffee-break:on-pr-{{revision}}` | Short retention via `image-expires-after` in the PR template. |

Integration test `applications/coffee/integration/verify-hello.yaml` expects the running container to print **`Hello World`** in logs (`src/app.py`).
