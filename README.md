# dno-pipelines — Konflux **coffee** / **coffee-break**

Build context: `components/coffee-break/`. Pipelines as Code: [`.tekton/coffee-break-*.yaml`](.tekton/).

- **Application:** `coffee`
- **Component:** `coffee-break` (must match the component name in Konflux)
- **Namespace:** `sfathii-tenant`

Image push target (adjust if the UI shows a different Quay path):

`quay.io/redhat-user-workloads/sfathii-tenant/coffee/coffee-break:<tag>`

If push fails with a registry path error, copy **`output-image`** from the component’s **Edit build pipeline** sample in Konflux (some clusters use `…/tenant/coffee-break` without the `coffee/` segment).

## Run the pipeline

1. In Konflux: **Application `coffee` → component `coffee-break`** — ensure the Git source is `tomswallaRH/dno-pipelines` and Pipelines as Code is installed for that repo.
2. **Push to `main`** (or open/update a PR to `main`) after this repo’s `.tekton/` and `components/coffee-break/` are on GitHub. That triggers **`coffee-break-on-push`** or **`coffee-break-on-pull-request`**.

## Integration test (optional)

See `integration/pipelines/coffee-break-verify-hello-world.yaml` and `integration/IntegrationTestScenario.example.yaml` (`spec.application: coffee`).
