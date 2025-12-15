# Terraform Configuration for Mail Server PoC

This directory contains Terraform configuration for provisioning the Vultr VPS instance.

## Prerequisites

1. Vultr account with API access enabled
2. SSH key pair (public/private)
3. Terraform installed (>= 1.0)

## Setup

1. **Create environment file:**
   ```bash
   cp ../.env.example ../.env
   # Edit ../.env with your credentials
   ```
