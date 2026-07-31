#!/usr/bin/env bash
# =============================================================
# Digi Bank — Full Setup & Startup Script
# UCC 122-1 · Cloud Architecture · Lab 2
#
# This script automates the complete setup and startup of
# the Digi Bank modular monolith application.
#
# Usage:
#   ./setup.sh              — Run everything (setup + build + deploy)
#   ./setup.sh db           — Database setup only
#   ./setup.sh build        — Maven build only (compile + test)
#   ./setup.sh test         — Run tests only
#   ./setup.sh wildfly      — Download, configure & start WildFly
#   ./setup.sh deploy       — Deploy WAR to running WildFly
#   ./setup.sh endpoints    — Test all REST endpoints
#   ./setup.sh all          — Full setup (db + build + wildfly + deploy + test endpoints)
# =============================================================

set -euo pipefail

# ── Configuration ──────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"
PARENT_DIR="$PROJECT_ROOT/digibank-parent"

# Database
DB_NAME="digibank_db"
DB_USER="digibank_user"
DB_PASS="digibank_pwd"
DB_HOST="localhost"
DB_PORT="5434"

# WildFly
WILDFLY_VERSION="33.0.2.Final"
WILDFLY_DIR="$PROJECT_ROOT/wildfly-${WILDFLY_VERSION}"
WILDFLY_HOME="$WILDFLY_DIR"
WILDFLY_MGMT_PORT="9999"
WILDFLY_HTTP_PORT="9090"
WILDFLY_ADMIN_USER="admin"
WILDFLY_ADMIN_PASS="admin"

# PostgreSQL JDBC driver
PG_JDBC_VERSION="42.7.5"
PG_JDBC_JAR="postgresql-${PG_JDBC_VERSION}.jar"
PG_JDBC_URL="https://jdbc.postgresql.org/download/${PG_JDBC_JAR}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# ── Helper Functions ───────────────────────────────────────────

print_header() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${CYAN}  🏦 $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_step() {
    echo -e "${GREEN}  ✓${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}  ⚠${NC} $1"
}

print_error() {
    echo -e "${RED}  ✗${NC} $1"
}

print_info() {
    echo -e "${CYAN}  ℹ${NC} $1"
}

check_command() {
    if ! command -v "$1" &> /dev/null; then
        print_error "$1 is not installed or not in PATH"
        return 1
    fi
    print_step "$1 found: $(command -v "$1")"
    return 0
}

# ── Phase: Check Prerequisites ─────────────────────────────────

check_prerequisites() {
    print_header "Checking Prerequisites"

    local missing=0

    check_command java || missing=1
    check_command mvn || missing=1
    check_command psql || missing=1
    check_command git || missing=1

    if [ $missing -eq 1 ]; then
        print_error "Some prerequisites are missing. Please install them first."
        exit 1
    fi

    # Check Java version
    local java_version
    java_version=$(java -version 2>&1 | head -1 | cut -d'"' -f2 | cut -d'.' -f1)
    if [ "$java_version" -lt 17 ] 2>/dev/null; then
        print_error "Java 17+ is required (found version $java_version)"
        exit 1
    fi
    print_step "Java version: $(java -version 2>&1 | head -1)"
    print_step "Maven version: $(mvn -version 2>&1 | head -1)"

    echo ""
    print_step "All prerequisites satisfied!"
}

# ── Phase: Database Setup ──────────────────────────────────────

setup_database() {
    print_header "Setting Up PostgreSQL Database"

    if psql -U "$DB_USER" -d "$DB_NAME" -h "$DB_HOST" -p "$DB_PORT" -c "SELECT 1;" &>/dev/null; then
        print_step "Database '$DB_NAME' already exists and is accessible"
        return 0
    fi

    print_info "Running database initialization script..."

    if [ -f "$PROJECT_ROOT/db/init.sql" ]; then
        sudo -u postgres psql -f "$PROJECT_ROOT/db/init.sql" 2>&1 || {
            print_warn "Could not run as postgres user. Trying current user..."
            psql -f "$PROJECT_ROOT/db/init.sql" 2>&1 || {
                print_error "Database setup failed. Please run manually:"
                echo ""
                echo "    sudo -u postgres psql -f db/init.sql"
                echo ""
                echo "  Or create manually:"
                echo "    CREATE DATABASE $DB_NAME;"
                echo "    CREATE USER $DB_USER WITH PASSWORD '$DB_PASS';"
                echo "    GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;"
                return 1
            }
        }
    else
        print_error "db/init.sql not found!"
        return 1
    fi

    # Verify connection
    if psql -U "$DB_USER" -d "$DB_NAME" -h "$DB_HOST" -p "$DB_PORT" -c "SELECT 1;" &>/dev/null; then
        print_step "Database connection verified successfully"
    else
        print_warn "Could not verify database connection. You may need to configure pg_hba.conf"
    fi
}

