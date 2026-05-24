# Automatic Container Builds

GitHub Actions that build and push Docker images to DockerHub on a weekly schedule. The purpose is to provide multi-arch images for projects where the maintainer doesn't publish official builds, or where official builds are missing specific architectures.

<!-- FOSSA Status -->
[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2Fzarguell%2Fauto_container_builds.svg?type=shield)](https://app.fossa.com/projects/git%2Bgithub.com%2Fzarguell%2Fauto_container_builds?ref=badge_shield)

## Images

### Self-Hosted Apps

| Docker Image | Source Repository | Cron (UTC) | Architectures |
|---|---|---|---|
| `zarguell/typemill` | [typemill/typemill](https://github.com/typemill/typemill) | Sun 06:15 | linux/amd64, linux/arm64 |
| `zarguell/documenso` | [documenso/documenso](https://github.com/documenso/documenso) | Sun 07:05 | linux/amd64, linux/arm64 |
| `zarguell/hoppscotch-app` | [hoppscotch/hoppscotch](https://github.com/hoppscotch/hoppscotch) | Sun 07:20 | linux/amd64, linux/arm64 |
| `zarguell/hoppscotch-backend` | [hoppscotch/hoppscotch](https://github.com/hoppscotch/hoppscotch) | Sun 07:15 | linux/amd64, linux/arm64 |
| `zarguell/hoppscotch-sh-admin` | [hoppscotch/hoppscotch](https://github.com/hoppscotch/hoppscotch) | Sun 07:25 | linux/amd64, linux/arm64 |
| `zarguell/tabby-web` | [Eugeny/tabby-web](https://github.com/Eugeny/tabby-web) | Sun 09:10 | linux/amd64, linux/arm64 |
| `zarguell/ryot` | [IgnisDa/ryot](https://github.com/IgnisDa/ryot) | Sun 06:30 | linux/arm64 |
| `zarguell/monica-fpm-supervisor-alpine` | [monicahq/docker](https://github.com/monicahq/docker) | Sun 13:25 | linux/amd64, linux/arm64 |
| `zarguell/monica-nginx` | [monicahq/docker](https://github.com/monicahq/docker) | Sun 13:25 | linux/amd64, linux/arm64 |
| `zarguell/firefly-iii-email-summary` | [davidschlachter/firefly-iii-email-summary](https://github.com/davidschlachter/firefly-iii-email-summary) | Sun 09:05 | linux/amd64, linux/arm64 |

### AI / Agent Workspaces

| Docker Image | Source Repository | Cron (UTC) | Architectures |
|---|---|---|---|
| `zarguell/hermes` | [NousResearch/hermes-agent](https://github.com/NousResearch/hermes-agent) | Sun 07:50 | linux/amd64, linux/arm64 |
| `zarguell/hermes:test` | [NousResearch/hermes-agent](https://github.com/NousResearch/hermes-agent) | Sun 07:50 | linux/amd64 |
| `zarguell/ai-workspace` | Hermes + [CodeNomad](https://github.com/NeuralNomadsAI/CodeNomad) | Sun 07:30 | linux/amd64, linux/arm64 |
| `zarguell/codenomad` | [NeuralNomadsAI/CodeNomad](https://github.com/NeuralNomadsAI/CodeNomad) | Sun 07:20 | linux/amd64, linux/arm64 |
| `zarguell/claudecode-ui` | [itsbrex/claudecode-ui](https://github.com/itsbrex/claudecode-ui) | Sun 16:45 | linux/amd64, linux/arm64 |

### Security & AD Tools

| Docker Image | Source Repository | Cron (UTC) | Architectures |
|---|---|---|---|
| `zarguell/adexplorersnapshot-bloodhound` | [c3c/ADExplorerSnapshot.py](https://github.com/c3c/ADExplorerSnapshot.py) | Sun 09:35 | linux/amd64, linux/arm64 |
| `zarguell/adexplorersnapshot-bloodhound:dev-ce` | [c3c/ADExplorerSnapshot.py](https://github.com/c3c/ADExplorerSnapshot.py) | Sun 09:45 | linux/amd64, linux/arm64 |
| `zarguell/rusthound-ce` | [g0h4n/RustHound-CE](https://github.com/g0h4n/RustHound-CE) | Sun 13:05 | linux/amd64, linux/arm64 |
| `zarguell/shredhound` | [ustayready/ShredHound](https://github.com/ustayready/shredhound) | Sun 13:10 | linux/amd64, linux/arm64 |
| `zarguell/sccmhunter` | [garrettfoster13/sccmhunter](https://github.com/garrettfoster13/sccmhunter) | Sun 14:45 | linux/amd64, linux/arm64 |
| `zarguell/pezor` | [phra/PEzor](https://github.com/phra/PEzor) | Sun 14:45 | linux/amd64, linux/arm64 |
| `zarguell/beelzebub` | [mariocandela/beelzebub](https://github.com/mariocandela/beelzebub) | Sun 08:05 | linux/arm64 |
| `zarguell/pashword` | [pashword/pashword](https://github.com/pashword/pashword) | Sun 08:40 | linux/amd64, linux/arm64 |
| `zarguell/libmedium` | [realaravinth/libmedium](https://git.batsense.net/realaravinth/libmedium) | Sun 08:50 | linux/amd64, linux/arm64 |
| `zarguell/maglit` | [NayamAmarshe/MagLit](https://github.com/NayamAmarshe/MagLit) | Sun 08:25 | linux/amd64, linux/arm64 |

### Games

| Docker Image | Source Repository | Cron (UTC) | Architectures |
|---|---|---|---|
| `zarguell/openclaw` | [openclaw/openclaw](https://github.com/openclaw/openclaw) | Sun 07:45 | linux/amd64, linux/arm64 |
| `zarguell/whosatmyfeeder` | [mmcc-xx/WhosAtMyFeeder](https://github.com/mmcc-xx/WhosAtMyFeeder) | Sun 07:35 | linux/amd64, linux/arm64 |

### Ghostwriter Stack (SpecterOps)

| Docker Image | Source Repository | Cron (UTC) | Architectures |
|---|---|---|---|
| `zarguell/ghostwriter_local_django` | [GhostManager/Ghostwriter](https://github.com/GhostManager/Ghostwriter) | Sun 11:05 | linux/amd64, linux/arm64 |
| `zarguell/ghostwriter_local_postgres` | [GhostManager/Ghostwriter](https://github.com/GhostManager/Ghostwriter) | Sun 11:15 | linux/amd64, linux/arm64 |
| `zarguell/ghostwriter_local_redis` | [GhostManager/Ghostwriter](https://github.com/GhostManager/Ghostwriter) | Sun 11:20 | linux/amd64, linux/arm64 |
| `zarguell/ghostwriter_local_hasura` | [GhostManager/Ghostwriter](https://github.com/GhostManager/Ghostwriter) | Sun 11:25 | linux/amd64, linux/arm64 |
| `zarguell/ghostwriter_production_django` | [GhostManager/Ghostwriter](https://github.com/GhostManager/Ghostwriter) | Sun 11:05 | linux/amd64, linux/arm64 |
| `zarguell/ghostwriter_production_nginx` | [GhostManager/Ghostwriter](https://github.com/GhostManager/Ghostwriter) | Sun 11:30 | linux/amd64, linux/arm64 |

---

## How It Works

Each container has a **Dockerfile** in `dockerfiles/` and a **GitHub Actions workflow** in `.github/workflows/`. Workflows run on a weekly Sunday cron schedule, staggered to avoid runner contention.

### Build Patterns

| Pattern | Description | Examples |
|---|---|---|
| **Source checkout** | Workflow checks out the upstream repo and builds its Dockerfile | typemill, documenso, hoppscotch, maglit, pashword, ryot, tabby-web, openclaw, monica, ghostwriter, whosatmyfeeder |
| **Self-contained Dockerfile** | Dockerfile clones or installs from source, workflow checks out this repo only | adexplorersnapshot-bloodhound, rusthound-ce, shredhound, sccmhunter, pezor, firefly-iii-email-summary |
| **Base image extension** | Extends an existing image with additional tools | hermes, hermes:test, ai-workspace, codenomad, claudecode-ui |

### Architecture Notes

- **linux/arm64 only**: ryot, beelzebub (upstream only publishes amd64)
- **linux/amd64 only**: hermes:test (test tag, single-arch for faster iteration)
- All others build for **both** amd64 and arm64 via QEMU emulation + Docker buildx

---

## Repo Structure

```
auto_container_builds/
├── dockerfiles/                          # One Dockerfile per container
│   ├── *.Dockerfile                      # Individual Dockerfiles
│   ├── ai-workspace/                     # Support files for ai-workspace
│   │   └── supervisord.conf
│   └── claudecode-ui/                    # Support files for claudecode-ui
│       ├── entrypoint.sh
│       └── healthcheck.js
├── .github/
│   ├── workflows/                        # One workflow per container
│   │   ├── *.yml                         # Build workflows
│   │   └── security-scorecard.yml        # OpenSSF Scorecards (non-Docker)
│   └── dependabot.yml                    # Docker & Actions dependency updates
├── assets/                               # Build artifacts (e.g. ML models)
│   └── model.tflite                      # Bird classifier model for WhosAtMyFeeder
├── README.md
└── renovate.json                         # Renovate config for version bumps
```

## Dependency Management

Two mechanisms keep dependencies fresh:

- **Dependabot** (`.github/dependabot.yml`) — updates base images (`FROM`) in Dockerfiles and GitHub Actions versions, weekly on Sundays, with 7-day cooldown
- **Renovate** (`renovate.json`) — uses regex managers to update version ARGs annotated with `# renovate: datasource=... depName=...` comments in Dockerfiles. Supports `github-releases`, `npm`, and `pypi` datasources

## License

[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2Fzarguell%2Fauto_container_builds.svg?type=large)](https://app.fossa.com/projects/git%2Bgithub.com%2Fzarguell%2Fauto_container_builds?ref=badge_large)
