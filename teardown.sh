#!/usr/bin/env bash
# ***********************************************
# teardown.sh 
# destroys all AWS resources created by run.sh script
# ***********************************************

set -euo pipefail

# ***********************************************
# Helper Functions for pretty printing
# ***********************************************

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

success() { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
die()     { echo -e "${RED}[ERROR]${NC} $*" >&2; exit 1; }

# ***********************************************
# Globals
# ***********************************************

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TF_DIR="${SCRIPT_DIR}/terraform"

# ***********************************************
# Prompt
# ***********************************************
warn "This will DESTROY all Minecraft AWS resources"
read -r -p "Are you sure? [y/N] " confirm

[[ "${confirm,,}" == "y" ]] || { die "Aborted."; exit 0; }

success "Running terraform destroy..."
(cd "${TF_DIR}" && terraform destroy -auto-approve -input=false)

# ***********************************************
# Clean up generated files
# ***********************************************

rm -f "${SCRIPT_DIR}"/*.pem
rm -f "${SCRIPT_DIR}/ansible/inventory.ini"

success "All resources destroyed and local files cleaned up"
