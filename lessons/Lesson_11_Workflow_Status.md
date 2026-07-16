# Phase 11: Workflow Status, Logs & Debugging

You now have a fully functional pipeline. In this phase, we learn how to **read, understand, and debug** what GitHub Actions shows you - because eventually something will fail and you need to know exactly where to look.

---

## The GitHub Actions UI

When you push code and navigate to the **Actions** tab on GitHub, you see a dashboard showing all workflow runs. Here is how to interpret everything:

### Workflow Run Status Icons

| Icon | Color | Meaning |
|---|---|---|
| ✅ | Green | All jobs passed successfully |
| ❌ | Red | At least one job or step failed |
| 🟡 | Yellow/Orange | Workflow is currently running |
| ⏭️ | Grey | Workflow was skipped or cancelled |

---

## Anatomy of a Workflow Run

When you click on a specific run, you see this layout:

```text
Workflow Run: "CI Pipeline" #12
─────────────────────────────────────────────────────
  Triggered by: push to master (commit: abc1234)
  Status: ✅ Success    Duration: 1m 42s
─────────────────────────────────────────────────────

  Jobs:
  ─────────────────────────────────
  ✅ build-and-test    (ubuntu-latest)   1m 42s
  ─────────────────────────────────

    Steps:
    ✅  Set up job                      2s
    ✅  Checkout Code                   1s
    ✅  Setup .NET SDK                  8s
    ✅  Restore Dependencies           12s
    ✅  Build                          18s
    ✅  Run Tests                       6s
    ✅  Publish                         5s
    ✅  Upload Build Artifact           4s
    ✅  Post Checkout Code              1s
    ✅  Complete job                    1s

  Artifacts:
  📦  cicd-dotnet-demo-api   (expires in 7 days)
```

---

## Reading Logs

Click on any step to expand its log output. The logs show the exact terminal output of every command, as if you ran it yourself.

**What to look for in a failing log:**

```text
❌ Build

  Determining projects to restore...
  ...
  Build FAILED.

  Error(s):
  /home/runner/work/cicd-dotnet-demo/CicdDotnetDemo.Api/Program.cs(5,1):
  error CS1002: ; expected

  ##[error]Process completed with exit code 1.   ← This line is critical
```

*   GitHub Actions prefixes special messages with `##[error]`, `##[warning]`, and `##[notice]`.
*   The line `Process completed with exit code 1` is what triggers the ❌ for that step.

---

## Annotations

When a step fails, GitHub often highlights the **exact file and line number** of the error directly in the Pull Request diff view (for PRs) and at the top of the run summary. These are called **Annotations**.

For example, if your code has a compile error, GitHub Actions will show:

```
❌ CicdDotnetDemo.Api/Program.cs line 5 - error CS1002: ; expected
```

This saves you from digging through logs manually.

---

## What Happens After a Step Fails?

By default, GitHub Actions uses a **fail-fast** strategy:

```text
✅ Checkout
✅ Setup .NET
✅ Restore
❌ Build  ← FAILS HERE
⏭️ Run Tests   ← SKIPPED
⏭️ Publish     ← SKIPPED
⏭️ Upload      ← SKIPPED
```

Once a step fails, all subsequent steps in that job are **skipped**. The job is marked as failed, and the overall workflow is marked as failed.

---

## Re-Running a Failed Job

Sometimes a failure is transient (e.g., a network timeout when contacting NuGet). You don't need to push a new commit - you can simply re-run the job:

1. Go to the failed workflow run
2. Click the **"Re-run jobs"** button (top right)
3. Choose:
   - **"Re-run all jobs"** - starts the entire workflow from scratch
   - **"Re-run failed jobs"** - re-runs only the jobs that failed (faster, skips already-passed jobs)

---

## The `Set up job` and `Complete job` Steps

You will notice two steps in every job that you did not write:

*   **`Set up job`**: GitHub provisions the VM, downloads the runner software, and prepares the environment. You cannot control this.
*   **`Complete job`**: Cleans up the workspace, uploads any final data, and destroys the VM. You cannot control this either.

These are always there. They are GitHub infrastructure, not your pipeline code.

---

### End of Lesson 11

#### 1. Summary
GitHub Actions provides a rich UI showing workflow run status, job status, step-level logs, and annotations. Failing steps are marked with ❌ and subsequent steps are skipped. You can re-run failed jobs without pushing new code. Exit codes drive everything - non-zero exit code = failure.

#### 2. Interview Questions
*   "A step in your CI pipeline fails with exit code 1. What happens to the steps that come after it?"
*   "What are GitHub Actions annotations and when do they appear?"

#### 3. Mini Quiz
1.  If the "Restore Dependencies" step passes but the "Build" step fails, will the "Run Tests" step run?
2.  What is the difference between "Re-run all jobs" and "Re-run failed jobs"?

#### 4. Small Exercise for You
1.  Intentionally introduce a syntax error in `UnitTest1.cs` (e.g., remove a semicolon).
2.  Push to `master`.
3.  Watch the pipeline fail on the Build step.
4.  Look at the GitHub Annotations - does it show the file and line number of your error?
5.  Fix the error, push again, and use "Re-run failed jobs" instead of pushing a new commit.

#### 5. Common Mistakes
*   Ignoring warnings in logs. They are yellow, not red, so they don't fail the build - but they are often hiding real problems.
*   Not reading the full log. Developers often see `Process completed with exit code 1` and stop there. The actual error is always a few lines above it.

#### 6. Best Practices
*   Always read from the **first** error in the log, not the last. Errors cascade - the first error causes all the ones below it.
*   Keep step names descriptive (`Restore Dependencies`, `Build`, `Run Tests`) so the summary view is instantly readable by anyone on the team.

#### 7. What we will learn next
In **Phase 12**, we will learn about **GitHub Secrets** - how to store sensitive values like API keys and passwords securely, and how to reference them safely inside workflow files.
