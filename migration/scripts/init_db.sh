#!/bin/bash

mysql_command="mysql -h${DB_HOST} -u${DB_USER} -p${DB_PASSWORD}"

echo "Create database ${MYSQL_DATABASE}" 1>&2
echo "DROP DATABASE IF EXISTS ${MYSQL_DATABASE};CREATE DATABASE ${MYSQL_DATABASE}" | ${mysql_command}
if [ $? -ne 0 ]; then
  echo "Failed to create database"
  exit 2
fi

echo "Do database migration in ${MYSQL_DATABASE}" 1>&2
cat "/app/data/ip2city.sql" | ${mysql_command} "${MYSQL_DATABASE}"
if [ $? -ne 0 ]; then
  echo "Failed to Do database migration"
  exit 4
fi