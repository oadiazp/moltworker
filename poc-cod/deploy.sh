#!/bin/bash
# Deploy script for COD PoC — 3 Clawdist bots
# Run from moltworker root: bash poc-cod/deploy.sh
#
# Prerequisites:
# 1. npx wrangler login (authenticated)
# 2. npm install (dependencies)
# 3. Secrets configured for each worker (see README.md)

set -e

BOTS=("camila" "neil" "arndt")

for bot in "${BOTS[@]}"; do
    WORKER_NAME="clawdist-${bot}"
    echo "========================================"
    echo "Deploying ${WORKER_NAME}..."
    echo "========================================"
    
    npx wrangler deploy --name "$WORKER_NAME"
    
    echo "${WORKER_NAME} deployed successfully!"
    echo ""
done

echo "All 3 bots deployed!"
echo ""
echo "URLs:"
for bot in "${BOTS[@]}"; do
    echo "  - clawdist-${bot}.<your-subdomain>.workers.dev"
done
echo ""
echo "Don't forget to set secrets for each worker if not done yet:"
echo "  npx wrangler secret put TELEGRAM_BOT_TOKEN --name clawdist-<name>"
echo "  npx wrangler secret put AI_GATEWAY_API_KEY --name clawdist-<name>"
echo "  npx wrangler secret put MOLTBOT_GATEWAY_TOKEN --name clawdist-<name>"
