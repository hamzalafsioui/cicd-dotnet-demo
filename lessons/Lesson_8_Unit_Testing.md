# Phase 8: Unit Testing

Our code is now compiled ✅. The next critical step in every CI pipeline is running **automated tests**. This is arguably the most important step - it is what gives CI its value.

---

## Why Run Tests in CI?

Without automated tests in the pipeline, you have no guarantee that a new commit didn't break existing functionality. CI tests act as a **safety net** — every push is automatically verified against your test suite before it can be merged.

```text
Developer pushes code
        │
        ▼
CI runs dotnet test
        │
      ┌─┴─┐
   Pass    Fail
      │       │
      ▼       ▼
  Pipeline   Pipeline
  continues  STOPS ❌
      │       │
      ▼       ▼
  Deploy   Developer
  allowed  must fix code
```

---

## How Does xUnit Work?

When you run `dotnet test`, here is what happens behind the scenes:

```text
dotnet test
      │
      ▼
Finds all projects with test framework references (xUnit, NUnit, MSTest)
      │
      ▼
Builds the test project (if not already built)
      │
      ▼
Loads the test DLL
      │
      ▼
Discovers all methods decorated with [Fact] or [Theory]
      │
      ▼
Runs each test in isolation
      │
      ▼
Reports: X passed, Y failed, Z skipped
      │
      ▼
Returns Exit Code:
  0 = all tests passed
  1 = one or more tests failed
```

---

## Exit Codes — How GitHub Knows a Step Failed

This is fundamental. Every command you run in a terminal returns an **exit code** (a number) when it finishes:

| Exit Code | Meaning |
|---|---|
| `0` | Success — everything is fine |
| Non-zero (1, 2, etc.) | Failure — something went wrong |

GitHub Actions monitors the exit code of every `run:` command. If any command returns a non-zero exit code, that step is marked as **failed ❌** and the entire job stops immediately. This is how GitHub "knows" your tests failed without reading the output text.

---

## Step 1: First, Write a Real Test

The default xUnit template creates a placeholder test. Let's replace it with a real one so we have something meaningful to test.

Open `CicdDotnetDemo.Tests/UnitTest1.cs` and replace its contents with:

```csharp
namespace CicdDotnetDemo.Tests;

public class MathTests
{
    [Fact]
    public void Add_TwoPositiveNumbers_ReturnsCorrectSum()
    {
        // Arrange
        int a = 5;
        int b = 3;

        // Act
        int result = a + b;

        // Assert
        Assert.Equal(8, result);
    }

    [Fact]
    public void Add_NegativeNumber_ReturnsCorrectSum()
    {
        // Arrange
        int a = 10;
        int b = -3;

        // Act
        int result = a + b;

        // Assert
        Assert.Equal(7, result);
    }
}
```

---

## Step 2: Update `ci.yml`

Add the test step after build:

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
```

---

## Keyword Explanations

*   **`--no-build`**: We already built the code in the previous step. This flag tells `dotnet test` to skip the internal build step and just run the test DLL directly. Same principle as `--no-restore` on build.
*   **`--configuration Release`**: Must match the configuration we built with! If you built with Release, you must test with Release. If you test with Debug, it won't find the Release DLL.
*   **`--verbosity normal`**: Controls how much output you see in the logs. Options are: `quiet`, `minimal`, `normal`, `detailed`, `diagnostic`. `normal` shows each test name and result — ideal for CI logs.

---

### End of Lesson 8

#### 1. Summary
`dotnet test` discovers all `[Fact]` and `[Theory]` methods in your test project, runs them, and returns exit code `0` (pass) or `1` (fail). GitHub Actions uses this exit code to decide whether the step succeeded or failed. We use `--no-build` and `--configuration Release` to stay consistent with the build step.

#### 2. Interview Questions
*   "How does GitHub Actions know that a test step failed? Does it read the output text or something else?"
*   "What is the difference between `[Fact]` and `[Theory]` in xUnit?"

#### 3. Mini Quiz
1.  If 10 tests pass and 1 test fails, what exit code does `dotnet test` return?
2.  If you build with `--configuration Release` but test with `--configuration Debug`, what will happen and why?

#### 4. Small Exercise for You
1.  Replace `UnitTest1.cs` with the `MathTests` class above.
2.  Add the `dotnet test` step to your `ci.yml`.
3.  Push to `master`, go to the GitHub Actions tab, and expand the "Run Tests" step — you should see your test names and a green result.
4.  **Bonus challenge:** Add a deliberately failing test (e.g., `Assert.Equal(99, result)`) and push again to watch the pipeline go red ❌, then fix it.

#### 5. Common Mistakes
*   Using `--no-build` when the build step used a different configuration. The test runner can't find the DLL and fails with a cryptic error.
*   Forgetting to write tests and leaving the default placeholder — it passes but gives you false confidence.
*   Not running tests in CI at all and only running them locally — defeats the entire purpose of CI.

#### 6. Best Practices
*   Follow the **AAA pattern** in every test: **Arrange** (set up data), **Act** (call the code), **Assert** (verify the result).
*   Give tests descriptive names that explain what they test: `MethodName_Scenario_ExpectedResult`.
*   In later phases, we will add **test result reporting** so GitHub shows test results directly in the Pull Request UI.

#### 7. What we will learn next
In **Phase 9**, we will run `dotnet publish` to produce the final deployable output of our API — the artifact that would actually be shipped to a server.
