# Phase 18: Continuous Deployment

Our pipeline builds, tests, and packages the app. The final frontier is **shipping it to a server automatically**. Before we write any code, we need to understand the deployment strategies that exist - because the wrong strategy can cause real downtime.

---

## Deployment Strategies

### 1. Manual Deployment
A human runs the deployment command. No automation.

```text
Build → Test → "Hey John, the build passed. Can you deploy?"
```

*   ✅ Full control, easy to audit
*   ❌ Slow, inconsistent, human error-prone

---

### 2. Automatic Deployment (Continuous Deployment)
Every green push to `master` automatically deploys to production with no human intervention.

```text
git push → CI passes → Auto-deploy ✅
```

*   ✅ Fastest delivery, fully automated
*   ❌ Requires very high test coverage and confidence. One bad commit = production incident.

---

### 3. Blue-Green Deployment
You run **two identical production environments**: Blue (current live) and Green (new version).

```text
             Users
               │
               ▼
         Load Balancer
               │
     ┌─────────┴─────────┐
     │                   │
  Blue Env           Green Env
 (v1 - LIVE)         (v2 - IDLE)

1. Deploy v2 to Green. Test it.
2. Switch Load Balancer to point at Green. 
3. Green is now LIVE. Blue is idle.
4. If v2 has a bug → instantly switch back to Blue (rollback in seconds!)
5. Once confident → decommission Blue.
```

*   ✅ Zero-downtime deployments, instant rollback
*   ❌ Costs double the infrastructure (two full environments running)

---

### 4. Canary Deployment
Release the new version to a **small percentage** of real users first (like the "canary in a coal mine"). Monitor for errors. If stable, gradually roll out to 100%.

```text
            Users (100%)
                │
                ▼
         Load Balancer
                │
      ┌─────────┴──────────────┐
      │                        │
   v1 Server              v2 Server
  (95% of traffic)       (5% of traffic)

If v2 looks good → gradually shift more traffic
If v2 has bugs → route 100% back to v1
```

*   ✅ Real-world validation, minimal blast radius if a bug slips through
*   ❌ Complex routing, need good monitoring/alerting

---

### 5. Rolling Deployment
You have multiple server instances. Update them **one by one** while the others keep serving traffic.

```text
[Server 1 v1] [Server 2 v1] [Server 3 v1] [Server 4 v1]

Step 1: Take Server 1 offline, update to v2
[Server 1 v2] [Server 2 v1] [Server 3 v1] [Server 4 v1]

Step 2: Take Server 2 offline, update to v2
[Server 1 v2] [Server 2 v2] [Server 3 v1] [Server 4 v1]

... and so on until all servers run v2.
```

*   ✅ No downtime, uses existing infrastructure (no extra cost)
*   ❌ During the rollout, some users hit v1 and some hit v2 simultaneously — risky if schemas change

---

## Summary Comparison

| Strategy | Downtime | Rollback Speed | Cost | Complexity |
|---|---|---|---|---|
| Manual | Possible | Slow | Low | Low |
| Automatic | None | Medium | Low | Low |
| Blue-Green | Zero | Instant | 2x infrastructure | Medium |
| Canary | Zero | Fast | Slightly higher | High |
| Rolling | None | Medium | Same | Medium |

---

## Step 1: Implement a Simple Automated Deployment

For this lesson, we will implement a real-world pattern: **build Docker image → push to GitHub Container Registry → simulate a deploy**. This is the foundation of almost every cloud deployment (Azure Container Apps, AWS ECS, etc.).

### Update `ci.yml` — Replace `build-docker-image` job

Replace the old `build-docker-image` job with this more complete version:

```yaml
  build-and-push-docker:
    needs: build-and-test
    runs-on: ubuntu-latest

    permissions:
      contents: read
      packages: write

    steps:
    - name: Checkout Code
      uses: actions/checkout@v4

    - name: Log in to GitHub Container Registry
      uses: docker/login-action@v3
      with:
        registry: ghcr.io
        username: ${{ github.actor }}
        password: ${{ secrets.GITHUB_TOKEN }}

    - name: Build and Push Docker Image
      uses: docker/build-push-action@v6
      with:
        context: .
        push: true
        tags: ghcr.io/${{ github.repository_owner }}/cicd-dotnet-demo:latest
```

---

## Keyword Explanations

*   **`permissions: packages: write`**: By default, workflows have read-only access to GitHub packages. We must explicitly grant write access to push a Docker image to GHCR.
*   **`docker/login-action@v3`**: Official Docker action to authenticate with a container registry. `ghcr.io` is GitHub Container Registry.
*   **`${{ github.actor }}`**: A built-in GitHub context variable — the username of whoever triggered the workflow.
*   **`${{ secrets.GITHUB_TOKEN }}`**: A special secret automatically created by GitHub for every workflow run. It has permissions to push to your repository's packages (GHCR). You do NOT need to create this secret yourself.
*   **`docker/build-push-action@v6`**: Official Docker action to build AND push an image in one step.
*   **`push: true`**: Actually pushes the image to the registry. Set to `false` if you just want to build locally (useful for PRs).
*   **`tags: ghcr.io/...`**: The full image path in the registry. The format is `ghcr.io/<owner>/<image-name>:<tag>`.

---

### End of Lesson 18

#### 1. Summary
There are 5 main deployment strategies (Manual, Automatic, Blue-Green, Canary, Rolling). We implemented a CD pipeline that builds a Docker image and pushes it to GitHub Container Registry using the automatic `GITHUB_TOKEN` for authentication. This image can then be pulled and run by any cloud provider.

#### 2. Interview Questions
*   "Explain Blue-Green deployment and when you would choose it over a Rolling deployment."
*   "What is `GITHUB_TOKEN` in GitHub Actions? Do you need to create it?"

#### 3. Mini Quiz
1.  In a Canary deployment, if 5% of your users encounter a critical bug in the new version, what percentage of users are affected before you roll back?
2.  What permission does a workflow need to push Docker images to GitHub Container Registry?

#### 4. Small Exercise for You
1.  Make sure your `UnitTest1.cs` has the correct assertions restored (`Assert.Equal(8, result)` not `999`).
2.  Replace the `build-docker-image` job in your `ci.yml` with the `build-and-push-docker` job shown above.
3.  Push to `master`. After the pipeline completes, go to your GitHub profile → **Packages** tab. You should see a new `cicd-dotnet-demo` Docker package listed!

#### 5. Common Mistakes
*   Forgetting to add `permissions: packages: write`. Without it, the push will fail with a `403 Forbidden` error.
*   Pushing to a registry on every Pull Request (not just `master` pushes). Use `push: ${{ github.ref == 'refs/heads/master' }}` to only push on merges to `master`.

#### 6. Best Practices
*   Tag images with the git commit SHA instead of (or in addition to) `latest`: `tags: ghcr.io/.../cicd-dotnet-demo:${{ github.sha }}`. This makes every image uniquely identifiable and allows precise rollbacks.
*   Never push images from Pull Request builds - they are unreviewed code. Only push from merged `master` builds.

#### 7. What we will learn next
In **Phase 19**, our final phase, we will cover advanced production best practices: **Reusable Workflows, Composite Actions, Workflow Dispatch, Scheduled Workflows, Concurrency, OIDC, Security Scanning with CodeQL, and Dependabot**.
