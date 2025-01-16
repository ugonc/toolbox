#!/bin/bash

# Verifies if exactly two parameters were provided
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <input_key.pem> <output_key.txt>"
  exit 1
fi

# Assign script parameters to variables
input_file="$1"
output_file="$2"

# Check if the input file exists
if [ ! -f "$input_file" ]; then
  echo "Error: File $input_file not found."
  exit 1
fi

# Detect key type (PKCS#1 or PKCS#8)
key_type=""

# Use grep -F (fixed string) plus -- to prevent option parsing 
# and treat the pattern as a literal string.
if grep -qF -- "-----BEGIN RSA PRIVATE KEY-----" "$input_file"; then
  key_type="PKCS#1"
elif grep -qF -- "-----BEGIN PRIVATE KEY-----" "$input_file"; then
  key_type="PKCS#8"
else
  echo "Error: Unrecognized key format."
  exit 1
fi

echo "Key type detected: $key_type"

# If the key is PKCS#1, convert it to PKCS#8
if [ "$key_type" = "PKCS#1" ]; then
  echo "Converting PKCS#1 key to PKCS#8 format..."
  # We create a temporary file for the converted key
  temp_converted_file=$(mktemp)

  openssl pkcs8 -topk8 -inform PEM -outform PEM -nocrypt -in "$input_file" -out "$temp_converted_file"
  
  # Overwrite input_file variable so we process the converted key
  input_file="$temp_converted_file"
fi

# Process the key to transform it into a single-line format:
# - Remove the first and last lines (the BEGIN and END lines)
# - Decode from base64, re-encode to base64, remove newlines
processed_key=$(
  sed '1d;$d' "$input_file" \
  | base64 -d \
  | base64 \
  | tr -d '\n'
)

# Output the single-line key to the specified output file
echo "$processed_key" > "$output_file"

# (Optional) Copy the result to the clipboard (macOS-specific)
# Uncomment if you want the script to automatically copy the single-line key.
# echo "$processed_key" | pbcopy

echo "Single-line key written to: $output_file"
