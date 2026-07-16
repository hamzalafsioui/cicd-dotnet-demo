# Phase 7: Build

We have checked out the code ✅, installed .NET 10 SDK ✅, and restored NuGet packages ✅.  
Now it is time to **compile** our code with `dotnet build`.

---

## What Does `dotnet build` Actually Do?

When you run `dotnet build`, the compiler reads your `.cs` source files and transforms them into **IL (Intermediate Language)** code stored in `.dll` files. This is not machine code yet so the .NET compiles to IL first, and then the runtime (JIT) converts it to native machine code at runtime.

```text
dotnet build
      │
      ▼
Reads project.assets.json (created by restore)
      │
      ▼
Compiles all .cs files → IL code
      │
      ▼
Produces DLL files in:
  bin/Debug/net10.0/CicdDotnetDemo.Api.dll
  bin/Debug/net10.0/CicdDotnetDemo.Tests.dll
      │
      ▼
Copies dependencies (other DLLs) next to your output
      │
      ▼
Reports: warnings, errors, build time
```

---

## Debug vs Release

`dotnet build` has two modes (called **configurations**):

| | Debug | Release |
|---|---|---|
| **Default?** | Yes | No - must specify `-c Release` |
| **Optimized?** | No - easier to debug | Yes - compiler optimizations applied |
| **Output folder** | `bin/Debug/` | `bin/Release/` |
| **Use case** | Local development | CI/CD pipelines & production |
| **Size** | Larger | Smaller |

In CI/CD, we **always build in Release mode** because we are producing production artifacts, not development binaries.

---

## Why `--no-restore`?

We already ran `dotnet restore` as a separate step. If we just run `dotnet build`, it will automatically run restore again internally - wasting time and re-downloading packages unnecessarily.

The `--no-restore` flag tells the build command: **"Skip the restore phase, I already did it."**

This is a key CI best practice - each step does exactly one job.

---

## Step 1: Update `ci.yml`

Add the build step after restore:

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
```

---

## Keyword Explanations

*   **`--no-restore`**: Skips the internal restore step. We already did it. This keeps CI fast and each step single-purpose.
*   **`--configuration Release`** (or `-c Release`): Compiles in Release mode. The compiler applies optimizations and the output goes to `bin/Release/` instead of `bin/Debug/`. Always use Release in CI.
*   **What about warnings?** By default, warnings do not fail the build. In production pipelines, teams often add `--warnaserror` to treat warnings as errors. We will keep it simple for now.

---

### End of Lesson 7

#### 1. Summary
`dotnet build` compiles `.cs` files into `.dll` files using the compiler. In CI, we always use `--configuration Release` for production-quality output and `--no-restore` to skip the redundant restore step that we already ran explicitly.

#### 2. Interview Questions
*   "What is the difference between Debug and Release build configurations in .NET, and which one should you use in a CI pipeline?"
*   "Why do we pass `--no-restore` to `dotnet build` in a pipeline that already has a separate restore step?"

#### 3. Mini Quiz
1.  If I run `dotnet build` without any flags, which configuration is used by default and where is the output placed?
2.  What does IL (Intermediate Language) mean, and at what point is it converted to native machine code?

#### 4. Small Exercise for You
1.  Update your `ci.yml` with the build step shown above.
2.  Push to `master` and observe the GitHub Actions log for the "Build" step.
3.  Notice the output path that appears in the logs - it should say `bin/Release/net10.0/`.

#### 5. Common Mistakes
*   Forgetting `--no-restore` after having a dedicated restore step - this causes packages to be downloaded twice.
*   Building in Debug mode (`--configuration Debug` or no flag) in a CI pipeline - the artifacts won't be optimized.
*   Not checking the build logs for **warnings** - in long-running projects, ignored warnings often become future bugs.

#### 6. Best Practices
*   In mature pipelines, add `--warnaserror` to fail the build on any warning. This enforces code quality.
*   Always specify the configuration explicitly (`-c Release`) even if it's not the default. Explicit is better than implicit in CI - it makes the pipeline behavior obvious to any developer who reads it.

#### 7. What we will learn next
In **Phase 8**, we will run `dotnet test`, learn how xUnit discovers and runs tests, what exit codes are and how GitHub Actions uses them to decide if a step passed or failed.
