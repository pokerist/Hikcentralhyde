#!/bin/bash

# Pre-deployment check script
# Run this before deploy.sh to verify everything is ready

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Pre-Deployment Check${NC}"
echo -e "${BLUE}========================================${NC}\n"

ERRORS=0
WARNINGS=0

# Check required files
echo -e "${BLUE}Checking required files...${NC}"

FILES=(
    "deploy.sh"
    "update.sh"
    "main.py"
    "config.py"
    "database.py"
    "requirements.txt"
    ".env.example"
    "api/supabase_api.py"
    "api/hikcentral_api.py"
    "dashboard/app.py"
    "processors/event_processor.py"
    "processors/image_processor.py"
    "utils/logger.py"
    "utils/sanitizer.py"
)

for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓${NC} $file"
    else
        echo -e "${RED}✗${NC} $file ${RED}MISSING${NC}"
        ERRORS=$((ERRORS + 1))
    fi
done

echo ""

# Check .env.example content
echo -e "${BLUE}Checking .env.example content...${NC}"

if [ -f ".env.example" ]; then
    REQUIRED_VARS=(
        "SUPABASE_URL"
        "SUPABASE_BEARER_TOKEN"
        "SUPABASE_API_KEY"
        "HIKCENTRAL_BASE_URL"
        "HIKCENTRAL_APP_KEY"
        "HIKCENTRAL_APP_SECRET"
        "DASHBOARD_PASSWORD"
    )
    
    for var in "${REQUIRED_VARS[@]}"; do
        if grep -q "^$var=" .env.example; then
            VALUE=$(grep "^$var=" .env.example | cut -d'=' -f2-)
            if [ "$var" = "DASHBOARD_PASSWORD" ] && [ "$VALUE" = "change_this_password_immediately" ]; then
                echo -e "${GREEN}✓${NC} $var (needs to be changed after deploy)"
            elif [ -n "$VALUE" ]; then
                echo -e "${GREEN}✓${NC} $var"
            else
                echo -e "${YELLOW}⚠${NC} $var is empty"
                WARNINGS=$((WARNINGS + 1))
            fi
        else
            echo -e "${RED}✗${NC} $var ${RED}MISSING${NC}"
            ERRORS=$((ERRORS + 1))
        fi
    done
else
    echo -e "${RED}✗ .env.example file missing${NC}"
    ERRORS=$((ERRORS + 1))
fi

echo ""

# Check Python files syntax
echo -e "${BLUE}Checking Python syntax...${NC}"

PYTHON_FILES=$(find . -name "*.py" -not -path "./venv/*" -not -path "./.git/*")
SYNTAX_ERRORS=0

for pyfile in $PYTHON_FILES; do
    if python3 -m py_compile "$pyfile" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} $pyfile"
    else
        echo -e "${RED}✗${NC} $pyfile ${RED}SYNTAX ERROR${NC}"
        SYNTAX_ERRORS=$((SYNTAX_ERRORS + 1))
    fi
done

if [ $SYNTAX_ERRORS -gt 0 ]; then
    ERRORS=$((ERRORS + SYNTAX_ERRORS))
fi

echo ""

# Check script permissions
echo -e "${BLUE}Checking script permissions...${NC}"

SCRIPTS=(
    "deploy.sh"
    "update.sh"
    "install_requirements.sh"
    "fix_installation.sh"
    "verify_setup.sh"
)

for script in "${SCRIPTS[@]}"; do
    if [ -f "$script" ]; then
        if [ -x "$script" ]; then
            echo -e "${GREEN}✓${NC} $script is executable"
        else
            echo -e "${YELLOW}⚠${NC} $script not executable (will be fixed by deploy.sh)"
            WARNINGS=$((WARNINGS + 1))
        fi
    fi
done

echo ""

# Summary
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Summary${NC}"
echo -e "${BLUE}========================================${NC}"

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓ All checks passed!${NC}"
    if [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}⚠ $WARNINGS warnings (non-critical)${NC}"
    fi
    echo ""
    echo -e "${GREEN}You can proceed with deployment:${NC}"
    echo -e "  ${YELLOW}bash deploy.sh${NC}"
    exit 0
else
    echo -e "${RED}✗ $ERRORS errors found${NC}"
    if [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}⚠ $WARNINGS warnings${NC}"
    fi
    echo ""
    echo -e "${RED}Please fix errors before deployment${NC}"
    exit 1
fi
