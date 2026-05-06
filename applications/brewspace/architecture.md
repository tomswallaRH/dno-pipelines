# brewspace architecture

## Runtime services

- `brewspace-api` (Flask)
  - Endpoint: `GET /health`
  - Returns service liveness metadata
- `brewspace-frontend` (NGINX + static HTML/JS)
  - Calls API health endpoint
  - Renders API status in browser

## Konflux model mapping

- **Application**: `brewspace`
  - Logical group for related components
  - Used for release/snapshot coordination
- **Components**:
  - `brewspace-api`
  - `brewspace-frontend`
  - Each component has its own source path, Containerfile, and image output

## Build and delivery flow

1. Developer pushes code or opens PR.
2. Pipeline-as-Code trigger starts component build pipeline runs.
3. Konflux build tasks clone source, build images, and publish image digests.
4. Integration tests run against component images collected into a Snapshot.
5. Passing Snapshot can be promoted in higher environments.

## Snapshot-centric behavior

A Snapshot captures immutable image digests for components in one application state.

- Prevents accidental drift from mutable tags.
- Makes integration tests reproducible.
- Decouples "build finished" from "ready to promote".

## Jenkins comparison

- Jenkins often stores orchestration logic in centralized jobs/pipelines.
- Konflux keeps intent mostly in Git manifests (`component.yaml`, integration configs, PaC YAMLs).
- Jenkins jobs commonly pass mutable artifacts or workspace state.
- Konflux emphasizes signed provenance, immutable digests, and policy checks by default.
