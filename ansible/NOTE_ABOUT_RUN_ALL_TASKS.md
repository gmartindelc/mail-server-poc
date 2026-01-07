# Note about run_all_tasks.sh

## Current Status

**`run_all_tasks.sh`** is currently specific to **Task Group 1.2** only and does NOT need to be changed for Task 1.3.1.

## Why?

1. **Task Group 1.2** (`run_all_tasks.sh`):
   - Runs tasks 1.2.1 through 1.2.7 sequentially
   - All tasks use SSH port 22
   - No mid-task SSH configuration changes
   - Safe to run as a batch

2. **Task Group 1.3** is different:
   - Task 1.3.1 **CHANGES the SSH port** from 22 to 2288
   - Tasks 1.3.2+ require SSH port 2288
   - Cannot run all tasks in a single batch without port switching
   - Should be run individually

## How to Run Task Group 1.3

### Option 1: Run Tasks Individually (Recommended)

```bash
# Task 1.3.1 - System Hardening (changes SSH port)
./run_task.sh 1.3.1

# After Task 1.3.1, set the new SSH port
export ANSIBLE_SSH_PORT=2288

# Task 1.3.2 - WireGuard VPN Integration
./run_task.sh 1.3.2

# Task 1.3.3 - Network Interfaces
./run_task.sh 1.3.3

# Task 1.3.4 - SSH Dependency
./run_task.sh 1.3.4
```

### Option 2: Create Separate run_all_tasks_1.3.sh (Future Enhancement)

If you want a batch script for Task Group 1.3, we could create `run_all_tasks_1.3.sh` that:
1. Runs Task 1.3.1
2. Automatically exports `ANSIBLE_SSH_PORT=2288`
3. Runs remaining Task 1.3.x tasks

**But this is optional and not needed right now.**

## Summary

✅ **Keep `run_all_tasks.sh` as-is** - It's perfect for Task Group 1.2
✅ **Run Task 1.3.1 individually** - Use `./run_task.sh 1.3.1`
✅ **Set SSH port after 1.3.1** - Export `ANSIBLE_SSH_PORT=2288`
✅ **Run remaining Task 1.3.x individually** - Use `./run_task.sh 1.3.x`

## Future Consideration

If you want, after all Task Group 1.3 tasks are created, we can create:
- `run_all_tasks_1.3.sh` - Batch runner for all Task Group 1.3 tasks
- `run_all_tasks_1.4.sh` - Batch runner for all Task Group 1.4 tasks
- etc.

But for now, the individual task runner (`run_task.sh`) is sufficient and safer for Task Group 1.3 due to the SSH port change.
