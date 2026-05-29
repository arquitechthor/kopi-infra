#!/bin/bash
# Check that all tools required to run Kopi Tools locally are installed.
set -e

ok=true

check() {
    local name=$1
    local cmd=$2
    local version_flag=${3:---version}
    if command -v "$cmd" >/dev/null 2>&1; then
        local ver
        ver=$($cmd $version_flag 2>&1 | head -1)
        echo "  ✓ $name — $ver"
    else
        echo "  ✗ $name — NOT FOUND"
        ok=false
    fi
}

echo "=== Kopi Tools — Prerequisites Check ==="
echo ""
echo "Docker:"
check "Docker"          docker    "--version"
check "Docker Compose"  docker    "compose version"

echo ""
echo "Kubernetes (optional — only needed for k8s deployment):"
check "kubectl"         kubectl   "version --client --short 2>/dev/null"

echo ""
echo "Development tools (optional — only needed to build from source):"
check "Java 21"         java      "-version 2>&1 | head -1"
check "Node.js"         node      "--version"
check "Python 3"        python3   "--version"

echo ""
if $ok; then
    echo "All required tools are available."
else
    echo "Some required tools are missing. Install them and re-run."
    exit 1
fi
