#!/usr/bin/env bash
# Demo script for architecture-reviewer skill
# Simulates an architecture drift report with colored output

set -e

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

clear

# Header
echo ""
printf "${CYAN}${BOLD}━━━ Architecture Drift Report — my-api ━━━${RESET}\n"
echo ""
sleep 0.3

# Processing lines
printf "${DIM}▸ Found: ARCHITECTURE.md, docs/adr/001-auth.md${RESET}\n"
sleep 0.2
printf "${DIM}▸ Scanning code structure...${RESET}\n"
sleep 0.3
printf "${DIM}▸ Comparing declared vs actual${RESET}\n"
sleep 0.4

echo ""

# Summary
printf "${MAGENTA}${BOLD}SUMMARY${RESET}\n"
printf "  Declared modules: ${BOLD}5${RESET} | Actual: ${BOLD}7${RESET} ${YELLOW}(+2 undocumented)${RESET}\n"
printf "  Alignment: ${YELLOW}${BOLD}72%%${RESET}\n"
sleep 0.3

echo ""

# Drift items
printf "${MAGENTA}${BOLD}DRIFT ITEMS${RESET}\n"

# Critical
printf "  ${RED}${BOLD}[CRITICAL]${RESET} Auth imports Billing directly ${RED}(boundary violation)${RESET}\n"
printf "    ${DIM}Documented: Auth → User → Billing${RESET}\n"
printf "    ${RED}Actual: Auth → Billing${RESET} ${DIM}(src/auth/verify.ts:14)${RESET}\n"
sleep 0.3

echo ""

# Warning 1
printf "  ${YELLOW}${BOLD}[WARNING]${RESET} Utils grew to ${BOLD}2,400 lines${RESET} ${YELLOW}(responsibility drift)${RESET}\n"
printf "    ${DIM}Documented: \"Shared utility functions\"${RESET}\n"
printf "    ${YELLOW}Actual: 47 functions — logging + validation + formatting${RESET}\n"
sleep 0.3

echo ""

# Warning 2
printf "  ${YELLOW}${BOLD}[WARNING]${RESET} REST → tRPC migration not documented ${YELLOW}(technology drift)${RESET}\n"
sleep 0.2

echo ""

# Info
printf "  ${CYAN}${BOLD}[INFO]${RESET} services/ renamed to modules/ ${CYAN}(naming drift)${RESET}\n"
sleep 0.3

echo ""

# Footer summary
printf "  ${RED}${BOLD}1 critical${RESET} · ${YELLOW}${BOLD}2 warnings${RESET} · ${CYAN}${BOLD}1 info${RESET}\n"
printf "  ${DIM}Run /review-arch for full report${RESET}\n"
echo ""

sleep 1
