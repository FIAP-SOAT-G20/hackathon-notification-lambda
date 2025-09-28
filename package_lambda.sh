#!/bin/bash

# Package script for AWS Lambda deployment

# Create package directory
mkdir -p package

# Install dependencies to package directory
pip3 install -r requirements.txt --target package/

# Copy Lambda function code to package directory
cp -r lambda/* package/

# Create deployment ZIP file
cd package
zip -r ../lambda-deployment-package.zip .
cd ..

# Verify the package was created
ls -la lambda-deployment-package.zip

# Move the deployment package to the Terraform directory
mv lambda-deployment-package.zip terraform/
