ifeq ($(OS),Windows_NT)
	ifeq ($(PROCESSOR_ARCHITECTURE),AMD64)
	else
		$(error This makefile requires a 64-bit version of Windows)
	endif
else
	$(error This makefile requires Windows 64-bit)
endif

SHELL = powershell
PATH := $(PATH);C:\Program Files (x86)\Embarcadero\Studio\22.0\bin

PROJECT = Project1.dproj
CONFIG = Debug
VERBOSITY = minimal

all: build

build64:
	cmd.exe /c "rsvars.bat && msbuild $(PROJECT) /t:Make /p:Config=$(CONFIG) /verbosity:$(VERBOSITY) /p:platform=Win64"

build32:
	cmd.exe /c "rsvars.bat && msbuild $(PROJECT) /t:Make /p:Config=$(CONFIG) /verbosity:$(VERBOSITY) /p:platform=Win32"

build: build64 build32

cleanup64:
	cmd.exe /c "rsvars.bat && msbuild $(PROJECT) /t:Clean /p:Config=$(CONFIG) /verbosity:$(VERBOSITY) /p:platform=Win64"

cleanup32:
	cmd.exe /c "rsvars.bat && msbuild $(PROJECT) /t:Clean /p:Config=$(CONFIG) /verbosity:$(VERBOSITY) /p:platform=Win32"

cleanup: cleanup64 cleanup32

rebuilt: cleanup build

.PHONY: all build build64 build32 cleanup rebuilt
