#include <sys/stat.h>
#include <sys/types.h>
#include <sys/wait.h>

#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define BMIN 31
#define WAIT_INTERVAL 60

#define CAPFILE "/sys/class/power_supply/BAT0/capacity"
#define STFILE "/sys/class/power_supply/BAT0/status"
