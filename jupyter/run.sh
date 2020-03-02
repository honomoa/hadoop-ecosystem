#!/bin/bash

set -e

exec su $JUPYTER_USER -c "PATH=$PATH jupyter notebook"
