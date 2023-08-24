/* libNexusDb.h

  Header File for libNexusDb.dll
*/

#ifndef __LIBNEXUSDB_H__
#define __LIBNEXUSDB_H__ __declspec(dllimport)
#else
#define __LIBNEXUSDB_H__ __declspec(dllexport)
#endif

#define NEXUSDB_API __stdcall

#include <stdbool.h>
#include <string.h>

#ifdef __cplusplus
extern "C"
{
#endif

  __LIBNEXUSDB_H__ char16_t *NEXUSDB_API AddDatabase();
  __LIBNEXUSDB_H__ char16_t *NEXUSDB_API AddRemoteDatabase();

  __LIBNEXUSDB_H__ bool NEXUSDB_API SetUsername(char16_t *dbId, char16_t *username);
  __LIBNEXUSDB_H__ bool NEXUSDB_API SetPassword(char16_t *dbId, char16_t *password);
  __LIBNEXUSDB_H__ bool NEXUSDB_API SetHost(char16_t *dbId, char16_t *server);

  __LIBNEXUSDB_H__ bool NEXUSDB_API Connect(char16_t *dbId);
  __LIBNEXUSDB_H__ bool NEXUSDB_API CloseDatabase(char16_t *dbId);

#ifdef __cplusplus
}
#endif
