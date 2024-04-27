#!/bin/bash
source /usr/local/gromacs/bin/GMXRC
# Execute the command passed to the container
exec "$@"