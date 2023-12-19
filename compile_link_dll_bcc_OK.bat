@echo off
REM
REM   	Script de génération de la DLL dll_core.dll et des programmee de test : "testdll_implicit.exe" (chargement implicite de la DLL),
REM 	"testdll_explicit.exe" (chargement explicite de la DLL), et enfin du script de test écrit en python.
REM		Ce fichier de commande est paramètrable avec deux paraamètres : 
REM			a) le premier paramètre permet de choisir la compilation et le linkage des programmes en une seule passe
REM 			soit la compilation et le linkage en deux passes successives : compilation séparée puis linkage,
REM 		b) le deuxième paramètre définit soit une compilation et un linkage en mode 32 bits, soit en mode 64 bits
REM 	 		pour les compilateurs qui le supportent.
REM     Le premier paramètre peut prendre les valeurs suivantes :
REM 		ONE ou TWO or ALL (or unknown value, because only ONE and TWO value are tested during execution)
REM     Et le deuxième paramètre peut prendre les valeurs suivantes :
REM 		32, 64 ou  ALL si vous souhaitez lancer les deux générations, 32 bits et 64 bits.
REM 	Dans le cas du compilateur Borland C/C++, une seule génération possible : 32 bits, ce deuxième paramètre est donc ignoré.
REM
REM 	Author : 						Thierry DECHAIZE
REM		Date creation/modification : 	20/11/2023
REM 	Reason of modifications : 	n° 1 - reprise pour apporter des améliorations au script initial : appel de fonctions dans les branches du test
REM 										sur le premier paramètre.
REM 	 							n° 2 - Des reliquats de description d'options d'un autre compilateur C à retirer et à remplacer par les bonnes options.
REM 	 							n° 3 - Remplacement de l'utilitaire "impdef" par "tdump" et generation de la library directement dans les options
REM 										(simplification).
REM 	Version number :				1.1.3          	(version majeure . version mineure . patch level)

echo. Lancement du batch de generation d'une DLL et deux tests de celle-ci avec Borland Compiler C/C++ 32 bits version 5.5.1
REM     Affichage du nom du système d'exploitation Windows :              			Microsoft Windows 11 Famille (par exemple)
REM 	Affichage de la version du système Windows :              					10.0.22621 (par exemple)
REM 	Affichage de l'architecture du processeur supportant le système Windows :   64-bit (par exemple)    
echo.  *********  Quelques caracteristiques du systeme hebergeant l'environnement de developpement.   ***********
WMIC OS GET Name
WMIC OS GET Version
WMIC OS GET OSArchitecture

REM 	Save of initial PATH on PATHINIT variable
set PATHINIT=%PATH%
REM      Mandatory, add to PATH the binary directory of compiler Borland C/C++ (You can adapt this directory at your personal software environment)
REM 	 I add two directory to transform OMF to COFF  format of OBJ file to the test with script python : 
REM 			C:\mingw32\bin 		to access tool "dllwrap", maybe you can position this directory to your own environment (MSYS2, MingW64, ...) 
REM 			C:\Outils\objconv 	to access tool "objconv", because I stored all my tools on Windows on directory C:\Outils
set PATH=C:\BCC55\bin;C:\mingw32\bin;C:\Outils\objconv;%PATH%
echo. **********      Pour cette generation le premier parametre vaut "%1" et le deuxieme "%2".     *************

IF "%1" == "ONE" ( 
   call :complinkONE
) ELSE (
   IF "%1" == "TWO" (
      call :complinkTWO
   ) ELSE (
      call :complinkONE
	  call :complinkTWO
	)
)

goto FIN

