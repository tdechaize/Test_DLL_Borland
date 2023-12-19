//*********************    File : dll_core.c (main core of dll)    *****************
// #define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <stdio.h>
#include "dll_share.h"

/* pragma suppresses "calling argument not used" warnings during compilation */
#pragma argsused
// Warning, this pragma is specific to Borland C/C++ compiler 

BOOL WINAPI DllEntryPoint(HINSTANCE hinst, DWORD reason, LPVOID reserved)
{
    switch( reason ) {
    case DLL_PROCESS_ATTACH:
        printf( "DLL attaching to process...\n" );
        break;
    case DLL_PROCESS_DETACH:
        printf( "DLL detaching from process...\n" );
        break;
		// The attached process creates a new thread.
	case DLL_THREAD_ATTACH:
		printf("The attached process creating a new thread...\n");
		break;
		// The thread of the attached process terminates.
	case DLL_THREAD_DETACH:
		printf("The thread of the attached process terminates...\n");
		break;
	default:
		printf("Reason called not matched, error if any : %ld...\n", GetLastError());
		break;
    }
    return( 1 );    /* Indicate success */
}

FUNCAPI int Hello()
 {
    printf( "Hello from a DLL!\n" );
    return( 0 );
 }

FUNCAPI int Addint(int i1, int i2)
 {
	return i1 + i2;
 }
 
FUNCAPI int Subint(int i1, int i2)
 {
	return i1 - i2;
 }

FUNCAPI int Multint(int i1, int i2)
 { 
   return i1 * i2;
 }
 
FUNCAPI int Squarint(int i)
 { 
   return i * i;
 }

FUNCAPI double Adddbl(double i1, double i2)
 {
	return i1 + i2;
 }
 
FUNCAPI double Subdbl(double i1, double i2)
 {
	return i1 - i2;
 }

FUNCAPI double Multdbl(double i1, double i2)
 { 
   return i1 * i2;
 }
 
FUNCAPI double Squardbl(double i)
 { 
   return i * i;
 }
//******************************    End dll_core.c   *********************************
