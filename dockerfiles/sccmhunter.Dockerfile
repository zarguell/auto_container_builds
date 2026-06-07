FROM cgr.dev/chainguard/python:latest-dev AS builder

WORKDIR /app

# Clone the sccmhunter repository
# The -dev variant includes git and other build tools
RUN git clone https://github.com/garrettfoster13/sccmhunter /app

# Create virtual environment and install dependencies
RUN python -m venv /app/venv
ENV PATH="/app/venv/bin:$PATH"
RUN pip install --no-cache-dir -r requirements.txt

FROM activestate/python:latest@sha256:b3759253fc3b6b41c33bd38180dee1c2fa761766ffacc4ede0cbc0578d3cab3e

WORKDIR /app

# Copy application code and virtual environment from builder
COPY --from=builder /app/sccmhunter.py /app/
COPY --from=builder /app/lib /app/lib
COPY --from=builder /app/venv /app/venv

ENV PATH="/app/venv/bin:$PATH"

ENTRYPOINT ["python", "sccmhunter.py"]
