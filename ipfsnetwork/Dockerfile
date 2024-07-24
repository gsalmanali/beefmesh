FROM python:3.9-slim

# Install required packages
RUN pip install flask requests

# Copy the application code
COPY app /app

# Set the working directory
WORKDIR /app

# Expose the Flask port
EXPOSE 5000

# Run the application
CMD ["python", "app.py"]
