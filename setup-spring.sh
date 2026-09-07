#!/usr/bin/env bash
# =============================================================
# Digi Bank (Spring Boot) — Full Setup & Startup Script
# UCC 122-1 · Cloud Architecture · Lab 3
#
# This script automates the complete setup and startup of the
# Digi Bank modular monolith built with Spring Boot, packaged
# as a WAR and deployed on WildFly via Docker Compose.
#
# Usage:
#   ./setup-spring.sh              — Interactive menu
#   ./setup-spring.sh docker       — Build + start DB/WildFly + test API (recommended)
#   ./setup-spring.sh docker-down  — Stop containers and clean volumes
#   ./setup-spring.sh build        — Maven build only (compile + test)
#   ./setup-spring.sh test         — Run tests only (JUnit + Cucumber)
#   ./setup-spring.sh endpoints    — Test all REST endpoints
#   ./setup-spring.sh check        — Check host prerequisites
# =============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"
PARENT_DIR="$PROJECT_ROOT/digibank-parent-spring"
COMPOSE_FILE="$PROJECT_ROOT/docker-compose.spring.yml"

MVN_CMD="mvn"
if ! command -v mvn &>/dev/null; then
    for candidate in \
        "$HOME/.m2/wrapper/dists/apache-maven-3.9.15/9925cc1d/bin/mvn" \
        "/usr/share/maven/bin/mvn"; do
        if [ -x "$candidate" ]; then
            MVN_CMD="$candidate"
            break
        fi
    done
fi

# Ports (Spring profile — distinct from Lab 2 to allow coexistence)
WILDFLY_HTTP_PORT="9091"
DB_PORT="5435"
ADMINER_PORT="8083"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

print_header() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${CYAN}  🏦 $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}
print_step() { echo -e "${GREEN}  ✓${NC} $1"; }
print_warn() { echo -e "${YELLOW}  ⚠${NC} $1"; }
print_error() { echo -e "${RED}  ✗${NC} $1"; }
print_info() { echo -e "${CYAN}  ℹ${NC} $1"; }

check_command() {
    if ! command -v "$1" &> /dev/null; then
        print_error "$1 is not installed or not in PATH"
        return 1
    fi
    print_step "$1 found: $(command -v "$1")"
    return 0
}

check_prerequisites() {
    print_header "Checking Prerequisites"
    local missing=0
    check_command java || missing=1
    if ! command -v "$MVN_CMD" &> /dev/null; then
        print_error "Maven (mvn) is not installed or not in PATH"
        missing=1
    else
        print_step "Maven found: $MVN_CMD"
    fi
    check_command docker || missing=1
    check_command git || missing=1

    if [ $missing -eq 1 ]; then
        print_error "Some core prerequisites are missing. Please install them first."
        exit 1
    fi
    local java_version
    java_version=$(java -version 2>&1 | head -1 | cut -d'"' -f2 | cut -d'.' -f1)
    if [ "$java_version" -lt 17 ] 2>/dev/null; then
        print_error "Java 17+ is required (found version $java_version)"
        exit 1
    fi
    print_step "Java version: $(java -version 2>&1 | head -1)"
    print_step "Maven version: $($MVN_CMD -version 2>&1 | head -1)"
    echo ""
    print_step "All prerequisites satisfied!"
}

maven_build() {
    print_header "Building Maven Project (Spring Boot)"
    cd "$PARENT_DIR"
    print_info "Running: $MVN_CMD clean install"
    echo ""
    "$MVN_CMD" clean install 2>&1 | tail -30
    local status=${PIPESTATUS[0]}
    echo ""
    if [ $status -eq 0 ]; then
        print_step "Maven build completed successfully!"
        if [ -f "digibank-app/target/digibank-app.war" ]; then
            local war_size
            war_size=$(du -h "digibank-app/target/digibank-app.war" | cut -f1)
            print_step "WAR file built: digibank-app/target/digibank-app.war ($war_size)"
        fi
    else
        print_error "Maven build failed! Check output above for errors."
        exit 1
    fi
    cd "$PROJECT_ROOT"
}

