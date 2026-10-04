# Deploy SPA Cloud Run App Action

A composite GitHub Action to build and deploy a Single Page Application (SPA)
to Google Cloud Storage (GCS) using Workload Identity Federation (WIF).

This action standardizes the build and deployment pipeline previously replicated
across projects such as `tisza-panasztar` and `bitter-pug`.

## Features

- **Automated Toolchain Setup**: Configures Node.js with package manager caching.
- **Dependency Installation**: Runs dependency installation (`npm ci` by default).
- **Asset Building**: Builds SPA assets (`make service/build` by default, customizable).
- **Keyless GCP Authentication**: Authenticates securely via Workload Identity Federation.
- **Google Cloud SDK**: Prepares Google Cloud SDK CLI (`gcloud`) for artifact uploading.
- **GCS Sync**: Executes deployment target with bucket name resolution.

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

### Basic Example (Convention-based with Makefile)

If your repository contains `service/build` and `service/deploy` Makefile targets:

```yaml
name: Deploy Service

on:
  push:
    branches:
      - main
    paths:
      - 'service/**'
      - 'package-lock.json'
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest

    permissions:
      contents: read
      id-token: write

    steps:
      - name: Checkout code
        uses: actions/checkout@v6

      - name: Deploy SPA
        uses: dszakallas/github-actions/deploy-cloud-run-spa@main
        with:
          workload_identity_provider: ${{ secrets.WIF_PROVIDER }}
          service_account: ${{ secrets.WIF_SERVICE_ACCOUNT }}
          gcs_bucket_name: ${{ secrets.GCS_BUCKET_NAME }}
```

### Custom Build and Deploy Commands

For projects not using `make service/build` / `make service/deploy`:

```yaml
      - name: Deploy SPA
        uses: dszakallas/github-actions/deploy-cloud-run-spa@main
        with:
          workload_identity_provider: ${{ secrets.WIF_PROVIDER }}
          service_account: ${{ secrets.WIF_SERVICE_ACCOUNT }}
          gcs_bucket_name: ${{ secrets.GCS_BUCKET_NAME }}
          build_command: npm run build
          deploy_command: gcloud storage rsync -r dist/ "gs://${GCS_BUCKET_NAME}/"
```

## Inputs

| Input                        | Description                              | Required | Default                |
| ---------------------------- | ---------------------------------------- | -------- | ---------------------- |
| `workload_identity_provider` | Workload Identity Provider resource name | Yes      | —                      |
| `service_account`            | Service account email to impersonate     | Yes      | —                      |
| `gcs_bucket_name`            | Target Google Cloud Storage bucket name  | No       | `""`                   |
| `node_version`               | Node.js version                          | No       | `'24'`                 |
| `cache`                      | Package manager cache in `setup-node`    | No       | `'npm'`                |
| `cache_dependency_path`      | Dependency lockfile path                 | No       | `'package-lock.json'`  |
| `install_command`            | Dependency installation command          | No       | `'npm ci'`             |
| `build_command`              | Build static assets command              | No       | `'make service/build'` |
| `deploy_command`             | Deployment command to upload assets      | No       | `'make service/deploy'`|
| `working_directory`          | Directory to execute commands in         | No       | `'.'`                  |
