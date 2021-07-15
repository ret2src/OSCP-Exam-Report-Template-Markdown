#!/usr/bin/env bash

# Convenience script for Docker-based report generation using 'noraj/OSCP-Exam-Report-Template-Markdown'.
#
# Credits:
#   - Initial script by @leonjza from the frida-boot workshop (https://github.com/leonjza/frida-boot)
#   - Adjusted and repurposed by @Tripex48 (https://github.com/Tripex48/OSCP-Exam-Report-Template-Markdown)
#   - Refactored and improved by @ret2src (https://github.com/ret2src/OSCP-Exam-Report-Template-Markdown)

# Default input and output directories on the host.
INPUT_DIR="${PWD}/src"
OUTPUT_DIR="${PWD}/output"

# Check if Docker is installed.
if ! hash docker 2>/dev/null; then
    echo "[-] Could not find the 'docker' command. Make sure you have Docker installed."
    exit 1
fi

# Print usage.
function usage() {
   cat << HEREDOC

   Usage: $0 action

   actions:
     build    build the Docker image locally
     run      run the Docker container
     shell    spawn a new bash shell in the already running Docker container

   optional arguments:
     -h, --help           show this help message and exit
     -i, --input PATH     defines an input directory for the Markdown files on the host
                          (Default: "${PWD}/src")
     -o, --output PATH    defines an output directory for the PDF and 7z files on the host
                          (Default: "${PWD}/output")

HEREDOC
}

# Build the Docker image locally.
function docker_build() {
    echo "[*] Building Docker image 'report-generator' locally ..."
    docker build -t report-generator .
}

# Run the Docker container.
function docker_run() {
    echo "[*] Running Docker container 'report-generator' ..."
    echo "[*] Input directory is set to: \"${INPUT_DIR}\"."
    echo "[*] Output directory is set to: \"${OUTPUT_DIR}\"."
    docker run --rm -it \
         --name report-generator \
         -v "${INPUT_DIR}:/root/report-generator/src" \
         -v "${OUTPUT_DIR}:/root/report-generator/output" \
         report-generator
}

# Spawn a shell in the already running Docker container.
function docker_shell() {
    docker exec -it report-generator /bin/bash
}

# Make sure the user has selected a valid action.
if ! [[ "$1" =~ ^(build|run|shell)$ ]]; then
    usage
    exit 1
fi

# Use `getopt` to parse command line arguments and store the output in $OPTS.
OPTS=$(getopt -o "h:i:o:" --long "help,input:,output:" -n "$0" -- "$@")
if [ $? != 0 ] ; then echo "[-] Error in command line arguments." >&2 ; usage; exit 1 ; fi
eval set -- "$OPTS"

# Interpret command line arguments.
while true; do
  case "$1" in
    -h | --help ) usage; exit; ;;
    -i | --input ) INPUT_DIR="$2"; shift 2 ;;
    -o | --output ) OUTPUT_DIR="$2"; shift 2 ;;
    -- ) case "$2" in
            build) docker_build ;;
            run) docker_run ;;
            shell) docker_shell ;;
         esac
        break ;;
    * ) break ;;
  esac
done

# Clean up: Unset variables.
unset INPUT_DIR
unset OUTPUT_DIR
