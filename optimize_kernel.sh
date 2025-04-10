#!/bin/bash

curl -fsSL https://raw.githubusercontent.com/buding-cat/KernelTuner/refs/heads/main/sysctl.conf > /etc/sysctl.conf
sysctl -p
