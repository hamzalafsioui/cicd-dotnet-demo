# Phase 3: First GitHub Action

We are going to create our very first GitHub Actions workflow.

### Step 1: Create the file
In the root of your `cicd-dotnet-demo` project, create a new folder structure called `.github/workflows`. Inside that, create a file named `ci.yml`.

*(Why `.github/workflows`? GitHub automatically looks for `.yml` or `.yaml` files in this exact directory to run as workflows. If you put it anywhere else, GitHub will ignore it.)*

### Step 2: Write the basic structure
Copy and paste this YAML into `ci.yml`:

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
    - name: Print a welcome message
      run: echo "Hello, CI/CD!"
```

### Concept Explanations

Let's break down every single keyword we just used:

*   **`name:`**: The human-readable name of your workflow. This is what you will see in the "Actions" tab on GitHub.
*   **`on:`**: This tells GitHub *when* to trigger this workflow.
*   **`push:`** & **`pull_request:`**: These are specific events. By specifying `branches: [ "master" ]`, we are saying: "Run this pipeline whenever someone pushes code directly to the `master` branch OR whenever someone creates a Pull Request trying to merge into the `master` branch."
*   **`jobs:`**: A workflow is made of one or more jobs. We created one job named `build-and-test`.
*   **`runs-on:`**: This is critical. It defines the runner (the Virtual Machine OS). We chose `ubuntu-latest`. 
    *   *Why ubuntu-latest?* It's cheaper (often free), faster to start up, and .NET is cross-platform so it runs perfectly on Linux. Alternatives are `windows-latest` or `macos-latest`.
*   **`steps:`**: The sequential tasks that execute inside our job.
*   **`- name:`**: A friendly label for the step so you can easily read the logs.
*   **`run:`**: This tells the runner to execute a command-line script inside the VM. Here, we are just echoing text to the terminal. (In Phase 4, we will learn about the `uses:` keyword).

---

### End of Lesson 3

#### 1. Summary
We created a YAML file in the mandatory `.github/workflows` folder. We defined a trigger (`on: push/pull_request`), created a job, selected a Linux runner (`runs-on: ubuntu-latest`), and added a simple step using the `run` command.

#### 2. Interview Questions
*   "Where must GitHub Actions workflows be stored in a repository?"
*   "What is the difference between the `on` block and the `jobs` block in a GitHub Actions workflow?"

#### 3. Mini Quiz
1. If I change `runs-on: ubuntu-latest` to `runs-on: windows-latest`, what changes behind the scenes?
2. If I create a branch called `feature-login` and push to it, will this specific workflow run? (Hint: Look at the `on:` block).

#### 4. Small Exercise for You
Create the `.github/workflows/ci.yml` file and paste the code from Step 2 into it. You can do this via your editor.

#### 5. Common Mistakes
*   YAML indentation errors. YAML relies heavily on exact spaces. If `steps:` is not indented correctly under the job name, the workflow will fail to parse.
*   Misspelling the `.github/workflows` directory (e.g., `.github/workflow` without the 's').

#### 6. Best Practices
*   Always give your steps a `name:`. If a step fails and it doesn't have a name, the logs are much harder to read.
*   Always restrict your triggers to specific branches. You usually don't want a full heavy CI pipeline running on every single experimental branch push unless necessary.

#### 7. What we will learn next
In **Phase 4**, we will learn about the `actions/checkout` step, how to use `uses:`, and why runners start completely empty.
