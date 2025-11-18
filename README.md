# Container Security Scanning Pipeline

A production-ready security scanning pipeline for Docker containers, demonstrating DevSecOps best practices.

## 🎯 Project Goals

- Automate vulnerability detection in container images
- Enforce security policies in CI/CD pipelines
- Demonstrate remediation strategies
- Provide clear security reporting

## 🏗️ Architecture

```
Code Push → Build Image → Security Scan → Policy Check → Deploy/Block
                              ↓
                         (Trivy, Grype, Scout)
                              ↓
                         Generate Reports
```

## 🚀 Quick Start

### Prerequisites

- Docker installed
- Git
- (Optional) GitHub account for CI/CD

### Local Setup

1. **Clone the repository:**
```bash
git clone <your-repo-url>
cd container-security-pipeline
```

2. **Build the vulnerable image:**
```bash
docker build -f vulnerable-app/Dockerfile.vulnerable \
  -t vulnerable-demo:latest \
  vulnerable-app/
```

3. **Run security scan:**
```bash
chmod +x scripts/scan-local.sh
./scripts/scan-local.sh vulnerable-demo:latest
```

4. **Build the secure image:**
```bash
docker build -f vulnerable-app/Dockerfile.secure \
  -t secure-demo:latest \
  vulnerable-app/
```

5. **Compare results:**
```bash
./scripts/scan-local.sh secure-demo:latest
```

## 📊 What Gets Scanned

1. **Vulnerabilities (CVEs)**
   - Base OS packages
   - Application dependencies
   - Runtime vulnerabilities

2. **Secrets Detection**
   - API keys
   - Passwords
   - Tokens
   - Private keys

3. **Misconfigurations**
   - Running as root
   - Exposed ports
   - Missing security options
   - Insecure defaults

4. **Policy Violations**
   - Outdated base images
   - High-severity CVE counts
   - Compliance requirements

## 🔧 Tools Used

- **Trivy**: Comprehensive vulnerability scanner
- **Docker Scout**: Container analysis
- **GitHub Actions**: CI/CD automation
- **jq**: JSON processing

## 📁 Project Structure

```
├── vulnerable-app/          # Demo application
│   ├── Dockerfile.vulnerable  # Intentionally insecure
│   ├── Dockerfile.secure      # Remediated version
│   ├── app.js                 # Simple Node.js app
│   └── package.json           # Dependencies
├── .github/workflows/       # CI/CD pipelines
│   ├── scan-vulnerable.yml
│   └── scan-secure.yml
├── scripts/                 # Automation scripts
│   ├── scan-local.sh
│   └── generate-report.sh
└── docs/                    # Documentation
    ├── VULNERABILITIES.md
    └── REMEDIATION.md
```

## 🎓 Learning Outcomes

After completing this project, you'll understand:

- Container security fundamentals
- CI/CD security integration
- Vulnerability management
- Docker best practices
- DevSecOps workflows
- Security policy enforcement

## 🔒 Security Policies

Images must pass these checks to deploy:

- ✅ Zero CRITICAL vulnerabilities
- ✅ Less than 5 HIGH vulnerabilities
- ✅ No hardcoded secrets
- ✅ Non-root user
- ✅ Current base image (< 90 days old)

## 📈 CI/CD Integration

Push to GitHub automatically triggers:

1. Image build
2. Multi-scanner analysis
3. Policy enforcement
4. Report generation
5. Deployment decision

View results in GitHub Actions tab.

## 🛠️ Customization

### Add More Scanners

Edit `.github/workflows/scan-*.yml`:

```yaml
- name: Grype scan
  uses: anchore/scan-action@v3
  with:
    image: "your-image:tag"
```

### Adjust Security Policies

Modify threshold in workflows:

```bash
if [ "$CRITICAL_COUNT" -gt 0 ] || [ "$HIGH_COUNT" -gt 5 ]; then
  exit 1
fi
```

### Add Custom Rules

Create `trivy-config.yaml`:

```yaml
severity:
  - CRITICAL
  - HIGH
ignoreUnfixed: true
```

## 📝 Reports

Scan results are saved to:
- `security-reports/vulnerabilities.json`
- `security-reports/vulnerabilities.txt`
- GitHub Actions artifacts

## 🤝 Contributing

This is a portfolio/learning project, but suggestions welcome!

## 📚 Resources

- [Docker Security Best Practices](https://docs.docker.com/develop/security-best-practices/)
- [Trivy Documentation](https://aquasecurity.github.io/trivy/)
- [OWASP Docker Security](https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html)

## 📄 License

MIT License - Feel free to use for learning and portfolio purposes

## 👤 Author

Brandon Forehand - https://github.com/BrandonF111

---

**⚠️ Disclaimer:** The vulnerable image is intentionally insecure for educational purposes. Never use it in production.
