# nexusdb-lib

This is a library for interacting with the NexusDB database engine. It is written in ObjectPascal/Delphi and may be used by any application that can load a DLL.

## Requirements

- NexusDB 4.50 or higher
- Delphi 2009 or higher

## Usage

The library can handle multiple database connections at a time. Both via direct file acces (local) and via the NexusDB server (remote).
Each connection gets a ssigned an id, which is used to identify the connection in all other functions.

This library can only be used to execute SQL statements. It does not provide any functionality for creating or altering tables.

### Strings

All strings are expected to be UTF-16 encoded.
String parameters are passed as a pointer to a struct called `NxStr16`.
It has a Pointer to the Char array and a Length field [`UINT64`].

```pascal
type
  NxStr16 = record
    Length: UINT64;
    Str: PWideChar;
  end;
```

```cpp
typedef struct {
  UINT64 Length;
  wchar_t *Str;
} NxStr16;
```
