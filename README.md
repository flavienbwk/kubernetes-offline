# kubernetes-offline

Benefit Kubernetes on your local computer when on vacation ✈️

## Pre-requisite

- [`docker`](https://docs.docker.com/engine/install/) on source (Internet)
- [`containerd`](https://github.com/containerd/containerd/blob/main/docs/getting-started.md) on target (air-gapped) hosts

## A. Download dependencies (online)

1. Edit env variables to match target version for Kubernetes (default to _1.27.1_)

    ```bash
    cp .env.example .env
    ```

2. Retrieve images

    ```bash
    docker-compose up --build download
    bash ./save-images.sh
    ```

## B. Load dependencies

1. Fully copy this repo with images present in `images/` and put it on your offline computer

2. Load images locally

    ```bash
    bash ./load-images.sh
    ```

    Optionally push them :

    ```bash
    bash ./load-images.sh -p
    ```
