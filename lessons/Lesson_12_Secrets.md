# Phase 12: Secrets

In real-world applications, you often need to connect to databases, third-party APIs, or cloud providers (like Azure or AWS). These connections require passwords, API keys, or certificates. 

**You must never commit these sensitive values directly into your `.yml` file or C# code.** If you do, anyone who can read your repository can steal your credentials.

---

## What are GitHub Secrets?

GitHub Secrets are encrypted environment variables that you create in your repository settings. Once created, they are securely stored by GitHub and can be passed into your workflows.

*   **Encryption:** Secrets are encrypted before they reach GitHub's servers and remain encrypted until the exact moment a runner needs them.
*   **Masking:** If a workflow tries to print a secret to the terminal (e.g., `echo $MY_SECRET`), GitHub will automatically intercept it and mask it in the logs like this: `***`.

---

## Variables vs. Secrets

GitHub also offers **Variables** (often called Configuration Variables).

| Feature | Variables | Secrets |
|---|---|---|
| **What are they?** | Plain text data | Encrypted sensitive data |
| **When to use?** | URLs, environment names (e.g., `ASPNETCORE_ENVIRONMENT=Staging`) | Passwords, API Keys, Tokens |
| **Visible in UI?** | Yes, you can view and edit them later | No, once saved, you can never see the value again (only update or delete it) |
| **Masked in logs?** | No, they print normally | Yes, they show as `***` |

---

## How to use them in YAML

To access a secret in your workflow, you use GitHub Actions' expression syntax: `${{ secrets.SECRET_NAME }}`.

You usually pass them as environment variables to a specific step.

### Step 1: Create a Secret in GitHub
1. Go to your repository on GitHub.
2. Click **Settings** (the gear icon at the top).
3. On the left sidebar, expand **Secrets and variables** and click **Actions**.
4. Click the green button **New repository secret**.
5. **Name:** `MY_SUPER_SECRET`
6. **Secret:** `ThisIsMyDatabasePassword123!`
7. Click **Add secret**.

### Step 2: Update `ci.yml`

Let's add a step to the end of your workflow to prove the secret is masked.

```yaml
    - name: Test Secret Masking
      env:
        SUPER_SECRET: ${{ secrets.MY_SUPER_SECRET }}
      run: |
        echo "The secret is: $SUPER_SECRET"
        echo "Notice how GitHub hides it!"
```

---

## Keyword Explanations

*   **`${{ ... }}`**: This is the GitHub Actions expression syntax. It tells GitHub to evaluate what's inside before sending the script to the runner.
*   **`secrets.MY_SUPER_SECRET`**: This accesses the `secrets` context to grab the specific secret you created.
*   **`env:`**: This block sets environment variables specifically for this single `run:` step. The runner's shell (like bash on Ubuntu) can then access them (e.g., `$SUPER_SECRET` in bash).

---

### End of Lesson 12

#### 1. Summary
Never store sensitive data in code. GitHub Secrets provide encrypted storage for passwords and API keys. They are injected into workflows using `${{ secrets.NAME }}` and are automatically masked as `***` in the logs to prevent accidental exposure. Variables are for non-sensitive data.

#### 2. Interview Questions
*   "If you need to pass an API key to a build script in GitHub Actions, how do you do it securely?"
*   "What is the difference between a GitHub Configuration Variable and a GitHub Secret?"

#### 3. Mini Quiz
1.  If you accidentally write a `run` command that tries to print your database password stored in a GitHub Secret, what will show up in the workflow logs?
2.  Can you view the value of a GitHub Secret in the repository settings after you have saved it?

#### 4. Small Exercise for You
1.  Follow Step 1 to create the secret `MY_SUPER_SECRET` in your repository via the GitHub website.
2.  Follow Step 2 to add the test step to the end of your `ci.yml`.
3.  Push to `master`, wait for the pipeline to finish, and expand the "Test Secret Masking" step in the logs. You should see `The secret is: ***`.

#### 5. Common Mistakes
*   Passing secrets via command-line arguments instead of environment variables (e.g., `run: ./script.sh ${{ secrets.API_KEY }}`). While GitHub tries to mask this, command-line arguments can sometimes be logged by the OS in system logs. Using `env:` is much safer.
*   Storing non-sensitive configuration (like a public API URL) as a secret. It makes debugging harder because you can't see the URL in the logs. Use Variables for those.

#### 6. Best Practices
*   Always inject secrets via the `env:` block.
*   Rotate your secrets regularly (e.g., every 90 days), especially if someone leaves the team.

#### 7. What we will learn next
In **Phase 13**, we will learn about **Environments** - how to set up staging and production environments, and how to require manual approvals before deploying.
