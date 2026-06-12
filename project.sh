#!/bin/bash

RED=`tput setaf 1`
GREEN=`tput setaf 2`
BOLD=$(tput bold)
ORANGE=`tput setaf 3`
NC=`tput sgr0` # Reset color

set -e

# Track last executed command for error tracing
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
trap 'if [ $? -ne 0 ]; then echo "${RED}\"${last_command}\" command failed with exit code $?${NC}"; fi' EXIT

app_build_dir_name="build"

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
REPO_ROOT="$SCRIPT_DIR"

cd "$REPO_ROOT"


# Utility function to find all directories containing package.json, excluding node_modules and build directories
function find_js_apps() {
    local path='./liferay-workspace/client-extensions'
    if [ ! -d "$path" ]; then
        return
    fi
    find "$path" -type f -name "package.json" ! -path "*/node_modules/*" ! -path "*/$app_build_dir_name/*" -exec dirname {} \;
}

function find_apps() {
    local path='./liferay-workspace/client-extensions'
    if [ ! -d "$path" ]; then
        return
    fi
    find "$path" -type f -name "client-extension.yaml" -exec dirname {} \;
}

function manual() {
    echo "${BOLD}Available commands:${NC}"
    echo "  start   : Start the runtime stack (docker/services)."
    echo "  stop    : Stop the runtime stack."
    echo "  clean   : Remove generated artifacts (build, bundles, node_modules, dist, bin)."
    echo "  build   : Clean project, build JS client extensions, then run workspace build.sh."
    echo "  refresh : Run full preparation cycle (clean, build, deploy)."
    echo "  help    : Display this help message."
    echo ""
    echo "Usage: ./project.sh <command>"
}

function clean() {

    echo "${GREEN}Cleaning Liferay workspace ...${NC}"

    if [ -d "liferay-workspace/build" ]; then
        echo "Removing liferay-workspace/build ..."
        rm -rf "liferay-workspace/build"
    fi

    if [ -d "liferay-workspace/bundles" ]; then
        echo "Removing liferay-workspace/bundles ..."
        rm -rf "liferay-workspace/bundles"
    fi   

    echo "${GREEN}Done .${NC}"

    if [ -d "liferay-workspace/client-extensions" ]; then
        while read -r project_dir; do
            echo "${GREEN}Cleaning in: $project_dir${NC}"

            if [ -d "$project_dir/node_modules" ]; then
                echo "  Removing $project_dir/node_modules ..."
                rm -rf "$project_dir/node_modules"
            fi

            if [ -d "$project_dir/build" ]; then
                echo "  Removing $project_dir/build ..."
                rm -rf "$project_dir/build"
            fi

            if [ -d "$project_dir/bin" ]; then
                echo "  Removing $project_dir/bin ..."
                rm -rf "$project_dir/bin"
            fi

            if [ -d "$project_dir/dist" ]; then
                echo "  Removing $project_dir/dist ..."
                rm -rf "$project_dir/dist"
            fi
        done < <(find_apps)
    fi

    echo "${GREEN}Done .${NC}"

}

function build() {

    original_path=$(pwd)

    while read -r package_dir; do
        echo "${GREEN}Building in: $package_dir from ${PWD} ${NC}"
        (
            cd "$package_dir" || exit 1
            yarn install
            yarn build
        )
    done < <(find_js_apps)

    cd "$REPO_ROOT" || return 1
    
    if [ ! -d "liferay-workspace/scripts" ]; then
        echo "${RED}Error: liferay-workspace/scripts directory not found${NC}"
        return 1
    fi
    
    cd "liferay-workspace/scripts" || return 1

    echo "${GREEN}Executing build.sh from $(pwd) ...${NC}"
    ./build.sh
    echo "${GREEN}Done .${NC}"

}

function deploy() {

    cd "$REPO_ROOT" || return 1
    
    if [ ! -d "liferay-workspace/scripts" ]; then
        echo "${RED}Error: liferay-workspace/scripts directory not found${NC}"
        return 1
    fi
    
    cd "liferay-workspace/scripts" || return 1
    echo "${GREEN}Executing deploy.sh from $(pwd) ...${NC}"
    ./deploy.sh
    echo "${GREEN}Done .${NC}"

}

function start() {

    cd "$REPO_ROOT" || return 1
    
    if [ ! -d "runtime/scripts" ]; then
        echo "${RED}Error: runtime/scripts directory not found${NC}"
        return 1
    fi
    
    cd "runtime/scripts" || return 1
    echo "${GREEN}Executing start.sh from $(pwd) ...${NC}"
    ./start.sh
    echo "${GREEN}Done .${NC}"

}

function stop() {

    cd "$REPO_ROOT" || return 1
    
    if [ ! -d "runtime/scripts" ]; then
        echo "${RED}Error: runtime/scripts directory not found${NC}"
        return 1
    fi
    
    cd "runtime/scripts" || return 1
    echo "${GREEN}Executing stop.sh from $(pwd) ...${NC}"
    ./stop.sh
    echo "${GREEN}Done .${NC}"

}

function refresh() {
    
    echo "${GREEN}Executing refresh.sh from $(pwd) ...${NC}"
    clean "$@"
    build "$@"
    deploy "$@"
    echo "${GREEN}Done .${NC}"
}

if [ $# -eq 0 ]; then
    manual
    exit 0
fi

case "$1" in
    "start")
        start "$@"
        ;;
    "stop")
        stop "$@"
        ;;
    "build")
        build "$@"
        ;;
    "clean")
        clean "$@"
        ;;
    "refresh")
        refresh "$@"
        ;;
    "help")
        manual
        ;;
    *)
        echo "${RED}Unknown command: $1${NC}"
        manual
        ;;
esac







