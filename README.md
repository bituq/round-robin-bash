# Round Robin Scheduling Bash Script

This repository hosts a Bash script that simulates Round Robin scheduling in an Operating System, which is a type of pre-emptive task scheduling method.

## What is Round Robin Scheduling?

Round Robin scheduling is one of the simplest scheduling algorithms for processes in an operating system, which assigns a fixed time slot to each process, called a quantum. Once a process is executed for a given time period, it is preempted and other processes are executed. 

The script receives a list of processes with their arrival times and burst times and employs the Round Robin scheduling algorithm to simulate the process execution. The process list should be provided in a CSV file specified in the command line following the -file option.

## Features:
- Generates process names automatically based on the number of processes.
- Arrival time and burst time for each process is randomly assigned.
- Creates a CSV file with the process details.

## Usage:

Clone the repository and mark the script as executable then run the script. The script requires a CSV file as input, containing processes information with process name, arrival time and burst time.

```
git clone https://github.com/bituq/round-robin-bash/

chmod +x simulator.sh

./simulator.sh -file processes.csv
```

To create an input CSV file with the desired number of processes, use the command below:
```
./generate_input.sh -n <number_of_processes>
```

### Example
**Input:**
```csv
P1,1,2
P2,2,1
P3,3,2
```

**Output:**
```text
P1 is using the CPU
P2 is using the CPU
Process P2 terminated
P3 is using the CPU
P1 is using the CPU
Process P1 terminated
P3 is using the CPU
Process P3 terminated
```

## Requirements:
- CSV file with columns `Process Name, Arrival Time, Burst Time`
- Script requires bash to run.

## License

This script is licensed under the [MIT License](LICENSE). Feel free to use it and modify it to suit your needs.
