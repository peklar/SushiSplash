#!/bin/sh
echo -ne '\033c\033]0;Sushi_Splash\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/Sushi_Splash.x86_64" "$@"
