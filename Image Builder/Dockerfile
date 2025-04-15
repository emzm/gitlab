FROM node:22-bullseye

# Install global npm packages
RUN npm install --global bun && \
    npm install --global eas-cli

# Verify installations
RUN node --version && \
    npm --version && \
    bun --version && \
    eas --version

# Set default work directory
WORKDIR /app

# Set default command (optional - shows installed versions)
CMD ["sh", "-c", "echo 'Node:' $(node --version) && echo 'NPM:' $(npm --version) && echo 'Bun:' $(bun --version) && echo 'EAS CLI:' $(eas --version)"]
