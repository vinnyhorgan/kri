#include <lauxlib.h>
#include <lua.h>
#include <lualib.h>

int main(int argc, char** argv) {
  lua_State* L = luaL_newstate();
  luaL_openlibs(L);
  luaL_loadstring(L, "print 'hello from lua!'");
  lua_call(L, 0, 0);
  lua_close(L);
  return 0;
}
