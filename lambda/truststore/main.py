from urllib.parse import urlparse
import logging
import boto3
import os

# Lambda Event Format
"""
{
    "truststore_s3_uri": "s3://rodo-title-cenm-network-trust-stores/dev-duplo/network-root-truststore.jks"
}
"""

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, _):
    s3_uri = event['truststore_s3_uri']

    bucket = urlparse(s3_uri).netloc
    key = urlparse(s3_uri).path

    logger.info(f"{bucket} key: {key}")
    s3 = boto3.client(service_name='s3', region_name=os.environ['AWS_REGION'])

    s3.download_file(Bucket=bucket, Key=key,
                     # This filepath and filename is always the same regardless of environment
                     Filename='/mnt/certificates/network-root-truststore.jks')

    # confirm the file is there
    os.listdir('/mnt/certificates')
