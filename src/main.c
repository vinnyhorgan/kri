#include <lauxlib.h>
#include <lua.h>
#include <lualib.h>
#include <miniz.h>
#include <uv.h>

#include "data.h"

static mz_zip_archive zip_archive;

static int zip_loader(lua_State* L) {
  const char* module = luaL_checkstring(L, 1);

  char filename[256];
  snprintf(filename, sizeof(filename), "%s.lua", module);

  mz_zip_archive_file_stat file_stat;
  int index = mz_zip_reader_locate_file(&zip_archive, filename, NULL, 0);
  if (index < 0) {
    return 0;
  }

  if (!mz_zip_reader_file_stat(&zip_archive, index, &file_stat)) {
    return 0;
  }

  size_t size = file_stat.m_uncomp_size;
  void* data = mz_zip_reader_extract_to_heap(&zip_archive, index, &size, 0);
  if (!data) {
    return 0;
  }

  if (luaL_loadbuffer(L, data, size, filename) != 0) {
    free(data);
    return lua_error(L);
  }

  free(data);
  return 1;
}

static int traceback(lua_State* L) {
  if (!lua_isstring(L, 1))
    return 1;
  lua_pushglobaltable(L);
  lua_getfield(L, -1, "debug");
  lua_remove(L, -2);
  if (!lua_istable(L, -1)) {
    lua_pop(L, 1);
    return 1;
  }
  lua_getfield(L, -1, "traceback");
  if (!lua_isfunction(L, -1)) {
    lua_pop(L, 2);
    return 1;
  }
  lua_pushvalue(L, 1);
  lua_pushinteger(L, 2);
  lua_call(L, 2, 1);
  return 1;
}

int main(int argc, char** argv) {
  memset(&zip_archive, 0, sizeof(zip_archive));
  if (!mz_zip_reader_init_mem(&zip_archive, data, data_len, 0)) {
    printf("failed to initialize embedded zip data\n");
    return 1;
  }

  argv = uv_setup_args(argc, argv);

  lua_State* L = luaL_newstate();
  if (!L) {
    printf("failed to create Lua state\n");
    return 1;
  }

  luaL_openlibs(L);

  lua_getglobal(L, "package");
  lua_getfield(L, -1, "searchers");
  lua_pushcfunction(L, zip_loader);
  lua_rawseti(L, -2, 2);
  lua_pop(L, 1);

  lua_pushcfunction(L, traceback);
  int errfunc = lua_gettop(L);

  if (luaL_loadstring(L, "return require('init')(...)")) {
    printf("failed to load init.lua\n");
    lua_close(L);
    return 1;
  }

  lua_createtable(L, argc, 0);
  for (int i = 0; i < argc; i++) {
    lua_pushstring(L, argv[i]);
    lua_rawseti(L, -2, i);
  }

  if (lua_pcall(L, 1, 1, errfunc)) {
    printf("%s\n", lua_tostring(L, -1));
    lua_close(L);
    return 1;
  }

  int ret = 0;
  if (lua_type(L, -1) == LUA_TNUMBER) {
    ret = (int)lua_tointeger(L, -1);
  }

  lua_close(L);
  mz_zip_reader_end(&zip_archive);

  return ret;
}
