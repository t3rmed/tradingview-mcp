# Use Python 3.11 slim image as base
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install system dependencies including git (needed for some hosting platforms)
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install uv for fast Python package management
RUN pip install uv

# Copy dependency files first for better layer caching
COPY pyproject.toml ./
# Copy uv.lock if it exists (some deployments might not have it)
COPY uv.lock* ./

# Install dependencies using uv
# Use --no-dev to skip development dependencies in production
RUN uv sync --frozen --no-dev || uv sync --no-dev

# Copy source code
COPY src/ ./src/
COPY package.json* ./

# Build the package
RUN uv run python -m build

# Install the built package
RUN uv pip install dist/*.whl

# Create a non-root user for security
RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app
USER appuser

# Expose port if needed (MCP servers typically use stdio)
# EXPOSE 8000

# Set the entry point
ENTRYPOINT ["uv", "run", "tradingview-mcp"]

# Default command (can be overridden)
CMD ["stdio"]