set -ex


RUN_ID=${RUN_ID:-"trace_experiment"}
NGPU=${NGPU:-"4"}
export LOG_RANK=${LOG_RANK:-0}
CONFIG_FILE=${CONFIG_FILE:-"./config${RUN_ID}.toml"}
TRAIN_FILE=${TRAIN_FILE:-"torchtitan_train"}
COMM_MODE=${COMM_MODE:-""}
TORCHFT_LIGHTHOUSE=${TORCHFT_LIGHTHOUSE:-"http://localhost:29510"}

if [ -n "$COMM_MODE" ]; then
    # Communication mode specified: validate configuration or run in debug mode
    echo "Running with comm_mode=${COMM_MODE}"
    NGPU="${NGPU}" LOCAL_RANK=0 python3 -m "${TRAIN_FILE}" --job.config_file "${CONFIG_FILE}" "$@" --comm.mode=${COMM_MODE} --training.steps=1
else
    # Normal training with torchrun
    PYTORCH_ALLOC_CONF="expandable_segments:True" \
    TORCHFT_LIGHTHOUSE=${TORCHFT_LIGHTHOUSE} \
    torchrun --nproc_per_node=${NGPU} --rdzv_backend c10d --rdzv_endpoint="localhost:0" \
    --local-ranks-filter ${LOG_RANK} --role rank --tee 3 \
    -m ${TRAIN_FILE} --job.config_file ${CONFIG_FILE} "$@"
fi
