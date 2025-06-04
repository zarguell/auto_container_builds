# Use an official Python runtime as a parent image
FROM python:3.12-alpine

# Install necessary packages
RUN apk add --no-cache git

# Create a non-root user and group
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Set the working directory
WORKDIR /app

# Clone the repository into /app and change ownership to the non-root user
RUN git clone https://github.com/zarguell/firefly-iii-email-summary.git /app \
    && chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser

# Set the working directory to the cloned repository
WORKDIR /app

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy the config.yaml.sample to config.yaml (will be overridden by mount)
RUN cp /app/config.yaml.sample /app/config.yaml

# Run the Python script
CMD ["python3", "monthly-report.py"]
