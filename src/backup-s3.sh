#!/usr/bin/env ash
# shellcheck shell=dash
set -e

command=$(basename "$0")

usage() {
  echo "usage: $command -b <aws-backup-bucket> -n <hostname> [-k <aws-access-key-id>] [-s <aws-secret-access-key>] [-r <aws-region>]"
}

while getopts "b:n:k:s:r:h" flag; do
  case "${flag}" in
  b) aws_backup_bucket=${OPTARG} ;;
  n) hostname=${OPTARG} ;;
  k) aws_access_key_id=${OPTARG} ;;
  s) aws_secret_access_key=${OPTARG} ;;
  r) aws_region=${OPTARG} ;;
  h)
    usage
    exit 0
    ;;
  *)
    usage
    exit 1
    ;;
  esac
done

if [ -z "$aws_backup_bucket" ]; then
  echo "$command: AWS backup bucket not set." >&2
  exit 1
fi

if [ -z "$hostname" ]; then
  echo "$command: Hostname not set." >&2
  exit 1
fi

if [ -z "$aws_access_key_id" ]; then
  # shellcheck disable=SC2153
  aws_access_key_id="$AWS_ACCESS_KEY_ID"
  if [ -z "$aws_access_key_id" ]; then
    echo "$command: AWS access key ID not set." >&2
    exit 1
  fi
fi

if [ -z "$aws_secret_access_key" ]; then
  # shellcheck disable=SC2153
  aws_secret_access_key="$AWS_SECRET_ACCESS_KEY"
  if [ -z "$aws_secret_access_key" ]; then
    echo "$command: AWS secret access key not set." >&2
    exit 1
  fi
fi

if [ -z "$aws_region" ]; then
  # shellcheck disable=SC2153
  aws_region="$AWS_REGION"
  if [ -z "$aws_region" ]; then
    aws_region="us-east-1"
  fi
fi

content_type='application/x-compressed-tar'
date=$(date -R)
# shellcheck disable=SC2169,SC3028
filename="$hostname-backup-$(date -Iseconds).tar.gz"
temp_dir="/tmp/openwrt-utils"
backup_path_local="$temp_dir/$filename"
backup_path_s3="$filename"
backup_url="https://$aws_backup_bucket.s3.$aws_region.amazonaws.com/$backup_path_s3"

trap 'rm $backup_path_local' EXIT

echo "Creating system backup $backup_path_local."
mkdir -p "$temp_dir"
sysupgrade -b "$backup_path_local"

echo "Uploading backup to S3 $backup_url."
string_to_sign="PUT\n\n$content_type\n$date\n/$backup_path_s3"
signature=$(echo -n "$string_to_sign" | openssl sha1 -hmac "$aws_secret_access_key" -binary | base64)
curl -X PUT -T "$backup_path_local" \
  -H "Host: $aws_backup_bucket.s3.$aws_region.amazonaws.com" \
  -H "Date: $date" \
  -H "Content-Type: $content_type" \
  -H "Authorization: AWS ${aws_access_key_id}:$signature" \
  "$backup_url"
