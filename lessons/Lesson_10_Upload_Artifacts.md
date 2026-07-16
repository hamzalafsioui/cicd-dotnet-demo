# Phase 10: Upload Artifacts

Our pipeline now produces a `./publish` folder containing the deployable API. But there is a problem: **when the job finishes, the runner VM is destroyed - and all its files are gone forever.**

Artifacts solve this. They let us save important files from a workflow run so they can be downloaded later or passed to another job.

---

## What Is a GitHub Artifact?

An artifact is a file or folder that you explicitly upload and attach to a specific workflow run. It lives on GitHub's servers (not the runner) and persists after the job ends.

```text
Runner VM
  │
  ├── checkout code
  ├── restore
  ├── build
  ├── test
  ├── publish → ./publish/ folder exists here
  │
  ▼
actions/upload-artifact
  │
  Uploads ./publish/ to GitHub storage
  │
  ▼
Runner VM is DESTROYED 💀
  │
  But ./publish/ lives on as an artifact ✅
  │
  ▼
You can:
  ├── Download it from the GitHub UI
  ├── Download it in another job (for deployment)
  └── Share it between jobs in the same workflow
```

---

## Artifacts vs Releases

These two concepts are often confused:

| | Artifacts | Releases |
|---|---|---|
| **What it is** | Temporary file attached to a workflow run | A tagged, versioned package attached to a Git tag |
| **Retention** | Default: 90 days (configurable, max 400 days) | Permanent (until manually deleted) |
| **Typical use** | Passing files between jobs, debugging CI | Distributing software to end users |
| **Created by** | `actions/upload-artifact` | GitHub Releases UI or `gh` CLI |

---

## Step 1: Update `ci.yml`

Add the upload step after publish:

```yaml
name: CI Pipeline

on:
  push:
    branches: [ "master" ]
  pull_request:
    branches: [ "master" ]

jobs:
  build-and-test:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout Code
      uses: actions/checkout@v4

    - name: Setup .NET SDK
      uses: actions/setup-dotnet@v4
      with:
        dotnet-version: '10.0.x'

    - name: Restore Dependencies
      run: dotnet restore

    - name: Build
      run: dotnet build --no-restore --configuration Release

    - name: Run Tests
      run: dotnet test --no-build --configuration Release --verbosity normal

    - name: Publish
      run: dotnet publish CicdDotnetDemo.Api/CicdDotnetDemo.Api.csproj --no-build --configuration Release --output ./publish

    - name: Upload Build Artifact
      uses: actions/upload-artifact@v4
      with:
        name: cicd-dotnet-demo-api
        path: ./publish
        retention-days: 7
```

---

## Keyword Explanations

*   **`uses: actions/upload-artifact@v4`**: The official GitHub action that uploads files from the runner to GitHub's artifact storage.
*   **`name: cicd-dotnet-demo-api`**: The display name of the artifact as it appears on the GitHub Actions run page. You will see a download button with this label.
*   **`path: ./publish`**: The folder on the runner to upload. Every file inside `./publish` will be zipped and stored.
*   **`retention-days: 7`**: How many days GitHub should keep this artifact. The default is 90 days. We use 7 days for this learning project to keep storage clean. You can set up to 400 days.

---

## How to Download an Artifact

After the pipeline runs successfully:
1. Go to your repository on GitHub
2. Click the **Actions** tab
3. Click on the latest workflow run
4. Scroll to the bottom - you will see a section called **Artifacts**
5. Click `cicd-dotnet-demo-api` to download a `.zip` file containing your published API

---

### End of Lesson 10

#### 1. Summary
`actions/upload-artifact` saves files from the runner VM to GitHub's servers before the runner is destroyed. The artifact can be downloaded from the GitHub UI, shared between jobs, or consumed by a deployment step. It is temporary and should not be confused with GitHub Releases, which are permanent versioned distributions.

#### 2. Interview Questions
*   "Why do we need to upload artifacts in GitHub Actions? What happens to files on the runner after the job ends?"
*   "What is the difference between a GitHub Actions Artifact and a GitHub Release?"

#### 3. Mini Quiz
1.  If I have two separate jobs in the same workflow - Job A does the build and Job B does the deployment - how can Job B access the files produced by Job A?
2.  If I set `retention-days: 400`, what is the maximum number of days GitHub will actually retain the artifact?

#### 4. Small Exercise for You
1.  Add the upload step to your `ci.yml`.
2.  Push to `master` and wait for the pipeline to succeed.
3.  Go to the GitHub Actions tab → click the run → scroll to the bottom and download the artifact ZIP.
4.  Unzip it and verify it contains your API DLL and `appsettings.json`.

#### 5. Common Mistakes
*   Uploading the wrong folder - e.g., uploading `./bin/Release/net10.0/` instead of `./publish`. They are not the same! The `publish` output is clean and complete; the `bin` folder contains intermediate build files.
*   Not naming artifacts meaningfully - when you have multiple artifacts in a workflow (e.g., test results + API binaries), vague names like "output" make it impossible to tell them apart.

#### 6. Best Practices
*   Use descriptive artifact names that include the project name and optionally the version or run number (e.g., `cicd-dotnet-demo-api-${{ github.run_number }}`).
*   Set a reasonable retention period. 90 days is the default but can fill up your GitHub storage quota quickly on active repos.
*   In production pipelines, a separate **deploy job** downloads this artifact using `actions/download-artifact` and pushes it to a server - keeping build and deploy concerns separated.

#### 7. What we will learn next
In **Phase 11**, we will explore the GitHub Actions UI in depth - green checks, red Xs, logs, annotations, failed steps, and how to re-run a failed job.
