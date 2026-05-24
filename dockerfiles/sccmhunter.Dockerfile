FROM cgr.dev/chainguard/python:latest-dev AS builder

WORKDIR /app

# Clone the sccmhunter repository
# The -dev variant includes git and other build tools
RUN git clone https://github.com/garrettfoster13/sccmhunter /app

# Create virtual environment and install dependencies
RUN python -m venv /app/venv
ENV PATH="/app/venv/bin:$PATH"
RUN pip install -r requirements.txt

FROM activestate/python:latest@sha256:6cc4a36d8311d9dbc5ff687f1a14928d603e342ee396082b9a5592c2cef97ab3

WORKDIR /app

# Copy application code and virtual environment from builder
COPY --from=builder /app/sccmhunter.py /app/
COPY --from=builder /app/lib /app/lib
COPY --from=builder /app/venv /app/venv

ENV PATH="/app/venv/bin:$PATH"

ENTRYPOINT ["python", "sccmhunter.py"]
