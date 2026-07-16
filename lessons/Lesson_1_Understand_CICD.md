# Phase 1: Understanding CI/CD


Before we write any YAML, we need to understand the concepts we are going to be working with.

### 1. What is CI (Continuous Integration)?
**What it is:** CI is the practice of automating the integration of code changes from multiple developers into a single shared repository, frequently (often multiple times a day).
**Why companies use it:** When multiple developers work on the same codebase, merging their changes can cause conflicts and break things. CI solves this by automatically building the code and running automated tests every time someone pushes a change. This ensures that the main codebase is always in a working state. 

### 2. What is CD (Continuous Delivery / Continuous Deployment)?
**What it is:** CD takes over where CI leaves off. 
*   **Continuous Delivery:** The code is built, tested, and packaged so that it *can* be deployed to production at any time, usually requiring a manual click to approve the final deployment.
*   **Continuous Deployment:** The code is automatically deployed to production without human intervention if it passes all tests.
**Why companies use it:** It removes the stress of "deployment day." Instead of deploying a massive, risky update once a month, companies deploy small, safe updates multiple times a day.

### 3. The Big Picture: What happens after `git push`?

Here is a simplified flow of a GitHub Actions CI/CD pipeline:

```text
Developer (You)
      │
      ▼
[ git push ] sends code to GitHub
      │
      ▼
   GitHub (Repository)
      │
      ▼
Workflow Trigger (e.g., "Oh, a push happened on the 'main' branch!")
      │
      ▼
    Runner (A fresh virtual machine starts up)
      │
      ├─► Step 1: Checkout Code (Download your repository)
      │
      ├─► Step 2: Setup .NET (Install .NET 10 SDK)
      │
      ├─► Step 3: Build (dotnet build)
      │
      ├─► Step 4: Test (dotnet test)
      │
      └─► Step 5: Publish & Save Artifacts (Create the final deployable files)
```

### 4. Core GitHub Actions Concepts

*   **Workflow:** An automated process made up of one or more jobs. This is essentially the entire pipeline, defined in a `.yml` file in your repository.
*   **Trigger (or Event):** The specific activity that kicks off a workflow. (e.g., a `git push`, a new Pull Request, or a schedule like "every night at midnight").
*   **Runner:** The server (Virtual Machine) that actually runs your workflow.
    *   **GitHub-hosted runner:** A fresh, clean VM provided by GitHub (e.g., Ubuntu, Windows, macOS). It's destroyed after your workflow finishes.
    *   **Self-hosted runner:** A server *you* own and maintain that listens to GitHub for jobs. Used when you need specific hardware or access to private internal networks.
*   **Jobs:** A workflow is made up of Jobs. A Job is a set of steps that execute on the *same runner*. By default, multiple jobs run in parallel unless you tell them to wait for each other.
*   **Steps:** A step is an individual task that can run commands (like `dotnet build`) or use a pre-built Action (like `actions/checkout@v4`). Steps run sequentially one after another inside a job.
*   **Artifacts:** Files or directories produced by your workflow that you want to save. For example, the compiled `.dll` files after a `dotnet publish`. You can share artifacts between jobs or download them later.
*   **Cache:** A way to speed up your workflows by saving dependencies (like NuGet packages) so they don't have to be re-downloaded from scratch every single time the workflow runs.
*   **Environment Variables:** Custom variables (like `ASPNETCORE_ENVIRONMENT=Production`) that you can pass into your workflow to change how your scripts behave without hardcoding values.
*   **Secrets:** Encrypted environment variables used to store sensitive data like API keys, database passwords, or deployment credentials. They are masked in the logs so they are never accidentally exposed.
*   **Matrix Builds:** A feature that lets you run the *same* job multiple times with different configurations. For example, testing your .NET API on Windows, Linux, and macOS simultaneously.

---

### End of Lesson 1

#### 1. Summary
CI (Continuous Integration) automates building and testing code when developers push changes. CD (Continuous Delivery/Deployment) automates releasing that code. In GitHub Actions, a Workflow is triggered by an event, which spins up a Runner to execute Jobs, which are made of Steps.

#### 2. Interview Questions
*   "Can you explain the difference between Continuous Delivery and Continuous Deployment?"
*   "What is a runner in the context of GitHub Actions, and why might you choose a self-hosted runner over a GitHub-hosted one?"

#### 3. Mini Quiz
1.  If I want to run `dotnet restore`, `dotnet build`, and `dotnet test`, are these considered Workflows, Jobs, or Steps?
2.  If I need my database password to run integration tests, should I put it in an Environment Variable or a Secret?

#### 4. Small Exercise for You
Think about a typical .NET Web API you have built in the past. If you had to deploy it manually right now, write down the 4-5 manual commands/actions you would take on your local machine (e.g., restoring, building, etc.). This manual list is exactly what we will automate.

#### 5. Common Mistakes
*   Confusing a Job with a Step. Remember: A Runner executes a Job. A Job contains Steps. If you have two Jobs, they will run on two completely different Runners (VMs) at the same time and won't share files by default.
*   Committing secrets to source control instead of using GitHub Secrets.

#### 6. Best Practices
*   Keep pipelines fast. If a pipeline takes 45 minutes, developers will stop waiting for it, defeating the purpose of CI.
*   Every commit to the main branch should result in a deployable artifact.

#### 7. What we will learn next
In **Phase 2**, we will create the actual .NET project structure on your machine, preparing a clean slate for our CI/CD pipeline.
