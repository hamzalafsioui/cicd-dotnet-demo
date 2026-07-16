# Phase 16: Branch Protection

You now have a powerful CI pipeline. But what if a developer on your team accidentally pushes broken code directly to `master`, bypassing CI entirely? Branch Protection Rules prevent exactly that.

---

## What is Branch Protection?

Branch Protection is a GitHub repository setting that prevents certain actions on important branches (like `master`) unless specific conditions are met.

The two most important rules for CI/CD:

1. **Require status checks to pass:** No one can merge a Pull Request into `master` until the CI pipeline (all jobs, or specific jobs) has passed with a green ✅.
2. **Require pull requests before merging:** Nobody can push directly to `master`. All changes must go through a Pull Request (PR) first.

This means the flow becomes:

```text
Developer                          GitHub

Creates feature branch
        │
     git push (feature branch)
        │
        ▼
     CI Pipeline RUNS
        │
     ✅ All checks pass?
        │
        ▼
     Opens Pull Request
        │
     📋 Code Review required
        │
     ✅ Reviewer approves
        │
     Merge allowed into master ✅

        ❌ CI fails? → Cannot merge!
        ❌ No reviewer? → Cannot merge!
```

---

## Step 1: Configure Branch Protection in GitHub

This is done entirely in the GitHub UI. There is no YAML to write here.

1. Go to your repository on GitHub.
2. Click **Settings**.
3. On the left sidebar, click **Branches**.
4. Click **Add branch ruleset** (or "Add rule" in older GitHub UI).
5. Give the ruleset a name, e.g., `Protect master`.
6. Under **Target branches**, type `master` and select it.
7. Enable the following rules:
   - ✅ **Require a pull request before merging**
   - ✅ **Require status checks to pass before merging**
     - Search for and add: `build-and-test (ubuntu-latest)`, `build-and-test (windows-latest)`, `build-and-test (macos-latest)`
   - ✅ **Require branches to be up to date before merging**
   - ✅ **Do not allow bypassing the above settings** *(optional but strong practice)*
8. Click **Create** to save.

---

## Step 2: Test it

Now try to merge something that would break a check:

1. Create a new branch locally: `git checkout -b feature/test-protection`
2. Add a failing test to `UnitTest1.cs` (e.g., `Assert.Equal(99, 5+3)`).
3. Push the branch: `git push -u origin feature/test-protection`
4. Go to GitHub and open a Pull Request from that branch to `master`.
5. Watch the PR page. You will see a status check running. When it fails, the **Merge** button will be greyed out.

---

## Why This Matters in a Team

| Without Branch Protection | With Branch Protection |
|---|---|
| Developers can push directly to `master` | All changes must go through a PR |
| Broken code can enter production | CI must pass before merge is allowed |
| No code review enforced | Human review can be made mandatory |
| Risk of accidental irreversible changes | Merge history is clean and auditable |

---

## Required Reviews

In addition to status checks, you can also require that at least one (or more) team members review and approve the code before it can be merged. This is the standard in every professional team - it enforces code review as a mandatory step, not an optional one.

---

### End of Lesson 16

#### 1. Summary
Branch Protection Rules enforce quality gates on important branches. By requiring CI checks to pass and Pull Requests to be used, you prevent broken or unreviewed code from ever reaching `master`. This is a non-negotiable practice in professional software teams.

#### 2. Interview Questions
*   "How do you prevent a developer from pushing broken code directly to the `main`/`master` branch in a team project?"
*   "What is the relationship between a GitHub Actions status check and a Branch Protection Rule?"

#### 3. Mini Quiz
1.  A developer fixes a critical bug and pushes it directly to `master` (bypassing the PR process). CI was never triggered. Is this acceptable? What should be in place to prevent it?
2.  If the `ubuntu-latest` matrix job passes but `windows-latest` fails, can the Pull Request be merged (assuming both are listed as required checks)?

#### 4. Small Exercise for You
1.  Set up Branch Protection on your `master` branch following Step 1 above.
2.  Create the `feature/test-protection` branch, add a failing test, and push it.
3.  Open a Pull Request on GitHub and observe that the Merge button is disabled while CI is running, and blocked when CI fails.
4.  Fix the test and push again. Watch the CI go green and the Merge button become available.

#### 5. Common Mistakes
*   Not adding the exact status check name. If you type the wrong job name, GitHub won't find the check and the rule won't enforce anything. Make sure the name matches exactly what you see in the Actions tab.
*   Setting up protection rules but leaving "Allow bypass for administrators" enabled. Admins can still merge broken code, which defeats the purpose.

#### 6. Best Practices
*   Require at least **1 reviewer** approval in addition to CI checks for all production-bound branches.
*   Use **"Require branches to be up to date"** to prevent merge if someone else merged to `master` after you created your branch (avoids integration bugs).
*   Enable **"Include administrators"** so even repo owners follow the same rules.

#### 7. What we will learn next
In **Phase 17**, we will containerize our API by writing a `Dockerfile` and building a Docker image directly inside GitHub Actions!
