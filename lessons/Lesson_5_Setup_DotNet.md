# Phase 5: Setup .NET

We have checked out our code. Now the runner has our files, but it still cannot build them. Why? Because the runner has no idea what .NET is. It doesn't have the SDK installed.

We need to install the .NET SDK on the runner before we can run any `dotnet` command.

### The Difference Between SDK and Runtime

Before we write the code, let's understand two important terms:

*   **SDK (Software Development Kit):** This is the full toolset used by *developers and CI pipelines*. It includes the compiler, the CLI (`dotnet` commands), and the Runtime. You use the SDK to **build and publish** your app.
*   **Runtime:** This is the minimal environment needed to **run** an already-compiled .NET application. It does not include the compiler. You install only the Runtime on your production server to keep it lightweight.

In CI, we always install the **SDK** because we need to compile the code.

### What is `global.json`?

`global.json` is an optional file you place at the root of your solution. It tells the .NET CLI exactly which SDK version to use. Without it, the CLI uses whatever version is installed. In a CI pipeline, this guarantees every developer on every machine (and the runner) uses the exact same .NET version, avoiding "works on my machine" bugs.

Let's create one. In the root of `cicd-dotnet-demo`, create `global.json`:

```json
{
  "sdk": {
    "version": "10.0.0",
    "rollForward": "latestMinor"
  }
}
```

*   **`version`**: Pin to .NET 10.
*   **`rollForward: latestMinor`**: If .NET 10.0.0 is not available, use the latest .NET 10.x patch version. This gives you security patches automatically without jumping to .NET 11.

### Step 1: Update `ci.yml`

Add the setup step **after** checkout and **before** any `dotnet` commands:

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

    - name: Print dotnet version
      run: dotnet --version
```

### Concept Explanations

*   **`uses: actions/setup-dotnet@v4`**: This is the official Microsoft-maintained action that installs the .NET SDK on the runner.
*   **`with:`**: When a `uses:` action needs input parameters, you pass them with the `with:` keyword. Think of it like passing arguments to a function.
*   **`dotnet-version: '10.0.x'`**: The `x` is a wildcard. It tells the action: "Install the latest patch of .NET 10.0" (e.g., 10.0.17). This ensures you always get the latest security fixes within .NET 10.
*   **What happens behind the scenes:** The `setup-dotnet` action checks if the requested .NET version is already cached on the runner. If yes, it uses the cache (fast). If no, it downloads the SDK from Microsoft's servers, installs it, and adds the `dotnet` executable to the system `PATH`, so all subsequent `run:` steps can call `dotnet` directly.

---

### End of Lesson 5

#### 1. Summary
Runners don't have .NET pre-installed. We use `actions/setup-dotnet@v4` with the `with:` keyword to install the exact SDK version we need. We optionally use `global.json` to pin the version across all environments.

#### 2. Interview Questions
*   "What is the difference between the .NET SDK and the .NET Runtime? Which one do you install on a CI runner and why?"
*   "Why would you use `global.json` in a .NET project?"

#### 3. Mini Quiz
1.  If I specify `dotnet-version: '10.0.x'` in my workflow, which exact version will be installed — the latest 10.0 patch or the latest overall .NET version?
2.  What does the `with:` keyword do in a GitHub Actions step?

#### 4. Small Exercise for You
1.  Create the `global.json` file at the root of `cicd-dotnet-demo` with the content shown above.
2.  Update your `ci.yml` to include the `actions/setup-dotnet@v4` step.
3.  Add the `run: dotnet --version` step so you can verify the correct SDK version is printed in the logs when you push to GitHub.

#### 5. Common Mistakes
*   Installing the Runtime instead of the SDK on a CI runner. The Runtime cannot compile code and `dotnet build` will fail.
*   Using `dotnet-version: '10'` instead of `'10.0.x'`. Always be explicit to avoid unexpected version jumps.

#### 6. Best Practices
*   Use `10.0.x` (wildcard for patch version) rather than a hardcoded full version like `10.0.101`. This way you automatically receive security patches without updating your YAML file.
*   Always follow the `Setup .NET` step immediately after `Checkout`. Never run a `dotnet` command before the SDK is installed.

#### 7. What we will learn next
In **Phase 6**, we will run `dotnet restore` and understand how NuGet packages are downloaded, what the dependency graph is, and why restore is its own separate step in the pipeline.
