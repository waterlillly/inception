# Inception - Containerized Web Stack

(This project is part of the CommonCore at 42)

A Docker-based web application stack featuring NGINX, WordPress, and MariaDB with SSL encryption and persistent data storage.

## Overview

This project demonstrates containerization best practices by deploying a complete web stack using Docker Compose.

The architecture includes:

- **NGINX** - Web server with SSL/TLS termination
- **WordPress** - Content management system with PHP-FPM
- **MariaDB** - Database server with persistent storage
- **Docker Secrets** - Secure password management
- **Custom Networks** - Isolated container communication
- **Health Checks** - Service monitoring and reliability

## Project Workflow

### 1. Environment Setup
- Clone repository and navigate to project directory
- Create required secret files with strong passwords
- Configure environment variables in `.env` file
- Set up custom domain in `/etc/hosts`

### 2. Container Build Process
- Docker builds custom images from Dockerfiles for each service
- Images are configured with necessary dependencies and security settings
- SSL certificates are generated for HTTPS encryption

### 3. Service Orchestration
- Docker Compose starts services in dependency order:
  1. MariaDB initializes and becomes healthy
  2. WordPress connects to database and becomes healthy
  3. NGINX starts and proxies requests to WordPress
- Custom network enables secure inter-service communication
- Volumes ensure data persistence across container restarts

### 4. Runtime Operation
- NGINX serves HTTPS requests on port 443
- WordPress processes dynamic content and database queries
- MariaDB manages data storage and transactions
- Health checks monitor service availability

## Prerequisites

Before running this project, ensure you have:

- **Docker** (version 20.10+)
- **Docker Compose** (version 2.0+)
- **Make** (for using the provided Makefile)
- **sudo privileges** (for modifying `/etc/hosts`)

### Installation on Ubuntu/Debian:
```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
sudo usermod -aG docker $USER

# Install Docker Compose
sudo apt update
sudo apt install docker-compose-plugin

# Install Make
sudo apt install make
```

## Setup Instructions

### 1. Clone and Setup Repository
```bash
# Clone the repository
git clone <repository-url> inception
cd inception
```

### 2. Create Secret Files

Docker Compose offers two methods for managing secrets. This project uses **Option 2** (file-based secrets) for better portability and project isolation.

#### Option 1: External Docker Secrets (Docker Swarm)
```bash
# Create secrets using Docker CLI
echo "your_password" | docker secret create password_file -
```

**docker-compose.yml configuration:**
```yaml
secrets:
  db_root_password:
    external: true    # Tells Docker the secret already exists
  # ... other secrets
```

**Pros:** Reusable across multiple compose projects, managed by Docker daemon  
**Cons:** Requires Docker Swarm mode, less portable, harder to manage in development

#### Option 2: File-based Secrets (Used in this project)
```bash
# Generate secure random passwords (32 characters each)
openssl rand -base64 32 > secrets/password_file

# Or create your own passwords (one per line, no trailing newlines)
echo -n "your_password" > secrets/password_file
```

**docker-compose.yml configuration (current setup):**
```yaml
secrets:
  db_root_password:
    file: ./../secrets/db_root_password    # Docker reads from file path
  # ... other secrets
```

**Pros:** Project-specific, portable, works without Swarm mode, version controllable structure  
**Cons:** Secrets tied to this compose project, can't reuse outside project scope

**Required secret files:**
- `secrets/db_root_password` - MariaDB root user password
- `secrets/db_user_password` - MariaDB application user password  
- `secrets/wp_admin_password` - WordPress administrator password
- `secrets/wp_user_password` - WordPress regular user password

### 3. Configure Environment Variables
```bash
# Copy the example environment file
cp srcs/.env.example srcs/.env

# Edit the .env file with your details
nano srcs/.env  # or vim, gedit, etc.
```

**Required changes in `.env` file:**
- Replace `your-login` with your actual login name
- Update `DOMAIN_NAME` to `your-login.42.fr`
- Modify WordPress settings (title, admin user, emails)
- Update database settings if needed

### 4. Setup Custom Domain
Add your custom domain to the hosts file:
```bash
# Add domain resolution
echo "127.0.0.1 your-login.42.fr" | sudo tee -a /etc/hosts

# Verify the entry was added
grep "your-login.42.fr" /etc/hosts
```

## Usage
Below are some of the available commands defined within the project's Makefile:

### Basic Operations
```bash
# Build and start all services
make all

# Start services (if already built)
make up

# Stop services
make down

# View running containers
make ps

# View logs
make logs
make logs-n  # nginx only
make logs-w  # wordpress only
make logs-m  # mariadb only

# Clean restart
make re
```

### Development Commands
```bash
# Rebuild images from scratch
make rebuild

# Start with live logs
make up-d

# Execute commands in containers
make exec SERVICE=mariadb CMD="mysql -u root -p"
make exec SERVICE=wordpress CMD="wp-cli --info"
```

### Maintenance
```bash
# Remove containers and volumes
make clean

# Remove all Docker resources (careful!)
make fclean

# System cleanup
make prune
```

## Accessing the Application

1. **Web Interface**: Navigate to `https://your-login.42.fr`
   - Accept the self-signed certificate warning
   - Complete WordPress installation if first time

2. **WordPress Admin**: `https://your-login.42.fr/wp-admin`
   - Username: Value from `WP_ADMIN_USER` in `.env`
   - Password: Contents of `secrets/wp_admin_password`

3. **Database Access**:
   ```bash
   make exec SERVICE=mariadb CMD="mysql -u root -p"
   # Password is contents of secrets/db_root_password
   ```

## Troubleshooting

### Common Issues
- **Port conflicts**: Ensure port 443 is available
- **Permission errors**: Check Docker group membership and file permissions
- **SSL warnings**: Normal for self-signed certificates, click "Advanced" → "Proceed"
- **Service won't start**: Check logs with `make logs-<service>`

### Health Check Failures
```bash
# Check service health
docker compose -f srcs/docker-compose.yml ps

# Debug specific service
make logs-w  # for wordpress issues
make logs-m  # for database issues
```

### Data Recovery
Data is stored in:
- WordPress files: `/home/$LOGIN/data/wordpress`
- Database files: `/home/$LOGIN/data/mariadb`

Additional information about Docker concepts used in this project -> [WIKI.md](WIKI.md).
