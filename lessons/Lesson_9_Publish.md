# Phase 9: Publish

Our pipeline now builds ✅ and tests ✅ the code. The next step is `dotnet publish` - producing the **final deployable output** of our API.

---

## What is `dotnet publish`?

`dotnet build` produces development binaries. `dotnet publish` produces **production-ready output** - it takes your compiled code, copies all required runtime dependencies, configuration files, and assets into a single self-contained output folder that is ready to be copied to a server and run.

```text
dotnet publish
      │
      ▼
Compiles the code (if not already)
      │
      ▼
Copies your DLLs + all runtime dependencies
      │
      ▼
Copies appsettings.json and other assets
      │
      ▼
Produces a complete deployable folder at:
  publish/
    ├── CicdDotnetDemo.Api.dll        ← Your app
    ├── CicdDotnetDemo.Api.exe        ← Entry point (Windows only)
    ├── appsettings.json              ← Configuration
    ├── web.config                    ← IIS config (if applicable)
    └── [all dependency DLLs]
```

---

## Framework-Dependent vs Self-Contained

There are two deployment models in .NET:

| | Framework-Dependent | Self-Contained |
|---|---|---|
| **What it is** | Requires .NET Runtime installed on the server | Includes the .NET Runtime inside the output folder |
| **Output size** | Small (only your code + direct deps) | Large (100–200 MB, includes the entire runtime) |
| **Server requirement** | Must have .NET 10 runtime installed | No .NET required on the server at all |
| **Flag** | Default (no flag needed) | `--self-contained true` |
| **Best for** | Cloud servers / Docker containers | Edge devices, standalone EXEs |

For this lesson, we use **Framework-Dependent** (the default). In the Docker phase, the Docker image will provide the runtime - so the output just needs to contain our code.

---

## Step 1: Update `ci.yml`

Add the publish step after test:

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
```

---

## Keyword Explanations

*   **`CicdDotnetDemo.Api/CicdDotnetDemo.Api.csproj`**: We explicitly target only the API project. We do NOT publish the Tests project - test code never goes to production.
*   **`--no-build`**: Same as before - we already built in the Build step. Skip recompiling.
*   **`--configuration Release`**: Must match the build configuration.
*   **`--output ./publish`**: Tells .NET where to place the published files. We choose a folder called `publish` at the root of the repository. This folder will be used in the next phase to upload as an artifact.

---

### End of Lesson 9

#### 1. Summary
`dotnet publish` produces a complete, self-contained folder with everything needed to run the API on a server. We target only the API project (not tests), use `--no-build` to avoid recompiling, and `--output ./publish` to control where the files land.

#### 2. Interview Questions
*   "What is the difference between `dotnet build` and `dotnet publish`?"
*   "When would you choose Self-Contained deployment over Framework-Dependent deployment?"

#### 3. Mini Quiz
1.  If I use `--self-contained true`, do I still need .NET installed on the production server?
2.  Why do we explicitly specify `CicdDotnetDemo.Api.csproj` instead of the `.sln` in the publish command?

#### 4. Small Exercise for You
1.  Add the publish step to your `ci.yml` as shown above.
2.  Push to `master` and let the pipeline run.
3.  After it succeeds, go to the GitHub Actions run, look at the logs for the Publish step and note the list of files that were placed in the `./publish` folder.

#### 5. Common Mistakes
*   Publishing the entire solution — `dotnet publish CicdDotnetDemo.sln` will fail because test projects cannot be published.
*   Forgetting `--output` — without it, publish dumps files into a deeply nested `bin/Release/net10.0/publish/` folder which is harder to reference in the next step.
*   Not matching `--configuration` between build and publish - this forces a recompile and breaks the `--no-build` assumption.

#### 6. Best Practices
*   Always specify `--output` to a predictable, clean path like `./publish`. This makes the next step (uploading artifacts) simple and reliable.
*   Never publish test projects. They are CI tools, not production code.

#### 7. What we will learn next
In **Phase 10**, we will use `actions/upload-artifact` to save the `./publish` folder as a **GitHub Artifact** - a downloadable package attached to the workflow run.
