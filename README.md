# Automatic Container Builds

The goal of this repo is to use Github actions to build and push docker images on a continious basis.

| Container Image | Source Repo | Build Cron | Build Status | Architectures |
| --------------- | ----------- | ---------- | ------------ | ------------- |
| docker.io/zarguell/Typemill | [Typemill](https://github.com/typemill/typemill) | 15 6 * * 0 | [![Build Typemill Container](https://github.com/zarguell/auto_container_builds/actions/workflows/typemill.yml/badge.svg)](https://github.com/zarguell/auto_container_builds/actions/workflows/typemill.yml) | amd64, arm64 |
| docker.io/zarguell/ryot | [ryot](https://github.com/IgnisDa/ryot) | 30 6 * * 0 | [![Build Ryot Container](https://github.com/zarguell/auto_container_builds/actions/workflows/ryot.yml/badge.svg)](https://github.com/zarguell/auto_container_builds/actions/workflows/ryot.yml) | arm64 |
