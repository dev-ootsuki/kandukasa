#!/bin/bash
docker image prune -af
docker network prune -f
docker builder prune -af
docker system prune -af
docker volume prune -af
