#!/bin/bash
curl -sfL https://get.k3s.io | \
K3S_URL="https://${controller_ip}:6443" \
K3S_TOKEN="${k3s_token}" \
sh -
