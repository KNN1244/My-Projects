#!/bin/bash
echo "ECE 4300 Python Script Benchmark"
output_file="collect_data_1.csv"
venv_path="/home/bug/python_projects/myproject1"  # <-- Update this path to your virtual environment
python_script="/home/bug/Desktop/Face_Recognition/facial_recognition.py"  # <-- Update this path to your Python script

# Header
echo "Timestamp,CPU Temperature (C),CPU Clock Speed (MHz),CPU Throttled" > "$output_file"

# Function to log a single data point
collect_data_point() {
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    cpu_temp=$(vcgencmd measure_temp | cut -d= -f2 | cut -d\' -f1)
    cpu_clock_speed=$(($(vcgencmd measure_clock arm | awk -F= '{print $2}') / 1000000))
    throttled_status=$(vcgencmd get_throttled)
    echo "$timestamp,$cpu_temp,$cpu_clock_speed,$throttled_status" >> "$output_file"
    echo "$timestamp - Temp: $cpu_temp°C, Clock: $cpu_clock_speed MHz, Throttled: $throttled_status"
}

# Function to collect data for N seconds
monitor_for_seconds() {
    local duration=$1
    for ((i = 0; i < duration; i++)); do
        collect_data_point
        sleep 1
    done
}

# --- PRE-SCRIPT MONITORING ---
echo "Monitoring before running Python script (5s)..."
monitor_for_seconds 5

# --- ACTIVATE VENV & START PYTHON SCRIPT IN BACKGROUND ---
echo "Running Python script with monitoring..."
source "$venv_path/bin/activate"
python "$python_script" &
script_pid=$!

# --- MONITOR WHILE SCRIPT IS RUNNING ---
while kill -0 "$script_pid" 2>/dev/null; do
    collect_data_point
    sleep 1
done

deactivate
echo "Python script finished."

# --- POST-SCRIPT MONITORING ---
echo "Monitoring after Python script (10s)..."
monitor_for_seconds 10

echo "Benchmark complete. Output saved to $output_file."
