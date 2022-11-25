#!/usr/bin/env bash

readonly BACKUP="$HOME"/.backup

if [ -e "$BACKUP" ]; then
	chmod ug+w "$BACKUP"

	rm -rf "$BACKUP"
fi
