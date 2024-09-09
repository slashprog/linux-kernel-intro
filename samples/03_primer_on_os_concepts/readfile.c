#include <stdio.h>
#include <stdlib.h>

#include <unistd.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/time.h>

#include <errno.h>
#include <string.h>

#define BUFSIZE 4096

int main(int argc, char *argv[])
{

	int retval = EXIT_FAILURE;
	int fd;
	char buf[BUFSIZE];
	size_t nread, nwritten;

	if (argc < 2) {
		fprintf(stderr, "usage: %s <path-to-file>\n", argv[0]);
		goto out;
	}

	if ((fd = open(argv[1], O_RDONLY)) == -1) {
		fprintf(stderr, "%s: error while opening %s: %m\n", argv[0], argv[1]);
		goto out;
	}

	do {
		nread = read(fd, buf, BUFSIZE); 
		if (nread == -1) {
			fprintf(stderr, "%s: error while reading %u bytes from %s: %m\n",
							argv[0], BUFSIZE, argv[1]);
			goto close_file;
		}
		
		nwritten = write(STDOUT_FILENO, buf, nread);
		if (nwritten == -1) {
			fprintf(stderr, "%s: error while writing %u bytes stdout: %m\n",
							argv[0], BUFSIZE);
			goto close_file;
		}
	} while (nread == BUFSIZE);

	retval = EXIT_SUCCESS;
close_file:
	close(fd);
out:
	return retval;
}
