# This stage is used to build the service project
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["app.csproj", "."]
RUN dotnet restore "./app.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "./app.csproj" -c $BUILD_CONFIGURATION -o /app/build

# This stage is used to publish the service project to be copied to the final stage
FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "./app.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

# This stage is used in production or when running from VS in regular mode (Default when not using the Debug configuration)
FROM registry.access.redhat.com/ubi8/dotnet-80-runtime:8.0
WORKDIR /app
COPY --from=publish /app/publish .

USER 127
EXPOSE 8080

ENTRYPOINT ["dotnet", "app.dll"]