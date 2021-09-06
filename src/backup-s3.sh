#!/usr/bin/env ash
# shellcheck shell=dash
set -e

if [ -n "$AWS_ACCESS_KEY_ID" ]; then
  echo "AWS_ACCESS_KEY_ID not set."
  exit 1
fi

if [ -n "$AWS_SECRET_ACCESS_KEY" ]; then
  echo "AWS_SECRET_ACCESS_KEY not set."
  exit 1
fi

if [ -n "$AWS_REGION" ]; then
  region="us-east-1"
fi

if [ -n "$AWS_BACKUP_BUCKET" ]; then
  echo "AWS_BACKUP_BUCKET not set."
  exit 1
fi

if [ -n "$HOSTNAME" ]; then
  echo "HOSTNAME not set."
  exit 1
fi

content_type='application/x-compressed-tar'
date=$(date -R)
# shellcheck disable=SC2169,SC3028
filename="$HOSTNAME-backup-$(date -Iseconds).tar.gz"
temp_dir="/tmp/openwrt-utils"
backup_path_local="$temp_dir/$filename"
backup_path_s3="$filename"
backup_url="https://$AWS_BACKUP_BUCKET.s3.amazonaws.com/$backup_path_s3"

trap 'rm $backup_path_local' EXIT

echo "Creating system backup $backup_path_local."
mkdir -p "$temp_dir"
sysupgrade -b "$backup_path_local"

echo "Uploading backup to S3 $backup_url."
string_to_sign="PUT\n\n$content_type\n$date\n/$backup_path_s3"
signature=$(echo -n "$string_to_sign" | openssl sha1 -hmac "$AWS_SECRET_ACCESS_KEY" -binary | base64)
curl -X PUT -T "$backup_path_local" \
  -H "Host: $AWS_BACKUP_BUCKET.s3.$region.amazonaws.com" \
  -H "Date: $date" \
  -H "Content-Type: $content_type" \
  -H "Authorization: AWS ${AWS_ACCESS_KEY_ID}:$signature" \
  "$backup_url"
