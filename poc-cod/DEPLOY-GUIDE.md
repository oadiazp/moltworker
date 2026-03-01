# Guía de Deploy Multi-Worker — Clawdist PoC

## Problema
Cada worker necesita un nombre de container application único. El nombre se genera como `{wrangler-name}-{class_name}`. Si todos usan el mismo `name` en wrangler.jsonc, colisionan.

## Solución
Cambiar SOLO el campo `"name"` en wrangler.jsonc antes de cada deploy. NO tocar `class_name`, `Sandbox`, ni `new_sqlite_classes` — esos deben coincidir con la clase exportada en el código TypeScript.

## Proceso paso a paso

### Prerequisitos (una sola vez)
```bash
cd /Users/zcool/src/zczoft/clawdist
npm install
export CLOUDFLARE_API_TOKEN=<token>
```

### Para cada nuevo bot:

#### 1. Crear secrets
```bash
BOT_NAME="clawdist-NOMBRE"

# Telegram
echo 'TOKEN_DEL_BOT' | npx wrangler secret put TELEGRAM_BOT_TOKEN --name $BOT_NAME
echo 'open' | npx wrangler secret put TELEGRAM_DM_POLICY --name $BOT_NAME

# LLM (Fireworks API key)
echo 'fw_XXXXX' | npx wrangler secret put ANTHROPIC_API_KEY --name $BOT_NAME

# Gateway token (generado automáticamente)
TOKEN=$(openssl rand -hex 32)
echo $TOKEN | npx wrangler secret put MOLTBOT_GATEWAY_TOKEN --name $BOT_NAME
echo "Gateway token para $BOT_NAME: $TOKEN"
```

#### 2. Deploy
```bash
# Limpiar builds anteriores
rm -rf dist .wrangler/deploy

# Cambiar nombre del worker en config (SOLO el campo "name", nada más)
sed -i '' 's/"name": "moltbot-sandbox"/"name": "'$BOT_NAME'"/' wrangler.jsonc

# Deploy
npx wrangler deploy --name $BOT_NAME

# Restaurar config original
git checkout wrangler.jsonc
```

#### 3. Verificar
- Web UI: `https://$BOT_NAME.zcool2005.workers.dev/?token=GATEWAY_TOKEN`
- Telegram: hablarle al bot (primera vez tarda 1-2 min por cold start)

## Errores comunes

### "application with the name X deployed that is associated with a different durable object namespace"
- Causa: no se cambió el `"name"` en wrangler.jsonc antes del deploy
- Fix: cambiar `"name"` y limpiar `dist/` y `.wrangler/deploy/`

### "Cannot create binding for class 'X' that is not exported by the script"
- Causa: se cambió `class_name` o `new_sqlite_classes` — NO hacer eso
- Fix: `git checkout wrangler.jsonc` y solo cambiar el campo `"name"`

### "Login failed" / keychain error
- Causa: Docker Desktop credential helper conflicto en macOS
- Fix: `sed -i '' 's/"credsStore": "desktop"/"credsStore": ""/g' ~/.docker/config.json`

### "redirected configuration path does not exist"
- Causa: se borró `dist/` pero queda `.wrangler/deploy/config.json` apuntando al viejo
- Fix: `rm -rf .wrangler/deploy` y rebuild

## Workers desplegados (PoC COD)

| Worker | URL | Telegram Bot | Gateway Token |
|--------|-----|-------------|---------------|
| clawdist-camila | clawdist-camila.zcool2005.workers.dev | 8325862546 | 370e69dc93c02a445f96257e11e695429e8dc3df0df942deb047dc3d6e045eb1 |
| clawdist-neil | clawdist-neil.zcool2005.workers.dev | 8495898368 | 21438cea194dbf530796a105e3e1641c4115a811efc5c09aaad6543ed2d242b1 |
| clawdist-arndt | clawdist-arndt.zcool2005.workers.dev | 8413372720 | (pendiente deploy) |

## Notas
- El plan Workers Paid ($5/mes) cubre TODOS los workers
- La imagen Docker se cachea — deploys subsiguientes son mucho más rápidos
- R2 bucket `moltbot-data` compartido para persistencia
- Container duerme por defecto: nunca (recomendado para PoC)
- Cron cada 5 min sincroniza config a R2
