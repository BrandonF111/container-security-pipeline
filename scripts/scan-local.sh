#!/bin/bash

# Local Docker image security scanning script
# Usage: ./scan-local.sh [image-name]

set -e

IMAGE_NAME=${1:-"vulnerable-demo:latest"}
REPORT_DIR="./security-reports"

echo "=========================================="
echo "Docker Security Scanning Pipeline"
echo "=========================================="
echo "Target Image: $IMAGE_NAME"
echo ""

# Create reports directory
mkdir -p "$REPORT_DIR"

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "Error: Docker is not running"
    exit 1
fi

# Check if image exists
if ! docker image inspect "$IMAGE_NAME" > /dev/null 2>&1; then
    echo "Error: Image $IMAGE_NAME not found"
    echo "Build it first with: docker build -f vulnerable-app/Dockerfile.vulnerable -t vulnerable-demo:latest vulnerable-app/"
    exit 1
fi

echo "Step 1: Installing Trivy (if not installed)..."
if ! command -v trivy &> /dev/null; then
    echo "Installing Trivy..."
    wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
    echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
    sudo apt-get update
    sudo apt-get install trivy -y
fi

echo ""
echo "Step 2: Scanning for OS and library vulnerabilities..."
trivy image --severity CRITICAL,HIGH,MEDIUM "$IMAGE_NAME" | tee "$REPORT_DIR/vulnerabilities.txt"

echo ""
echo "Step 3: Generating JSON report..."
trivy image --format json --output "$REPORT_DIR/vulnerabilities.json" "$IMAGE_NAME"

echo ""
echo "Step 4: Scanning for secrets..."
trivy image --scanners secret "$IMAGE_NAME" | tee "$REPORT_DIR/secrets.txt"

echo ""
echo "Step 5: Scanning for misconfigurations..."
trivy image --scanners config "$IMAGE_NAME" | tee "$REPORT_DIR/misconfigurations.txt"

echo ""
echo "Step 6: Generating summary..."
CRITICAL=$(jq '[.Results[].Vulnerabilities[]? | select(.Severity=="CRITICAL")] | length' "$REPORT_DIR/vulnerabilities.json")
HIGH=$(jq '[.Results[].Vulnerabilities[]? | select(.Severity=="HIGH")] | length' "$REPORT_DIR/vulnerabilities.json")
MEDIUM=$(jq '[.Results[].Vulnerabilities[]? | select(.Severity=="MEDIUM")] | length' "$REPORT_DIR/vulnerabilities.json")

echo "=========================================="
echo "SCAN SUMMARY"
echo "=========================================="
echo "Image: $IMAGE_NAME"
echo "Critical: $CRITICAL"
echo "High: $HIGH"
echo "Medium: $MEDIUM"
echo ""
echo "Reports saved to: $REPORT_DIR/"
echo "=========================================="

if [ "$CRITICAL" -gt 0 ] || [ "$HIGH" -gt 10 ]; then
    echo "⚠️  SECURITY POLICY VIOLATION"
    echo "This image would be blocked in production"
    exit 1
else
    echo "✅ Security policy passed"
fi
