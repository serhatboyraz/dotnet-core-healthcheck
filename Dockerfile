FROM mcr.microsoft.com/dotnet/core/sdk:3.0 AS build
COPY . src/
WORKDIR /src
RUN dotnet restore HealtCheck.sln

FROM build AS publish
WORKDIR /src/
RUN dotnet publish HealtCheck.sln -c Debug -o /app

FROM mcr.microsoft.com/dotnet/core/aspnet:3.0 AS runtime
COPY . src/
WORKDIR /app
EXPOSE 8003

FROM runtime AS final
WORKDIR /app
COPY --from=publish /app .

RUN apt-get update && apt-get install -y curl
HEALTHCHECK --interval=5s --retries=5 --timeout=3s CMD curl localhost/health

ENTRYPOINT ["dotnet", "HealtCheck.dll"]