run_tests() {
    print_header "Running Tests (JUnit + Cucumber)"
    cd "$PARENT_DIR"
    print_info "Running: mvn test"
    echo ""
    mvn test 2>&1 | tail -40
    local status=${PIPESTATUS[0]}
    echo ""
    if [ $status -eq 0 ]; then
        print_step "All tests passed!"
    else
        print_error "Some tests failed! Check output above."
    fi
    cd "$PROJECT_ROOT"
    return $status
}

test_endpoints() {
    print_header "Testing REST Endpoints"
    local base="http://localhost:${WILDFLY_HTTP_PORT}/digibank-app/api"
    local pass=0
    local fail=0
    local suffix
    suffix=$(date +%s)

    test_endpoint() {
        local method=$1 url=$2 desc=$3 data=${4:-}
        local response http_code tmp
        tmp=$(mktemp)
        if [ "$method" = "GET" ]; then
            http_code=$(curl -s -o "$tmp" -w "%{http_code}" "$url" 2>/dev/null || echo "000")
        else
            http_code=$(curl -s -o "$tmp" -w "%{http_code}" -X POST "$url" \
                -H "Content-Type: application/json" -d "$data" 2>/dev/null || echo "000")
        fi
        response=$(cat "$tmp")
        rm -f "$tmp"
        if [[ "$http_code" =~ ^2 ]]; then
            print_step "$method $desc — HTTP $http_code"
            echo -e "       ${CYAN}Response:${NC} $(echo "$response" | head -c 200)"
            pass=$((pass + 1))
        else
            print_error "$method $desc — HTTP $http_code"
            echo -e "       ${RED}Response:${NC} $(echo "$response" | head -c 200)"
            fail=$((fail + 1))
        fi
    }

    test_endpoint "POST" "$base/customers" "/api/customers (create)" \
        "{\"firstName\":\"Ali\",\"lastName\":\"Diallo\",\"email\":\"ali.diallo${suffix}@digibank.com\"}"
    test_endpoint "GET" "$base/customers" "/api/customers (list)"
    test_endpoint "POST" "$base/accounts" "/api/accounts (create)" \
        "{\"accountNumber\":\"ACC-${suffix}\",\"balance\":1500.00}"
    test_endpoint "GET" "$base/accounts" "/api/accounts (list)"
    test_endpoint "POST" "$base/transactions" "/api/transactions (create)" \
        '{"type":"DEPOSIT","amount":5000.00}'
    test_endpoint "GET" "$base/transactions" "/api/transactions (list)"
    test_endpoint "GET" "$base/compliance/validate/5000" "/api/compliance/validate/5000"
    test_endpoint "GET" "$base/compliance/validate/25000" "/api/compliance/validate/25000"

    echo ""
    echo -e "${BOLD}  Results: ${GREEN}$pass passed${NC}, ${RED}$fail failed${NC} out of $((pass + fail)) endpoints${NC}"
}

