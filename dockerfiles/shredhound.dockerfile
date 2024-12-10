# Base image for Python
FROM python:3.13-slim

# Set working directory
WORKDIR /app

# Install system dependencies for Python virtual environment and git
RUN apt-get update && apt-get install -y \
    git \
    python3-venv \
    && rm -rf /var/lib/apt/lists/*

# Clone the ShredHound repository
RUN git clone https://github.com/ustayready/shredhound.git .

# Set up a virtual environment
RUN python3 -m venv venv

# Activate the virtual environment
RUN . venv/bin/activate

# Ensure the Python virtual environment is used for the entrypoint
ENV PATH="/app/venv/bin:$PATH"

# Set the entrypoint to the Python script
ENTRYPOINT ["python", "shred.py"]
