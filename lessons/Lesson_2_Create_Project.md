# Phase 2: Create the Project

In this phase, we are going to create a clean .NET solution that we will use throughout our CI/CD journey. 

please open your terminal in the root of your project (`cicd-dotnet-demo`) and run the following commands sequentially:

### Step 1: Create the Project Structure

```bash
# 1_ Create a new Solution file
dotnet new sln -n CicdDotnetDemo

# 2_ Create the ASP.NET Core Web API project
dotnet new webapi -n CicdDotnetDemo.Api

# 3_ Create the Unit Test project using xUnit
dotnet new xunit -n CicdDotnetDemo.Tests

# 4_ Add both projects to the Solution
dotnet sln add CicdDotnetDemo.Api/CicdDotnetDemo.Api.csproj
dotnet sln add CicdDotnetDemo.Tests/CicdDotnetDemo.Tests.csproj

# 5_ Add a reference in the Test project to the API project
dotnet add CicdDotnetDemo.Tests/CicdDotnetDemo.Tests.csproj reference CicdDotnetDemo.Api/CicdDotnetDemo.Api.csproj
```

### Concept Explanations

Here is a breakdown of what we just created and why:

*   **Solution (`.sln`):** A solution is simply a container used by .NET to organize one or more related projects. When we build the solution later in our pipeline, it automatically knows to build all the projects inside it.
*   **API Project (`CicdDotnetDemo.Api`):** This is your actual application code (an ASP.NET Core Web API). This is the code that will eventually be packaged and deployed to production.
*   **Test Project (`CicdDotnetDemo.Tests`):** This project contains our automated tests. We chose `xunit` as the testing framework because it's the industry standard for .NET.
*   **Why tests are separated:** We never want to ship test code to production! By keeping tests in a separate project, test frameworks (like xUnit) and mocking libraries (like Moq) are not compiled into our final API executable. This keeps the production deployment clean, lightweight, and secure. Adding a `reference` from the Test project to the API project allows the tests to see and execute the API code without mixing them together.

---

### End of Lesson 2

#### 1. Summary
We set up a standard .NET architecture with a Solution containing two separate projects: an API project for production code and a Test project for testing code. They are linked via a project reference.

#### 2. Interview Questions
*   "Why do we keep unit tests in a completely separate project from the main application code in .NET?"
*   "What is the purpose of a `.sln` (Solution) file in a CI pipeline?"

#### 3. Mini Quiz
1.  If I run `dotnet build CicdDotnetDemo.sln`, will it build just the API, just the Tests, or both?
2.  Should the API project have a reference to the Test project, or should the Test project have a reference to the API project?

#### 4. Small Exercise for You
Run the commands provided in Step 1. After doing so, run `dotnet test` in your terminal just to verify that the template test passes successfully.

#### 5. Common Mistakes
*   Forgetting to add projects to the `.sln` file. If they aren't in the solution, `dotnet build` at the root level won't find them.
*   Adding the project reference backwards (API referencing Tests). This causes a circular dependency or bloats the API project.

#### 6. Best Practices
*   Use a clear naming convention. If your app is `MyApp`, your tests should be `MyApp.Tests` or `MyApp.UnitTests`.
*   Always ensure your basic template compiles and passes tests before setting up CI/CD. It's much harder to debug a pipeline if the code itself is broken.

#### 7. What we will learn next
In **Phase 3**, we will create our very first GitHub Actions workflow file and learn about triggers, jobs, and steps!