# ── Phase: Maven Build ─────────────────────────────────────────

maven_build() {
    print_header "Building Maven Project"

    cd "$PARENT_DIR"

    print_info "Running: mvn clean install"
    echo ""

    mvn clean install 2>&1 | tail -30

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

# ── Phase: Run Tests ───────────────────────────────────────────

run_tests() {
    print_header "Running Tests"

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

# ── Phase: WildFly Setup ──────────────────────────────────────

setup_wildfly() {
    print_header "Setting Up WildFly ${WILDFLY_VERSION}"

    # Download WildFly if not present
    if [ ! -d "$WILDFLY_HOME" ]; then
        local wildfly_zip="wildfly-${WILDFLY_VERSION}.zip"
        local wildfly_url="https://github.com/wildfly/wildfly/releases/download/${WILDFLY_VERSION}/${wildfly_zip}"

        if [ ! -f "$PROJECT_ROOT/$wildfly_zip" ]; then
            print_info "Downloading WildFly ${WILDFLY_VERSION}..."
            curl -L -o "$PROJECT_ROOT/$wildfly_zip" "$wildfly_url" 2>&1
            print_step "Downloaded: $wildfly_zip"
        fi

        print_info "Extracting WildFly..."
        unzip -q "$PROJECT_ROOT/$wildfly_zip" -d "$PROJECT_ROOT"
        print_step "Extracted to: $WILDFLY_HOME"
    else
        print_step "WildFly already installed at: $WILDFLY_HOME"
    fi

    # Download PostgreSQL JDBC driver
    local pg_module_dir="$WILDFLY_HOME/modules/system/layers/base/org/postgresql/main"
    if [ ! -f "$pg_module_dir/$PG_JDBC_JAR" ]; then
        print_info "Setting up PostgreSQL JDBC driver module..."
        mkdir -p "$pg_module_dir"

        if [ ! -f "$PROJECT_ROOT/$PG_JDBC_JAR" ]; then
            print_info "Downloading PostgreSQL JDBC driver ${PG_JDBC_VERSION}..."
            curl -L -o "$PROJECT_ROOT/$PG_JDBC_JAR" "$PG_JDBC_URL" 2>&1
        fi

        cp "$PROJECT_ROOT/$PG_JDBC_JAR" "$pg_module_dir/"
        print_step "JDBC driver installed: $pg_module_dir/$PG_JDBC_JAR"

        # Create module.xml
        cat > "$pg_module_dir/module.xml" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<module xmlns="urn:jboss:module:1.5" name="org.postgresql">
    <resources>
        <resource-root path="${PG_JDBC_JAR}" />
    </resources>
    <dependencies>
        <module name="javax.api" />
        <module name="javax.transaction.api" />
    </dependencies>
</module>
EOF
        print_step "Created module.xml for PostgreSQL driver"
    else
        print_step "PostgreSQL JDBC driver already configured"
    fi

    # Configure datasource in standalone.xml
    local standalone_xml="$WILDFLY_HOME/standalone/configuration/standalone.xml"
    if ! grep -q "DigiBankDS" "$standalone_xml" 2>/dev/null; then
        print_info "Configuring datasource in standalone.xml..."

        # Add driver to drivers section
        sed -i '/<drivers>/a\
                        <driver name="postgresql" module="org.postgresql">\
                            <driver-class>org.postgresql.Driver</driver-class>\
                        </driver>' "$standalone_xml"

        # Add datasource after <datasources>
        sed -i '/<datasources>/a\
                    <datasource jndi-name="java:/jdbc/DigiBankDS" pool-name="DigiBankDS" enabled="true" use-java-context="true">\
                        <connection-url>jdbc:postgresql://'"$DB_HOST"':'"$DB_PORT"'/'"$DB_NAME"'</connection-url>\
                        <driver>postgresql</driver>\
                        <security user-name="'"$DB_USER"'" password="'"$DB_PASS"'"/>\
                    </datasource>' "$standalone_xml"

        print_step "Datasource 'java:/jdbc/DigiBankDS' configured"
    else
        print_step "Datasource already configured in standalone.xml"
    fi

    # Create admin user
    if [ ! -f "$WILDFLY_HOME/.admin_created" ]; then
        print_info "Creating WildFly management user..."
        "$WILDFLY_HOME/bin/add-user.sh" \
            -u "$WILDFLY_ADMIN_USER" \
            -p "$WILDFLY_ADMIN_PASS" \
            --silent 2>&1 || true
        touch "$WILDFLY_HOME/.admin_created"
        print_step "Admin user created (admin/admin)"
    else
        print_step "Admin user already exists"
    fi

    print_step "WildFly setup complete!"
}

# ── Phase: Start WildFly ───────────────────────────────────────

start_wildfly() {
    print_header "Starting WildFly"

    # Check if already running
    if curl -s -o /dev/null -w "%{http_code}" "http://localhost:${WILDFLY_HTTP_PORT}" 2>/dev/null | grep -q "200\|302"; then
        print_step "WildFly is already running on port ${WILDFLY_HTTP_PORT}"
        return 0
    fi

    if [ ! -d "$WILDFLY_HOME" ]; then
        print_error "WildFly not found at $WILDFLY_HOME. Run './setup.sh wildfly' first."
        return 1
    fi

    print_info "Starting WildFly in the background..."
    chmod +x "$WILDFLY_HOME/bin/standalone.sh"
    nohup "$WILDFLY_HOME/bin/standalone.sh" -b 0.0.0.0 > "$PROJECT_ROOT/wildfly.log" 2>&1 &
    local wf_pid=$!
    echo "$wf_pid" > "$PROJECT_ROOT/wildfly.pid"

    print_info "WildFly PID: $wf_pid (log: wildfly.log)"

    # Wait for WildFly to start
    print_info "Waiting for WildFly to start..."
    local max_wait=120
    local waited=0
    while [ $waited -lt $max_wait ]; do
        if curl -s -o /dev/null "http://localhost:${WILDFLY_HTTP_PORT}" 2>/dev/null; then
            echo ""
            print_step "WildFly started successfully on port ${WILDFLY_HTTP_PORT}!"
            return 0
        fi
        printf "."
        sleep 2
        waited=$((waited + 2))
    done

    echo ""
    print_error "WildFly did not start within ${max_wait}s. Check wildfly.log"
    return 1
}

# ── Phase: Stop WildFly ────────────────────────────────────────

stop_wildfly() {
    print_header "Stopping WildFly"

    if [ -f "$PROJECT_ROOT/wildfly.pid" ]; then
        local pid
        pid=$(cat "$PROJECT_ROOT/wildfly.pid")
        if kill -0 "$pid" 2>/dev/null; then
            kill "$pid"
            print_step "WildFly stopped (PID: $pid)"
        else
            print_info "WildFly process not running"
        fi
        rm -f "$PROJECT_ROOT/wildfly.pid"
    else
        # Try to find and kill WildFly process
        local pid
        pid=$(pgrep -f "wildfly.*standalone" 2>/dev/null || true)
        if [ -n "$pid" ]; then
            kill "$pid"
            print_step "WildFly stopped (PID: $pid)"
        else
            print_info "No WildFly process found"
        fi
    fi
}

# ── Phase: Deploy ──────────────────────────────────────────────

deploy_app() {
    print_header "Deploying Application"

    local war_file="$PARENT_DIR/digibank-app/target/digibank-app.war"

    if [ ! -f "$war_file" ]; then
        print_error "WAR file not found. Run build first."
        print_info "Running build..."
        maven_build
    fi

    # Try Maven deploy first
    cd "$PARENT_DIR"
    print_info "Deploying via wildfly-maven-plugin..."

    mvn wildfly:deploy -pl digibank-app 2>&1 | tail -10

    local status=${PIPESTATUS[0]}
    if [ $status -eq 0 ]; then
        print_step "Application deployed successfully!"
    else
        # Fallback: copy WAR directly
        print_warn "Maven deploy failed. Trying manual deployment..."
        if [ -d "$WILDFLY_HOME/standalone/deployments" ]; then
            cp "$war_file" "$WILDFLY_HOME/standalone/deployments/"
            print_step "WAR copied to WildFly deployments directory"
        else
            print_error "Could not deploy. Is WildFly running?"
        fi
    fi

    cd "$PROJECT_ROOT"

    echo ""
    print_info "Application URL: http://localhost:${WILDFLY_HTTP_PORT}/digibank-app"
    print_info "REST API Base:   http://localhost:${WILDFLY_HTTP_PORT}/digibank-app/api/"
}

# ── Phase: Test Endpoints ──────────────────────────────────────

test_endpoints() {
    print_header "Testing REST Endpoints"

    local base="http://localhost:${WILDFLY_HTTP_PORT}/digibank-app/api"
    local pass=0
    local fail=0

    test_endpoint() {
        local method=$1
        local url=$2
        local desc=$3
        local data=${4:-}

        local response
        local http_code

        if [ "$method" = "GET" ]; then
            http_code=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null || echo "000")
            response=$(curl -s "$url" 2>/dev/null || echo "Connection refused")
        else
            http_code=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$url" \
                -H "Content-Type: application/json" -d "$data" 2>/dev/null || echo "000")
            response=$(curl -s -X POST "$url" -H "Content-Type: application/json" -d "$data" 2>/dev/null || echo "Connection refused")
        fi

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

    # POST - Create a customer
    test_endpoint "POST" "$base/customers" "/api/customers (create)" \
        '{"firstName":"Ali","lastName":"Diallo","email":"ali.diallo@digibank.com"}'

    # GET - List customers
    test_endpoint "GET" "$base/customers" "/api/customers (list)"

    # POST - Create an account
    test_endpoint "POST" "$base/accounts" "/api/accounts (create)" \
        '{"accountNumber":"ACC-001","balance":1500.00}'

    # GET - List accounts
    test_endpoint "GET" "$base/accounts" "/api/accounts (list)"

    # POST - Create a transaction
    test_endpoint "POST" "$base/transactions" "/api/transactions (create)" \
        '{"type":"DEPOSIT","amount":5000.00}'

    # GET - List transactions
    test_endpoint "GET" "$base/transactions" "/api/transactions (list)"

    # GET - Compliance: valid amount
    test_endpoint "GET" "$base/compliance/validate/5000" "/api/compliance/validate/5000"

    # GET - Compliance: invalid amount
    test_endpoint "GET" "$base/compliance/validate/25000" "/api/compliance/validate/25000"

    echo ""
    echo -e "${BOLD}  Results: ${GREEN}$pass passed${NC}, ${RED}$fail failed${NC} out of $((pass + fail)) endpoints${NC}"
}

# ── Phase: Full Setup (all-in-one) ─────────────────────────────

run_all() {
    check_prerequisites
    setup_database
    maven_build
    setup_wildfly
    start_wildfly
    deploy_app
    test_endpoints

    print_header "Setup Complete! 🎉"
    echo ""
    print_info "Application:  http://localhost:${WILDFLY_HTTP_PORT}/digibank-app"
    print_info "REST API:     http://localhost:${WILDFLY_HTTP_PORT}/digibank-app/api/"
    print_info "WildFly log:  $PROJECT_ROOT/wildfly.log"
    print_info "Stop WildFly: ./setup.sh stop"
    echo ""
}

# ── Phase: Docker Compose Setup ────────────────────────────────

run_docker() {
    print_header "Running Digi Bank via Docker Compose"
    
    # Check if docker is installed
    if ! command -v docker &> /dev/null; then
        print_error "Docker command not found. Please install Docker."
        exit 1
    fi
    
    # 1. Build host Maven package
    maven_build
    
    # 1.5 Download PostgreSQL JDBC driver on host if not present
    if [ ! -f "$PROJECT_ROOT/$PG_JDBC_JAR" ]; then
        print_info "Downloading PostgreSQL JDBC driver ${PG_JDBC_VERSION} on host..."
        curl -L -o "$PROJECT_ROOT/$PG_JDBC_JAR" "$PG_JDBC_URL" 2>&1
        print_step "Downloaded: $PG_JDBC_JAR"
    fi
    
    # 2. Start compose
    print_info "Starting services: db and wildfly..."
    docker compose down -v 2>/dev/null || true
    docker compose up --build -d
    
    # 3. Wait for app deployment
    print_info "Waiting for JAX-RS application deployment on http://localhost:${WILDFLY_HTTP_PORT}/digibank-app..."
    local max_wait=90
    local waited=0
    while [ $waited -lt $max_wait ]; do
        if curl -s -o /dev/null "http://localhost:${WILDFLY_HTTP_PORT}/digibank-app/api/index" 2>/dev/null; then
            echo ""
            print_step "Application deployed and responsive!"
            sleep 2
            test_endpoints
            print_header "Docker Setup Complete! 🎉"
            echo ""
            print_info "Application:  http://localhost:${WILDFLY_HTTP_PORT}/digibank-app"
            print_info "REST API:     http://localhost:${WILDFLY_HTTP_PORT}/digibank-app/api/"
            print_info "Swagger UI:   http://localhost:${WILDFLY_HTTP_PORT}/digibank-app/swagger.html"
            print_info "Adminer DB:   http://localhost:8082"
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
    docker compose logs
    exit 1
}

stop_docker() {
    print_header "Stopping Docker Compose Services"
    docker compose down -v
    print_step "Docker containers stopped and volumes removed."
}

# ── Phase: Interactive Menu ────────────────────────────────────

interactive_menu() {
    print_header "Interactive Control Center"
    echo -e "  Please choose an action to execute:"
    echo ""
    echo -e "  ${BOLD}${GREEN}1)${NC} Run via Docker Compose (Build + Start DB/WildFly + Test API) ${YELLOW}[Recommended]${NC}"
    echo -e "  ${BOLD}${GREEN}2)${NC} Stop Docker Compose (Clean Containers & Volumes)"
    echo -e "  ${BOLD}${GREEN}3)${NC} Run locally (Local PostgreSQL + Local WildFly + Build + Test API)"
    echo -e "  ${BOLD}${GREEN}4)${NC} Run Maven Build & Tests only (JUnit + Cucumber BDD)"
    echo -e "  ${BOLD}${GREEN}5)${NC} Verify JAX-RS REST endpoints (Via curl calls)"
    echo -e "  ${BOLD}${GREEN}6)${NC} Start local WildFly instance (Background)"
    echo -e "  ${BOLD}${GREEN}7)${NC} Stop local WildFly instance"
    echo -e "  ${BOLD}${GREEN}8)${NC} Check host prerequisites (Java, Maven, Postgres, Docker)"
    echo -e "  ${BOLD}${GREEN}9)${NC} Exit"
    echo ""
    
    local choice
    read -rp "  Enter choice (1-9): " choice
    echo ""
    
    case "$choice" in
        1) run_docker ;;
        2) stop_docker ;;
        3) run_all ;;
        4) run_tests ;;
        5) test_endpoints ;;
        6) start_wildfly ;;
        7) stop_wildfly ;;
        8) check_prerequisites ;;
        9) print_info "Exiting Control Center."; exit 0 ;;
        *) print_error "Invalid selection. Please choose 1 to 9."; echo ""; interactive_menu ;;
    esac
}

