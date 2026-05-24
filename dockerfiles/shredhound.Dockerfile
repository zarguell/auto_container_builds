FROM cgr.dev/chainguard/python:latest-dev AS builder

WORKDIR /app

# Clone the ShredHound repository
# shred.py is pure stdlib — no external dependencies needed
RUN git clone https://github.com/ustayready/shredhound.git .

FROM cgr.dev/chainguard/python:latest

WORKDIR /app

# Copy the application from the builder stage
COPY --from=builder /app /app

ENTRYPOINT ["python", "shred.py"]
