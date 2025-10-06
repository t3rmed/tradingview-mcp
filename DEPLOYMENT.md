# Deployment Guide

## Quick Start - Choose Your Method

You have 4 docker-compose files to choose from:

1. **`docker-compose.yml`** - Git context (modern Docker platforms)
2. **`docker-compose.local.yml`** - Local file build (upload source files)
3. **`docker-compose.github.yml`** - Explicit GitHub context
4. **`docker-compose.image.yml`** - Pre-built image (most reliable)

## Method 1: Git Context (Recommended)

**Use:** `docker-compose.yml`

This should work on modern Docker platforms that support git contexts:

```yaml
services:
  tradingview-mcp:
    build:
      context: https://github.com/t3rmed/tradingview-mcp.git#main
      dockerfile: Dockerfile
```

**For Phala Network:** Try this first - just upload `docker-compose.yml`

## Method 2: Pre-built Image (Most Reliable)

**Use:** `docker-compose.image.yml`

This repository has GitHub Actions that automatically builds and pushes Docker images to GitHub Container Registry.

```yaml
services:
  tradingview-mcp:
    image: ghcr.io/t3rmed/tradingview-mcp:latest
```

**For any hosting platform:**
1. Rename `docker-compose.image.yml` to `docker-compose.yml`
2. Upload just that one file
3. The image is automatically built and available

## Method 3: Local File Upload

**Use:** `docker-compose.local.yml`

If git context doesn't work, upload these files:
- `docker-compose.local.yml` (rename to `docker-compose.yml`)
- `Dockerfile`
- `pyproject.toml`
- `uv.lock`
- `package.json`
- `src/` directory

## Troubleshooting Phala Network

### Error: "git": executable file not found

**Cause:** Build environment doesn't have git installed

**Solutions (in order of preference):**

1. **Try Method 1 first** - Modern Docker should handle git contexts
2. **Use Method 2** - Pre-built images (most reliable)
3. **Use Method 3** - Upload source files directly

### Error: Dependencies not found

**Solution:** Ensure you're using the updated Dockerfile that handles missing `uv.lock`

## GitHub Actions Auto-Build

This repository includes GitHub Actions (`.github/workflows/docker.yml`) that automatically:

- ✅ Builds Docker images on every commit to main
- ✅ Pushes to GitHub Container Registry (ghcr.io)
- ✅ Creates multi-architecture images (AMD64 + ARM64)
- ✅ Tags with version numbers and 'latest'

**Using auto-built images:**
```yaml
services:
  tradingview-mcp:
    image: ghcr.io/t3rmed/tradingview-mcp:latest
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