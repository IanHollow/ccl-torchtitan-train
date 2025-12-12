source /pscratch/sd/g/gb555/final_proj/ccl-torchtitan-train/perlmutter/activate.sh

sbatch perlmutter/run_llama3_8b_fsdp.sbatch

./scripts/analyze_traces.sh /pscratch/sd/g/gb555/ccl-bench-traces/llama3_8b_fsdp/torch_traces --workload-card /pscratch/sd/g/gb555/final_proj/ccl-torchtitan-train/train_configs/llama3_8b_fsdp.toml