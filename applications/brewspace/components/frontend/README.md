# brewspace frontend component

This component serves a static HTML/JavaScript page over NGINX.

The page calls `/health` on the API and renders:

- `API Status: OK` when the API returns `{ "status": "ok" }`

## Build context

- Source path: `applications/brewspace/components/frontend`
- Containerfile: `applications/brewspace/components/frontend/Containerfile`
