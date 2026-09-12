#!/bin/sh
set -e

# Update package index
sudo apt-get update -y

# Install troubleshooting and database tools
sudo apt-get install -y \
  postgresql-client \
  dnsutils \
  netcat-openbsd \
  curl \
  wget \
  jq \
  traceroute \
  iputils-ping \
  iproute2 \
  lsof \
  tcpdump \
  openssl \
  telnet