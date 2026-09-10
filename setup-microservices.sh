#!/usr/bin/env bash
# =============================================================
# Digi Bank (Microservices) — Setup & Startup Script
# UCC 122-1 · Cloud Architecture · Lab 4
#
# This script automates the complete setup and startup of the
# Digi Bank Microservices architecture (Spring Boot 3.4,
# Spring Cloud 2024, Eureka, Config Server, API Gateway, Postgres).
#
# Usage:
#   ./setup-microservices.sh              — Interactive menu
#   ./setup-microservices.sh docker       — Build + start Docker Compose + test APIs (recommended)
#   ./setup-microservices.sh docker-down  — Stop containers and clean volumes
#   ./setup-microservices.sh build        — Maven build only (compile + package)
#   ./setup-microservices.sh test         — Run tests only (JUnit)
#   ./setup-microservices.sh endpoints    — Test all REST endpoints
#   ./setup-microservices.sh check        — Check host prerequisites
# =============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"
MICROSERVICES_DIR="$PROJECT_ROOT/digibank-microservices"
COMPOSE_FILE="$MICROSERVICES_DIR/docker-compose.yml"
ENV_FILE="$MICROSERVICES_DIR/.env"

# Auto-detect Maven executable
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

# Ports
GATEWAY_PORT="8080"
EUREKA_PORT="8761"
CONFIG_PORT="8888"

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
    print_header "Checking Prerequisites (Microservices)"
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

ensure_env_file() {
    if [ ! -f "$ENV_FILE" ]; then
        print_info "Creating default .env file in digibank-microservices..."
        cat << 'EOF' > "$ENV_FILE"
DB_USERNAME=digibank_user
DB_PASSWORD=digibank_pwd
EOF
        print_step ".env file created with default database credentials."
    fi
}

maven_build() {
    print_header "Building Maven Microservices Project"
    cd "$MICROSERVICES_DIR"
    print_info "Running: $MVN_CMD clean package -DskipTests"
    echo ""
    "$MVN_CMD" clean package -DskipTests 2>&1 | tail -35
    local status=${PIPESTATUS[0]}
    echo ""
    if [ $status -eq 0 ]; then
        print_step "Maven build completed successfully!"
    else
        print_error "Maven build failed! Check output above for errors."
        exit 1
    fi
    cd "$PROJECT_ROOT"
}

run_tests() {
    print_header "Running Microservice Unit Tests"
    cd "$MICROSERVICES_DIR"
    print_info "Running: $MVN_CMD test"
    echo ""
    "$MVN_CMD" test 2>&1 | tail -40
    local status=${PIPESTATUS[0]}
    echo ""
    if [ $status -eq 0 ]; then
        print_step "All microservices tests passed!"
    else
        print_error "Some tests failed! Check output above."
    fi
    cd "$PROJECT_ROOT"
    return $status
}

test_endpoints() {
    print_header "Testing REST Endpoints via API Gateway (Port 8080)"
    local base="http://localhost:${GATEWAY_PORT}/api"
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
        "{\"firstName\":\"Micro\",\"lastName\":\"User\",\"email\":\"micro.user${suffix}@digibank.com\"}"
    test_endpoint "GET" "$base/customers" "/api/customers (list)"
    test_endpoint "POST" "$base/accounts" "/api/accounts (create)" \
        "{\"accountNumber\":\"ACC-MICRO-${suffix}\",\"balance\":2500.00}"
    test_endpoint "GET" "$base/accounts" "/api/accounts (list)"
    test_endpoint "POST" "$base/transactions" "/api/transactions (create)" \
        '{"type":"DEPOSIT","amount":7500.00,"accountId":1}'
    test_endpoint "GET" "$base/transactions" "/api/transactions (list)"
    test_endpoint "GET" "$base/compliance/validate/5000" "/api/compliance/validate/5000"
    test_endpoint "GET" "$base/compliance/validate/25000" "/api/compliance/validate/25000"
    test_endpoint "GET" "$base/notifications" "/api/notifications (list)"

    echo ""
    echo -e "${BOLD}  Results: ${GREEN}$pass passed${NC}, ${RED}$fail failed${NC} out of $((pass + fail)) endpoints${NC}"
}

