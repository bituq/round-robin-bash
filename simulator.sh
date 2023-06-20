#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 2 ] || [ "$1" != "-file" ]; then
    echo "Usage: $0 -file <input_file>"
    exit 1
fi

input_file="$2"

# Check if the input file exists and is readable
if [ ! -r "$input_file" ]; then
    echo "Error: Cannot read input file '$input_file'"
    exit 1
fi

# Create a temporary file to store the ready queue
ready_queue=$(mktemp)
if [ $? -ne 0 ]; then
    echo "Error: Failed to create temporary file for ready queue"
    exit 1
fi

trap 'rm -f "$ready_queue"' EXIT

# Load the processes into the ready queue and validate the input file's content
process_id=0
while IFS=',' read -r process_name arrival_time burst_time || [[ -n "$process_name" ]]; do
    # Validate the input file's content (process name, arrival time, and burst time)
    if [[ ! "$process_name" =~ ^[A-Za-z0-9]+$ ]] || [[ ! "$arrival_time" =~ ^[0-9]+$ ]] || [[ ! "$burst_time" =~ ^[0-9]+$ ]]; then
        echo "Error: Invalid data in input file"
        exit 1
    fi
    # Define a unique process name to ensure duplicate processes are handled properly
    unique_process_name="${process_name}_${process_id}"
    echo "$unique_process_name,$arrival_time,$burst_time,$process_id" >> "$ready_queue" 
    process_id=$((process_id + 1))
done < "$input_file"

# Sort the ready queue based on arrival time and process ID
# This ensures that processes are executed in the order they arrive and maintain fairness
sort -t',' -k2,2n -k4,4n -o "$ready_queue" "$ready_queue"

current_time=0

# Run the scheduler until the ready queue is empty
while [ "$(wc -l < "$ready_queue")" -gt 0 ]; do
    # Check if any process has arrived
    arrived_process=$(awk -F',' -v time="$current_time" '$2 <= time { print; exit }' "$ready_queue")

    if [ -n "$arrived_process" ]; then
        unique_process_name=$(echo "$arrived_process" | cut -d',' -f1)
        arrival_time=$(echo "$arrived_process" | cut -d',' -f2)
        burst_time=$(echo "$arrived_process" | cut -d',' -f3)
        process_name=$(echo "$unique_process_name" | cut -d'_' -f1)

        # Execute the process for one quantum
        echo -e "$process_name is using the CPU"
        burst_time=$((burst_time - 1))

        # Update the ready queue
        grep -v "^$unique_process_name," "$ready_queue" > "${ready_queue}.tmp"
        mv "${ready_queue}.tmp" "$ready_queue"

        # If the process has not finished, add it back to the ready queue
        if [ "$burst_time" -gt 0 ]; then
            process_id=$((process_id + 1))
            echo "$unique_process_name,$((current_time + 1)),$burst_time,$process_id" >> "$ready_queue"
            sort -t',' -k2,2n -k4,4n -o "$ready_queue" "$ready_queue"
        else
            echo -e "Process $process_name terminated"
        fi
    else
        echo "idle"
    fi

    current_time=$((current_time + 1))
done
