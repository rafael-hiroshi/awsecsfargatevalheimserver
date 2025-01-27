#!/bin/bash

# Ensure a timeout for the operation
timeout 60 bash -c "
  mkdir -p /tmp/backup && \
  unzip -o @BACKUP_FILE@ -d /tmp/backup && \
  aws s3 cp /tmp/backup/ s3://$S3_BUCKET_NAME/$WORLD_NAME/ --recursive && \
  rm -rf /tmp/backup
"
