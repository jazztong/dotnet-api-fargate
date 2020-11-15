FROM mcr.microsoft.com/dotnet/core/aspnet:3.1 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS build
WORKDIR /src
COPY ["src/SampleApi/SampleApi.csproj", "src/SampleApi/"]
RUN dotnet restore "src/SampleApi/SampleApi.csproj"
COPY . .
WORKDIR "/src/src/SampleApi"
RUN dotnet build "SampleApi.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "SampleApi.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "SampleApi.dll"]
