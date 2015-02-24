#include "batm.h"

int main()
{
	char *state, *procent;
	int c,n,p;
	FILE *f, *s;

	while (1) {
		f = fopen(CAPFILE, "r");
		if (f == NULL) {
			sleep(60 * WAIT_INTERVAL);
			continue;
		}
		fscanf(f, "%d", &p);
		fclose(f);

		if (p < BMIN && !(p % 5)) {

			state = (char *) malloc(15);
			s = fopen(STFILE, "r");
			fscanf(s, "%s\n", state);
			fclose(s);

			/* do nothing when charging, else send a notification */
			if (strncmp(state, "Charging", 8)) {
				procent = (char *) malloc(5);
				sprintf(procent, "%d", p);
				procent = strcat(procent, "%");

				n = fork();
				if (n < 0) {
					perror("fork");
				} else if (n > 0 ) {
					if (p > 10)
						execlp("notify-send", "notify-send", "battery low", procent, NULL);
					else
						execlp("notify-send", "notify-send", "-u", "critical", "battery low", procent, NULL);
				} else {
					wait(NULL);
				}
				free(procent);
				sleep(3 * WAIT_INTERVAL);
			}
			free(state);
		}
		sleep(WAIT_INTERVAL);
	}

	return 0;
}
