# CI/CD .NET Demo

![CI/CD Pipeline](https://github.com/hamzalafsioui/cicd-dotnet-demo/actions/workflows/ci.yml/badge.svg)

This repository serves as a comprehensive, step-by-step guide and working example of building a production-grade CI/CD pipeline using **.NET 10** and **GitHub Actions**.

## 📖 About The Project

The goal of this project is to demonstrate how to take a standard .NET 10 Web API and automate its build, test, and deployment lifecycle. Instead of just showing the final result, this repository contains 19 detailed lessons explaining every single concept from the ground up.

### Key Features
* **.NET 10 Web API** - A clean, simple API to serve as our deployment target.
* **xUnit Testing** - Automated unit tests integrated directly into the pipeline.
* **GitHub Actions** - A complete YAML-based CI/CD workflow (`.github/workflows/ci.yml`).
* **Matrix Builds** - Cross-platform verification on Windows, Ubuntu, and macOS.
* **Docker Containerization** - Multi-stage `Dockerfile` to build and package the application.
* **Branch Protection** - Enforced status checks before merging to `master`.
* **Caching & Artifacts** - Optimized pipeline performance and build output retention.

---

## 🚀 Getting Started

### Prerequisites
* [.NET 10 SDK](https://dotnet.microsoft.com/download/dotnet/10.0)
* [Docker Desktop](https://www.docker.com/products/docker-desktop) (optional, for containerization)
* Git

### Installation & Running Locally

1. **Clone the repository**
   ```bash
   git clone https://github.com/hamzalafsioui/cicd-dotnet-demo.git
   cd cicd-dotnet-demo
   ```

2. **Restore dependencies**
   ```bash
   dotnet restore
   ```

3. **Build the project**
   ```bash
   dotnet build --no-restore
   ```

4. **Run the API**
   ```bash
   dotnet run --project src/Api/Api.csproj
   ```
   Navigate to `http://localhost:5000/swagger` to view the API documentation.

5. **Run the Tests**
   ```bash
   dotnet test --no-build
   ```

---

## ⚙️ CI/CD Pipeline Architecture

Whenever code is pushed or a Pull Request is opened against the `master` branch, our GitHub Actions workflow triggers. 

Here is what happens behind the scenes:
1. **Checkout**: The runner fetches the latest code.
2. **Setup .NET**: Installs the correct .NET 10 SDK.
3. **Cache Packages**: Restores NuGet dependencies from cache (or downloads them if missed) to save time.
4. **Restore & Build**: Compiles the C# code into binaries.
5. **Test**: Runs the xUnit test suite. If any test fails, the pipeline halts, and the Pull Request is blocked.
6. **Publish**: Packages the application for deployment.
7. **Upload Artifacts**: Saves the published binaries to GitHub so they can be downloaded or deployed later.
8. **Docker Build**: Builds a Docker container image of the application.

---

## 📚 Lessons Roadmap

This repository was built interactively. You can find the entire curriculum in the `/lessons` directory:

* [Lesson 1: Understand CI/CD](lessons/Lesson_1_Understand_CICD.md)
* [Lesson 2: Create Project](lessons/Lesson_2_Create_Project.md)
* [Lesson 3: First GitHub Action](lessons/Lesson_3_First_GitHub_Action.md)
* [Lesson 4: Checkout](lessons/Lesson_4_Checkout.md)
* [Lesson 5: Setup .NET](lessons/Lesson_5_Setup_DotNet.md)
* [Lesson 6: Restore](lessons/Lesson_6_Restore.md)
* [Lesson 7: Build](lessons/Lesson_7_Build.md)
* [Lesson 8: Unit Testing](lessons/Lesson_8_Unit_Testing.md)
* [Lesson 9: Publish](lessons/Lesson_9_Publish.md)
* [Lesson 10: Upload Artifacts](lessons/Lesson_10_Upload_Artifacts.md)
* [Lesson 11: Workflow Status](lessons/Lesson_11_Workflow_Status.md)
* [Lesson 12: Secrets](lessons/Lesson_12_Secrets.md)
* [Lesson 13: Environments](lessons/Lesson_13_Environments.md)
* [Lesson 14: Caching](lessons/Lesson_14_Caching.md)
* [Lesson 15: Matrix Builds](lessons/Lesson_15_Matrix_Builds.md)
* [Lesson 16: Branch Protection](lessons/Lesson_16_Branch_Protection.md)
* [Lesson 17: Docker](lessons/Lesson_17_Docker.md)
* [Lesson 18: Continuous Deployment](lessons/Lesson_18_Continuous_Deployment.md)
* [Lesson 19: Production Best Practices](lessons/Lesson_19_Production_Best_Practices.md)

---

## 🤝 Contributing
Since this is an educational repository, contributions to improve the clarity of the lessons or update best practices are welcome! Please open an issue or submit a Pull Request.
