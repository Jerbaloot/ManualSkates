#!/bin/sh
echo -ne '\033c\033]0;Manual Skates\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/Manual Skates.x86_64" "$@"
