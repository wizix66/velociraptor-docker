FROM ubuntu:22.04
LABEL version="Velociraptor v0.6.9"
LABEL description="Velociraptor server in a Docker container"
LABEL maintainer="wizix"
COPY ./entrypoint .
COPY ./velociraptor /velociraptor/
RUN chmod +x entrypoint && \
    chmod +x velociraptor && \
    cp entrypoint /velociraptor/ && \
    apt-get update && \
    apt-get install -y curl wget jq rsync && \
    # Create dirs for Velo binaries
    mkdir -p /opt/velociraptor && \
    for i in linux mac windows linux-arm; do mkdir -p /opt/velociraptor/$i; done && \
    # Get Velox binaries
    WINDOWS_EXE=$(curl -s https://api.github.com/repos/velocidex/velociraptor/releases/latest | jq -r 'limit(1 ; ( .assets[].browser_download_url | select ( contains("windows-amd64.exe") )))')  && \
    WINDOWS_MSI=$(curl -s https://api.github.com/repos/velocidex/velociraptor/releases/latest | jq -r 'limit(1 ; ( .assets[].browser_download_url | select ( contains("windows-amd64.msi") )))') && \
    MAC_BIN=$(curl -s https://api.github.com/repos/velocidex/velociraptor/releases/latest | jq -r 'limit(1 ; ( .assets[].browser_download_url | select ( contains("darwin-amd64") )))') && \
    wget -O /opt/velociraptor/mac/velociraptor_client "$MAC_BIN" && \
    wget -O /opt/velociraptor/windows/velociraptor_client.exe "$WINDOWS_EXE" && \
    wget -O /opt/velociraptor/windows/velociraptor_client.msi "$WINDOWS_MSI" && \
    cp velociraptor/velociraptor /opt/velociraptor/linux/ && \
    # Clean up 
    apt-get remove -y --purge curl wget jq && \
    apt-get clean
WORKDIR /velociraptor 
CMD ["/entrypoint"]

