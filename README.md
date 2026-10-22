# kimun-action

Grade the code health of a project with [Kimün](https://github.com/lnds/kimun) (`km`) in GitHub Actions, and publish a badge of the score:

[![km score](https://raw.githubusercontent.com/lnds/kimun/main/.github/km-score.svg)](https://kimun.tools)

The action installs the `km` binary of a kimun release (checked against its published checksums), runs `km score`, and writes two badges to a directory:

- `km-score.svg`: a self-contained badge, to serve as is;
- `km-score.json`: the JSON of a [shields.io endpoint badge](https://shields.io/badges/endpoint-badge).

`km` stays on the `PATH` for the steps that follow.

## A badge that stays current, on GitHub Pages

A badge committed to the repository is as fresh as its last run, and a workflow cannot commit to a protected branch. Publishing it on GitHub Pages keeps it current on every push without touching the branch:

```yaml
name: km score

on:
  push:
    branches: [main]

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: pages
  cancel-in-progress: true

jobs:
  badge:
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: ${{ steps.deploy.outputs.page_url }}
    steps:
      - uses: actions/checkout@v4
      - uses: lnds/kimun-action@v1
      - uses: actions/upload-pages-artifact@v3
        with:
          path: km-badge
      - id: deploy
        uses: actions/deploy-pages@v4
```

Turn on Pages with **Settings → Pages → Source: GitHub Actions**, then put the badge in the README:

```markdown
[![km score](https://OWNER.github.io/REPO/km-score.svg)](https://kimun.tools)
```

or through shields.io, which caches it and lets you restyle it:

```markdown
[![km score](https://img.shields.io/endpoint?url=https://OWNER.github.io/REPO/km-score.json)](https://kimun.tools)
```

This workflow publishes the badge as the whole Pages site. If the repository already has one, copy `km-badge/` into the site you build instead of uploading it alone.

## Inputs

| Input | Default | Description |
|-------|---------|-------------|
| `version` | `latest` | Version of kimun to install, such as `0.44.0` |
| `path` | `.` | Directory to analyze |
| `badge-dir` | `km-badge` | Directory where `km-score.svg` and `km-score.json` are written |

## Outputs

| Output | Example | Description |
|--------|---------|-------------|
| `score` | `91.4` | The score, 0 to 100 |
| `grade` | `A` | The grade, A++ to F-- |
| `badge-dir` | `km-badge` | Directory holding the badges |

## More than the badge

Once the action has run, `km` is installed, so the next steps can use any command. A quality gate on pull requests, failing when a changed file gets worse:

```yaml
on: pull_request

jobs:
  gate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - uses: lnds/kimun-action@v1
      - run: km score --trend origin/${{ github.base_ref }} --fail-if-worse --gate-scope changed
```

See the [kimun documentation](https://kimun.tools/en/docs/score/) for every command and flag.

## Runners

Linux (x64 and ARM64), macOS on Apple silicon and Windows x64. On other runners, install kimun with `cargo install kimun` before this action.

## License

MIT
