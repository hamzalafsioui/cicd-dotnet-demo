# Phase 19 — Production Best Practices

Welcome to the final phase! Now that you have a working CI/CD pipeline, it's time to elevate it to **enterprise-grade**. As your repository grows, your pipelines can become messy, slow, and insecure if you don't follow best practices.

In this lesson, we will cover advanced features of GitHub Actions that help you manage scale, improve security, and automate more effectively.

---

## 1. Reusable Workflows (`workflow_call`)

**WHY:** When you have multiple microservices or repositories, you don't want to copy-paste the exact same CI/CD YAML file into every single one. If you need to update a step (e.g., changing the .NET SDK version), you'd have to update it everywhere.
**WHAT:** Reusable workflows allow you to define a workflow once and call it from other workflows, just like a function in programming.
**HOW:** You define a workflow with `on: workflow_call`. Other workflows can then invoke it using `uses: owner/repo/.github/workflows/reusable.yml@main`.

## 2. Composite Actions

**WHY:** Sometimes you have a specific sequence of steps that you repeat across multiple jobs *within* the same workflow (e.g., Setup .NET + Restore Packages + Authenticate).
**WHAT:** A Composite Action lets you bundle multiple `steps` into a single, reusable action. 
**HOW:** You create a `action.yml` file in a folder. Instead of `runs-on`, you use `runs: using: "composite"` and list your steps.
*Difference from Reusable Workflows:* Reusable workflows reuse entire *jobs/workflows*. Composite actions reuse a sequence of *steps*.

## 3. Manual Triggers (`workflow_dispatch`)

**WHY:** Sometimes you want to trigger a pipeline manually, rather than waiting for a push or PR. For example, deploying to production, running a nightly cleanup script, or rolling back a release.
**WHAT:** `workflow_dispatch` is an event trigger that adds a "Run workflow" button in the GitHub Actions UI.
**HOW:** You add `workflow_dispatch:` under the `on:` block. You can also define `inputs` so the person clicking the button can provide parameters (like choosing which environment to deploy to).

## 4. Scheduled Workflows (`schedule`)

**WHY:** You might need to run tasks regularly, such as running end-to-end (E2E) tests every night, generating weekly reports, or cleaning up stale environments.
**WHAT:** The `schedule` event triggers a workflow at scheduled times.
**HOW:** It uses POSIX cron syntax.
```yaml
on:
  schedule:
    - cron: '0 2 * * *' # Runs at 2:00 AM every day
```

## 5. Concurrency

**WHY:** Imagine you push code to `main`. The deployment starts. A minute later, you realize you made a typo, fix it, and push again. Now you have two deployments running at the same time to the same environment. They might overwrite each other or lock files, causing chaos.
**WHAT:** The `concurrency` key ensures that only a single job or workflow using the same concurrency group runs at a time.
**HOW:** 
```yaml
concurrency:
  group: production-environment
  cancel-in-progress: true
```
This tells GitHub: "If another workflow targeting 'production-environment' is already running, cancel the old one and run the new one."

## 6. Permissions (Principle of Least Privilege)

**WHY:** By default, GitHub Actions runners get a token (`GITHUB_TOKEN`) with broad permissions to your repository. If a malicious script runs in your pipeline (e.g., via a compromised npm/NuGet package), it could push code or delete packages.
**WHAT:** The `permissions` block explicitly restricts what the `GITHUB_TOKEN` is allowed to do.
**HOW:**
```yaml
permissions:
  contents: read
  pull-requests: write # Only allow commenting on PRs, not modifying code
```
*Best Practice:* Always set default permissions to `read-all` or restrict them to only what is strictly necessary.

## 7. OpenID Connect (OIDC)

**WHY:** To deploy to AWS, Azure, or GCP, you usually need credentials. The old way was creating long-lived access keys and storing them in GitHub Secrets. But long-lived keys can leak, expire, or be forgotten.
**WHAT:** OIDC allows GitHub Actions to request a temporary, short-lived cloud token directly from the cloud provider (AWS/Azure/GCP) based on trust. No hardcoded secrets needed!
**HOW:** You configure your cloud provider to trust your GitHub repository. The runner requests a token during the workflow run, uses it to deploy, and the token expires minutes later.

## 8. Security Scanning & Dependabot

**WHY:** Vulnerabilities are constantly discovered in libraries (like Log4j or NewtonSoft.Json). You need automated ways to detect them.
**WHAT:** 
- **Dependabot:** Scans your `csproj` or `package.json`, finds outdated/vulnerable packages, and automatically creates PRs to update them.
- **CodeQL:** GitHub's semantic code analysis engine. It scans your actual C# code for vulnerabilities like SQL Injection, Cross-Site Scripting (XSS), or hardcoded credentials.
**HOW:** You enable Dependabot in repository settings. CodeQL is set up as a standard GitHub Actions workflow (`github/codeql-action`).

---

## What Happens Behind the Scenes (OIDC Example)

When you use OIDC to authenticate to Azure:
1. The GitHub Action requests an OIDC token from GitHub's internal Identity Provider.
2. GitHub generates a JWT (JSON Web Token) containing claims about the workflow (repo name, branch, environment).
3. The Action sends this JWT to Azure.
4. Azure verifies the signature. If it matches a pre-configured federated trust relationship, Azure issues a short-lived access token.
5. The Action uses the Azure access token to deploy.
6. The token dies automatically. Even if a hacker steals it from the logs, it's useless after an hour.
