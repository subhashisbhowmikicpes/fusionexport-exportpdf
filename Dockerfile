# Use Windows Server Core base image
FROM mcr.microsoft.com/windows/servercore:ltsc2022

# Set working directory
WORKDIR C:/fusionexport

# Copy only what's needed for runtime
COPY fusionexport-service.exe .
COPY fusionexport.bat .

# Copy only essential Chrome binaries
COPY chrome/win64-686378/chrome-win/chrome.exe ./chrome/
COPY chrome/win64-686378/chrome-win/*.dll ./chrome/
COPY chrome/win64-686378/chrome-win/icudtl.dat ./chrome/
COPY chrome/win64-686378/chrome-win/v8_context_snapshot.bin ./chrome/

# Copy only required resources (templates/fonts/images)
COPY examples/resources/ ./resources/

# Expose the service port
EXPOSE 1337

# Start the FusionExport service
CMD ["fusionexport-service.exe"]
