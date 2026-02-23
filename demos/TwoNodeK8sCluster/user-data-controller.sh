#!/bin/bash
curl -sfL https://get.k3s.io | \
INSTALL_K3S_EXEC="server --token ${k3s_token} --tls-san $(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)" \
sh -
