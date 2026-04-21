# ember-app-server

A lightweight Sinatra server that serves `index.html` from S3 with in-memory caching and instant rollback support.

## How it works

1. A user visits any path (e.g. `/`, `/classes`, `/dashboard`)
2. The server checks its in-memory cache for the HTML
3. If not cached, it fetches `index.html` from S3 using the key configured in `S3_KEY`
4. The HTML is cached permanently in memory — all subsequent requests are served from cache
5. The cache is only invalidated when you explicitly call `/cache/clear`

## Environment variables

| Variable | Required | Default | Description |
|---|---|---|---|
| `S3_BUCKET` | Yes | — | S3 bucket name |
| `S3_KEY` | No | `wtm-dashboard-app/staging/index.html` | S3 object key for `index.html` |
| `AWS_REGION` | No | `ap-southeast-2` | AWS region |
| `SECRET_KEY` | Yes | — | Auth key for admin endpoints |
| `AWS_ACCESS_KEY_ID` | Yes | — | AWS credentials |
| `AWS_SECRET_ACCESS_KEY` | Yes | — | AWS credentials |

## Endpoints

### `GET /*`
Serves the cached `index.html`. Fetches from S3 on first request or after cache clear.

### `GET /up`
Health check. Returns `200 OK`.

### `POST /cache/clear`
Clears the cache. The current cached HTML is saved to a history stack (max 5 steps) before clearing. The next user request will re-fetch from S3.

Requires auth via `secret_key` query param or `X-Secret-Key` header.

### `POST /rollback?step=N`
Rolls back to a previous cached version. `step=1` restores the last version, `step=2` goes back two versions, etc. Max 5 steps of history are kept.

Requires auth via `secret_key` query param or `X-Secret-Key` header.

## Scripts

### Clear cache
```bash
bin/clear-cache <subdomain> <secret_key>

# Examples:
bin/clear-cache dashboard-staging mysecret
bin/clear-cache dashboard mysecret
bin/clear-cache dash-pr-233 mysecret
```

### Rollback
```bash
bin/rollback <subdomain> <secret_key> [step]

# Examples:
bin/rollback dashboard-staging mysecret      # rolls back 1 step
bin/rollback dashboard-staging mysecret 2    # rolls back 2 steps
```

## Typical deploy flow

1. Deploy new `index.html` to S3
2. Clear cache: `bin/clear-cache dashboard-staging <secret_key>`
3. Next user request fetches the new version from S3
4. If something is wrong: `bin/rollback dashboard-staging <secret_key>`
5. The previous HTML is restored instantly from memory (no S3 fetch needed)
