# Container image that runs the code
FROM node:12.13.0-alpine

# Copies code file from the action repo to the filesystem path '/' of the container
COPY entrypoint.sh /entrypoint.sh

# Code file to execute when the docker container starts up ('entrypoint.sh')
ENTRYPOINT ["/entrypoint.sh"]
