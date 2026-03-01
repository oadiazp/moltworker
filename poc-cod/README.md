# PoC Clawdist — 3 Bots para equipo COD

## Arquitectura
- 1 cuenta Cloudflare (plan Workers Paid $5/mes) → cubre todos los workers
- 3 workers separados, uno por persona:
  - `clawdist-camila` 
  - `clawdist-neil`
  - `clawdist-arndt`
- Cada uno es un Moltworker independiente con su propio Telegram bot
- LLM: Fireworks AI (Qwen3 235B o DeepSeek V3) via AI Gateway o directo

## Estado

### Listo (Asere hizo)
- [x] Fork de Moltworker: github.com/oadiazp/moltworker
- [x] Código estudiado y entendido
- [x] SOUL.md preparado para cada bot (en poc-cod/bots/)
- [x] Wrangler configs preparados para multi-deploy
- [x] Script de deploy preparado

### Falta (Omar necesario)
- [ ] Crear cuenta Cloudflare + plan Workers Paid ($5/mes)
- [ ] Crear cuenta Fireworks AI + $10 crédito
- [ ] Crear 3 bots de Telegram via @BotFather:
  - Bot 1: nombre sugerido `CamilaCODBot` → guardar token
  - Bot 2: nombre sugerido `NeilCODBot` → guardar token  
  - Bot 3: nombre sugerido `ArndtCODBot` → guardar token
- [ ] `npm install` + `npx wrangler login` (autenticar con CF)
- [ ] Configurar secrets con wrangler (tokens, API keys)
- [ ] Deploy de los 3 workers

## Cómo hacer el deploy

### 1. Autenticar Cloudflare
```bash
cd /home/zcool/clawd/moltworker
npm install
npx wrangler login
```

### 2. Configurar Fireworks como LLM provider
Fireworks es compatible con OpenAI API, así que usamos AI_GATEWAY vars:
```bash
# Para cada bot (cambiar el --name):
npx wrangler secret put AI_GATEWAY_API_KEY --name clawdist-camila
# → pegar Fireworks API key

npx wrangler secret put AI_GATEWAY_BASE_URL --name clawdist-camila  
# → pegar: https://api.fireworks.ai/inference/v1
# (Fireworks usa formato OpenAI, así que endpoint /openai no aplica - ver nota)
```

**Nota Fireworks:** Fireworks usa API compatible con OpenAI pero su base URL es `https://api.fireworks.ai/inference/v1`. El modelo se configura en el config del bot.

### 3. Configurar Telegram bots
```bash
npx wrangler secret put TELEGRAM_BOT_TOKEN --name clawdist-camila
# → pegar token del bot de Camila

npx wrangler secret put TELEGRAM_DM_POLICY --name clawdist-camila
# → "open" (para que cualquiera pueda hablar sin pairing)
```

### 4. Gateway token
```bash
export TOKEN_CAMILA=$(openssl rand -hex 32)
echo "$TOKEN_CAMILA" | npx wrangler secret put MOLTBOT_GATEWAY_TOKEN --name clawdist-camila
echo "Camila token: $TOKEN_CAMILA"
```

### 5. Deploy
```bash
# Deploy cada bot con su nombre
npx wrangler deploy --name clawdist-camila
npx wrangler deploy --name clawdist-neil  
npx wrangler deploy --name clawdist-arndt
```

### 6. Verificar
Cada bot estará en:
- `https://clawdist-camila.<subdomain>.workers.dev/?token=TOKEN`
- `https://clawdist-neil.<subdomain>.workers.dev/?token=TOKEN`
- `https://clawdist-arndt.<subdomain>.workers.dev/?token=TOKEN`
