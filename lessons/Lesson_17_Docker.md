# Phase 17: Docker

So far, our artifact is a folder of `.dll` files. To run it, the server needs the .NET Runtime installed. Docker eliminates this requirement entirely — it packages your app **and its entire runtime** into a portable, self-contained unit called a **container**.

---

## What is Docker?

*   **Image:** A read-only blueprint of your application — like a compiled template. It contains your code + OS layers + .NET runtime + dependencies.
*   **Container:** A running instance of an image. You can run many containers from the same image.
*   **Dockerfile:** A text file with step-by-step instructions on how to build an image.
*   **Registry:** A place to store and distribute images. Docker Hub is the public registry. GitHub has its own: **GitHub Container Registry (GHCR)**.

```text
Dockerfile
  (instructions)
       │
       ▼
   docker build
       │
       ▼
    Docker Image
  (stored locally or in a registry)
       │
       ▼
   docker run
       │
       ▼
  Running Container  ← Your API is running here!
```

---

## Step 1: Create the Dockerfile

Create a file called `Dockerfile` (no extension) in the **root** of `cicd-dotnet-demo`:

```dockerfile
# ─── Stage 1: Build ───────────────────────────────────────────────────────────
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# Copy project files and restore dependencies
COPY CicdDotnetDemo.Api/CicdDotnetDemo.Api.csproj CicdDotnetDemo.Api/
COPY CicdDotnetDemo.Tests/CicdDotnetDemo.Tests.csproj CicdDotnetDemo.Tests/
RUN dotnet restore CicdDotnetDemo.Api/CicdDotnetDemo.Api.csproj

# Copy ALL source code and build
COPY . .
RUN dotnet build CicdDotnetDemo.Api/CicdDotnetDemo.Api.csproj --no-restore --configuration Release

# Publish to /app/publish folder
RUN dotnet publish CicdDotnetDemo.Api/CicdDotnetDemo.Api.csproj \
    --no-build \
    --configuration Release \
    --output /app/publish

# ─── Stage 2: Runtime ─────────────────────────────────────────────────────────
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime
WORKDIR /app

# Copy only the published output from Stage 1
COPY --from=build /app/publish .

# Expose port 8080 (default for .NET 8+)
EXPOSE 8080

# Start the application
ENTRYPOINT ["dotnet", "CicdDotnetDemo.Api.dll"]
```

---

## Dockerfile Line-by-Line Explanation

### Stage 1: Build

*   **`FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build`**: Start from Microsoft's official .NET 10 SDK image. We give this stage the alias `build`. The SDK is needed to compile the code.
*   **`WORKDIR /src`**: Sets the working directory inside the container to `/src`. All subsequent commands run from here.
*   **`COPY ... .csproj .../`**: We copy *only* the `.csproj` files first. This is a Docker optimization — if `.csproj` files haven't changed, Docker uses its layer cache and skips `dotnet restore` entirely on the next build.
*   **`RUN dotnet restore`**: Download NuGet packages.
*   **`COPY . .`**: Now copy all the source code. This runs after restore, so a code change doesn't invalidate the restore cache layer.
*   **`RUN dotnet build`**: Compile the code.
*   **`RUN dotnet publish ... --output /app/publish`**: Create the deployable output in `/app/publish`.

### Stage 2: Runtime (Multi-Stage Build)

*   **`FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime`**: This is a **completely new, clean image** — the ASP.NET Core Runtime image. It is much smaller than the SDK image (~200MB vs ~800MB) because it has no compiler tools.
*   **`COPY --from=build /app/publish .`**: Copy only the published output from Stage 1. The SDK, source code, intermediate files — none of that makes it into the final image!
*   **`EXPOSE 8080`**: Documents that this container listens on port 8080. (Does not actually open the port — that happens when you run the container.)
*   **`ENTRYPOINT [...]`**: The command that runs when the container starts.

---

## Step 2: Add a Docker Build Job to `ci.yml`

Add a new job after `build-and-test`. This job will build the Docker image:

```yaml
  build-docker-image:
    needs: build-and-test
    runs-on: ubuntu-latest

    steps:
    - name: Checkout Code
      uses: actions/checkout@v4

    - name: Build Docker Image
      run: docker build -t cicd-dotnet-demo:latest .
```

---

## Step 2 Explanation

*   **`needs: build-and-test`**: Only build the Docker image if all build-and-test matrix jobs pass. No point building an image from broken code.
*   **`runs-on: ubuntu-latest`**: Docker is built-in on GitHub's Ubuntu runner — no setup required!
*   **`docker build -t cicd-dotnet-demo:latest .`**:
    *   `docker build` — the command to build an image from a Dockerfile.
    *   `-t cicd-dotnet-demo:latest` — tags the image with a name (`cicd-dotnet-demo`) and a version tag (`latest`).
    *   `.` — the build context (the current directory). Docker uses everything in this directory to build the image.

---

### End of Lesson 17

#### 1. Summary
A Dockerfile defines how to build a Docker image using a multi-stage pattern: Stage 1 uses the full SDK image to compile and publish the app. Stage 2 uses the small runtime-only image and copies just the published output, producing a lean, production-ready container. GitHub's Ubuntu runners have Docker pre-installed, so we just need to run `docker build`.

#### 2. Interview Questions
*   "What is a multi-stage Docker build and why is it important?"
*   "What is the difference between `FROM mcr.microsoft.com/dotnet/sdk` and `FROM mcr.microsoft.com/dotnet/aspnet`?"

#### 3. Mini Quiz
1.  Why do we copy `.csproj` files and run `dotnet restore` BEFORE copying the rest of the source code in the Dockerfile?
2.  In a multi-stage build, does the final image contain the `.NET SDK` compiler tools? Why or why not?

#### 4. Small Exercise for You
1.  Create the `Dockerfile` at the root of `cicd-dotnet-demo` with the content above.
2.  Add the `build-docker-image` job to your `ci.yml`.
3.  Push to `master`. Watch the pipeline — `build-and-test` runs first (3 parallel matrix jobs), then `build-docker-image` runs after all three pass.
4.  **Bonus:** In the `build-docker-image` job logs, look at the output of `docker build`. You should see Docker building each stage separately and the final image size reported.

#### 5. Common Mistakes
*   Copying all source code before running restore — this kills the Docker layer cache. Every single code change forces a full `dotnet restore`, making image builds very slow.
*   Using the SDK image as the final runtime image. Your production image would be ~800MB instead of ~200MB and would contain compiler tools that are a security risk.

#### 6. Best Practices
*   Always use multi-stage builds for .NET apps.
*   Add a `.dockerignore` file to prevent unnecessary files from being sent to Docker's build context (similar to `.gitignore`).

```
# .dockerignore
**/bin/
**/obj/
**/.git/
**/lessons/
```

#### 7. What we will learn next
In **Phase 18**, we will learn about **Continuous Deployment strategies** — Blue-Green, Canary, Rolling — and then implement a simple automated deployment!
