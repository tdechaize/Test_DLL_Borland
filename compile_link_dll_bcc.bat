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
REM 		ONE ou TWO (or unknown value, because only ONE value is tested during execution)
REM     Et le deuxième paramètre peut prendre les valeurs suivantes :
REM 		32, 64 ou  ALL si vous souhaitez lancer les deux générations, 32 bits et 64 bits.
REM 	Dans le cas du compilateur Borland C/C++, une seule génération possible : 32 bits, ce deuxième paramètre est donc ignoré.
REM
REM 	Author : 						Thierry DECHAIZE
REM		Date creation/modification : 	21/10/2023
REM 	Reason of modifications : 	n° 1 - Blah Blah Blah  
REM 	 							n° 2 - Blah Blah Blah 
REM 	 							n° 3 - ........
REM 	Version number :				1.1.0           	(version majeure . version mineure . patch level)

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
set PATH=C:\BCC55\bin;%PATH%
echo. **********      Pour cette generation le premier parametre vaut "%1" et le deuxieme "%2".     *************
if "%1" == "ONE" (
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
REM 	don't use -e output_file		-> force name of output file, although this name is the same of source file extend of .EXE or .DLL
REM     		C code does not need runtime type id or exception handling so they are suppressed with -RT- and -x-
REM     		noeh32.lib stubs out any of those things found in the libraries, making the output file smaller
echo "*********************************     Generation de la DLL.       ***********************************"
bcc32 -q -WDR -RT- -x- -DBUILD_DLL -D_WIN32 -DNDEBUG -IC:\BCC55\Include -LC:\BCC55\Lib;C:\BCC55\Lib\PSDK src/dll_core.c noeh32.lib
REM     Add src/dll_core.def or dll_core.def on the precedent line don't work. Only presence of dll_core.def on present directory work fine !!!!
REM 	Erratic behaviour of Borland Compiler C/C++, this compiler exploit directly file dll_core.def without message or advertizing !!!!!! 
REM     Use of "implib" utility" mandatory for the next steps : compile and link two test programs
implib -c dll_core.lib dll_core.dll
REM     Use of "impdef" utility" to extract export symbols of dll. It's fine : find symbols/functions with "_", but although without this prefix.
impdef src\dll_core_2.def dll_core.dll
type src\dll_core_2.def
REM 	Generation of the main test program of DLL in "one pass", with implicit load of DLL : a console application.
echo "*************  Generation et lancement du premier programme de test de la DLL en mode implicite.   ************"
REM		-q 								-> set to quiet mode (don't see copyrigth information)		
REM 	-WC								-> set generation to console program (entry of programm is only "main" not "winMain")
bcc32 -q -WC -IC:\BCC55\Include -LC:\BCC55\Lib;C:\BCC55\Lib\PSDK src\testdll_implicit.c dll_core.lib 
REM 	Run the main test program of DLL in "one pass", with implicit load of DLL :					All success.
testdll_implicit.exe
echo "*************  Generation et lancement du deuxieme programme de test de la DLL en mode explicite.  *************"
REM 	Generation of the main test program of DLL in "one pass", with explicit load of DLL : a console application.
bcc32 -q -WC -IC:\BCC55\Include -LC:\BCC55\Lib;C:\BCC55\Lib\PSDK src\testdll_explicit.c dll_core.lib
REM 	Run the main test program of DLL in "one pass", with explicit load of DLL:					All success.
testdll_explicit.exe
echo "*************              Lancement du script python de test de la DLL.                           *************"
REM 	Run the script python to test DLL with arguments passed on "__cdecl" format (another script test exist with call passed on "__sdtcall" format)
REM 																	Fail, don't load DLL correctly !!!!!
%PYTHON32% version.py
%PYTHON32% testdll_cdecl.py dll_core.dll
   ) else (
echo "******************          Compilation de la DLL.        *******************"
REM Options used with Borland compiler C/C++ 32 bits version 5.5.1 :
REM		-c 								-> compile only, not call of linker
REM		-q 								-> set to quiet mode (don't see copyrigth information)		
REM 	-WDR							-> set generation to Windows DLL (mandatory, in evidence !!!) and 
REM 	-RT-							-> disable runtime type id (RTTI) (default is -RT)
REM 	-x- 							-> disable exception handling 
REM 	-Dxxxxxxxxxx 	 				-> define a variable xxxxxxxxxx used by precompiler
bcc32 -c -q -WDR -RT- -x- -DBUILD_DLL -D_WIN32 -DNDEBUG src\dll_core.c 
REM Format genaral of ilink32 command : 
REM     ILINK32 [@<respfile>][<options>] <startup> <myobjs>, [<exefile>],[<mapfile>], [<libraries>], [<deffile>], [<resfiles>]  (comma separated list of flles used by linker)
REM Options used with linker of Borland C/C++ compiler 32 bits version 5.5.1 :
REM 	-Tpd							-> set the linker to generate DLL  
REM 	-aa 							-> set the linker to generate Windows 32 application (NT system or superior, like Windows 7, 8, 10 or 11)
REM 	-x								-> enable exception handling
REM 	-Gi    							-> Normally, tell linker to generate .lib file, but nothing done !!! Bug ???
REM 	c0d32							-> Startup provide by Borland/Inprise for DLL (anther startup, can be c0w32 for windows application (GUI))
REM  At the end of this command's line of linker, you must indicate def file, not same with bbc32 command line with one pass !!!!! 
echo "*****************    Edition des liens (linkage) de la DLL.      ***************"
ilink32 -Tpd -aa -x -q -Gi c0d32 dll_core.obj,dll_core.dll,,import32 cw32i, dll_core.def
REM    Mandatory, because option /Gi used by linker don't generate library file !!!
implib -c dll_core.lib dll_core.dll
REM     Use of "impdef" utility" to extract export symbols of dll. It's fine : find symbols/functions with "_", but although without this prefix.
impdef src\dll_core_2.def dll_core.dll
type src\dll_core_2.def
echo "************     Generation et lancement du premier programme de test de la DLL en mode implicite.      *************"
bcc32 -q -c -D_WIN32 -DNDEBUG src\testdll_implicit.c 
REM Options used with linker of Borland C/C++ compiler 32 bits version 5.5.1 :
REM 	-Tpe							-> set the linker to generate executable
REM 	-aa 							-> set the linker to generate Windows 32 application (NT system or superior, like Windows 7, 8, 10 or 11)
REM 	-C								-> enable exception handling
ilink32 -Tpe -ap -C -LC:\BCC55\Lib;C:\BCC55\Lib\PSDK c0x32.obj testdll_implicit.obj,testdll_implicit.exe,,import32 cw32i dll_core.lib
REM 	Run the main test program of DLL in "two pass", with explicit load of DLL :	  		All success.
testdll_implicit.exe
echo "************     Generation et lancement du deuxieme programme de test de la DLL en mode explicite.     ************"
bcc32 -q -c -D_WIN32 -DNDEBUG src\testdll_explicit.c 
REM Options used with Digital Mars Compiler linker 32 bits :
REM 	/SUBSYSTEM:CONSOLE						-> set the subsystem to console application 
REM 	/NOLOGO  								-> don't see copyrigth and other informations about bcc32
REM 	/EXETYPE:NT 							-> set the type of executable to Windows NT (NT system or superior, like Windows 7, 8, 10 or 11)
ilink32 -Tpe -ap -LC:\BCC55\Lib;C:\BCC55\Lib\PSDK c0x32.obj testdll_explicit.obj,testdll_explicit.exe,,import32 cw32i dll_core.lib
REM 	Run the main test program of DLL in "two pass", with explicit load of DLL :			All success.
testdll_explicit.exe
REM 	Execution of python script (version 32 bits) to test DLL : 						Fail, don't load DLL correctly !!!!!
echo "****************                  Lancement du script python de test de la DLL.                  ********************"
%PYTHON32% version.py
%PYTHON32% testdll_cdecl.py dll_core.dll
) 
echo "      Fin de la generation de la DLL et des tests avec Borland Compiler C/C++ 32 bits version 5.5.1   "
REM 	Return in initial PATH
set PATH=%PATHINIT%