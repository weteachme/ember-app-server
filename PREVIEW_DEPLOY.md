# Preview Deploy

Deploy a PR branch using the preview config.

## Required Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `SERVICE_NAME` | Unique name for this preview (e.g. PR number) | `ember-preview-123` |
| `HOST` | Hostname the proxy will route to | `dashboard-preview-123.weteachme.com` |

## Steps

### 1. Add DNS record in Cloudflare

Create a CNAME record in Cloudflare for the preview hostname (e.g. `dashboard-preview-123.weteachme.com`) pointing to the server before deploying.

### 2. Deploy

```bash
SERVICE_NAME=ember-preview-123 HOST=dashboard-preview-123.weteachme.com kamal deploy -d preview
```

The volume mount `/data/ember-app/<SERVICE_NAME>` is created automatically. The `post-deploy` hook fixes permissions so `ec2-user` can upload `index.html`.

### 3. Upload index.html

```bash
sftp ec2-user@wtm-mcp-servers.taildbf88f.ts.net <<EOF
put index.html /data/ember-app/ember-preview-123/index.html
EOF
```

## Teardown

```bash
SERVICE_NAME=ember-preview-123 HOST=dashboard-preview-123.weteachme.com kamal remove -d preview
ssh ec2-user@wtm-mcp-servers.taildbf88f.ts.net 'rm -rf /data/ember-app/ember-preview-123'
```
