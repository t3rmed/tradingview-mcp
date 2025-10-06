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

# Create virtual environment
RUN uv venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Copy dependency file for layer caching
COPY pyproject.toml ./

# Install dependencies directly from pyproject.toml
RUN uv pip install -e .

# Copy source code
COPY src/ ./src/
COPY package.json* ./

# Create a non-root user for security
RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app /opt/venv
USER appuser

# Expose port if needed (MCP servers typically use stdio)
# EXPOSE 8000

# Set the entry point to use the installed package
ENTRYPOINT ["/opt/venv/bin/tradingview-mcp"]

# Default command (can be overridden)
CMD ["stdio"]