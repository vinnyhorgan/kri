#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <miniz.h>
#include <uv.h>

int main(int argc, char** argv) {
  if (argc != 3) {
    printf("usage: %s <directory> <header>\n", argv[0]);
    return 1;
  }

  const char* directory = argv[1];
  const char* header = argv[2];

  mz_zip_archive zip_archive;
  memset(&zip_archive, 0, sizeof(zip_archive));
  if (!mz_zip_writer_init_heap(&zip_archive, 0, 0)) {
    printf("failed to init zip archive\n");
    return 1;
  }

  uv_fs_t scandir_req;
  int r = uv_fs_scandir(uv_default_loop(), &scandir_req, directory, 0, NULL);
  if (r < 0) {
    printf("failed to read directory: %s\n", uv_strerror(r));
    mz_zip_writer_end(&zip_archive);
    return 1;
  }

  uv_dirent_t dent;
  while (uv_fs_scandir_next(&scandir_req, &dent) != UV_EOF) {
    if (dent.type == UV_DIRENT_FILE) {
      char full_path[1024];
      snprintf(full_path, sizeof(full_path), "%s/%s", directory, dent.name);

      FILE* fp = fopen(full_path, "rb");
      if (!fp) {
        printf("failed to open file: %s\n", full_path);
        uv_fs_req_cleanup(&scandir_req);
        mz_zip_writer_end(&zip_archive);
        return 1;
      }

      fseek(fp, 0, SEEK_END);
      long file_size = ftell(fp);
      fseek(fp, 0, SEEK_SET);

      char* file_data = malloc(file_size);
      if (!file_data) {
        printf("failed to allocate memory for file: %s\n", full_path);
        fclose(fp);
        uv_fs_req_cleanup(&scandir_req);
        mz_zip_writer_end(&zip_archive);
        return 1;
      }

      if (fread(file_data, 1, file_size, fp) != file_size) {
        printf("failed to read file: %s\n", full_path);
        free(file_data);
        fclose(fp);
        uv_fs_req_cleanup(&scandir_req);
        mz_zip_writer_end(&zip_archive);
        return 1;
      }

      fclose(fp);

      if (!mz_zip_writer_add_mem(&zip_archive, dent.name, file_data, file_size, MZ_BEST_COMPRESSION)) {
        printf("failed to add file to zip: %s\n", dent.name);
        free(file_data);
        uv_fs_req_cleanup(&scandir_req);
        mz_zip_writer_end(&zip_archive);
        return 1;
      }

      free(file_data);
    }
  }

  uv_fs_req_cleanup(&scandir_req);

  void* zip_data;
  size_t zip_size;
  if (!mz_zip_writer_finalize_heap_archive(&zip_archive, &zip_data, &zip_size)) {
    printf("failed to finalize zip archive\n");
    mz_zip_writer_end(&zip_archive);
    return 1;
  }

  mz_zip_writer_end(&zip_archive);

  FILE* fp = fopen(header, "w");
  if (!fp) {
    printf("failed to open header file: %s\n", header);
    free(zip_data);
    return 1;
  }

  fprintf(fp, "unsigned char data[] = {\n");

  for (size_t i = 0; i < zip_size; i++) {
    if (i % 12 == 0) {
      fprintf(fp, "  ");
    }
    fprintf(fp, "0x%02x", ((unsigned char*)zip_data)[i]);

    if (i != zip_size - 1) {
      fprintf(fp, ", ");
    }

    if ((i + 1) % 12 == 0 || i == zip_size - 1) {
      fprintf(fp, "\n");
    }
  }

  fprintf(fp, "};\n\n");
  fprintf(fp, "unsigned int data_len = %zu;\n", zip_size);

  fclose(fp);
  free(zip_data);

  return 0;
}
