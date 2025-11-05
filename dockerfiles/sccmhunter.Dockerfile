FROM python:3.13-slim-bullseye ASs builder

# Clone the sccmhunter repository
RUN apt-get update && apt-get install -y --no-install-recommends git \
    && git clone https://github.com/garrettfoster13/sccmhunter /app \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Create virtual environment and install dependencies
RUN python -m venv /app/venv
ENV PATH="/app/venv/bin:$PATH"
RUN pip install --no-cache-dir -r requirements.txt

FROM activestate/python:latest

WORKDIR /app

# Copy the application code and virtual environment from builder
COPY --from=builder /app/sccmhunter.py /app/
COPY --from=builder /app/lib /app/lib
COPY --from=builder /app/venv /app/venv

# Set PATH to use the virtual environment
ENV PATH="/app/venv/bin:$PATH"

ENTRYPOINT ["python", "sccmhunter.py"]