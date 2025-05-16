import pandas as pd
import matplotlib.pyplot as plt
import csv
import os

# ========== FPS PLOT ==========
if os.path.isfile("fps_log.csv"):
    frames = []
    fps_values = []

    with open("fps_log.csv", newline="") as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            frames.append(int(row["Frame"]))
            fps_values.append(float(row["FPS"]))

    plt.figure(figsize=(10, 4))
    plt.plot(frames, fps_values, marker='o', linestyle='-', color='blue')
    plt.title("FPS Over Time")
    plt.xlabel("Frame Number")
    plt.ylabel("Frames Per Second (FPS)")
    plt.grid(True)
    plt.tight_layout()
    plt.savefig("fps_plot.png")
    plt.close()
    print("[INFO] Saved fps_plot.png")

else:
    print("[WARNING] fps_log.csv not found. Skipping FPS plot.")

# ========== SYSTEM METRICS ==========
if os.path.isfile("data_Pi5.csv"):
    df = pd.read_csv("data_Pi5.csv", parse_dates=["Timestamp"])
    df["CPU Throttled"] = df["CPU Throttled"].astype(str).str.extract(r"(\d+)").astype(int)

    # Plot CPU Temperature
    plt.figure(figsize=(12, 4))
    for script in df["Script"].unique():
        df_sub = df[df["Script"] == script]
        plt.plot(df_sub["Timestamp"], df_sub["CPU Temperature (°C)"], label=script)
    plt.title("CPU Temperature Over Time")
    plt.ylabel("Temp (°C)")
    plt.xlabel("Timestamp")
    plt.legend()
    plt.xticks(rotation=45)
    plt.tight_layout()
    plt.savefig("cpu_temp_plot.png")
    plt.close()
    print("[INFO] Saved cpu_temp_plot.png")

    # Plot CPU Clock Speed
    plt.figure(figsize=(12, 4))
    for script in df["Script"].unique():
        df_sub = df[df["Script"] == script]
        plt.plot(df_sub["Timestamp"], df_sub["CPU Clock Speed (MHz)"], label=script)
    plt.title("CPU Clock Speed Over Time")
    plt.ylabel("MHz")
    plt.xlabel("Timestamp")
    plt.legend()
    plt.xticks(rotation=45)
    plt.tight_layout()
    plt.savefig("cpu_clock_plot.png")
    plt.close()
    print("[INFO] Saved cpu_clock_plot.png")

    # Plot CPU Throttled
    plt.figure(figsize=(12, 4))
    plt.plot(df["Timestamp"], df["CPU Throttled"], color='red', drawstyle='steps-post')
    plt.title("CPU Throttling Status Over Time")
    plt.ylabel("Throttled (Non-zero = Yes)")
    plt.xlabel("Timestamp")
    plt.xticks(rotation=45)
    plt.tight_layout()
    plt.savefig("cpu_throttled_plot.png")
    plt.close()
    print("[INFO] Saved cpu_throttled_plot.png")

else:
    print("[WARNING] data_Pi5.csv not found. Skipping system metrics plots.")