# ── Main ───────────────────────────────────────────────────────

print_header "Digi Bank — Setup & Startup Script"
echo -e "  ${CYAN}UCC 122-1 · Cloud Architecture · Lab 2${NC}"
echo -e "  ${CYAN}Modular Monolith · Jakarta EE 10 · WildFly 33${NC}"

if [ $# -eq 0 ]; then
    interactive_menu
else
    case "$1" in
        check)
            check_prerequisites
            ;;
        db|database)
            check_prerequisites
            setup_database
            ;;
        build)
            maven_build
            ;;
        test)
            run_tests
            ;;
        wildfly)
            setup_wildfly
            ;;
        start)
            start_wildfly
            ;;
        stop)
            stop_wildfly
            ;;
        deploy)
            deploy_app
            ;;
        endpoints)
            test_endpoints
            ;;
        docker)
            run_docker
            ;;
        docker-down)
            stop_docker
            ;;
        all)
            run_all
            ;;
        *)
            echo ""
            echo "Usage: $0 {check|db|build|test|wildfly|start|stop|deploy|endpoints|docker|docker-down|all}"
            echo ""
            echo "  check        Check prerequisites (Java, Maven, PostgreSQL, Git)"
            echo "  db           Setup PostgreSQL database"
            echo "  build        Maven clean install (compile + test)"
            echo "  test         Run tests only (JUnit + Cucumber)"
            echo "  wildfly      Download, configure & setup WildFly"
            echo "  start        Start WildFly server"
            echo "  stop         Stop WildFly server"
            echo "  deploy       Deploy WAR to WildFly"
            echo "  endpoints    Test all REST endpoints"
            echo "  docker       Build application and start via Docker Compose"
            echo "  docker-down  Stop Docker Compose services and clean volumes"
            echo "  all          Full setup locally: db → build → wildfly → deploy → test"
            echo ""
            exit 1
            ;;
    esac
fi
