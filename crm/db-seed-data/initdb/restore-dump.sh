#!/bin/bash
set -e

pg_restore --if-exists --verbose --clean --no-acl --no-owner -U "$POSTGRES_USER" -d "$POSTGRES_DB" /docker-entrypoint-initdb.d/seed-data.dump