:complinkONE
REM 	Format of command "bcc32" (bcc32 is a one-step program to compile and link C++, C and ASM files)
REM 	 			BCC32 [ options ] file[s] * = default; -x- = turn switch x off 
REM 	Generation of the DLL in "one pass", with many options :
REM		-q 								-> set to quiet mode (don't see copyrigth information)		
REM 	-WDR							-> set generation to Windows DLL (mandatory, in evidence !!!) and 
REM 	-RT-							-> disable runtime type id (RTTI) (default is -RT)
REM 	-x- 							-> disable exception handling 
REM 	-Dxxxxxxxxxx 	 				-> define a variable xxxxxxxxxx used by precompiler
REM 	-Ixxxxxxxx  					-> set the search path to include files
REM 	-Lxxxxxxxx  					-> set the search path to library files (many option -L.... or list of search directory separated by ";")
REM 	-lGi							-> -lxxx add option to linker, here, option to generate lib file.
REM 	don't use -e output_file		-> force name of output file, although this name is the same of source file extend of .EXE or .DLL
REM     		C code does not need runtime type id or exception handling so they are suppressed with -RT- and -x-
REM     		noeh32.lib stubs out any of those things found in the libraries, making the output file smaller
echo.  *********************************           Generation de la DLL.            ***********************************
bcc32 -q -WDR -RT- -x- -DBUILD_DLL -D_WIN32 -DNDEBUG -IC:\BCC55\Include -LC:\BCC55\Lib;C:\BCC55\Lib\PSDK -lGi src/dll_core.c noeh32.lib
REM     Add src/dll_core.def on the precedent line don't work. Only presence of dll_core.def on present directory work fine !!!!
REM 	Erratic behaviour of Borland Compiler C/C++, this compiler exploit directly file dll_core.def without message or advertizing !!!!!! 
REM     Not mandatory, the use of "implib" utility", because option -lGi added with precedent command "bcc32" generate it. Fine !!!
REM  implib -c dll_core.lib dll_core.dll
echo.  ***************** 	           Listage des symboles exportes de la DLL 32 bits				 *****************
REM     Use of "tdump" utility" to extract export symbols of dll. It's fine : find symbols/functions with "_", but although without this prefix.
tdump -q -ee dll_core.dll
REM 	Generation of the main test program of DLL in "one pass", with implicit load of DLL : a console application.
echo.  *************  Generation et lancement du premier programme de test de la DLL en mode implicite.   *************
REM		-q 								-> set to quiet mode (don't see copyrigth information)		
REM 	-WC								-> set generation to console program (entry of programm is only "main" not "WinMain")
bcc32 -q -WC -IC:\BCC55\Include -LC:\BCC55\Lib;C:\BCC55\Lib\PSDK src\testdll_implicit.c dll_core.lib 
REM 	Run the main test program of DLL in "one pass", with implicit load of DLL :					All success.
testdll_implicit.exe
echo.  *************  Generation et lancement du deuxieme programme de test de la DLL en mode explicite.  *************
REM 	Generation of the main test program of DLL in "one pass", with explicit load of DLL : a console application.
bcc32 -q -WC -IC:\BCC55\Include -LC:\BCC55\Lib;C:\BCC55\Lib\PSDK src\testdll_explicit.c dll_core.lib
REM 	Run the main test program of DLL in "one pass", with explicit load of DLL:					All success.
testdll_explicit.exe
echo.  *************            Lancement du script python de test de la "very tranformed" DLL            *************
REM 	Run the script python to test DLL with arguments passed on "__cdecl" format (another script test exist with call passed on "__stdcall" format)
REM 	Failed if you respect standard format of obj/lib of this compiler (OMF format), and format of initial DLL (PE format), but with special DllEntryPoint "entry point". 
REM 	An alternative is to use two tools, first "objconv" on OBJ file to tranform it in COFF format and after create DLL with "dllwrap" tool (yes, it is a "bidouille" !).    
objconv -fcoff -nr:GetLastError:DllEntryPoint -ar:DllEntryPoint:DllMain dll_core.obj dll_core_coff.obj
dllwrap --enable-stdcall-fixup --def dll_core_coff.def -o dll_core_coff.dll dll_core_coff.obj													
%PYTHON32% version.py
%PYTHON32% testdll_cdecl.py dll_core_coff.dll
exit /B 

:complinkTWO
echo "******************          Compilation de la DLL.        *******************"
REM Options used with Borland compiler C/C++ 32 bits version 5.5.1 :
REM		-c 								-> compile only, not call of linker
REM		-q 								-> set to quiet mode (don't see copyrigth information)		
REM 	-WDR							-> set generation to Windows DLL (mandatory, in evidence !!!) and 
REM 	-RT-							-> disable runtime type id (RTTI) (default is -RT)
REM 	-x- 							-> disable exception handling 
REM 	-Dxxxxxxxxxx 	 				-> define a variable xxxxxxxxxx used by precompiler
bcc32 -c -q -WDR -RT- -x- -DBUILD_DLL -D_WIN32 -DNDEBUG src\dll_core.c 
REM Format general of ilink32 command : 
REM     ILINK32 [@<respfile>][<options>] <startup> <myobjs>, [<exefile>],[<mapfile>], [<libraries>], [<deffile>], [<resfiles>]  (comma separated list of flles used by linker)
REM Options used with linker of Borland C/C++ compiler 32 bits version 5.5.1 :
REM 	-Tpd							-> set the linker to generate DLL  
REM 	-aa 							-> set the linker to generate Windows 32 application (NT system or superior, like Windows 7, 8, 10 or 11)
REM 	-x								-> enable exception handling
REM 	/Gi    							-> option -Gi tell linker to generate .lib file, but nothing done. Change option to /Gi active generation of lib file.
REM 	c0d32							-> Startup provide by Borland/Inprise for DLL (anther startup, can be c0w32 for windows application (GUI))
REM  At the end of this command's line of linker, you must/can indicate def file, not same with bbc32 command line with one pass !!!!! 
echo "*****************    Edition des liens (linkage) de la DLL.      ***************"
ilink32 -Tpd -aa -x -q /Gi c0d32 dll_core.obj,dll_core.dll,,import32 cw32i, src\dll_core.def
REM    Not mandatory, because option -Gi used by linker don't generate library file, but option /Gi do. Good surprise !!!
REM implib -c dll_core.lib dll_core.dll
echo.  ***************** 	       Listage des symboles exportes de la DLL 32 bits				*****************
REM     Use of "tdump" utility" to extract export symbols of dll. It's fine : find symbols/functions with "_", but although without this prefix.
tdump -q -ee dll_core.dll
echo "************     Generation et lancement du premier programme de test de la DLL en mode implicite.      *************"
bcc32 -q -c -D_WIN32 -DNDEBUG src\testdll_implicit.c 
REM Options used with linker of Borland C/C++ compiler 32 bits version 5.5.1 :
REM 	-Tpe							-> set option to generate executable
REM 	-ap 							-> set option to generate console application
REM 	-c								-> case sensitive linking
REM 	-Lxxxxxxxx  					-> set the search path to library files (many option -L.... or list of search directory separated by ";")
REM 	c0x32.obj						-> Startup provide by Borland/Inprise for console application (anther startup, can be c0w32 for windows application (GUI))
ilink32 -Tpe -ap -c -LC:\BCC55\Lib;C:\BCC55\Lib\PSDK c0x32.obj testdll_implicit.obj,testdll_implicit.exe,,import32 cw32i dll_core.lib
REM 	Run the main test program of DLL in "two pass", with explicit load of DLL :	  		All success.
testdll_implicit.exe
echo   ************     Generation et lancement du deuxieme programme de test de la DLL en mode explicite.     ************
bcc32 -q -c -D_WIN32 -DNDEBUG src\testdll_explicit.c 
ilink32 -Tpe -ap -c -LC:\BCC55\Lib;C:\BCC55\Lib\PSDK c0x32.obj testdll_explicit.obj,testdll_explicit.exe,,import32 cw32i dll_core.lib
REM 	Run the main test program of DLL in "two pass", with explicit load of DLL :			All success.
testdll_explicit.exe
echo   ****************        Lancement du script python de test de la "very transformed" DLL.           ********************
REM 	Run the script python to test DLL with arguments passed on "__cdecl" format (another script test exist with call passed on "__stdcall" format)
REM 	Failed if you respect standard format of obj/lib of this compiler (OMF format), and format of initial DLL (PE format), but with special DllEntryPoint "entry point". 
REM 	An alternative is to use two tools, first "objconv" on OBJ file to tranform it in COFF format and after create DLL with "dllwrap" tool (yes, it is a "bidouille" !).  
objconv -fcoff -nr:GetLastError:DllEntryPoint -ar:DllEntryPoint:DllMain dll_core.obj dll_core_coff.obj
dllwrap --enable-stdcall-fixup --def dll_core_coff.def -o dll_core_coff.dll dll_core_coff.obj													
%PYTHON32% version.py
%PYTHON32% testdll_cdecl.py dll_core_coff.dll
exit /B 

:FIN
echo.       Fin de la generation de la DLL et des tests avec Borland Compiler C/C++ 32 bits version 5.5.1   
REM 	Return in initial PATH
set PATH=%PATHINIT%