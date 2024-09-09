#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/time.h>

#include <errno.h>
#include <string.h>

int main(int argc, char *argv[])
{
	struct input_event_struct {
		struct timeval time;
		unsigned short type;
		unsigned short code;
		unsigned int value;
	} input_event;

	size_t input_event_size = sizeof(struct input_event_struct);
	size_t nread;

	int fd;
	int retval = EXIT_FAILURE;

	if (argc < 2) {
		fprintf(stderr, "usage: %s <path-to-event-file>\n", argv[0]);
		goto out;
	}

	if ((fd = open(argv[1], O_RDONLY)) == -1) {
		fprintf(stderr, "%s: error while opening %s: %m\n", argv[0], argv[1]);
		goto out;
	}

	do {
		nread = read(fd, (struct input_event_struct *) &input_event, 
				                                    input_event_size);

		if (nread == -1) {
			fprintf(stderr, "%s: error while reading %zu bytes from %s: %m\n",
							argv[0], input_event_size, argv[1]);
			goto close_file;
		}
		
		printf("time: %8lu.%08lu, type: 0x%02hx, code: 0x%02hx, value: 0x%04hx\n", 
				input_event.time.tv_sec, input_event.time.tv_usec, 
				input_event.type, input_event.code, input_event.value);

	} while (nread == input_event_size);

	retval = EXIT_SUCCESS;
close_file:
	close(fd);
out:
	return retval;
}
