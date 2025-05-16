#!/bin/bash
echo "ECE 4300 Multi-Script Benchmark"
output_file="data_Pi5.csv"
venv_path="faceVENV"

# List of Python scripts to run
python_scripts=(
	"Face_Recognition/image_capture_kwan.py"
	"Face_Recognition/image_capture_naing.py"
	"Face_Recognition/image_capture_pollak.py"
	"Face_Recognition/image_capture_tran.py"
    "Face_Recognition/model_training.py"
    "Face_Recognition/facial_recognition.py")


# Header
echo "Timestamp,Script,CPU Temperature (°C),CPU Clock Speed (MHz),CPU Throttled" > "$output_file"

# Function to collect a single data point
collect_data_point() {
    local current_script="$1"
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    cpu_temp=$(vcgencmd measure_temp | cut -d= -f2 | cut -d\' -f1)
    cpu_clock_speed=$(($(vcgencmd measure_clock arm | awk -F= '{print $2}') / 1000000))
    throttled_status=$(vcgencmd get_throttled)
    echo "$timestamp,$current_script,$cpu_temp,$cpu_clock_speed,$throttled_status" >> "$output_file"
    echo "$timestamp - [$current_script] Temp: $cpu_temp°C, Clock: $cpu_clock_speed MHz, Throttled: $throttled_status"
}

# Function to monitor for N seconds
monitor_for_seconds() {
    local duration=$1
    local current_script="$2"
    for ((i = 0; i < duration; i++)); do
        collect_data_point "$current_script"
        sleep 1
    done
}

# Activate virtual environment
source "$venv_path/bin/activate"

# Loop through each script
for script in "${python_scripts[@]}"; do
    script_name=$(basename "$script")

    echo ">>> Monitoring before $script_name (5s)..."
    monitor_for_seconds 5 "$script_name"

    echo ">>> Running $script_name with monitoring..."
    python "$script" &
    script_pid=$!
       
    while kill -0 "$script_pid" 2>/dev/null; do
        collect_data_point "$script_name"
        sleep 1
    done

done

    echo ">>> Monitoring after $script_name (30s)..."
    monitor_for_seconds 30 "$script_name"

# Deactivate environment
# ======================
# Run Combined Plot Script
# ======================
 echo "Generating all plots..."
 python plot_all_metrics.py

deactivate

echo "All scripts complete. Output saved to $output_file."
