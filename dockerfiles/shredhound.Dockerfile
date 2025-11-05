FROM cgr.dev/chainguard/python:latest-dev AS builder

WORKDIR /app

# Clone the ShredHound repository
RUN git clone https://github.com/ustayready/shredhound.git .

# Create virtual environment and install dependencies
RUN python -m venv venv
ENV PATH="/app/venv/bin:$PATH"
RUN pip install -r requirements.txt

FROM cgr.dev/chainguard/python:latest

WORKDIR /app

# Copy application and virtual environment from builder
COPY --from=builder /app /app

ENV PATH="/app/venv/bin:$PATH"

ENTRYPOINT ["python", "shred.py"]
