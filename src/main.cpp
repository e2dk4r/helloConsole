#include <stdio.h>
#include <string.h>

struct flags {
  int version : 1;
  int help    : 1;
};

int
main(int    argc,
     char **argv) {
  struct flags flags = {0};
  
  // argument parsing
  if (argc != 1) {
    char **iterator;
    char *param;
    for (iterator = argv + 1; (iterator - argv) < argc; iterator += 1) {
      param = *iterator;

      // only flags accepted
      if (*param != '-') {
        fputs("Parameters is not allowed\n", stderr);
        flags.help = 1;
        break;
      }

      if (strcmp(param, "-h") == 0 || strcmp(param, "--help") == 0) {
        flags.help = 1;
        break;
      } else if (strcmp(param, "-v") == 0 || strcmp(param, "--version") == 0) {
        flags.version = 1;
        continue;
      } else {
        fputs("Specified flag(s) is not recognized\n", stderr);
        flags.help = 1;
        break;
      }
    }
  }

  if (flags.help) {
    puts(
      "NAME"                           "\n"
      "  helloConsole - greet world"   "\n"
      "DESCRIPTION"                    "\n"
      "  prints hello world to screen" "\n"
      "SYNOPSIS"                       "\n"
      "  helloConsole [flags]"         "\n"
      "FLAGS"                          "\n"
      "  -v, --version"                "\n"
      "    show version"               "\n"
      "  -h, --help"                   "\n"
      "    show help screen"           "\n"
    );
    return 1;
  } else if (flags.version) {
    puts(
      APP_VERSION                      "\n"
      "Timetamp: " APP_BUILD_TIMESTAMP "\n"
    );
    return 0;
  }
  
  printf("Hello world!\n");
  return 0;
}

