# github-actions

A collection of reusable, production-ready GitHub Actions.

## Available Actions

| Action                                           | Description                                                |
| ------------------------------------------------ | ---------------------------------------------------------- |
| [`deploy-cloud-run-spa`](./deploy-cloud-run-spa) | Deploy pre-built SPA static assets to GCS using WIF.       |

## Repository Structure

Each action is maintained in its own top-level directory containing an `action.yml` metadata file and documentation:

```text
.
├── .github/
│   └── workflows/
│       └── ci.yml               # Actionlint CI verification
├── deploy-cloud-run-spa/
│   ├── action.yml               # Composite action definition
│   └── README.md                # Action documentation and examples
├── devenv.nix                   # Development environment definition
├── devenv.yaml                  # Devenv inputs (nixpkgs, git-hooks, bikeshed)
└── README.md
```

Actions in this repository can be consumed using the path syntax:

```yaml
- uses: dszakallas/github-actions/<action-name>@<ref>
  with:
    ...
```

## Development Environment

This repository uses [devenv.sh](https://devenv.sh) to provide a consistent Nix-based environment for
authoring, linting, and testing GitHub Actions.

### Tools Included

- **`actionlint`**: Static checker and linter for GitHub Actions workflows and actions.
- **`act`**: Run GitHub Actions workflows locally inside Docker/Podman containers.
- **`gh`**: GitHub CLI.
- **`shellcheck`**: Bash linter integrated with actionlint.
- **`yamlfmt`**: Formatter for YAML files.
- **`git-hooks`**: Pre-commit hooks for running `actionlint`, `markdownlint`, and `nixfmt`.

### Getting Started

If you use `direnv`:

```bash
direnv allow
```

Otherwise, enter the devenv shell directly:

```bash
devenv shell
```

To include AI agent configurations:

```bash
devenv --profile agents up
```

### Running Checks

Lint workflows and actions:

```bash
actionlint
```

Run tests with devenv:

```bash
devenv test
```
