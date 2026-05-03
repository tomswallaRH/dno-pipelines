# Application: `coffee`

Logical Konflux **Application** for coffee-related automation and images. It groups **components**, **build contracts** (Tekton pipelines under `pipelines/`), and **integration** tests.

## Components

| Component | Path | Image (example) |
|-----------|------|-----------------|
| **coffee-break** | `applications/coffee/components/coffee-break/` | `quay.io/redhat-user-workloads/<tenant>/coffee/coffee-break:<tag>` |

Source of truth for the component in Konflux is the **Component** CR; this repo carries `component.yaml` beside the source so Git review matches the cluster intent.

## How pipelines are triggered

1. **Build (CI)** — **Pipelines as Code** only reads `.tekton/` at the repository root.  
   - **Push to `main`:** `.tekton/coffee-break-on-push.yaml` → `PipelineRun` when `applications/coffee/components/coffee-break/**` or that PaC file changes.  
   - **Pull request to `main`:** `.tekton/coffee-break-on-pr.yaml` → same component paths; PR images typically use a short-lived tag (e.g. `on-pr-<revision>`).

2. **Effective Tekton pipeline for builds** — PaC resolves the Konflux catalog **`docker-build-oci-ta`** bundle (clone/fetch, build, push). Parameters (`path-context`, `dockerfile`) point at **coffee-break**’s `Containerfile`, aligned with `applications/coffee/pipelines/coffee-break-pipeline.yaml` and `component.yaml`.

3. **Reference / GitOps pipeline** — `pipelines/coffee-break-pipeline.yaml` documents the same build contract (clone → buildah using that context → push) for manual `PipelineRun`s or future git-resolver wiring; it is not mixed into the component directory.

4. **Integration** — After a build snapshot, Konflux can run `integration/verify-hello.yaml` via an **IntegrationTestScenario** (see `IntegrationTestScenario.example.yaml`).
