# hello-world

Minimal Python service container built and delivered through **Konflux** (Red Hat OpenShift / App Studio model).

## Local run

```bash
python app.py
```

## Local container

```bash
podman build -f Containerfile -t hello-world:local .
podman run --rm hello-world:local
```

## Konflux

Apply the `Component` manifest (adjust `metadata.namespace` and image/Git URLs for your tenant). Konflux reconciles the Component and wires repository webhooks or polling to **Tekton** `PipelineRun` resources that build and push `containerImage`.

See `component.yaml` in this directory.
