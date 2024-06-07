# Use an official Python runtime as a parent image
FROM python:3.12-alpine

# Install necessary packages
RUN apk add --no-cache git build-base python3-dev musl-dev linux-headers cmake

# Create a non-root user and group
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Set the working directory
WORKDIR /app

# Clone the repository into /app and change ownership to the non-root user
RUN git clone https://github.com/dirkjanm/BloodHound.py.git /app \
    && chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser

# Set the working directory to the cloned repository
WORKDIR /app

# Install cia pip
RUN pip install --user .

# Run the Python script
CMD ["python3", "ADExplorerSnapshot.py"]