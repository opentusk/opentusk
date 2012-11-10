#!/bin/bash

for l  in translated/po/*
do
    bn=$(basename $l)
    echo "translating locale $bn"

    cat $l/*.po > $bn/LC_MESSAGES/tusk.po
   # python manage.py compilemessages -l $bn
done
