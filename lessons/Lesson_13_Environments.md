# Phase 13: Environments

So far, our pipeline builds and tests the code. But where does it go after? In the real world, you don't just deploy straight to production. You usually have multiple **Environments**:

1. **Development (Dev):** Where developers test new features.
2. **Staging:** A clone of production used for final QA testing before release.
3. **Production (Prod):** The live app used by real customers.

GitHub Actions has a native feature called **Environments** to manage this.

---

## What are GitHub Environments?

An Environment in GitHub is a virtual representation of your deployment targets (like Dev, Staging, Prod). 

By linking a job in your workflow to a specific Environment, you unlock two major superpowers:

1. **Environment-Specific Secrets:** You can have a secret called `DB_PASSWORD`. In the `Staging` environment, it holds the staging password. In the `Production` environment, it holds the production password. The workflow automatically picks the right one based on the job's environment!
2. **Approval Gates:** You can configure the `Production` environment to pause the workflow and wait for a human (like a QA manager or Tech Lead) to click "Approve" before the deployment job is allowed to run.

---

## Step 1: Create Environments in GitHub

You configure environments in the GitHub UI, just like secrets.

1. Go to your repository on GitHub.
2. Click **Settings**.
3. On the left sidebar, click **Environments**.
4. Click **New environment** and name it `Staging`. Click **Configure environment**.
5. Go back to Environments, click **New environment** and name it `Production`. Click **Configure environment**.

---

## Step 2: Add an Approval Gate to Production

Let's protect Production so nobody can deploy to it by accident.

1. While configuring the `Production` environment in GitHub Settings, look for **Environment protection rules**.
2. Check the box for **Required reviewers**.
3. Search for your own GitHub username and select it.
4. Click **Save protection rules**.

Now, any workflow job targeting `Production` will pause and wait for you to approve it.

---

## Step 3: Update `ci.yml` with a Deployment Job

Up until now, we had one job (`build-and-test`). Now we will add a second job just to simulate deploying to Staging.

Add this at the very bottom of your `ci.yml` (make sure `deploy-to-staging:` is aligned with `build-and-test:`):

```yaml
  deploy-to-staging:
    needs: build-and-test
    runs-on: ubuntu-latest
    environment: Staging
    
    steps:
    - name: Download Build Artifact
      uses: actions/download-artifact@v4
      with:
        name: cicd-dotnet-demo-api
        path: ./publish

    - name: Simulate Deployment
      run: |
        echo "Deploying to Staging Server..."
        echo "Copying files from ./publish..."
        # Here is where you would run real deployment commands (Azure, AWS, SSH, etc.)
        echo "Deployment Successful!"
```

---

## Keyword Explanations

*   **`needs: build-and-test`**: By default, jobs run in parallel. This tells GitHub: "Do not start the deployment job until the build-and-test job has finished successfully." If build fails, deploy never runs.
*   **`environment: Staging`**: This links the job to the `Staging` environment you created in the UI. It will use Staging's secrets and rules.
*   **`actions/download-artifact@v4`**: The opposite of upload. The runner for this new job starts completely empty. We don't checkout the code again; instead, we download the compiled `./publish` artifact we saved in the previous job!

---

### End of Lesson 13

#### 1. Summary
Environments model your real-world deployment targets (Dev, Staging, Prod). They allow you to scope secrets per environment and enforce manual approval gates. We use the `needs` keyword to make jobs run sequentially (Build -> Deploy), and we use `download-artifact` to move compiled files between jobs.

#### 2. Interview Questions
*   "How can you prevent a GitHub Actions workflow from deploying to production without manual QA sign-off?"
*   "If you have a database connection string for Staging and a different one for Production, how do you handle that in GitHub Actions?"

#### 3. Mini Quiz
1.  If I remove `needs: build-and-test` from the deploy job, what happens?
2.  In the `deploy-to-staging` job, why do we use `download-artifact` instead of `checkout` and `dotnet build`?

#### 4. Small Exercise for You
1.  Create the `Staging` and `Production` environments in your repository settings.
2.  Add yourself as a required reviewer for `Production`.
3.  Update your `ci.yml` with the `deploy-to-staging` job shown above.
4.  Push to `master` and watch the Actions tab. You will see two jobs now, linked by a line showing their dependency!

#### 5. Common Mistakes
*   Forgetting `needs:`. If you forget it, the deploy job tries to download the artifact before the build job has even created it, causing it to fail immediately.
*   Checking out code and rebuilding it in the deploy job. This is a bad practice. The artifact you tested is the *exact* binary you should deploy. Rebuilding introduces the risk of deploying something slightly different than what you tested.

#### 6. Best Practices
*   Always separate Build and Deploy into separate jobs.
*   Use Environment Protection Rules (reviewers, wait timers) on your Production environment.
*   Pass compiled artifacts from Build to Deploy using `upload-artifact` and `download-artifact`.

#### 7. What we will learn next
In **Phase 14**, we will learn how to make our pipeline **much faster** by caching our NuGet packages using `actions/cache`.
