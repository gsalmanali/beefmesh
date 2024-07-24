# Author  : Salman Ali <alisalm1@msu.edu>

FROM python:3.6.9-slim
LABEL maintainer "Salman Ali <alisalm1@msu.edu>"
LABEL description="This is custom Docker Image for Beef Chain Application"

# Install system packages
RUN apt-get update && apt-get install -y --no-install-recommends \
      bzip2 \
      g++ \
      git \
      graphviz \
      libgl1-mesa-glx \
      libhdf5-dev \
      openmpi-bin \
      wget \
      python3-tk && \
    rm -rf /var/lib/apt/lists/*

# Setting up working directory
RUN mkdir /app
WORKDIR /app 
COPY requirements.txt /requirements.txt
ADD requirements.txt /app


# Install pip dependancy
#RUN echo "@testing http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories
#RUN apk add --update --no-cache py3-numpy py3-pandas@testing
RUN python -m pip install --upgrade pip
#RUN python -m pip install opencv-python numpy pandas
RUN python -m pip install numpy pandas
RUN python -m pip install -U scikit-learn scipy matplotlib h5py
RUN python -m pip install --no-cache-dir -r requirements.txt
# copy whole directory inside /code working directory.
COPY . /app

# Minimize image size 
RUN (apt-get autoremove -y; \
     apt-get autoclean -y)

# Open ports, set environment variables, start gunicorn.
EXPOSE 5501
ENV PORT 5501
ENV FLASK_ENV=testing 

# This command execute at the time when conatiner start.
CMD ["python3", "app.py"]
# ----------------------------------------------------- 
