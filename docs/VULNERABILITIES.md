# Vulnerability Analysis

## Intentional Vulnerabilities in Demo Image

This document explains the security issues present in the vulnerable Docker image.

### 1. Base Image Vulnerabilities

**Issue:** Using Node.js 14.15.0 (released November 2020)
- Contains multiple CVEs in Node.js runtime
- Outdated OpenSSL version
- Vulnerable system libraries in base Debian image

**Impact:** HIGH/CRITICAL
- Remote code execution potential
- Cryptographic weaknesses
- Privilege escalation risks

### 2. Vulnerable Dependencies

**Express 4.16.0**
- CVE-2022-24999: Open redirect vulnerability
- Impact: Phishing attacks, credential theft

**Lodash 4.17.19**
- CVE-2021-23337: Command injection via template
- Impact: Remote code execution

**Axios 0.21.0**
- CVE-2021-3749: SSRF vulnerability
- Impact: Server-side request forgery attacks

**JsonWebToken 8.5.0**
- CVE-2022-23529: Token verification bypass
- Impact: Authentication bypass

### 3. Configuration Issues

**Running as Root User**
- Container runs with UID 0 (root)
- Any compromise = full container control
- Violates principle of least privilege

**Hardcoded Secrets**
- API keys in environment variables
- Secrets baked into image layers
- Exposed in image history

**Unnecessary Exposure**
- Overly broad EXPOSE directives
- No resource limits
- Missing security options

### 4. Missing Security Controls

- No health checks
- No resource constraints
- No read-only root filesystem
- No capability dropping
- No seccomp/AppArmor profiles

## Detection Methods

Each vulnerability type is detectable by:

1. **CVE scanning**: Trivy, Grype, Snyk
2. **Secret detection**: TruffleHog, Trivy secrets
3. **Configuration audit**: Docker Bench, Trivy config
4. **SBOM analysis**: Syft, Trivy SBOM

## Remediation Priority

1. **Critical**: Update base image to Node 20
2. **High**: Update all dependencies to latest secure versions
3. **Medium**: Implement non-root user
4. **Low**: Add security hardening (health checks, etc.)
