#!/bin/sh

python3 -m venv ./.commodore-venv/
. ./.commodore-venv/bin/activate
pip install -r requirements txt
exec commodore component sync $@
