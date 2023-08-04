#!/bin/bash

if [ "$#" -ne 2 ] || [ "$1" != "-file" ]; then
    echo "Usage: $0 -file <file>"
    exit 1
fi

file="$2"

if [ ! -r "$file" ]; then
    echo "Error: Cannot read input file '$file'"
    exit 1
fi

# Create a temp file for the ready queue
# This is done using mktemp which generates a unique temp file name and creates an empty file with that name.
# This is useful to make ensure that there are no conflicts in file names.
queue_temp=$(mktemp ./ready_queue.XXXXXX)
if [ $? -ne 0 ]; then
    echo "Error: Failed to create temporary file for ready queue"
    exit 1
fi

# This command ensures that the temp file is deleted when the scripts exits, even during an error.
# This makes sure that there are no temp files cluttered in the file system.
trap 'rm -f "$queue_temp"' EXIT

# Load processes into the ready queue and validate input file content
proc_id=0
while IFS=',' read -r proc_name arrival burst || [[ -n "$proc_name" ]]; do
    # Validate input file content (process name, arrival time, and burst time)
    if [[ ! "$proc_name" =~ ^[A-Za-z0-9]+$ ]] || [[ ! "$arrival" =~ ^[0-9]+$ ]] || [[ ! "$burst" =~ ^[0-9]+$ ]]; then
        echo "Error: Invalid data in input file"
        exit 1
    fi
    # Define a unique process name to handle duplicate processes properly
    unique_proc_name="${proc_name}_${proc_id}"
    echo "$unique_proc_name,$arrival,$burst,$proc_id" >> "$queue_temp" 
    proc_id=$((proc_id + 1))
done < "$file"

# Sort the ready queue based on arrival time and process ID
sort -t',' -k2,2n -k4,4n -o "$queue_temp" "$queue_temp"

current_time=0

# Run the scheduler until the ready queue is empty
# The wc -l command counts the lines, and the loop continues as long as there is at least one process in the queue.
while [ "$(wc -l < "$queue_temp")" -gt 0 ]; do
    # The awk command is used to check if any process has arrived by comparing the arrival time with the current time.
    arrived=$(awk -F',' -v time="$current_time" '$2 <= time { print; exit }' "$queue_temp")

    if [ -n "$arrived" ]; then
        # The cut command is used to extract the unique proc name, arrival, and burst time. The original process name is also extracted by removing the appended process ID.
        unique_proc_name=$(echo "$arrived" | cut -d',' -f1)
        arrival=$(echo "$arrived" | cut -d',' -f2)
        burst=$(echo "$arrived" | cut -d',' -f3)
        proc_name=$(echo "$unique_proc_name" | cut -d'_' -f1)

        # Execute the process for one quantum
        echo -e "$proc_name is using the CPU"
        burst=$((burst - 1))

        # grep -v is used to remove the executed process from the ready queue by excluding lines that start with the unique process name.
        # The updated queue is written to a temp file, which is then renamed to replace the original queue file.
        grep -v "^$unique_proc_name," "$queue_temp" > "${queue_temp}.tmp"
        mv "${queue_temp}.tmp" "$queue_temp"

        # If the process has not finished, add it back to the ready queue
        # The ready queue is then sorted again based on arrival and PID to maintain the correct order of processes.
        if [ "$burst" -gt 0 ]; then
            proc_id=$((proc_id + 1))
            echo "$unique_proc_name,$((current_time + 1)),$burst,$proc_id" >> "$queue_temp"
            sort -t',' -k2,2n -k4,4n -o "$queue_temp" "$queue_temp"
        else
            echo -e "Process $proc_name terminated"
        fi
    else
        echo "idle"
    fi

    current_time=$((current_time + 1))
done
