FROM cgr.dev/chainguard/python:latest-dev AS builder

WORKDIR /app

# Clone the repository
RUN git clone https://github.com/davidschlachter/firefly-iii-email-summary.git .

# Create virtual environment and install dependencies
RUN python -m venv venv
ENV PATH="/app/venv/bin:$PATH"
RUN pip install --no-cache-dir -r requirements.txt

FROM cgr.dev/chainguard/python:latest

WORKDIR /app

# Chainguard Python image runs as nonroot by default
# Copy application and virtual environment from builder
COPY --from=builder /app /app

# Copy config template (user mounts config.yaml over this at runtime)
COPY --from=builder /app/config.yaml.sample /app/config.yaml

# Ensure nonroot user owns the application directory
RUN chown -R nonroot:nonroot /app

# Chainguard Python image already runs as nonroot
ENV PATH="/app/venv/bin:$PATH"

CMD ["python", "monthly-report.py"]
