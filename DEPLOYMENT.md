# Deployment Guide

## Phala Network Deployment

### Issue: Git not available in build environment

If you encounter this error:
```
failed to init repo: exec: "git": executable file not found in $PATH
```

This means the hosting platform doesn't have git available during the Docker build process.

### Solution 1: Upload Source Files Directly

1. **Download/clone your repository locally**
2. **Upload these files to Phala Network:**
   - `Dockerfile`
   - `docker-compose.yml` (or `docker-compose.local.yml`)
   - `pyproject.toml`
   - `uv.lock`
   - `package.json`
   - `src/` directory (entire folder)

3. **Use the standard docker-compose.yml** which builds from local files:
   ```yaml
   version: '3.8'
   services:
     tradingview-mcp:
       build: .
       # ... rest of config
   ```

### Solution 2: Pre-built Docker Image (Recommended)

Build and push to Docker Hub, then reference the image:

1. **Build locally:**
   ```bash
   docker build -t yourusername/tradingview-mcp .
   docker push yourusername/tradingview-mcp
   ```

2. **Create simple docker-compose.yml:**
   ```yaml
   version: '3.8'
   services:
     tradingview-mcp:
       image: yourusername/tradingview-mcp:latest
       container_name: tradingview-mcp-server
       environment:
         - PYTHONUNBUFFERED=1
       command: tail -f /dev/null
       restart: unless-stopped
       ports:
         - "8000:8000"
   ```

### Solution 3: GitHub Actions Auto-Build

Set up GitHub Actions to automatically build and push Docker images:

1. **Create `.github/workflows/docker.yml`:**
   ```yaml
   name: Build Docker Image
   on:
     push:
       branches: [ main ]
   jobs:
     build:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v3
         - name: Build and push Docker image
           uses: docker/build-push-action@v3
           with:
             context: .
             push: true
             tags: yourusername/tradingview-mcp:latest
   ```

## Other Hosting Platforms

### Railway, Render, Fly.io

These platforms typically support GitHub integration and should work with:

```yaml
version: '3.8'
services:
  tradingview-mcp:
    build:
      context: https://github.com/t3rmed/tradingview-mcp.git
      dockerfile: Dockerfile
```

### Local Development

Use `docker-compose.local.yml` for local testing:

```bash
docker-compose -f docker-compose.local.yml up --build
```

## Troubleshooting

1. **Build fails with git error**: Use Solution 1 (upload files directly)
2. **Dependencies not found**: Ensure `uv.lock` is present
3. **Port issues**: Adjust the port in docker-compose.yml to match platform requirements
4. **Permission issues**: The Dockerfile now creates a non-root user for security

## Testing Your Deployment

```bash
# Test locally first
docker-compose -f docker-compose.local.yml up --build

# Test the MCP server
docker-compose exec tradingview-mcp uv run tradingview-mcp stdio
```