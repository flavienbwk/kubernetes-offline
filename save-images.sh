#!/bin/bash

source ./helpers.sh

IMAGES_FILE_PATH="./images/kubeadm-images.txt"

# Flannel
retrieve_images_from_url_yaml "flannel" "https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml" "$(pwd)/images"

# Read kubeadm images
while IFS= read -r line; do
    # Split the line using ":" as the delimiter
    IFS=':' read -ra values <<< "$line"
    
    # Retrieve the values
    registry="${values[0]}"
    image_tag="${values[1]}"
    image_name="${registry}_${image_tag}"
    image_name=$(slugify "$image_name").tar

    # Process the values as needed
    echo "Registry: $registry"
    echo "Image Tag: $image_tag"

    # Docker pull & save
    docker pull "$line"
    docker save -o "./images/$image_name" "$line"
    echo "=================="
done < "$IMAGES_FILE_PATH"
