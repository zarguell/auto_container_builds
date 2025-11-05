FROM cgr.dev/chainguard/python:latest-dev AS builder

WORKDIR /app

# Clone the repository
RUN git clone https://github.com/c3c/ADExplorerSnapshot.py /app

# Create virtual environment and install the package
RUN python -m venv venv
ENV PATH="/app/venv/bin:$PATH"
RUN pip install --upgrade pip && pip install .

FROM cgr.dev/chainguard/python:latest

WORKDIR /app

# Copy application and virtual environment from builder
COPY --from=builder /app/ADExplorerSnapshot.py /app/
COPY --from=builder /app/adexpsnapshot /app/adexpsnapshot
COPY --from=builder /app/venv /app/venv

# Ensure nonroot user owns the application
RUN chown -R nonroot:nonroot /app

ENV PATH="/app/venv/bin:$PATH"

ENTRYPOINT ["python", "ADExplorerSnapshot.py"]
