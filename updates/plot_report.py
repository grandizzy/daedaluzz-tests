#!/usr/bin/env python3
import json
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from collections import defaultdict
import os
import sys
import glob

def load_json_files_from_dir(directory):
    json_data = []
    pattern = os.path.join(directory, "*.json")
    for filename in glob.glob(pattern):
        try:
            with open(filename) as f:
                try:
                    data = json.load(f)
                    if isinstance(data, list):
                        json_data.extend(data)
                    else:
                        json_data.append(data)
                except json.JSONDecodeError:
                    with open(filename) as f2:
                        for line in f2:
                            line = line.strip()
                            if line:
                                json_data.append(json.loads(line))
        except Exception as e:
            print(f"Warning: Could not read {filename}: {e}")
    return json_data

def main():
    directory = sys.argv[1] if len(sys.argv) > 1 else "."

    print(f"Loading JSON files from directory: {directory}")
    json_data = load_json_files_from_dir(directory)

    violations_per_tool = defaultdict(int)

    for entry in json_data:
        tool = entry.get("tool", "unknown")
        try:
            violations = int(entry.get("violations", 0))
        except ValueError:
            violations = 0
        violations_per_tool[tool] += violations

    if not violations_per_tool:
        print("No data found to plot.")
        return

    plt.figure(figsize=(8, 4))
    tools = list(violations_per_tool.keys())
    violations_tool = [violations_per_tool[t] for t in tools]

    plt.bar(tools, violations_tool, color="skyblue")
    plt.title("Violations per Tool")
    plt.xlabel("Tool")
    plt.ylabel("Total Violations")
    plt.grid(axis="y", linestyle="--", alpha=0.7)
    plt.tight_layout()

    output_path = os.path.join(directory, "violations_per_tool.png")
    plt.savefig(output_path)
    plt.close()

    print(f"Plot saved as {output_path}")

if __name__ == "__main__":
    main()

