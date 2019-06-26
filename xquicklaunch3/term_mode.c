#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <termios.h>

/* Lua headers */
#include <lua.h>
#include <lauxlib.h>

/* Use this variable to remember original terminal attributes. */

struct termios saved_attributes;

void
reset_input_mode (void)
{
  tcsetattr (STDIN_FILENO, TCSANOW, &saved_attributes);
}

void
set_input_mode (void)
{
  struct termios tattr;
  char *name;

  /* Make sure stdin is a terminal. */
  if (!isatty (STDIN_FILENO))
    {
      fprintf (stderr, "Not a terminal.\n");
      exit (EXIT_FAILURE);
    }

  /* Save the terminal attributes so we can restore them later. */
  tcgetattr (STDIN_FILENO, &saved_attributes);
  //atexit (reset_input_mode);

  /* Set the funny terminal modes. */
  tcgetattr (STDIN_FILENO, &tattr);
  tattr.c_lflag &= ~(ICANON|ECHO); /* Clear ICANON and ECHO. */
  tattr.c_cc[VMIN] = 1;
  tattr.c_cc[VTIME] = 0;
  tcsetattr (STDIN_FILENO, TCSAFLUSH, &tattr);
}

static int set_term_mode_to_raw (lua_State *L) {
	set_input_mode();
	lua_pushboolean(L, 1);
	return 1;
}

static int reset_term_mode (lua_State *L) {
	reset_input_mode();
	lua_pushboolean(L, 1);
	return 1;
}

static const luaL_reg R[] = {

    {"set_mode_to_raw", set_term_mode_to_raw},
    {"reset_mode",      reset_term_mode},

    {NULL, NULL} /* конец списка экспортируемых функций */
};

/* вызывается при загрузке библиотеку */
LUALIB_API int luaopen_term_mode(lua_State *L) {

	//luaL_openlib(L, "emilua", R, 0);
	luaL_register(L, "term_mode", R);

	return 1; /* завершаемся успешно */
}