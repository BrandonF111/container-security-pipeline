#!/bin/bash

# Generate HTML vulnerability report
# Usage: ./generate-report.sh vulnerabilities.json output.html

set -e

JSON_FILE=${1:-"./security-reports/vulnerabilities.json"}
OUTPUT_FILE=${2:-"./security-reports/report.html"}

if [ ! -f "$JSON_FILE" ]; then
    echo "Error: JSON file not found: $JSON_FILE"
    exit 1
fi

cat > "$OUTPUT_FILE" << 'EOF'



    
    
    Container Security Scan Report
    
        body { font-family: Arial, sans-serif; margin: 20px; background: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; }
        h1 { color: #333; border-bottom: 3px solid #e74c3c; padding-bottom: 10px; }
        .summary { display: flex; gap: 20px; margin: 20px 0; }
        .stat-card { flex: 1; padding: 20px; border-radius: 8px; text-align: center; }
        .critical { background: #e74c3c; color: white; }
        .high { background: #e67e22; color: white; }
        .medium { background: #f39c12; color: white; }
        .low { background: #3498db; color: white; }
        .stat-number { font-size: 48px; font-weight: bold; }
        .stat-label { font-size: 14px; text-transform: uppercase; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background: #34495e; color: white; }
        .severity-badge { padding: 4px 8px; border-radius: 4px; font-size: 12px; font-weight: bold; }
    


    
        🔒 Container Security Scan Report
        Generated: 
        
        
    
    
        document.getElementById('timestamp').textContent = new Date().toLocaleString();
    


EOF

echo "HTML report template generated: $OUTPUT_FILE"
echo "Open in browser to view results"
