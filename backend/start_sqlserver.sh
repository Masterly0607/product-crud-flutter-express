#!/bin/bash

docker rm -f sqlserver 2>/dev/null

docker run --platform linux/amd64 \
  -e "ACCEPT_EULA=Y" \
  -e "SA_PASSWORD=Masterly123!" \
  -p 1433:1433 \
  --name sqlserver \
  -d mcr.microsoft.com/mssql/server:2022-latest
