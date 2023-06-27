#!/bin/bash

source ./helpers.sh

IMAGES_FILE_PATH="./images/kubeadm-images.txt"
CURRENT_DIR=$(pwd)
PRIVATE_REGISTRY="${PRIVATE_REGISTRY_URL}/${PRIVATE_REGISTRY_REPO_NAME}"
REGEX_IMAGE_WITH_DOMAIN='^(([a-z0-9]+\.)+([a-z]{2,}))\/[^/]+'

# /** Options **/

push=false

while getopts ":p" opt; do
  case $opt in
    p)
      push=true
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

# !/** Options **/


echo "INFO: Script for loading and pushing Che images found in folder..."
echo "INFO: The current working directory is: $CURRENT_DIR"

if [[ ! -f "$CURRENT_DIR/.env" ]]; then
    echo "ERROR: Env file not found : $CURRENT_DIR/.env"
    echo "ERROR: Place yourself in the kubernetes-offline top-level directory. Did you copy the .env.example file ?"
    exit 1
fi
source "$CURRENT_DIR/.env"

IMAGES_DIR_PATH="${CURRENT_DIR}/images"
if [[ ! -d "$IMAGES_DIR_PATH" ]]; then
    echo "ERROR: Export directory not found : $IMAGES_DIR_PATH"
    echo "ERROR: Place yourself in the \"kubernetes-offline\" top-level directory."
    exit 1
fi


echo "INFO: Processing docker images in $IMAGES_DIR_PATH ..."
private_registry="${REGISTRY_URL}/${REGISTRY_REPO_NAME}"
private_registry_fmt=$(escape_slashes "$private_registry")
for chart_yaml_file_path in $(find "$IMAGES_DIR_PATH" -iname "*.yaml" -iname "*.txt"); do
    echo "INFO: Replacing images found in file: $chart_yaml_file_path"
    docker_images=$(get_docker_images_from_file "$chart_yaml_file_path")
    docker_error_occured_in_file=0
    for docker_image in $docker_images; do
        docker_image_slug=$(slugify "$docker_image")
        docker_image_esc=$(escape_slashes "$docker_image")
        docker_image_path="${IMAGES_DIR_PATH}/${DOCKER_IMAGE_SLUG}.tar"
        if [[ $docker_image =~ $REGEX_IMAGE_WITH_DOMAIN ]]; then
            # Docker images with a domain
            docker_image_domain="${BASH_REMATCH[1]}"
            docker_image_private=$(echo "$docker_image_esc" | sed -E "s/${docker_image_domain}/${private_registry_fmt}/g")
        else
            # Docker images without a domain (hub.docker.com)
            docker_image_private=$(echo "$docker_image_esc" | sed -E "s/${docker_image_esc}/${private_registry_fmt}\/${docker_image_esc}/g")
        fi
        if [[ ! -f "$docker_image_path" ]]; then
            docker_error_occured_in_file=1
            echo "WARN:     Docker image NOT FOUND : $docker_image_path !!"
            continue
        do
        echo "INFO: Loading \"$docker_image\"..."
        docker load -i "$docker_image_path"
        if docker inspect "$docker_image_path" > /dev/null 2>&1; then
            echo "INFO:     Load succeeded."
        else
            docker_error_occured_in_file=1
            echo "WARN:     Load failed."
            continue
        fi
        echo "INFO:     Tagging to \"$docker_image_private\""
        docker tag "$docker_image" "$docker_image_private"
        if [ $? -eq 0 ]; then
            echo "INFO:     Tagged successfully."
        else
            docker_error_occured_in_file=1
            echo "WARN:     Tagging failed."
            continue
        fi

        
        if $push ; then
            echo "INFO:     Pushing..."
            docker push "$docker_image_path"
            if [ $? -eq 0 ]; then
                echo "INFO:     Pushed successfully."
            else
                docker_error_occured_in_file=1
                echo "WARN:     Push failed."
                continue
            fi
        fi
    done
    if [[ "$docker_error_occured_in_file" -eq 0 ]]; then
        sed -i -E "s/${docker_image}/${docker_image_private}/g" "$file_path"
        echo "INFO: OK."
    else
        echo "WARN: Something went wrong, see logs above. Files were not edited."
    fi
done
echo "INFO: OK."

echo "INFO: OK."
