# Konflux automation layout

**GitHub URL:** whatever name the repository has in **Settings → General → Repository name** (today that is often [`dno-pipelines`](https://github.com/tomswallaRH/dno-pipelines)). Pushing from Git or changing files **does not** change that URL.

## Get the URL `https://github.com/tomswallaRH/dno-automation-services`

1. Sign in to GitHub as someone with **admin** on [`tomswallaRH/dno-pipelines`](https://github.com/tomswallaRH/dno-pipelines) (the owner account, e.g. **tomswallaRH**).
2. Open **[Settings → Rename repository](https://github.com/tomswallaRH/dno-pipelines/settings/rename)**.
3. Set the new name to **`dno-automation-services`** and confirm. GitHub will redirect the old URL for clones and web traffic.
4. Point your local `origin` at the new path, for example:  
   `git remote set-url origin git@github.com-tomswallaRH:tomswallaRH/dno-automation-services.git`  
   (use your real SSH host alias if different.)
5. Update Konflux Git strings in this repo from `dno-pipelines` to `dno-automation-services` in `component.yaml`, `.tekton/coffee-break-on-*.yaml`, and `applications/coffee/integration/IntegrationTestScenario.example.yaml`, then commit and push.

This repo holds Konflux automation (applications, components, Tekton pipelines, and Pipelines as Code under `.tekton/`). Structure follows **Application → Component → image**.

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

1. Konflux **Pipelines as Code** must use the **same** HTTPS URL as this GitHub repo (today: `https://github.com/tomswallaRH/dno-pipelines`; after rename: `…/dno-automation-services`). Keep `component.yaml` and `.tekton` `build.appstudio.openshift.io/repo` in sync with that slug.
2. On **push** or **pull_request** to `main`, PaC evaluates `.tekton/*.yaml` CEL rules.
3. Changes under `applications/coffee/components/coffee-break/**` (or the PaC file) instantiate a **`PipelineRun`** labeled Application `coffee`, Component `coffee-break`.
4. The run uses **bundle** pipeline `docker-build-oci-ta` with `path-context: applications/coffee/components/coffee-break` and `dockerfile: Containerfile`, matching `coffee-break-pipeline.yaml` and `component.yaml`.

Adjust `namespace`, `output-image`, `build.appstudio.openshift.io/repo`, and `component.yaml` for your tenant and registry.

## Integration test

Register **IntegrationTestScenario** with `pathInRepo: applications/coffee/integration/verify-hello.yaml` (see `applications/coffee/integration/IntegrationTestScenario.example.yaml`).
