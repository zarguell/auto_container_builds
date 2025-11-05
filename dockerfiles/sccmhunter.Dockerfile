FROM dhi/python:3-fips

# Install necessary packages for building Python packages and common dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    python3-venv

# Set the working directory
WORKDIR /app

# Clone the repository into /app
RUN git clone https://github.com/garrettfoster13/sccmhunter /app

# Install Python dependencies in a virtual environment
RUN python3 -m venv venv \
    && . venv/bin/activate \
    && pip install -r requirements.txt

# Run the Python script
ENTRYPOINT ["venv/bin/python", "sccmhunter.py"]
