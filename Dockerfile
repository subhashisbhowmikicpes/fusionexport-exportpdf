# Use a lightweight Windows base image with .NET runtime
FROM mcr.microsoft.com/dotnet/runtime:8.0-windowsservercore-ltsc2022

ENV FUSIONEXPORT_CHROME_FLAGS="--no-sandbox --disable-dev-shm-usage --disable-gpu --disable-software-rasterizer --disable-setuid-sandbox --single-process"

WORKDIR /app
COPY . .

EXPOSE 8088
CMD ["fusionexport-service.exe", "--port", "8088"]
