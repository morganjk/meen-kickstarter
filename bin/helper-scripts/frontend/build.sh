#!/usr/bin/env bash

echo "========================================================"
echo "STARTING TASK: Build frontend into /dist"
echo "========================================================"
cd frontend;
"$FRONTEND_NODE_MODULES_BIN"/gulp build;
cd -;
echo "========================================================"
echo "COMPLETE TASK"
echo "========================================================"
