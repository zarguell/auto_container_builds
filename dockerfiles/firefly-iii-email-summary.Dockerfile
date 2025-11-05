FROM cgr.dev/chainguard/python:latest-dev AS builder

WORKDIR /app

RUN git clone https://github.com/davidschlachter/firefly-iii-email-summary.git .

RUN python -m venv venv
ENV PATH="/app/venv/bin:$PATH"
RUN pip install --no-cache-dir -r requirements.txt

FROM cgr.dev/chainguard/python:latest

WORKDIR /app

# Copy with explicit ownership (65532 is nonroot UID in Chainguard)
COPY --from=builder --chown=65532:65532 /app /app

ENV PATH="/app/venv/bin:$PATH"

CMD ["python", "monthly-report.py"]
