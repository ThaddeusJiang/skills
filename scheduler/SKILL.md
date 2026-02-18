# Scheduler Skill

Execute commands after a delay or at a scheduled time.

## Capability

This skill provides time-based command execution:
- Delay execution by N seconds/minutes/hours
- Schedule commands to run at specific times
- Run commands in background (survives shell exit)

## When to Use

- User wants to delay a command execution
- Need to schedule tasks for later
- Building higher-level reminder/notification skills

---

## Basic Delayed Execution

### Delay in seconds

```bash
nohup sh -c 'sleep $SECONDS && YOUR_COMMAND' > /tmp/scheduler_$$.log 2>&1 &
echo $!
```

### Delay in minutes

```bash
nohup sh -c 'sleep $((MINUTES * 60)) && YOUR_COMMAND' > /tmp/scheduler_$$.log 2>&1 &
echo $!
```

### Delay in hours

```bash
nohup sh -c 'sleep $((HOURS * 3600)) && YOUR_COMMAND' > /tmp/scheduler_$$.log 2>&1 &
echo $!
```

---

## Examples

### 5 minutes delay

```bash
nohup sh -c 'sleep 300 && echo "Done" > /tmp/task_done.log' > /tmp/scheduler_$$.log 2>&1 &
echo "Scheduled task PID: $!"
```

### 1 hour delay

```bash
nohup sh -c 'sleep 3600 && /path/to/script.sh' > /tmp/scheduler_$$.log 2>&1 &
echo "Scheduled task PID: $!"
```

### Multiple commands

```bash
nohup sh -c 'sleep 300 && command1 && command2 && command3' > /tmp/scheduler_$$.log 2>&1 &
echo "Scheduled task PID: $!"
```

---

## Check Scheduled Tasks

```bash
# List all sleep-based scheduled tasks
ps aux | grep 'sleep' | grep -v grep

# Check specific task
ps -p $PID
```

---

## Cancel Scheduled Tasks

```bash
# Cancel specific task
kill $PID

# Cancel all scheduled tasks (use with caution)
pkill -f 'sleep'
```

---

## Execution Policy

1. **MUST use `nohup` + `&`** - Ensure process survives after shell exits
2. **MUST verify process started** - Check PID exists with `ps -p $PID`
3. **MUST report PID** - Tell user the process ID for cancellation
4. **MUST redirect output** - Log to `/tmp/scheduler_$$.log` for debugging

---

## Periodic Execution (Cron-style)

### Run every N seconds

```bash
# Run command every 60 seconds
nohup sh -c 'while true; do YOUR_COMMAND; sleep 60; done' > /tmp/scheduler_$$.log 2>&1 &
echo $!
```

### Run every N minutes

```bash
# Run command every 5 minutes
nohup sh -c 'while true; do YOUR_COMMAND; sleep 300; done' > /tmp/scheduler_$$.log 2>&1 &
echo $!
```

### Run every hour at specific minute

```bash
# Run at minute 30 of every hour
nohup sh -c 'while true; do NOW=$(date +%M); if [ "$NOW" = "30" ]; then YOUR_COMMAND; fi; sleep 60; done' > /tmp/scheduler_$$.log 2>&1 &
echo $!
```

### Run at specific times daily

```bash
# Run at 09:00 and 21:00 every day
nohup sh -c 'while true; do HOUR=$(date +%H); MIN=$(date +%M); if [ "$HOUR" = "09" ] && [ "$MIN" = "00" ]; then YOUR_COMMAND; elif [ "$HOUR" = "21" ] && [ "$MIN" = "00" ]; then YOUR_COMMAND; fi; sleep 60; done' > /tmp/scheduler_$$.log 2>&1 &
echo $!
```

### Run on specific days of week

```bash
# Run every Monday at 10:00 (1=Monday in date +%u)
nohup sh -c 'while true; do DOW=$(date +%u); HOUR=$(date +%H); MIN=$(date +%M); if [ "$DOW" = "1" ] && [ "$HOUR" = "10" ] && [ "$MIN" = "00" ]; then YOUR_COMMAND; fi; sleep 60; done' > /tmp/scheduler_$$.log 2>&1 &
echo $!
```

---

## Examples: Periodic Tasks

### Send Telegram message every hour

```bash
nohup sh -c 'while true; do curl -s -X POST "https://api.telegram.org/bot${EUE_TELEGRAM_TOKEN}/sendMessage" -d "chat_id=-1002246024089" -d "text=Hourly check-in"; sleep 3600; done' > /tmp/scheduler_hourly_$$.log 2>&1 &
echo "Hourly task PID: $!"
```

### Check system status every 5 minutes

```bash
nohup sh -c 'while true; do uptime >> /tmp/uptime.log; sleep 300; done' > /tmp/scheduler_uptime_$$.log 2>&1 &
echo "Uptime monitor PID: $!"
```

### Daily backup at 02:00

```bash
nohup sh -c 'while true; do HOUR=$(date +%H); MIN=$(date +%M); if [ "$HOUR" = "02" ] && [ "$MIN" = "00" ]; then /path/to/backup.sh; fi; sleep 60; done' > /tmp/scheduler_backup_$$.log 2>&1 &
echo "Daily backup PID: $!"
```

---

## List All Periodic Tasks

```bash
# Find all while-true sleep loops
ps aux | grep 'while true' | grep -v grep

# Alternative: find by script pattern
ps aux | grep 'sleep' | grep 'while' | grep -v grep
```

---

## Limitations

- Not persistent across reboots (use cron/launchd for that)
- If machine sleeps, tasks may be delayed
- No built-in retry mechanism
- Time is relative (delay), not absolute (wall clock)
- Periodic tasks run in shell, not system cron

---

## Advanced: At Specific Time

For wall-clock scheduling, calculate seconds until target time:

```bash
# Run at 22:30 today
TARGET_HOUR=22
TARGET_MIN=30
NOW=$(date +%s)
TARGET=$(date -j -f "%Y-%m-%d %H:%M" "$(date +%Y-%m-%d) ${TARGET_HOUR}:${TARGET_MIN}" +%s)
DELAY=$((TARGET - NOW))

if [ $DELAY -lt 0 ]; then
  echo "Time already passed today"
else
  nohup sh -c "sleep $DELAY && YOUR_COMMAND" > /tmp/scheduler_$$.log 2>&1 &
  echo "Scheduled for $(date -j -f "%s" $TARGET '+%Y-%m-%d %H:%M:%S'), PID: $!"
fi
```
