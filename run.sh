#!/usr/bin/env bash
# ***********************************************
# run.sh provisions AWS instance with terraform 
# and then configures Minecraft on the instance
# via Ansible
#
# Usage:
#   ./run.sh          # provision + configure
#
# Prerequisites: 
#   - AWS credentials exported 
#       - AWS_ACCESS_KEY_ID 
#       - AWS_SECRET_ACCESS_KEY
#       - AWS_SESSION_TOKEN
#   - terraform >= 1.15.5 installed
#   - ansible >= 2.21 installed
# ***********************************************

set -euo pipefail

# ***********************************************
# Helper Functions for pretty printing
# ***********************************************

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No color after label

info()    { echo -e "${CYAN}[INFO]${NC}  $*"; }
success() { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
die()     { echo -e "${RED}[ERROR]${NC} $*" >&2; exit 1; }

# ***********************************************
# Globals
# ***********************************************

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TF_DIR="${SCRIPT_DIR}/terraform"
ANSIBLE_DIR="${SCRIPT_DIR}/ansible"

# ***********************************************
# Pre-requesite checks
# ***********************************************

info "Running pre-req checks..."

command -v terraform >/dev/null 2>&1 || die "Terraform not found. Install Terraform first."
command -v ansible-playbook >/dev/null 2>&1 || die "ansible-playbook not found. Install Ansible first."
command -v aws >/dev/null 2>&1 || die "AWS CLI not found. Install the AWS CLI first."

[[ -z "${AWS_ACCESS_KEY_ID:-}" ]]     && die "AWS_ACCESS_KEY_ID is not set."
[[ -z "${AWS_SECRET_ACCESS_KEY:-}" ]] && die "AWS_SECRET_ACCESS_KEY is not set."
[[ -z "${AWS_SESSION_TOKEN:-}" ]]     && warn "AWS_SESSION_TOKEN is not set."

success "Pre-req checks passed."

# ***********************************************
# Terraform
# ***********************************************

info "Initialising Terraform..."
(cd "${TF_DIR}" && terraform init -upgrade -input=false)

info "Applying Terraform plan..."
(cd "${TF_DIR}" && terraform apply -auto-approve -input=false)

PUBLIC_IP=$(cd "${TF_DIR}" && terraform output -raw public_ip)
KEY_PATH=$(cd "${TF_DIR}" && terraform output -raw private_key_path)
KEY_PATH=$(realpath "${SCRIPT_DIR}/$(basename "${KEY_PATH}")")

success "EC2 instance ready. Public IP: ${PUBLIC_IP}"
success "Private key: ${KEY_PATH}"

# ***********************************************
# Ansible Inventory
# Relies on Terraform outputs above
# ***********************************************

INVENTORY="${ANSIBLE_DIR}/inventory.ini"

info "Writing Ansible inventory to ${INVENTORY}"
cat > "${INVENTORY}" <<EOF
[minecraft]
${PUBLIC_IP} ansible_user=ubuntu ansible_ssh_private_key_file=${KEY_PATH} ansible_ssh_common_args='-o StrictHostKeyChecking=no'
EOF
success "Inventory written"

# ***********************************************
# Wait for SSH to become available
# ***********************************************

info "Waiting for SSH on ${PUBLIC_IP}:22"

MAX_RETRIES=60
RETRY_INTERVAL=10
attempt=1

until ssh -o StrictHostKeyChecking=no \
          -o ConnectTimeout=5 \
          -o BatchMode=yes \
          -i "${KEY_PATH}" \
          "ubuntu@${PUBLIC_IP}" \
          exit 2>/dev/null; do
  if (( attempt >= MAX_RETRIES )); then
    die "SSH still not available after $((MAX_RETRIES * RETRY_INTERVAL)) secs. Aborting."
  fi
  echo "  Attempt ${attempt}/${MAX_RETRIES} — retrying in ${RETRY_INTERVAL}s..."
  sleep "${RETRY_INTERVAL}"
  (( attempt++ ))
done

success "SSH is available."

# ***********************************************
# Run Ansible playbook
# ***********************************************

info "Running Ansible playbook..."
(cd "${ANSIBLE_DIR}" && ansible-playbook -i inventory.ini playbook.yml)

# ***********************************************
# Done
# ***********************************************

echo ""
success "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
success " Minecraft server is up!"
success ""
success " Connect in-game :  ${PUBLIC_IP}:25565"
success " Verify with nmap:  nmap -sV -Pn -p T:25565 ${PUBLIC_IP}"
success "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
