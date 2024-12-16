FROM python:3.12-slim-bullseye

# Install necessary packages for building Python packages and common dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git

# Set the working directory
WORKDIR /app

# Clone the repository into /app
RUN git clone https://github.com/garrettfoster13/sccmhunter /app

# Install Python dependencies in a virtual environment
RUN virtualenv --python=python3 . \
    && source bin/activate \
    && pip3 install -r requirements.txt

# Run the Python script
CMD ["python3", "sccmhunter.py"]
