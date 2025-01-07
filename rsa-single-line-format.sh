#!/bin/bash

# Verifies if a parameter was passed
if [ "$#" -ne 1 ]; then
  echo "Usage: detect_key_type.sh <keyfile.pem>"
  exit 1
fi

# Input file
input_file="$1"

# Check if the file exists
if [ ! -f "$input_file" ]; then
  echo "Error: File $input_file not found."
  exit 1
fi

# Detect key type (PKCS#1 or PKCS#8)
key_type=""
if grep -q "-----BEGIN RSA PRIVATE KEY-----" "$input_file"; then
  key_type="PKCS#1"
elif grep -q "-----BEGIN PRIVATE KEY-----" "$input_file"; then
  key_type="PKCS#8"\else
  echo "Error: Unrecognized key format."
  exit 1
fi

echo "Key type detected: $key_type"

# If the key is PKCS#1, convert it to PKCS#8
if [ "$key_type" = "PKCS#1" ]; then
  echo "Converting PKCS#1 key to PKCS#8 format..."
  output_file="converted_key.pem"
  openssl pkcs8 -topk8 -inform PEM -outform PEM -nocrypt -in "$input_file" -out "$output_file"
  input_file="$output_file"
fi

# Process the key to transform it into a single-line format
processed_key=$(sed '1d;$d' "$input_file" | base64 -d | base64 | tr -d '\n')

echo "Processed key in single-line format:" 
echo "$processed_key"

# Copy the result to the clipboard (macOS-specific)
echo "$processed_key" | pbcopy

echo "The single-line key has been copied to the clipboard."
