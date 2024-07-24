FROM ubuntu:18.04
LABEL maintainer "Salman Ali <alisalm1@msu.edu>"
LABEL description="This is custom Docker Image for Beef Supply Chain Bioinformatics"


ENV DEBIAN_FRONTEND=noninteractive


RUN apt-get update && apt-get install -y --no-install-recommends build-essential r-base r-cran-randomforest python3.6 python3-pip python3-setuptools python3-dev
RUN apt -y install vim


RUN mkdir /app
COPY . /app
WORKDIR /app

RUN pip3 install --upgrade pip
COPY requirements.txt /app/requirements.txt
# COPY requirements.r /app/requirements.r

RUN pip3 install --no-cache-dir -r requirements.txt

RUN Rscript -e "install.packages('data.table')"

EXPOSE 8020 
ENV PORT 8020

# CMD service mysql start && exec python3 app.py

# COPY . /app




