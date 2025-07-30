#!/bin/sh
set -e

echo $(python3 -c "from urllib.parse import quote; print(quote('$1'))")
