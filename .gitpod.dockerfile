# install tailscale
FROM gitpod/workspace-full
# FROM gitpod/workspace-mongodb

USER root

# install tailscale
RUN curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/focal.gpg | sudo apt-key add - \
     && curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/focal.list | sudo tee /etc/apt/sources.list.d/tailscale.list \
     && sudo apt-get update -q \
     && sudo apt-get install -y tailscale \
     && sudo update-alternatives --set ip6tables /usr/sbin/ip6tables-nft

# SAMPLE CODE START
# FROM gitpod/workspace-full

# # Install Redis.
# RUN sudo apt-get update \
#  && sudo apt-get install -y \
#   redis-server \
#  && sudo rm -rf /var/lib/apt/lists/*
# SAMPLE CODE END