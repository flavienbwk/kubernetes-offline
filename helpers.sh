#!/bin/bash

# Escape slahes from input
# Usage: escape_slashes input:str
function escape_slashes() {
  local input="$1"
  local output="$(echo "$input" | sed 's/\//\\\//g')"
  echo "$output"
}

# Slugify a provided string
# Usage: slugify name:str
# Return: str
slugify() {
  local string="$1"
  # convert string to lowercase
  string=$(echo "$string" | tr '[:upper:]' '[:lower:]')
  # replace spaces with hyphens
  string=$(echo "$string" | sed -E 's/\s+/-/g')
  # replace special characters with hyphens
  string=$(echo "$string" | sed -E 's/[^[:alnum:]]+/-/g')
  # remove hyphens from the start and end of the string
  string=$(echo "$string" | sed -E 's/^-+|-+$//g')
  echo "$string"
}

# Returns a list of Docker images in the provided file
# Usage : get_docker_images file_path:str
# Returns : [str]
get_docker_images_from_file () {
    file_path="$1"
    # Original regex: (image|value)"?'?:\s*["'"]?([a-zA-Z0-9._@\/-]+:[a-zA-Z0-9._-]+)["'"]?
    regex="(image|value)\"?'?:\\s*[\"']?([a-zA-Z0-9._@\\/\\-]+:[a-zA-Z0-9._\\-]+)[\"']?"
    images=()
    while read -r line; do
        if [[ $line =~ $regex ]]; then
            docker_image="${BASH_REMATCH[2]}"
            images+=("$docker_image")
        fi
    done < "$file_path"
    echo "${images[@]}"
}

# Parse and save images from a remote YAML configuration file.
# Usage : retrieve_images_from_url_yaml object_name:str file_url_yaml:str dest_dir:str
# Returns : (void)
retrieve_images_from_url_yaml() {
    slug_name=$(slugify "$1")
    url_yaml="$2"
    dest_dir="$(realpath "$3")"
    echo "INFO: Retrieving $1 dependencies..."
    service_path="$slug_name.yaml"
    wget --directory-prefix="$dest_dir" -N "$url_yaml"
    service_docker_images=$(get_docker_images_from_file "$service_path")
    echo "INFO: Retrieving $1 images..."
    for docker_image in $service_docker_images
    do
        slugified_docker_image=$(slugify "$docker_image")
        docker pull $docker_image
        docker save -o "$dest_dir/${slugified_docker_image}.tar" "$docker_image"
    done
    echo "INFO: OK."
}

# Parse and save images from a local YAML configuration file.
# Usage : retrieve_images_from_local_yaml object_name:str file_url_yaml:str dest_dir:str
# Returns : (void)
retrieve_images_from_local_yaml() {
    slug_name=$(slugify "$1")
    service_yaml_path="$2"
    dest_dir="$(realpath "$3")"
    echo "INFO: Retrieving $1 dependencies..."
    service_docker_images=$(get_docker_images_from_file "$service_yaml_path")
    echo "INFO: Retrieving $1 images..."
    for docker_image in $service_docker_images
    do
        slugified_docker_image=$(slugify "$docker_image")
        docker pull $docker_image
        docker save -o "$dest_dir/${slugified_docker_image}.tar" "$docker_image"
    done
    echo "INFO: OK."
}
