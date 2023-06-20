#!/bin/bash

regex_docker_images="^([a-zA-Z0-9.-]+\/)*[a-zA-Z0-9.-]+\/[a-zA-Z0-9.-]+(:[a-zA-Z0-9_.-]+)?$"

for image in $(kubeadm config images list --kubernetes-version ${K8S_VERSION} | grep registry.k8s.io); do
    if [[ $image =~ $regex_docker_images ]]; then
        if ! grep -Fxq "$image" "/images/kubeadm-images.txt"; then
            echo "$image" >> "/images/kubeadm-images.txt"
            echo "$image added captured."
        fi
    fi
done
