#!/bin/bash

echo "#renv settings
RENV_PATHS_PREFIX_AUTO=TRUE
RENV_CONFIG_PAK_ENABLED=TRUE
OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES
" > .Renviron

echo ".Renviron has been updated."
