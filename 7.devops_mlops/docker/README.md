## Introduction
This is a Dockerfile to build a miniconda based container image with installed python packages: 
* mlflow
* boto3
* pymysql


## Building from source
To build from source you need to clone the git repo and run docker build:
```bash
git clone https://github.com/grant88/education.git
cd 7.devops_mlops/docker
```

followed by
```bash
docker build -t netology-ml:netology-ml .
```

## Running
To run the container:
```
sudo docker run -d netology-ml:netology-ml
```

Default root:
```
/app
```
