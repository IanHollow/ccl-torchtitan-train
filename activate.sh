source /pscratch/sd/g/gb555/final_proj/ccl-torchtitan-train/perlmutter/activate.sh
sbatch perlmutter/run_llama3_8b_tp.sbatch
ccl-metrics --trace <trace_dir> --metric <metric_name>