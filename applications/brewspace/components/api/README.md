# brewspace api component

This component provides a Flask health endpoint for the `brewspace` application.

## Endpoint

- `GET /health`
- Response:

```json
{
  "status": "ok",
  "service": "brewspace-api"
}
```

## Build context

- Source path: `applications/brewspace/components/api`
- Containerfile: `applications/brewspace/components/api/Containerfile`
