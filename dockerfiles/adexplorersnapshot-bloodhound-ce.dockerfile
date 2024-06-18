# Stage 1: Build stage
FROM python:3.12-alpine AS build

# Install necessary packages for building
RUN apk add --no-cache git build-base python3-dev musl-dev linux-headers cmake libffi-dev

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
FROM python:3.12-alpine

# Install runtime dependencies
RUN apk add --no-cache libstdc++ libgcc libffi

# Create a non-root user and group
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

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
