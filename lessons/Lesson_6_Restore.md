# Phase 6: Restore

Our runner now has the code (checkout ✅) and the .NET SDK (setup-dotnet ✅).  
The next step is `dotnet restore` and this is more important than it looks.

---

## Why Does `dotnet restore` Exist?

Your project references external libraries (NuGet packages) like `Microsoft.AspNetCore`, `xUnit`, etc.  
These packages are **not** stored in your Git repository (they are ignored by `.gitignore`).  
The runner's VM is fresh - it has none of them.

`dotnet restore` contacts the NuGet package registry, downloads every package your project needs, and places them in a local cache on the runner. Without this step, the compiler has no idea what `[ApiController]` or `[Fact]` means.

---

## What Happens Behind the Scenes

When you run `dotnet restore`:

```text
dotnet restore
      │
      ▼
Reads your .csproj files (and the .sln to find them all)
      │
      ▼
Builds a dependency graph
(Your project needs Package A, Package A needs Package B...)
      │
      ▼
Contacts NuGet.org (or your private feed)
      │
      ▼
Downloads missing .nupkg files
      │
      ▼
Extracts packages into the local NuGet cache
(~/.nuget/packages on Linux)
      │
      ▼
Generates obj/project.assets.json
(A lock file: exact list of every resolved package & version)
```

`project.assets.json` is critical - the compiler reads it to find the actual DLL locations during build.

---

## Step 1: Update `ci.yml`

Add the restore step after `setup-dotnet`:

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
        dotnet-version: '8.0.x'

    - name: Restore Dependencies
      run: dotnet restore
```

---

## Why Is Restore a Separate Step?

You might ask: "Doesn't `dotnet build` also restore automatically?"  
Yes - but in CI, we **separate them intentionally** for these reasons:

| Reason | Explanation |
|---|---|
| **Clarity in logs** | If a package fails to download, you see it fail at "Restore", not buried inside "Build" |
| **Caching** | In Phase 14, we will cache the NuGet packages. Caching only works cleanly when restore is its own step |
| **Speed** | Restore can run in parallel with other setup tasks in advanced pipelines |
| **Fail fast** | If a package is unavailable (e.g. private feed is down), you know immediately |

---

### End of Lesson 6

#### 1. Summary
`dotnet restore` reads all `.csproj` files in the solution, builds a dependency graph, downloads required NuGet packages from NuGet.org, and generates `project.assets.json`. This must run before the build step so the compiler can locate all dependencies.

#### 2. Interview Questions
*   "What does `dotnet restore` actually do? What file does it generate, and why is that file important?"
*   "Why would you separate `dotnet restore` from `dotnet build` in a CI pipeline instead of letting build handle it automatically?"

#### 3. Mini Quiz
1.  If NuGet.org is temporarily unreachable and your packages are not cached, which step in the pipeline will fail - Restore, Build, or Test?
2.  Where on a Linux runner does .NET store the local NuGet package cache by default?

#### 4. Small Exercise for You
Update your `.github/workflows/ci.yml` to include the `dotnet restore` step as shown above, then push to `master`.  
In the GitHub Actions tab, click on the workflow run, expand the "Restore Dependencies" step, and observe the output - you should see each package being resolved.

#### 5. Common Mistakes
*   Running `dotnet build --no-restore` before running `dotnet restore`. The `--no-restore` flag skips the automatic restore inside build, so if you haven't run restore first, the build will fail with "assets file not found".
*   Not restoring the solution file (`dotnet restore MySolution.sln`) and instead restoring only one project - this misses packages needed by other projects in the solution.

#### 6. Best Practices
*   Always run `dotnet restore` against the `.sln` file (or from the root directory where the `.sln` lives) so that all projects are restored in one step.
*   In a later phase, we will add a NuGet cache layer before this step - which will make restore near-instant on subsequent runs.

#### 7. What we will learn next
In **Phase 7**, we will run `dotnet build`, understand what compilation produces, the difference between Debug and Release modes, and why we pass `--no-restore` to the build command.
