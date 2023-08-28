/* libNexusDb.h
  Header File for libNexusDb.dll
*/

#pragma once

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
  struct NxStr16
  {
    char16_t *str;
    size_t len;
  };
  typedef NxStr16 *NxStr16Ptr;

  __LIBNEXUSDB_H__ bool NEXUSDB_API FreeString(NxStr16Ptr s);
  __LIBNEXUSDB_H__ NxStr16Ptr NEXUSDB_API AddDatabase(NxStr16Ptr path);
  __LIBNEXUSDB_H__ NxStr16Ptr NEXUSDB_API AddRemoteDatabase(NxStr16Ptr host, NxStr16Ptr alias, NxStr16Ptr username, NxStr16Ptr password);
  __LIBNEXUSDB_H__ NxStr16Ptr NEXUSDB_API ExecuteSql(NxStr16Ptr dbId, NxStr16Ptr sql, NxStr16Ptr params = NULL);
  __LIBNEXUSDB_H__ bool NEXUSDB_API CloseDatabase(NxStr16Ptr dbId);

  // typedefs
  typedef bool(__stdcall *FreeStringPtr)(NxStr16Ptr s);
  typedef NxStr16Ptr(__stdcall *AddRemoteDatabasePtr)(NxStr16Ptr host, NxStr16Ptr alias, NxStr16Ptr username, NxStr16Ptr password);
  typedef NxStr16Ptr(__stdcall *AddDatabasePtr)(NxStr16Ptr path);
  typedef NxStr16Ptr(__stdcall *ExecuteSqlPtr)(NxStr16Ptr dbId, NxStr16Ptr sql, NxStr16Ptr params);
  typedef bool(__stdcall *CloseDatabasePtr)(NxStr16Ptr dbId);

#ifdef __cplusplus
}
#endif
