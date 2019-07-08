# orbs-for-tools
[![CircleCI](https://circleci.com/gh/izumin5210/orbs-for-tools/tree/master.svg?style=svg)](https://circleci.com/gh/izumin5210/orbs-for-tools/tree/master)
[![license](https://img.shields.io/github/license/izumin5210/orbs-for-tools.svg)](./LICENSE)

:recycle: CircleCI Orbs for Continous-Delivery for Tools

| name | description | version |
| --- | --- | --- |
| [**go-crossbuild**](#go-crossbuild-) | Build Go applications for multiplatform and packaging with [goxz](https://github.com/Songmu/goxz) | [![CircleCI Orb Version](https://img.shields.io/badge/endpoint.svg?url=https://badges.circleci.io/orb/izumin5210/go-crossbuild)](https://circleci.com/orbs/registry/orb/izumin5210/go-crossbuild) |
| [**github-release**](#github-release-) | Create a new release on GitHub with [ghr](https://github.com/tcnksm/ghr) | [![CircleCI Orb Version](https://img.shields.io/badge/endpoint.svg?url=https://badges.circleci.io/orb/izumin5210/github-release)](https://circleci.com/orbs/registry/orb/izumin5210/github-release) |
| [**homebrew**](#homebrew-) | Create a Formula for Homebrew with [maltmill](https://github.com/Songmu/maltmill) and commit it to tap repository | [![CircleCI Orb Version](https://img.shields.io/badge/endpoint.svg?url=https://badges.circleci.io/orb/izumin5210/homebrew)](https://circleci.com/orbs/registry/orb/izumin5210/homebrew) |
| [**inline**](#inline-) | Describe commands on workflows directly, like inline-steps | [![CircleCI Orb Version](https://img.shields.io/badge/endpoint.svg?url=https://badges.circleci.io/orb/izumin5210/inline)](https://circleci.com/orbs/registry/orb/izumin5210/inline) |
| [**protobuf**](#protobuf-) | Install protobuf (protoc command and standard libs) | [![CircleCI Orb Version](https://img.shields.io/badge/endpoint.svg?url=https://badges.circleci.io/orb/izumin5210/protobuf)](https://circleci.com/orbs/registry/orb/izumin5210/protobuf) |

```yaml
version: 2.1

orbs:
  go-module: timakin/go-module@0.3.0
  go-crossbuild: izumin5210/go-crossbuild@0.1.1
  github-release: izumin5210/github-release@0.1.1
  homebrew: izumin5210/homebrew@0.1.3
  inline: izumin5210/inline@0.1.0

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

      # Describe "run tests" steps to a workflow directly
      # https://circleci.com/orbs/registry/orb/izumin5210/inline
      - inline/steps:
          executor: default
          name: test
          steps:
            - run: go test -race -v ./...
          requires:
            - go-module/download

      # Build a Go application for clossplatform
      # https://circleci.com/orbs/registry/orb/izumin5210/go-crossbuild
      - go-crossbuild/build:
          <<: *filter-default
          executor: default
          packages: ./cmd/awesomecli
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
          executor: default
          context: tool-releasing
          requires:
            - go-crossbuild/build

      # Create (or update) a Homebrew formula
      # https://circleci.com/orbs/registry/orb/izumin5210/homebrew
      - homebrew/update:
          <<: *filter-release
          executor: default
          context: tool-releasing
          requires:
            - github-release/create
```


## [go-crossbuild ![CircleCI Orb Version](https://img.shields.io/badge/endpoint.svg?url=https://badges.circleci.io/orb/izumin5210/go-crossbuild)](https://circleci.com/orbs/registry/orb/izumin5210/go-crossbuild)

Build Go applications for multiplatform and packaging with [goxz](https://github.com/Songmu/goxz)

<details>
<summary>Example</summary>

```yaml
workflows:
  build:
    jobs:
      # you should download dependencies
      - setup

      - go-crossbuild/build:
          executor: default
          packages: ./cmd/awesomecli
          workspace-root: /go/src/github.com/example/awesomecli
          requires:
            - setup
```

</details>


## [github-release ![CircleCI Orb Version](https://img.shields.io/badge/endpoint.svg?url=https://badges.circleci.io/orb/izumin5210/github-release)](https://circleci.com/orbs/registry/orb/izumin5210/github-release)

Create a new release on GitHub with [ghr](https://github.com/tcnksm/ghr)

<details>
<summary>Example</summary>

```yaml
aliases:
  filter-release: &filter-release
    filters:
      branches:
        ignore: /.*/
      tags:
        only: /^v\d+\.\d+\.\d+$/

workflows:
  build:
    jobs:
      # you should put built binaries into <path> of github-release/create
      # default: ./artifacts/
      - build

      - github-release/create:
          <<: *filter-release
          # This context contains following env vars:
          # * GITHUB_TOKEN
          context: tool-releasing
          requires:
            - go-crossbuild/build
```

</details>


## [homebrew ![CircleCI Orb Version](https://img.shields.io/badge/endpoint.svg?url=https://badges.circleci.io/orb/izumin5210/homebrew)](https://circleci.com/orbs/registry/orb/izumin5210/homebrew)

Create a Formula for Homebrew with [maltmill](https://github.com/Songmu/maltmill) and commit it to tap repository

<details>
<summary>Example</summary>

```yaml
aliases:
  filter-release: &filter-release
    filters:
      branches:
        ignore: /.*/
      tags:
        only: /^v\d+\.\d+\.\d+$/

workflows:
  build:
    jobs:
      - homebrew/update:
          <<: *filter-release
          # This context contains following env vars:
          # * HOMEBREW_TAP_REPO_SLUG
          # * GITHUB_TOKEN
          # * GITHUB_EMAIL
          # * GITHUB_USER
          context: tool-releasing
          requires:
            - github-release/create
```

</details>


## [inline ![CircleCI Orb Version](https://img.shields.io/badge/endpoint.svg?url=https://badges.circleci.io/orb/izumin5210/inline)](https://circleci.com/orbs/registry/orb/izumin5210/inline)

Describe commands on workflows directly, like inline-steps

<details>
<summary>Example</summary>

```yaml
version: 2.1

orbs:
  go-module: timakin/go-module@0.3.0
  inline: izumin5210/inline@0.0.1

executors:
  golang:
    parameters:
      version:
        type: string
    docker:
      - image: circleci/golang:<< parameters.version >>
    environment:
      - GO111MODULE: "on"

aliases:
  go1.11: &go-1-11
    executor:
      name: golang
      version: '1.11'
  go1.12: &go-1-12
    executor:
      name: golang
      version: '1.12'

workflows:
  test:
    jobs:
      - go-module/download:
          <<: *go-1-12
          name: 'setup-1.12'
          persist-to-workspace: true
          vendoring: true

      - go-module/download:
          <<: *go-1-11
          name: 'setup-1.11'
          persist-to-workspace: true
          vendoring: true

      - inline/steps:
          <<: *go-1-12
          name: 'test-1.12'
          steps:
            - run: make cover
            - run: bash <(curl -s https://codecov.io/bash)
          requires:
            - setup-1.12

      - inline/steps:
          <<: *go-1-11
          name: 'test-1.11'
          steps:
            - run: make test
          requires:
            - setup-1.11

      - inline/steps:
          <<: *go-1-12
          name: 'test-e2e-1.12'
          steps:
            - run: make test-e2e
          requires:
            - setup-1.12

      - inline/steps:
          <<: *go-1-11
          name: 'test-e2e-1.11'
          steps:
            - run: make test-e2e
          requires:
            - setup-1.11
```

</details>


## [protobuf ![CircleCI Orb Version](https://img.shields.io/badge/endpoint.svg?url=https://badges.circleci.io/orb/izumin5210/protobuf)](https://circleci.com/orbs/registry/orb/izumin5210/protobuf)

Install protobuf (protoc command and standard libs)

<details>
<summary>Example</summary>

```yaml
version: 2.1

orbs:
  protobuf: izumin5210/protobuf@0.0.1

jobs:
  protoc:
    docker:
      - image: circleci/golang
    steps:
      - run: protoc --version

workflows:
  build:
    jobs:
      - protobuf/install

      - protoc
```

</details>
