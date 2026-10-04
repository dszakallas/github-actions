# Deploy SPA Cloud Run App Action

A composite GitHub Action to deploy pre-built Single Page Application (SPA)
static assets to Google Cloud Storage (GCS) using Workload Identity Federation (WIF).

This action focuses solely on the deployment phase. It authenticates with Google Cloud,
prepares the Cloud SDK, and synchronizes the built distribution folder to the destination
GCS bucket via `gcloud storage rsync`.

## Features

- **Deployment Only**: Designed for pre-built applications, decoupled from build tools and Node versions.
- **Keyless GCP Authentication**: Authenticates securely via Workload Identity Federation.
- **Direct GCS Sync**: Runs `gcloud storage rsync` with recursive copy and optional stale object cleanup.
- **Flexible Destination**: Accepts bucket names with or without `gs://` prefix, including nested subpaths.

## Prerequisites

1. **Workload Identity Provider**: Configured to trust GitHub Actions OIDC tokens.
2. **Service Account**: Granted permissions to write to target GCS bucket (`roles/storage.objectAdmin`)
   and bound to the Workload Identity Provider via `roles/iam.workloadIdentityUser`.
3. **Workflow Permissions**: The calling GitHub Actions job **must** have:

   ```yaml
   permissions:
     contents: read
     id-token: write
   ```

## Usage

### Example

```yaml
name: Deploy Service

on:
  push:
    branches:
      - main
  workflow_dispatch:

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest

    permissions:
      contents: read
      id-token: write

    steps:
      - name: Checkout code
        uses: actions/checkout@v6

      - name: Setup Node.js
        uses: actions/setup-node@v6
        with:
          node-version: '24'
          cache: 'npm'

      - name: Build application
        run: |
          npm ci
          npm run build

      - name: Deploy to GCS
        uses: dszakallas/github-actions/deploy-cloud-run-spa@main
        with:
          workload_identity_provider: ${{ secrets.WIF_PROVIDER }}
          service_account: ${{ secrets.WIF_SERVICE_ACCOUNT }}
          bucket: ${{ secrets.GCS_BUCKET_NAME }}
          source_dir: dist
```

### Destination with Subpath

To deploy to a specific prefix inside the bucket (e.g. `dist/app`):

```yaml
      - name: Deploy to GCS
        uses: dszakallas/github-actions/deploy-cloud-run-spa@main
        with:
          workload_identity_provider: ${{ secrets.WIF_PROVIDER }}
          service_account: ${{ secrets.WIF_SERVICE_ACCOUNT }}
          bucket: ${{ secrets.GCS_BUCKET_NAME }}/dist/app
          source_dir: service/dist
```

## Inputs

| Input                        | Description                                  | Required | Default  |
| ---------------------------- | -------------------------------------------- | -------- | -------- |
| `workload_identity_provider` | Workload Identity Provider resource name     | Yes      | —        |
| `service_account`            | Service account email to impersonate         | Yes      | —        |
| `bucket`                     | Target GCS bucket or path (e.g. `my-bucket`) | Yes      | —        |
| `source_dir`                 | Local directory containing built static files| No       | `'dist'` |
| `delete_unmatched`           | Delete destination objects not in source     | No       | `'true'` |
