#/usr/bin/sh

#Appends TARGET to SOURCE if not already present

SOURCE="/etc/hosts"
TARGET="127.0.0.1        scambier.42.fr"

if [ -z "$(cat "$SOURCE" | grep "$TARGET")" ]; then
	echo "$TARGET" >> "$SOURCE"
fi
