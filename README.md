# kubernetes-offline

Benefit Kubernetes on your local computer when on vacation ✈️

## Pre-requisite

- [`docker`](https://docs.docker.com/engine/install/) on source (Internet)
- [`containerd`](https://github.com/containerd/containerd/blob/main/docs/getting-started.md) on target (air-gapped) hosts

## Download dependencies (offline)

1. Edit env variables to match target version for Kubernetes (default to _1.27.1_)

    ```bash
    cp .env.example .env
    ```

2. Retrieve images

    ```bash
    docker-compose up --build download
    bash ./save-images.sh
    ```

## Load 
