# Stage 1: Build stage
FROM python:3.13-slim-bullseye AS build

# Install necessary packages for building Python packages and common dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    python3-dev \
    cmake \
    libffi-dev \
    libssl-dev \
    zlib1g-dev \
    libjpeg-dev \
    libfreetype6-dev \
    liblcms2-dev \
    libopenjp2-7-dev \
    libtiff-dev \
    tk-dev \
    tcl-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libcairo2-dev \
    libpango1.0-dev \
    libgdk-pixbuf2.0-dev \
    libxslt1-dev \
    libxml2-dev \
    libpq-dev \
    libmariadb-dev \
    libcapstone-dev \
    bash

# Set the working directory
WORKDIR /app

# Clone the repository into /app
RUN git clone https://github.com/xAiluros/ADExplorerSnapshot.py /app

# Install Python dependencies in a virtual environment
RUN python3 -m venv /app/venv \
    && . /app/venv/bin/activate \
    && pip install --upgrade pip \
    && pip install .

# Stage 2: Runtime stage
FROM python:3.13-slim-bullseye

# Install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    libstdc++6 \
    libffi7 \
    libssl1.1 \
    zlib1g \
    libjpeg62-turbo \
    libfreetype6 \
    liblcms2-2 \
    libopenjp2-7 \
    libtiff5 \
    tk8.6 \
    tcl8.6 \
    libharfbuzz0b \
    libfribidi0 \
    libcairo2 \
    libpango-1.0-0 \
    libgdk-pixbuf2.0-0 \
    libxslt1.1 \
    libxml2 \
    libpq5 \
    libmariadb3 \
    libcapstone4 \
    bash \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user and group
RUN groupadd -r appgroup && useradd -r -g appgroup appuser

# Set the working directory
WORKDIR /app

# Copy the application code and virtual environment from the build stage
COPY --from=build /app /app

# Change ownership to the non-root user
RUN chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser

# Set the working directory to the cloned repository
WORKDIR /app

# Ensure the virtual environment is used
ENV PATH="/app/venv/bin:$PATH"

# Run the Python script
CMD ["python3", "ADExplorerSnapshot.py"]
