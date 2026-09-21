#!/bin/bash
set -e

./scripts/setup_dynamodb.sh
./scripts/create_s3_bucket.sh
./scripts/package_and_create_lambdas.sh
./scripts/create_and_configure_api_gateway.sh
./scripts/create_state_machine.sh
