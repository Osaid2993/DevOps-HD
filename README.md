# DevOps HD — Secure Blue/Green CI/CD Pipeline

A Jenkins-driven CI/CD pipeline for a small Node.js Express service. The focus is the pipeline itself: automated testing, security scanning, policy gates, container publishing, and blue/green deployment with health checks and rollback.

## What this project is

The application under the pipeline is a minimal Express API with a `/health` endpoint. The app is intentionally small so that the attention stays on the build, quality, security, and deployment stages around it.

## Pipeline overview

The Jenkins pipeline runs the following stages on every commit:

1. **Checkout** — pulls the repository into the Jenkins workspace.
2. **Build & Unit Tests** — installs dependencies with `npm ci` and runs Jest with coverage, producing a JUnit report that Jenkins picks up.
3. **Mutation Tests** — runs Stryker to measure test effectiveness and archives the mutation report.
4. **Lint & SAST** — runs ESLint for style issues and SonarQube (via `sonar-scanner`) for static analysis when a Sonar token is configured.
5. **Contract Test** — verifies the Pact contract file between the consumer and provider.
6. **Docker Build + SBOM & Vuln Scan** — builds the production image, generates an SPDX SBOM with Syft, and runs Trivy and Grype vulnerability scans on the image.
7. **Policy Gate** — runs OPA Conftest against the Dockerfile using policies in the `policies/` folder.
8. **DAST** — spins up the staging stack with Docker Compose and runs an OWASP ZAP baseline scan against the running app.
9. **Release Image** — tags the image as `:prod` and pushes to Docker Hub.
10. **Blue/Green Deploy** — brings up the green environment, runs a health check against `/health`, then switches traffic. If the health check fails, the pipeline rolls back to blue automatically.
11. **Monitoring** — captures a recent slice of application logs and the final health status as build artifacts.

## Tech stack

- **App:** Node.js, Express
- **Testing:** Jest, Supertest, jest-junit
- **Mutation testing:** Stryker
- **Linting:** ESLint
- **Static analysis:** SonarQube
- **Contract testing:** Pact
- **Containers:** Docker, Docker Compose (staging, prod blue, prod green)
- **Supply chain / security:** Trivy, Grype, Syft (SBOM), OWASP ZAP (DAST), OPA Conftest (policy)
- **CI/CD:** Jenkins
- **Registry:** Docker Hub

## Running locally

Install dependencies and start the app:
npm install
npm start

Run the test suite:
npm test

Run the linter:
npm run lint

## Running the full stack

Staging:
docker compose -f docker-compose.staging.yml up --build

The app exposes `/health` on port 3001 (staging) and port 3000 (prod green).

## Jenkins setup

The pipeline expects the following Jenkins credentials:

- `sonar-token` — SonarQube authentication token (optional; stage skips if missing).
- `dockerhub-creds` — username and password for pushing the release image.

The Jenkins agent needs Docker, Docker Compose, Node.js, `sonar-scanner`, `trivy`, `syft`, `grype`, and `conftest` available on its PATH.

## Blue/green deployment

Two production Compose files define the blue and green environments. The pipeline always deploys to green, verifies `/health`, and then tears down blue. If the health check on green fails, the `unsuccessful` post block tears green down and brings blue back up.

## Notes

- This project was built for a Deakin University Professional Practice in IT unit and is a learning exercise rather than production infrastructure.
- Some pipeline stages are marked `|| true` so that a single scan failure does not block the entire pipeline during iteration; for a real production setup those would be made strict gates.
