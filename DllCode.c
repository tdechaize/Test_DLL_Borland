//*********************    File : DllCode.c (main core of dll)    *****************
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <stdio.h>
#include "dllcode.h"

/* pragma suppresses "calling argument not used" warnings during compilation */
#pragma argsused

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


ADDAPI int Add(int a, int b)
{
  return a + b;
}

ADDAPI int Multiply(int a, int b)
{
  return a * b;
}
//******************************    End DllCode.c   *********************************