run_docker() {
    print_header "Running Digi Bank (Spring Boot) via Docker Compose"
    if ! command -v docker &> /dev/null; then
        print_error "Docker command not found. Please install Docker."
        exit 1
    fi

    maven_build

    print_info "Starting services: db and wildfly..."
    docker compose -f "$COMPOSE_FILE" down -v 2>/dev/null || true
    docker compose -f "$COMPOSE_FILE" up --build -d

    print_info "Waiting for Spring Boot application deployment on http://localhost:${WILDFLY_HTTP_PORT}/digibank-app..."
    local max_wait=120
    local waited=0
    while [ $waited -lt $max_wait ]; do
        if curl -s -o /dev/null "http://localhost:${WILDFLY_HTTP_PORT}/digibank-app/api/customers" 2>/dev/null; then
            echo ""
            print_step "Application deployed and responsive!"
            sleep 2
            test_endpoints
            print_header "Docker Setup Complete! 🎉"
            echo ""
            print_info "Application:  http://localhost:${WILDFLY_HTTP_PORT}/digibank-app"
            print_info "REST API:     http://localhost:${WILDFLY_HTTP_PORT}/digibank-app/api/"
            print_info "Adminer DB:   http://localhost:${ADMINER_PORT}"
            echo -e "                 ${YELLOW}System:${NC} PostgreSQL | ${YELLOW}Server:${NC} db"
            echo -e "                 ${YELLOW}User:${NC} digibank_user | ${YELLOW}Password:${NC} digibank_pwd"
            echo -e "                 ${YELLOW}Database:${NC} digibank_db"
            print_info "Stop Docker:  $0 docker-down"
            echo ""
            return 0
        fi
        printf "."
        sleep 2
        waited=$((waited + 2))
    done

    echo ""
    print_error "Application did not deploy within ${max_wait}s."
    print_info "Displaying docker logs:"
    docker compose -f "$COMPOSE_FILE" logs
    exit 1
}

stop_docker() {
    print_header "Stopping Docker Compose Services (Spring)"
    docker compose -f "$COMPOSE_FILE" down -v
    print_step "Docker containers stopped and volumes removed."
}

interactive_menu() {
    print_header "Interactive Control Center (Spring Boot)"
    echo -e "  Please choose an action to execute:"
    echo ""
    echo -e "  ${BOLD}${GREEN}1)${NC} Run via Docker Compose (Build + Start DB/WildFly + Test API) ${YELLOW}[Recommended]${NC}"
    echo -e "  ${BOLD}${GREEN}2)${NC} Stop Docker Compose (Clean Containers & Volumes)"
    echo -e "  ${BOLD}${GREEN}3)${NC} Run Maven Build & Tests only (JUnit + Cucumber BDD)"
    echo -e "  ${BOLD}${GREEN}4)${NC} Verify REST endpoints (Via curl calls)"
    echo -e "  ${BOLD}${GREEN}5)${NC} Check host prerequisites (Java, Maven, Docker)"
    echo -e "  ${BOLD}${GREEN}6)${NC} Exit"
    echo ""
    local choice
    read -rp "  Enter choice (1-6): " choice
    echo ""
    case "$choice" in
        1) run_docker ;;
        2) stop_docker ;;
        3) run_tests ;;
        4) test_endpoints ;;
        5) check_prerequisites ;;
        6) print_info "Exiting Control Center."; exit 0 ;;
        *) print_error "Invalid selection. Please choose 1 to 6."; echo ""; interactive_menu ;;
    esac
}

print_header "Digi Bank (Spring Boot) — Setup & Startup Script"
echo -e "  ${CYAN}UCC 122-1 · Cloud Architecture · Lab 3${NC}"
echo -e "  ${CYAN}Modular Monolith · Spring Boot 3.5 · WildFly 33${NC}"

if [ $# -eq 0 ]; then
    interactive_menu
else
    case "$1" in
        check) check_prerequisites ;;
        build) maven_build ;;
        test) run_tests ;;
        endpoints) test_endpoints ;;
        docker) run_docker ;;
        docker-down) stop_docker ;;
        *)
            echo ""
            echo "Usage: $0 {check|build|test|endpoints|docker|docker-down}"
            echo ""
            echo "  check        Check prerequisites (Java, Maven, Docker)"
            echo "  build        Maven clean install (compile + test)"
            echo "  test         Run tests only (JUnit + Cucumber)"
            echo "  endpoints    Test all REST endpoints"
            echo "  docker       Build application and start via Docker Compose"
            echo "  docker-down  Stop Docker Compose services and clean volumes"
            echo ""
            exit 1
            ;;
    esac
fi
