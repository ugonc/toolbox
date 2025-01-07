#!/bin/bash

# Set default key size or use provided argument
KEY_SIZE=${1:-2048}

# Create a directory to store the keys
mkdir -p keys
echo "Generating RSA private key of size $KEY_SIZE..."

# Generate a private key
if ! openssl genrsa -out keys/private.pem $KEY_SIZE; then
  echo "Failed to generate private key."
  exit 1
fi
chmod 600 keys/private.pem
echo "Private key saved to keys/private.pem."

# PKCS#1 is the format used for specific RSA private keys.
# PKCS#8 is a generic format that supports multiple types of private keys.

# Optional: Generate a private key in PKCS#8 format if needed
if [[ "$2" == "pkcs8" ]]; then
  echo "Converting private key to PKCS#8 format..."
  if ! openssl genrsa $KEY_SIZE | openssl pkcs8 -topk8 -nocrypt -out keys/private.pem; then
    echo "Failed to convert private key to PKCS#8 format."
    exit 1
  fi
  echo "Private key converted to PKCS#8 format."
fi

# Generate the corresponding public key
echo "Generating public key..."
if ! openssl rsa -in keys/private.pem -pubout -out keys/public.pem; then
  echo "Failed to generate public key."
  exit 1
fi
echo "Public key saved to keys/public.pem."

# Check if pem-jwk is installed
if ! command -v pem-jwk &> /dev/null; then
  echo "pem-jwk not found. Install it using 'npm install -g pem-jwk'."
  exit 1
fi

# Generate the JWKS
echo "Generating JWKS..."
if ! cat keys/public.pem | pem-jwk > keys/public.jwk; then
  echo "Failed to generate JWKS."
  exit 1
fi
echo "JWKS saved to keys/public.jwk."

# Optional: Export the public key in DER format
if [[ "$3" == "der" ]]; then
  echo "Exporting public key in DER format..."
  if ! openssl rsa -in keys/private.pem -pubout -outform DER -out keys/public.der; then
    echo "Failed to export public key in DER format."
    exit 1
  fi
  echo "Public key in DER format saved to keys/public.der."
fi

echo "All tasks completed successfully!"
