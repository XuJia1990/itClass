# itClass dev web deployment

## First setup on the server

The backend deployment owns the shared `twschool-watchtower-dev` container. Start
the backend stack first, then install this compose project:

```bash
mkdir -p /work/projects/twschool-app-dev
cd /work/projects/twschool-app-dev
cp .env.example .env
docker login ghcr.io -u xujia1990
chmod +x deploy-dev.sh
./deploy-dev.sh
```

Set `NPM_NETWORK` in `.env` when Nginx Proxy Manager does not use
`root_default`.

## Automatic deployment

Pushes to `main` build and publish `ghcr.io/xujia1990/itclass:dev`. The shared
Watchtower checks labeled containers every 60 seconds and replaces
`twschool-app-dev` when the image changes.

The one-time server setup above is still required. GitHub Actions only publishes
the image; Watchtower performs the server-side update.

## Nginx Proxy Manager

The public web proxy should forward to:

- Forward hostname: `twschool-app-dev`
- Forward port: `80`
- Network: the value of `NPM_NETWORK`
