#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 2 ] || [ "$1" != "-n" ]; then
    echo "Usage: $0 -n <number_of_processes>"
    exit 1
fi

number_of_processes="$2"

# Validate the number of processes
if [[ ! "$number_of_processes" =~ ^[0-9]+$ ]] || [ "$number_of_processes" -le 0 ]; then
    echo "Error: Invalid number of processes"
    exit 1
fi

output_file="input_file.csv"

# Remove the output file if it already exists
if [ -f "$output_file" ]; then
    rm "$output_file"
fi

# Generate process names, arrival times, and burst times
for i in $(seq 1 "$number_of_processes"); do
    # Use the specified convention for process names
    process_name="P$i"

    # Generate a random arrival time (between 0 and 100)
    arrival_time=$((RANDOM % number_of_processes))

    # Generate a random burst time (between 1 and 50)
    burst_time=$((RANDOM % number_of_processes + 1))

    echo "$process_name,$arrival_time,$burst_time" >> "$output_file"
done

echo "Input file '$output_file' generated with $number_of_processes processes."
