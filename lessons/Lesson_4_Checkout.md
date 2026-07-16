# Phase 4: Checkout

In the last phase, we created a job that printed "Hello, CI/CD!" to the terminal. But if we tried to run `dotnet build` right now, it would fail. Why? Because the runner starts completely empty!

### The Empty Runner Concept

When a GitHub-hosted runner (like `ubuntu-latest`) starts up, it is a brand new, clean virtual machine. 
It does **not** have your source code. 
It doesn't know about your `.sln` file or your `C#` code.

Before we can build our code, we have to download it into the runner. 

### Step 1: Add the Checkout Action

Let's update our `ci.yml` file. We will use our first pre-built action. Update your `steps:` block to look like this:

```yaml
    steps:
    - name: Checkout Code
      uses: actions/checkout@v4
      
    - name: Print a welcome message
      run: echo "Code has been downloaded!"
```


### Concept Explanations

*   **`uses:`**: Unlike `run:` which executes a raw terminal command, `uses:` tells GitHub to run a pre-packaged set of instructions (an Action) written by someone else. You can find thousands of these in the GitHub Marketplace.
*   **`actions/checkout@v4`**: This is the official action provided by GitHub to download your code.
    *   `actions` is the organization/owner of the action.
    *   `checkout` is the name of the action.
    *   `@v4` is the version tag. We use `v4` to ensure we get the latest stable features and security updates for this action without it breaking unexpectedly if a `v5` is released.
*   **What it actually downloads:** Behind the scenes, this action automatically configures authentication and runs `git fetch` and `git checkout` to pull the exact commit of your repository into the runner's workspace directory. Now, your `.sln` and `.cs` files exist on the virtual machine!

---

### End of Lesson 4

#### 1. Summary
Runners start completely empty. We must explicitly tell the runner to download our repository code using the `actions/checkout` action via the `uses:` keyword.

#### 2. Interview Questions
*   "What is the difference between `run:` and `uses:` in a GitHub Actions workflow?"
*   "Why is `actions/checkout` usually the very first step in almost every CI workflow?"

#### 3. Mini Quiz
1.  If I forget to include `actions/checkout@v4` and I try to run `run: ls` (list files in Linux), what will I see?
2.  What does the `@v4` signify in `actions/checkout@v4`?

#### 4. Small Exercise for You
Update your `.github/workflows/ci.yml` file to include the Checkout step as shown in Step 1. Order matters: Checkout must happen *before* you try to do anything with the code!

#### 5. Common Mistakes
*   Trying to build or test code before checking it out. The runner will just say "file not found".
*   Hardcoding versions to old ones (e.g., `@v1` or `@v2`) which might use deprecated software behind the scenes and cause workflow warnings.

#### 6. Best Practices
*   Always pin your actions to a specific version (like `@v4`) rather than `@master`. This prevents your pipeline from suddenly breaking if the action's author pushes an untested breaking change.

#### 7. What we will learn next
In **Phase 5**, we will learn how to install the .NET SDK onto the runner so we can finally start building our C# code.
