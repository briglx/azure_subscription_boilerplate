#!/usr/bin/env bash

FILE_NAME=ConfluenceDB
SERVER_NAME="$1"

/opt/mssql-tools/sqlpackage/sqlpackage /Action:Export "/TargetFile:${FILE_NAME}.bacpac" "/SourceServerName:$SERVER_NAME" "/SourceDatabaseName:$CONFLUENCE_DB_NAME"  "/SourceUser:$CONFLUENCE_ADMIN_NAME" "/SourcePassword:$CONFLUENCE_ADMIN_PASSWORD"
