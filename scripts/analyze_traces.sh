#!/usr/bin/env bash
# Analyze workload traces and generate reports
# Usage: ./analyze_traces.sh <trace_base_dir> [output_dir] [workload_name] [--workload-card PATH]
#
# Examples:
#   ./analyze_traces.sh /pscratch/sd/i/imh39/ccl-bench-traces/llama3_8b_pp/torch_traces
#   ./analyze_traces.sh ./traces ./output "My Model PP"
#   ./analyze_traces.sh ./traces ./output "My Model" --workload-card train_configs/llama3_8b_tp.toml

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TOOLS_DIR="$PROJECT_ROOT/tools"

# Parse arguments - handle both positional and optional --workload-card
TRACE_BASE=""
OUTPUT_DIR=""
WORKLOAD_NAME=""
WORKLOAD_CARD=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --workload-card)
            WORKLOAD_CARD="$2"
            shift 2
            ;;
        *)
            if [ -z "$TRACE_BASE" ]; then
                TRACE_BASE="$1"
            elif [ -z "$OUTPUT_DIR" ]; then
                OUTPUT_DIR="$1"
            elif [ -z "$WORKLOAD_NAME" ]; then
                WORKLOAD_NAME="$1"
            else
                echo "Error: Too many arguments"
                exit 1
            fi
            shift
            ;;
    esac
done

if [ -z "$TRACE_BASE" ]; then
    echo "Usage: $0 <trace_base_dir> [output_dir] [workload_name] [--workload-card PATH]"
    echo ""
    echo "Arguments:"
    echo "  trace_base_dir  Directory containing iteration_* subdirectories"
    echo "  output_dir      Output directory (default: auto-generated in analysis_output/)"
    echo "  workload_name   Name for the workload (default: auto-detected)"
    echo "  --workload-card Path to workload card YAML or TOML config file (optional)"
    echo ""
    echo "Examples:"
    echo "  $0 /pscratch/sd/i/imh39/ccl-bench-traces/llama3_8b_pp/torch_traces"
    echo "  $0 ./traces ./output 'My Model PP'"
    echo "  $0 ./traces ./output 'My Model' --workload-card train_configs/llama3_8b_tp.toml"
    exit 1
fi

# Check trace directory exists
if [ ! -d "$TRACE_BASE" ]; then
    echo "Error: Trace directory not found: $TRACE_BASE"
    exit 1
fi

# Auto-generate output directory if not provided
if [ -z "$OUTPUT_DIR" ]; then
    # Extract workload name from path
    PARENT_DIR=$(basename "$(dirname "$TRACE_BASE")")
    OUTPUT_DIR="$PROJECT_ROOT/analysis_output/$PARENT_DIR"
fi

# Build command
CMD="python3 $TOOLS_DIR/analyze_workload.py --trace-base \"$TRACE_BASE\" --output \"$OUTPUT_DIR\""

if [ -n "$WORKLOAD_NAME" ]; then
    CMD="$CMD --name \"$WORKLOAD_NAME\""
fi

if [ -n "$WORKLOAD_CARD" ]; then
    # Convert to absolute path if relative
    if [[ "$WORKLOAD_CARD" != /* ]]; then
        if [ -f "$WORKLOAD_CARD" ]; then
            WORKLOAD_CARD="$(cd "$(dirname "$WORKLOAD_CARD")" && pwd)/$(basename "$WORKLOAD_CARD")"
        fi
    fi
    CMD="$CMD --workload-card \"$WORKLOAD_CARD\""
fi

echo "========================================"
echo "CCL-Bench Workload Analysis"
echo "========================================"
echo "Trace Base: $TRACE_BASE"
echo "Output Dir: $OUTPUT_DIR"
if [ -n "$WORKLOAD_CARD" ]; then
    echo "Workload Card: $WORKLOAD_CARD"
fi
echo ""

# Run analysis
eval $CMD

echo ""
echo "========================================"
echo "Analysis Complete!"
echo "========================================"
echo ""
echo "Generated files:"
ls -la "$OUTPUT_DIR"
echo ""
echo "To view the HTML report, open:"
echo "  $OUTPUT_DIR/report.html"
