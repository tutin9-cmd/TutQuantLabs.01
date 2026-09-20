# TutQuantLabs.01
robinhood mcp
# Robinhood Breakout Bot — Code Explorer

A production-ready web application that showcases a complete **Volatility Breakout crypto trading bot** built for Robinhood's Agentic Trading MCP. Browse, read, and understand every line of the Python codebase through an interactive GitHub-style code viewer.

![Python 3.11+](https://img.shields.io/badge/Python-3.11+-blue?logo=python)
![Status](https://img.shields.io/badge/Status-Production%20Ready-green)
![License](https://img.shields.io/badge/License-Proprietary-red)

---

## 🎯 What Is This?

This repository contains two things:

1. **A React web application** (this repo) — An interactive code explorer with syntax highlighting, file tree navigation, architecture diagrams, and strategy documentation.
2. **A complete Python trading bot** (served as static files) — A fail-closed, hybrid-architecture algorithmic trading system that executes volatility breakout strategies on crypto markets.

---

## 🖥️ The Web Application

### Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | React 18 + TypeScript |
| Build Tool | Vite 6 |
| Styling | Tailwind CSS 4 |
| Syntax Highlighting | Prism.js |
| Icons | Lucide React |

### Features

- **📋 Strategy Overview** — Full documentation of the Volatility Breakout strategy, entry/exit conditions, and risk parameters.
- **🏗️ Architecture Diagram** — Visual representation of the scan cycle pipeline, data flow, and fail-closed design principles.
- **💻 Source Code Viewer** — GitHub-style code browser with:
  - Line numbers
  - Python syntax highlighting (dark theme)
  - Copy-to-clipboard
  - File tree navigation
  - Line count indicators

### Running Locally

```bash
# Install dependencies
npm install

# Start development server
npm run dev

# Build for production
npm run build

# Type-check
npm run typecheck
```

### Project Structure

```
├── index.html                  # Entry HTML
├── src/
│   ├── App.tsx                 # Main app with view routing
│   ├── index.css               # Tailwind + Prism.js theme
│   ├── main.tsx                # React entry point
│   └── components/
│       ├── Header.tsx          # Top nav bar with view tabs
│       ├── FileTree.tsx        # Sidebar file explorer
│       ├── CodeViewer.tsx      # Syntax-highlighted code display
│       ├── ArchitectureDiagram.tsx  # System architecture visual
│       └── StrategyOverview.tsx     # Strategy documentation page
├── public/
│   └── code/                 # Python source files served statically
│       ├── config.py
│       ├── main.py
│       ├── Dockerfile
│       ├── docker-compose.yml
│       ├── requirements.txt
│       ├── .env.example
│       ├── .gitignore
│       ├── src/
│       │   ├── __init__.py
│       │   ├── data_fetcher.py
│       │   ├── technical_engine.py
│       │   ├── llm_regime_guard.py
│       │   ├── risk_engine.py
│       │   └── execution_manager.py
│       └── tests/
│           ├── __init__.py
│           ├── test_technical_engine.py
│           └── test_risk_engine.py
└── dist/                     # Production build output
```

---

## 🤖 The Trading Bot

### Strategy: Volatility Breakout (Long-Only Spot)

The bot scans a **Top-25 crypto allowlist** for assets where volatility has contracted and price breaks out upward on high volume.

#### Entry Conditions (ALL must be true)

| # | Condition | Implementation |
|---|-----------|---------------|
| 1 | **BB Squeeze** | 20-period Bollinger Band Width at 30-day low (bottom 20th percentile) |
| 2 | **Breakout** | Price breaks above 20-period Donchian Channel OR Upper Bollinger Band |
| 3 | **Volume Surge** | Current volume > 1.5× the 20-period SMA of volume |
| 4 | **LLM Approval** | Regime guard confirms on-chain + social data supports the breakout |

#### Exit Logic

| Exit Type | Trigger | Action |
|-----------|---------|--------|
| **Stop-Loss** | Price ≤ entry − 2×ATR(14) | Full liquidation |
| **Take-Profit** | Price ≥ entry × 1.08 | Sell 50% of position |
| **Trailing Stop** | Price drops below 20-SMA | Sell remaining 50% |
| **Time-Stop** | 48h elapsed, PnL ≤ 0% | Full liquidation at market |

### Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                  SCAN CYCLE (every 5 min)                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────┐   ┌─────────────────┐   ┌──────────────┐  │
│  │ Data Fetcher │──▶│ Technical Engine │──▶│ LLM Regime   │  │
│  │ Polygon.io   │   │ BB, ATR,         │   │ Guard (GPT)  │  │
│  │ LunarCrush   │   │ Donchian, Volume │   │              │  │
│  │ Arkham       │   │                  │   │ VETO only    │  │
│  └─────────────┘   └─────────────────┘   └──────┬───────┘  │
│                                                  │          │
│                                                  ▼          │
│  ┌─────────────┐   ┌─────────────────┐   ┌──────────────┐  │
│  │ Execution    │◀──│ Risk Engine      │◀──│ Approved     │  │
│  │ Manager      │   │ Hard limits,     │   │ candidates   │  │
│  │ Robinhood MCP│   │ Position sizing  │   │              │  │
│  └─────────────┘   └─────────────────┘   └──────────────┘  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Deterministic Risk Controls

These limits are enforced in Python code and **cannot be overridden** by the LLM:

| Control | Limit |
|---------|-------|
| Total Capital | $250.00 |
| Max Position Size | $50.00 (20% of account) |
| Max Concurrent Positions | 3 ($150 deployed, $100 reserve) |
| Trade Velocity | Max 2 trades per asset per 24h rolling window |
| Weekend Blackout | No new entries Fri 8PM – Sun 8PM EST |
| Max Spread | 0.75% bid-ask |
| Min Risk/Reward | 1.5:1 |

### Fail-Closed Design

Every component defaults to **NO TRADE** on error:

| Failure Mode | Behavior |
|-------------|----------|
| API timeout / error | Skip asset, continue scan |
| LLM parse failure | Veto trade immediately |
| MCP connection error | Abort execution |
| Missing market data | Skip entire scan cycle |
| Ambiguous state | Never trade blind |
| Config missing | Refuse to start |

### File Descriptions

| File | Purpose |
|------|---------|
| `config.py` | Pydantic settings with env-var loading, validation, fail-closed on missing keys |
| `main.py` | Entry point, APScheduler loop, Flask health endpoint, graceful shutdown |
| `src/data_fetcher.py` | Polygon.io OHLCV/quotes, LunarCrush sentiment, Arkham on-chain flows |
| `src/technical_engine.py` | Bollinger Bands, ATR, Donchian Channel, Volume SMA, breakout detection |
| `src/llm_regime_guard.py` | LLM prompt construction, strict JSON parsing, retry logic, veto mechanism |
| `src/risk_engine.py` | All hard risk limits, position sizing, exit management (SL/TP/trailing/time) |
| `src/execution_manager.py` | Robinhood MCP abstraction, idempotency keys, order tracking, audit trail |
| `tests/test_technical_engine.py` | Unit tests for BB, Donchian, ATR, Volume SMA, percentile rank |
| `tests/test_risk_engine.py` | Unit tests for spread, velocity, concurrent positions, exit decisions |

### API Dependencies

| Service | Purpose | Key Required |
|---------|---------|:---:|
| [Polygon.io](https://polygon.io) | OHLCV candles, real-time quotes | ✅ |
| [LunarCrush](https://lunarcrush.com) | Social sentiment metrics | ✅ |
| [Arkham Intelligence](https://arkhamintelligence.com) | On-chain flow data | ✅ |
| [OpenAI](https://openai.com) | GPT-4o-mini for regime guard | ✅ |
| Robinhood MCP | Order execution | ✅ |

### Deployment

```bash
# 1. Configure environment
cp .env.example .env
# Edit .env with your API keys

# 2. Run with Docker
docker-compose up -d

# 3. Verify health
curl http://localhost:8080/health

# 4. View logs
docker-compose logs -f breakout-bot
```

### Development

```bash
# Install Python dependencies
pip install -r requirements.txt

# Run tests
pytest tests/ -v

# Run the bot directly
python main.py
```

### Crypto Allowlist

```
BTC  ETH  SOL  AVAX  DOGE  MATIC  LINK  UNI  ATOM  LTC
XLM  ALGO  DOT  ADA  FIL  AAVE  NEAR  APT  ARB  OP
SUI  SEI  TIA  INJ  RNDR
```

---

## ⚠️ Disclaimer

This software is provided for **educational and research purposes only**. Cryptocurrency trading involves substantial risk of loss. The authors are not responsible for any financial losses incurred through the use of this software. Always paper-trade before risking real capital.

---

## 📄 License

Proprietary. Internal use only.

