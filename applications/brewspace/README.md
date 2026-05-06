# brewspace

`brewspace` is a minimal microservices-style learning application for Konflux.

It intentionally contains two components:

- `api`: a Flask service that exposes `GET /health`
- `frontend`: a static web UI served by NGINX that calls the API

Use this app to understand Konflux concepts in a realistic but small setup:

- Application and Component boundaries
- Build execution and image outputs
- Snapshot creation and usage
- Integration test wiring
- Pipeline orchestration in Konflux

## Layout

- `components/api/`: Flask API component
- `components/frontend/`: static frontend component
- `integration/`: integration test scenario examples
- `pipelines/`: learning-focused Konflux pipeline definition
- `architecture.md`: service and CI/CD architecture
- `konflux-learning-guide.md`: concept walkthrough and workflow
