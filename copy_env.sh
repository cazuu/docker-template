#!/bin/bash

ROOT_DIR=..

if [[ ! -e $ROOT_DIR/.env ]]; then
    cp $ROOT_DIR/.env.example $ROOT_DIR/.env
fi

sed -i "" "/APP_URL/s/$/:9400/" $ROOT_DIR/.env
sed -i "" "/DB_HOST/s/=.*/=mysql/" $ROOT_DIR/.env
sed -i "" "/DB_DATABASE/s/=.*/=database/" $ROOT_DIR/.env
sed -i "" "/DB_PASSWORD/s/=.*/=password/" $ROOT_DIR/.env
sed -i "" "/MAIL_HOST/s/=.*/=smtp/" $ROOT_DIR/.env
sed -i "" "/MAIL_PORT/s/=.*/=1025/" $ROOT_DIR/.env
