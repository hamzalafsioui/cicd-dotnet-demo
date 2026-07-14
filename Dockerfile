# =============== Stage 1: Build ===============
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

# =============== Stage 2: Runtime ===============
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime
WORKDIR /app

# Copy only the published output from Stage 1
COPY --from=build /app/publish .

# Expose port 8080 (default for .NET 8+)
EXPOSE 8080

# Start the application
ENTRYPOINT ["dotnet", "CicdDotnetDemo.Api.dll"]