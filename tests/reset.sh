#!/usr/bin/env bash

readonly BACKUP="$HOME"/.backup
readonly LOGS="$HOME"/Área\ de\ Trabalho/.logs

if [ -e "$BACKUP" ]; then
	rm -rf "$BACKUP"
fi

if [ -e "$LOGS" ]; then
	rm -rf "$LOGS"
fi
