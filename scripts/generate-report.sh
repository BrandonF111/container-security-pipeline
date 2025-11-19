#!/bin/bash

# Generate HTML vulnerability report from Trivy JSON output
# Usage: ./generate-report.sh [input.json] [output.html]

set -e

JSON_FILE=${1:-"./security-reports/vulnerabilities.json"}
OUTPUT_FILE=${2:-"./security-reports/report.html"}

if [ ! -f "$JSON_FILE" ]; then
    echo "Error: JSON file not found: $JSON_FILE"
    echo "Run a scan first: ./scripts/scan-local.sh vulnerable-demo:latest"
    exit 1
fi

echo "Generating HTML report from: $JSON_FILE"

# Extract vulnerability counts
CRITICAL=$(jq '[.Results[]?.Vulnerabilities[]? | select(.Severity=="CRITICAL")] | length' "$JSON_FILE")
HIGH=$(jq '[.Results[]?.Vulnerabilities[]? | select(.Severity=="HIGH")] | length' "$JSON_FILE")
MEDIUM=$(jq '[.Results[]?.Vulnerabilities[]? | select(.Severity=="MEDIUM")] | length' "$JSON_FILE")
LOW=$(jq '[.Results[]?.Vulnerabilities[]? | select(.Severity=="LOW")] | length' "$JSON_FILE")

# Generate HTML report
cat > "$OUTPUT_FILE" << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Container Security Scan Report</title>
    <style>
        body { 
            font-family: Arial, sans-serif; 
            margin: 20px; 
            background: #f5f5f5; 
        }
        .container { 
            max-width: 1200px; 
            margin: 0 auto; 
            background: white; 
            padding: 20px; 
            border-radius: 8px; 
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        h1 { 
            color: #333; 
            border-bottom: 3px solid #e74c3c; 
            padding-bottom: 10px; 
        }
        .metadata {
            background: #ecf0f1;
            padding: 15px;
            border-radius: 5px;
            margin: 20px 0;
        }
        .summary { 
            display: flex; 
            gap: 20px; 
            margin: 20px 0; 
            flex-wrap: wrap;
        }
        .stat-card { 
            flex: 1; 
            min-width: 150px;
            padding: 20px; 
            border-radius: 8px; 
            text-align: center; 
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .critical { background: #e74c3c; color: white; }
        .high { background: #e67e22; color: white; }
        .medium { background: #f39c12; color: white; }
        .low { background: #3498db; color: white; }
        .stat-number { 
            font-size: 48px; 
            font-weight: bold; 
            display: block;
            margin: 10px 0;
        }
        .stat-label { 
            font-size: 14px; 
            text-transform: uppercase; 
            opacity: 0.9;
        }
        .policy-result {
            padding: 15px;
            margin: 20px 0;
            border-radius: 5px;
            font-weight: bold;
        }
        .policy-pass {
            background: #2ecc71;
            color: white;
        }
        .policy-fail {
            background: #e74c3c;
            color: white;
        }
        table { 
            width: 100%; 
            border-collapse: collapse; 
            margin-top: 20px; 
        }
        th, td { 
            padding: 12px; 
            text-align: left; 
            border-bottom: 1px solid #ddd; 
        }
        th { 
            background: #34495e; 
            color: white; 
            position: sticky;
            top: 0;
        }
        tr:hover {
            background: #f8f9fa;
        }
        .severity-badge { 
            padding: 4px 8px; 
            border-radius: 4px; 
            font-size: 12px; 
            font-weight: bold; 
            color: white;
        }
        .badge-critical { background: #e74c3c; }
        .badge-high { background: #e67e22; }
        .badge-medium { background: #f39c12; }
        .badge-low { background: #3498db; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🔒 Container Security Scan Report</h1>
        
        <div class="metadata">
            <p><strong>Generated:</strong> $(date)</p>
            <p><strong>Scan File:</strong> $JSON_FILE</p>
        </div>

        <div class="summary">
            <div class="stat-card critical">
                <div class="stat-label">Critical</div>
                <span class="stat-number">$CRITICAL</span>
            </div>
            <div class="stat-card high">
                <div class="stat-label">High</div>
                <span class="stat-number">$HIGH</span>
            </div>
            <div class="stat-card medium">
                <div class="stat-label">Medium</div>
                <span class="stat-number">$MEDIUM</span>
            </div>
            <div class="stat-card low">
                <div class="stat-label">Low</div>
                <span class="stat-number">$LOW</span>
            </div>
        </div>
EOF

# Add policy result
if [ "$CRITICAL" -eq 0 ] && [ "$HIGH" -lt 10 ]; then
    cat >> "$OUTPUT_FILE" << EOF
        <div class="policy-result policy-pass">
            ✅ Security Policy: PASSED - Image approved for deployment
        </div>
EOF
else
    cat >> "$OUTPUT_FILE" << EOF
        <div class="policy-result policy-fail">
            ❌ Security Policy: FAILED - Too many high-severity vulnerabilities
        </div>
EOF
fi

# Add vulnerabilities table
cat >> "$OUTPUT_FILE" << EOF
        <h2>Vulnerability Details</h2>
        <table>
            <thead>
                <tr>
                    <th>Severity</th>
                    <th>CVE ID</th>
                    <th>Package</th>
                    <th>Installed Version</th>
                    <th>Fixed Version</th>
                    <th>Title</th>
                </tr>
            </thead>
            <tbody>
EOF

# Extract and add vulnerabilities
jq -r '.Results[]?.Vulnerabilities[]? | 
    "<tr>" +
    "<td><span class=\"severity-badge badge-" + (.Severity | ascii_downcase) + "\">" + .Severity + "</span></td>" +
    "<td>" + (.VulnerabilityID // "N/A") + "</td>" +
    "<td>" + (.PkgName // "N/A") + "</td>" +
    "<td>" + (.InstalledVersion // "N/A") + "</td>" +
    "<td>" + (.FixedVersion // "Not Fixed") + "</td>" +
    "<td>" + (.Title // "No description") + "</td>" +
    "</tr>"' "$JSON_FILE" >> "$OUTPUT_FILE"

# Close HTML
cat >> "$OUTPUT_FILE" << EOF
            </tbody>
        </table>

        <div style="margin-top: 40px; padding: 20px; background: #ecf0f1; border-radius: 5px;">
            <h3>Summary</h3>
            <p><strong>Total Vulnerabilities:</strong> $(($CRITICAL + $HIGH + $MEDIUM + $LOW))</p>
            <p><strong>Recommendation:</strong> 
EOF

if [ "$CRITICAL" -gt 0 ]; then
    echo "Immediate action required! Critical vulnerabilities found." >> "$OUTPUT_FILE"
elif [ "$HIGH" -gt 10 ]; then
    echo "High priority: Too many high-severity vulnerabilities." >> "$OUTPUT_FILE"
else
    echo "Low risk: Image meets security standards." >> "$OUTPUT_FILE"
fi

cat >> "$OUTPUT_FILE" << EOF
            </p>
        </div>
    </div>
</body>
</html>
EOF

echo "✅ Report generated: $OUTPUT_FILE"
echo "Open it with: xdg-open $OUTPUT_FILE"
