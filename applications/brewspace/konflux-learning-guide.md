# Konflux learning guide for brewspace

## 1) Application vs Component

- **Application**: a product boundary (here: `brewspace`).
- **Component**: a buildable unit inside an application (here: `api`, `frontend`).

In Konflux, components are independently built and versioned, but grouped under one application for coordinated snapshots and releases.

## 2) Build vs Pipeline

- **Build**: one execution that produces an image digest for a component.
- **Pipeline**: the ordered workflow that performs clone, build, scan, and metadata steps.

Think of build as an event (a run), and pipeline as the reusable process definition.

## 3) Snapshot lifecycle

1. Component builds finish and publish image digests.
2. Konflux creates a Snapshot representing one coherent application state.
3. Integration tests execute against Snapshot contents.
4. If tests and policies pass, Snapshot is promotable.

Snapshots are key because they freeze exactly what was tested.

## 4) How Konflux differs from Jenkins

- Konflux is Git-declarative and Kubernetes-native.
- Build provenance and trusted task chains are first-class.
- Pipelines are reusable Tekton bundles and policy-driven.
- Snapshots and integration service are built-in concepts.

Jenkins can implement similar behavior, but usually with custom scripting and plugin composition.

## 5) Typical developer workflow

1. Change code under a component path.
2. Open a pull request.
3. PR build pipeline runs for changed component(s).
4. Inspect produced image digest and build logs.
5. Integration scenarios validate behavior.
6. Merge PR; push build runs on main and updates deployable state.

## 6) Where to look in this repo

- Component definitions: `components/*/component.yaml`
- Build orchestration example: `pipelines/brewspace-pipeline.yaml`
- Integration examples: `integration/*.yaml`
- Component runtime code: `components/api/src/app.py`, `components/frontend/index.html`
