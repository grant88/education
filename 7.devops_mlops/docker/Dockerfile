FROM continuumio/miniconda3:latest
RUN mkdir /app
COPY ./1.sh /app/1.sh
RUN chmod +x /app/1.sh
RUN pip install mlflow boto3 pymysql
CMD bash /app/1.sh