#!/bin/bash

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get -y install awscli
aws s3 sync "s3://$S3_BUCKET_NAME/$WORLD_NAME/config/worlds_local/" "/home/valheim/.config/unity3d/IronGate/Valheim/worlds_local/"
