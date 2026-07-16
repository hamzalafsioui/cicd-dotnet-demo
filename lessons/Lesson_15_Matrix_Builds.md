# Phase 15: Matrix Builds

You have a pipeline that runs on `ubuntu-latest`. But what if you want to guarantee your .NET API works correctly on Windows AND macOS as well? Running three separate, almost-identical jobs would mean a lot of copy-pasting. 

**Matrix Builds** solve this elegantly.

---

## What is a Matrix Build?

A Matrix Build tells GitHub Actions: "Take this single job definition and run it multiple times, each time substituting a different value from this list."

The jobs are created automatically and run **in parallel** - so testing on 3 operating systems takes the same time as testing on one!

```text
strategy:
  matrix:
    os: [ubuntu-latest, windows-latest, macos-latest]

GitHub creates 3 parallel jobs:

  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
  │  ubuntu-latest  │  │ windows-latest  │  │  macos-latest   │
  │                 │  │                 │  │                 │
  │  ✅ Checkout    │  │  ✅ Checkout    │  │  ✅ Checkout    │
  │  ✅ Setup .NET  │  │  ✅ Setup .NET  │  │  ✅ Setup .NET  │
  │  ✅ Restore     │  │  ✅ Restore     │  │  ✅ Restore     │
  │  ✅ Build       │  │  ✅ Build       │  │  ✅ Build       │
  │  ✅ Test        │  │  ✅ Test        │  │  ✅ Test        │
  └─────────────────┘  └─────────────────┘  └─────────────────┘
  
  All running simultaneously!
```

---

## Step 1: Update the `build-and-test` job

We will modify the existing `build-and-test` job to use a matrix. You only need to change two things:
1. Add the `strategy:` block to the job.
2. Replace the hardcoded `ubuntu-latest` with `${{ matrix.os }}`.

Update your `build-and-test` job definition:

```yaml
  build-and-test:
    strategy:
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]
    runs-on: ${{ matrix.os }}

    steps:
    - name: Checkout Code
      uses: actions/checkout@v4

    - name: Setup .NET SDK
      uses: actions/setup-dotnet@v4
      with:
        dotnet-version: '10.0.x'

    - name: Cache NuGet Packages
      uses: actions/cache@v4
      with:
        path: ~/.nuget/packages
        key: ${{ runner.os }}-nuget-${{ hashFiles('**/*.csproj') }}
        restore-keys: |
          ${{ runner.os }}-nuget-

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
        name: cicd-dotnet-demo-api-${{ matrix.os }}
        path: ./publish
        retention-days: 7

    - name: Test Secret Masking
      env:
        SUPER_SECRET: ${{ secrets.MY_SUPER_SECRET }}
      run: |
        echo "The secret is: $SUPER_SECRET"
        echo "Notice how GitHub hides it!"
```

*(Note: The `deploy-to-staging` job at the bottom of the file stays unchanged.)*

---

## Important Changes Explained

*   **`strategy:`**: This block tells GitHub Actions to use a matrix strategy for this job.
*   **`matrix:`**: Defines the variables. Here, we have one variable called `os` with three values.
*   **`${{ matrix.os }}`**: The job runs once for each value. On the first run, `matrix.os` = `ubuntu-latest`. On the second, it equals `windows-latest`, and so on.
*   **`name: cicd-dotnet-demo-api-${{ matrix.os }}`**: We use the OS name in the artifact name. If all three jobs tried to upload an artifact with the same name at the same time, they would conflict. Making the name unique avoids this.

---

## Matrix with Multiple Dimensions

You can also create a matrix with multiple variables. GitHub creates every possible *combination*:

```yaml
strategy:
  matrix:
    os: [ubuntu-latest, windows-latest]
    dotnet-version: ['8.0.x', '10.0.x']
```

This creates **4 jobs** (2 OS × 2 .NET versions): Ubuntu+8, Ubuntu+10, Windows+8, Windows+10.

---

### End of Lesson 15

#### 1. Summary
Matrix Builds automatically generate parallel copies of a job with different configuration values. We use `strategy.matrix` to define the variables and `${{ matrix.os }}` to reference them. This ensures our code works correctly across multiple operating systems or .NET versions without copy-pasting jobs.

#### 2. Interview Questions
*   "How would you configure a GitHub Actions workflow to test a library against multiple versions of .NET in parallel?"
*   "If one OS in a matrix build fails, do the other matrix jobs stop running?"

#### 3. Mini Quiz
1.  If I add `dotnet-version: ['8.0.x', '10.0.x']` to the matrix alongside `os: [ubuntu-latest, windows-latest]`, how many total jobs will GitHub create?
2.  Why do we append `${{ matrix.os }}` to the artifact name in the upload step?

#### 4. Small Exercise for You
1.  Update your `build-and-test` job with the matrix strategy above.
2.  Push to `master` and watch the Actions tab. You should see 3 parallel `build-and-test` jobs (one per OS), plus the `deploy-to-staging` job waiting for all of them.

#### 5. Common Mistakes
*   Uploading artifacts with the same name from multiple matrix jobs. They will overwrite each other. Always include `${{ matrix.os }}` or a similar unique variable in the artifact name.
*   Using `windows-latest` runners unnecessarily. They are significantly slower to spin up than `ubuntu-latest` and may cost more on paid plans.

#### 6. Best Practices
*   Use `fail-fast: false` under `strategy:` if you want all matrix jobs to finish even if one of them fails. By default (`fail-fast: true`), a failure in one OS cancels all remaining matrix jobs.

```yaml
strategy:
  fail-fast: false
  matrix:
    os: [ubuntu-latest, windows-latest, macos-latest]
```

#### 7. What we will learn next
In **Phase 16**, we will learn about **Branch Protection** - how to require a green CI pipeline before any Pull Request can be merged into `master`.
