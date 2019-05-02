# orbs-for-tools
[![CircleCI](https://circleci.com/gh/izumin5210/orbs-for-tools/tree/master.svg?style=svg)](https://circleci.com/gh/izumin5210/orbs-for-tools/tree/master)
[![license](https://img.shields.io/github/license/izumin5210/orbs-for-tools.svg)](./LICENSE)

:recycle: CircleCI Orbs for Continous-Delivery for Tools

```yaml
version: 2.1

orbs:
  go-module: timakin/go-module@0.3.0
  go-crossbuild: izumin5210/go-crossbuild@0.0.1
  github-release: izumin5210/github-release@0.0.1
  homebrew: izumin5210/homebrew@0.0.1

aliases:
  filter-default: &filter-default
    filters:
      tags:
        only: /.*/
  filter-release: &filter-release
    filters:
      branches:
        ignore: /.*/
      tags:
        only: /^v\d+\.\d+\.\d+$/

executors:
  default:
    working_directory: /go/src/github.com/example/awesomecli
    docker:
      - image: circleci/golang:1.12
    environment:
      - GO111MODULE: "on"

workflows:
  build:
    jobs:
      # Download and cache dependencies
      # https://circleci.com/orbs/registry/orb/timakin/go-module
      - go-module/download:
          <<: *filter-default
          executor: default
          persist-to-workspace: true
          vendoring: true
          workspace-root: /go/src/github.com/example/awesomecli

      # Build a Go application for clossplatform
      # https://circleci.com/orbs/registry/orb/izumin5210/go-crossbuild
      - go-crossbuild/build:
          <<: *filter-default
          executor: default
          packages: ./cmd/awesomecli
          workspace-root: /go/src/github.com/example/awesomecli
          requires:
            - go-module/download

      # Create a new release to GitHub Releases
      # https://circleci.com/orbs/registry/orb/izumin5210/github-release
      - github-release/create:
          <<: *filter-release
          # This context contains following env vars:
          # * HOMEBREW_TAP_REPO_SLUG
          # * GITHUB_TOKEN
          # * GITHUB_EMAIL
          # * GITHUB_USER
          context: tool-releasing
          requires:
            - go-crossbuild/build

      # Create (or update) a Homebrew formula
      # https://circleci.com/orbs/registry/orb/izumin5210/homebrew
      - homebrew/update:
          <<: *filter-release
          context: tool-releasing
          requires:
            - github-release/create
```


## [go-crossbuild ![CircleCI Orb Version](https://img.shields.io/badge/endpoint.svg?url=https://badges.circleci.io/orb/izumin5210/go-crossbuild)](https://circleci.com/orbs/registry/orb/izumin5210/go-crossbuild)

TBD


## [github-release ![CircleCI Orb Version](https://img.shields.io/badge/endpoint.svg?url=https://badges.circleci.io/orb/izumin5210/github-release)](https://circleci.com/orbs/registry/orb/izumin5210/github-release)

TBD


## [homebrew ![CircleCI Orb Version](https://img.shields.io/badge/endpoint.svg?url=https://badges.circleci.io/orb/izumin5210/homebrew)](https://circleci.com/orbs/registry/orb/izumin5210/homebrew)

TBD
