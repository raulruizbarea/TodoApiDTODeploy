ARG DOTNET_SDK_VERSION
ARG DOTNET_ASPNET_VERSION

FROM mcr.microsoft.com/dotnet/sdk:${DOTNET_SDK_VERSION} as builder
 
WORKDIR /usr/src/todo-api-dto

COPY *.csproj ./
RUN dotnet restore
 
COPY . ./
RUN dotnet build -o /app -r linux-x64 /p:PublishReadyToRun=true
RUN dotnet publish -o /publish -r linux-x64 --self-contained true --no-restore /p:PublishTrimmed=true /p:PublishReadyToRun=true /p:PublishSingleFile=true
 
FROM mcr.microsoft.com/dotnet/aspnet:${DOTNET_ASPNET_VERSION} as production
COPY --from=builder  /publish /app
WORKDIR /app
EXPOSE 80
EXPOSE 443
#If you’re using the Linux Container
#HEALTHCHECK CMD curl --fail http://localhost || exit 1
#If you’re using Windows Container with Powershell
#HEALTHCHECK CMD powershell -command `
#    try { `
#     $response = iwr http://localhost; `
#     if ($response.StatusCode -eq 200) { return 0} `
#     else {return 1}; `
#    } catch { return 1 }
CMD ["./TodoApiDTO"]