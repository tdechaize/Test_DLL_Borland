# **************************************     File : Project.mak     ******************************
# comments start with the pound symbol
# automatically check if a header file has changed
.autodepend

# -WR windows GUI exe dynamic linked (-W for static linked)
# -WC console application exe dynamic linked (-W for static linked)
# -v generate debug info
testdll_implicit.exe : dll_core.lib src\testdll_implicit.c
  bcc32 -WC -v src\testdll_implicit.c dll_core.lib

# create an import library
# -c case sensitive
dll_core.lib : dll_core.dll
  implib -c dll_core.lib dll_core.dll

# C code does not need runtime type id or exception
# handling so they are suppressed with -RT- and -x-
# noeh32.lib stubs out any of those things found in
# the libraries, making the output file smaller
# -WDR windows dll dynamic linked (-WD for static linked)
# You can write also -WD -WR, last option is used here to 
# specify a dynamic variant of the runtime library. 
# -v generate debug info
dll_core.dll : src\dll_core.c
  bcc32 -DBUILD_DLL -WDR -v -RT- -x- src\dll_core.c noeh32.lib
# **************************************     End Project.mak     ******************************