run_docker() {
    print_header "Running Digi Bank Microservices via Docker Compose"
    if ! command -v docker &> /dev/null; then
        print_error "Docker command not found. Please install Docker."
        exit 1
    fi

    ensure_env_file
    maven_build

    print_info "Starting Docker Compose services..."
    cd "$MICROSERVICES_DIR"
    docker compose down -v 2>/dev/null || true
    docker compose up --build -d

    print_info "Waiting for Microservices API Gateway to respond on http://localhost:${GATEWAY_PORT}/api/customers..."
    local max_wait=180
    local waited=0
    while [ $waited -lt $max_wait ]; do
        local code
        code=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:${GATEWAY_PORT}/api/customers" 2>/dev/null || echo "000")
        if [ "$code" = "200" ]; then
            echo ""
            print_step "Microservices system active and responsive!"
            print_info "Waiting for all services to register in Eureka..."
            local reg_wait=120
            local reg_elapsed=0
            while [ $reg_elapsed -lt $reg_wait ]; do
                local registered
                registered=$(curl -s "http://localhost:${EUREKA_PORT}/eureka/apps" 2>/dev/null | grep -oE '<name>[^<]+</name>' | grep -cE 'CUSTOMER|ACCOUNT|TRANSACTION|COMPLIANCE|NOTIFICATION' || true)
                if [ "$registered" -ge 5 ]; then
                    print_step "All 5 business services registered in Eureka."
                    break
                fi
                sleep 3
                reg_elapsed=$((reg_elapsed + 3))
            done
            print_info "Waiting for API Gateway to route to all services..."
            local gw_wait=120
            local gw_elapsed=0
            while [ $gw_elapsed -lt $gw_wait ]; do
                local all_ok=1
                for route in customers accounts transactions compliance/validate/5000 notifications; do
                    local rc
                    rc=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:${GATEWAY_PORT}/api/$route" 2>/dev/null || echo "000")
                    if [ "$rc" != "200" ]; then
                        all_ok=0
                        break
                    fi
                done
                if [ "$all_ok" = "1" ]; then
                    print_step "All gateway routes responding with HTTP 200."
                    break
                fi
                sleep 3
                gw_elapsed=$((gw_elapsed + 3))
            done
            sleep 2
            test_endpoints
            print_header "Microservices Docker Setup Complete! 🎉"
            echo ""
            print_info "API Gateway:        http://localhost:${GATEWAY_PORT}"
            print_info "Eureka Discovery:   http://localhost:${EUREKA_PORT}"
            print_info "Config Server:      http://localhost:${CONFIG_PORT}"
            print_info "Customer Service:   http://localhost:8081"
            print_info "Account Service:    http://localhost:8082"
            print_info "Transaction Service:http://localhost:8083"
            print_info "Compliance Service: http://localhost:8084"
            print_info "Notification Service:http://localhost:8085"
            echo ""
            print_info "Stop Docker:        $0 docker-down"
            echo ""
            cd "$PROJECT_ROOT"
            return 0
        fi
        printf "."
        sleep 3
        waited=$((waited + 3))
    done

    echo ""
    print_error "Microservices did not fully initialize within ${max_wait}s."
    print_info "Displaying docker logs:"
    docker compose logs --tail 50
    cd "$PROJECT_ROOT"
    exit 1
}

stop_docker() {
    print_header "Stopping Docker Compose Microservices"
    cd "$MICROSERVICES_DIR"
    docker compose down -v
    print_step "Docker containers stopped and volumes removed."
    cd "$PROJECT_ROOT"
}

interactive_menu() {
    print_header "Interactive Control Center (Microservices)"
    echo -e "  Please choose an action to execute:"
    echo ""
    echo -e "  ${BOLD}${GREEN}1)${NC} Run via Docker Compose (Build JARs + Docker Compose + Test API) ${YELLOW}[Recommended]${NC}"
    echo -e "  ${BOLD}${GREEN}2)${NC} Stop Docker Compose (Clean Containers & Volumes)"
    echo -e "  ${BOLD}${GREEN}3)${NC} Run Maven Build & Tests only"
    echo -e "  ${BOLD}${GREEN}4)${NC} Verify REST endpoints via API Gateway"
    echo -e "  ${BOLD}${GREEN}5)${NC} Check host prerequisites (Java, Maven, Docker)"
    echo -e "  ${BOLD}${GREEN}6)${NC} Exit"
    echo ""
    local choice
    read -rp "  Enter choice (1-6): " choice
    echo ""
    case "$choice" in
        1) run_docker ;;
        2) stop_docker ;;
        3) maven_build && run_tests ;;
        4) test_endpoints ;;
        5) check_prerequisites ;;
        6) print_info "Exiting Control Center."; exit 0 ;;
        *) print_error "Invalid selection. Please choose 1 to 6."; echo ""; interactive_menu ;;
    esac
}

print_header "Digi Bank (Microservices) — Setup & Startup Script"
echo -e "  ${CYAN}UCC 122-1 · Cloud Architecture · Lab 4${NC}"
echo -e "  ${CYAN}Distributed Architecture · Spring Boot 3.4 · Spring Cloud · Docker${NC}"

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
            echo "  build        Maven package all microservices"
            echo "  test         Run JUnit tests across all microservices"
            echo "  endpoints    Test REST endpoints via API Gateway"
            echo "  docker       Build microservices and start via Docker Compose"
            echo "  docker-down  Stop Docker Compose services and clean volumes"
            echo ""
            exit 1
            ;;
    esac
fi
