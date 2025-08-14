#!/bin/bash

set -e

if [ $# -eq 0 ]; then
    echo "Usage: $0 <version>"
    echo "Example: $0 1.0.24"
    exit 1
fi

VERSION=$1

echo "Updating Go service deployments to version: $VERSION"

BASE_DIR="$(dirname "$0")/base"

update_image_tag() {
    local file=$1
    local image_name=$2
    
    if [ ! -f "$file" ]; then
        echo "Error: File $file not found"
        exit 1
    fi
    
    echo "Updating $file..."
    sed -i.bak "s|image: $image_name:.*|image: $image_name:$VERSION|" "$file"
    rm -f "$file.bak"
    echo "✓ Updated $file"
}

update_image_tag "$BASE_DIR/deployment-go.yaml" "ypeskov/orgfin-api-go"
update_image_tag "$BASE_DIR/deployment-scheduler-go.yaml" "ypeskov/orgfin-scheduler-go"
update_image_tag "$BASE_DIR/deployment-worker-go.yaml" "ypeskov/orgfin-worker-go"

echo ""
echo "All Go service deployments updated to version: $VERSION"
echo ""
echo "Updated files:"
echo "  - $BASE_DIR/deployment-go.yaml"
echo "  - $BASE_DIR/deployment-scheduler-go.yaml"
echo "  - $BASE_DIR/deployment-worker-go.yaml"
echo ""
echo "To apply changes, run:"
echo "  cd orgfin-backend && ./apply.sh"