::Build 2.02 -->Optimizacion del code

@echo off
mode con: cols=96 lines=26
setlocal enabledelayedexpansion

:recursos
	set cl=tools\bin\cecho.exe
	set busybox=tools\bin\busybox
	set bin=tools\bin

:main
	cls
    title Scarlett Kitchen - Choose project
	call :banner2
	%cl%   {47} Choose project {#}
	echo.
	echo.
	set "num=0"
	for /f %%a in ('dir /ad /b' ) do (
		set "project=%%a"
		if not "%%a"==".git" if not "%%a"=="tools" (
			set /a num+=1
			echo.  !num!] %%~nxa
			echo.  !num!].%%~nxa>>"%temp%\projects.txt"
		)
	)
	%cl%   {06}n) Create new project{#}
	echo.
	%cl%   {05}r) restart{#}
	echo.
	%cl%   {04}e) Exit{#}
	echo.
	echo.
	set /p "option=# Select any option: "
	if "!option!"=="n" goto crear_proyecto
	if "!option!"=="r" call :reiniciar
	if "!option!"=="e" exit
	echo(%option%|findstr "^[-][1-9][0-9]*$ ^[1-9][0-9]*$ ^0$">nul&&goto :rest||echo."%option%" not exist & pause>nul & cls & goto :main
	:rest
	for /f "tokens=2 delims=." %%a in ('findstr "%option%" "%temp%\projects.txt"') do (
		if not "%%a"=="tools" (
		if exist "%cd%\%%a" set "seleccion=%cd%\%%a" & set "current=%%~nxa"
		)
	)

:rutas
	set data=%current%\_project_files\data
	set system=%current%\system\system 
	set vendor=%current%\vendor
	set product=%current%\product

:verificador
	if exist %current%\_project_files\data\user_data ( goto home ) else (
	cls
	call :banner2
	%cl%   No project data detect in {03}%current%{#}
	pause>nul
	goto main
)
:: --- --- --- 0) Home --- --- --- ::
:home
    cls
	call :datos
	call :obtener_versiones
    title Scarlett Kitchen - Full Edition [%scarlett_version%]
	call :banner
	del %temp%\projects.txt >nul 2>nul
	%cl%   {47} Main Menu {#}
	echo.
	echo.
	%cl%   {09}1) Create new project{#}
	echo.
	%cl%   {07}2) Choose a different project{#}
	echo.
	%cl%   {07}3) Open ROM files/directory{#}
	echo.
	%cl%   {0C}4) Delete a project{#}
	echo.
	%cl%   {07}5) Extract Firmware{#}
	echo.
	%cl%   {06}6) Kitchen Configs{#} ({08}build: {#}{02}%scarlett_version%{#})
	echo.
	%cl%   {03}7) ROM tools menu{#}
	echo.
	%cl%   {03}8) Project tools{#}
	echo.
	%cl%   {05}9) Plugin manager{#}
	echo.
	%cl%   {04}e) Exit{#}
	echo.
	echo.
	set /p select=# Select any option: 
	if "!select!"=="1" goto crear_proyecto
	if "!select!"=="2" goto main
	if "!select!"=="3" goto abrir_archivos_del_proyecto
	if "!select!"=="4" goto borrar_proyecto
	if "!select!"=="5" goto menu_de_extraccion
	if "!select!"=="6" goto configuraciones
	if "!select!"=="7" goto rom_tools
	if "!select!"=="8" goto herramientas_del_proyecto
	if "!select!"=="9" goto plugin_check
	if "!select!"=="e" goto salir
	) else (
        goto home
    )

:: --- --- --- 1) Herramientas del proyecto --- --- --- ::
:herramientas_del_proyecto
    cls
    title Scarlett Kitchen - Project tools
	call :banner
	%cl%   {47} Project tools {#}
	echo.
	echo.
	%cl%   {09}1) Create new project{#}
	echo.
	%cl%   {09}2) Extraction menu{#}
	echo.
	%cl%   {08}3) Project Information{#}
	echo.
	%cl%   {07}4) Build menu{#}
	echo.
	%cl%   {05}5) Rewrite META-INF{#}
	echo.
	%cl%   {06}b) Back{#}
	echo.
	echo.
	set /p select=# Select any option: 
	if "!select!"=="1" goto crear_proyecto
	if "!select!"=="2" goto menu_de_extraccion
	if "!select!"=="3" goto Informacion
	if "!select!"=="4" goto menu_de_compilacion
	if "!select!"=="5" goto reescribir_meta
	if "!select!"=="b" goto home
	) else (
        goto herramientas_del_proyecto
    )
:menu_de_extraccion
	if not exist "%current%\*.zip" (
		if not exist "%current%\*.md5" (
			if not exist "%current%\*.tar" (
				if not exist "%current%\*.lz4" (
					if not exist "%current%\*.img" (
						cls
						call :banner
						%cl%   {47} Extraccion menu {#}
						echo.
						echo.
						%cl%   Please put the files to extract in {03}"%current%\"{#}
						echo.
						echo.
						%cl%   {06}r] Reload{#}
						echo.
						%cl%   {05}b] Back{#}
						echo.
						set /p select=# Select any option: 
						if "!select!"=="r" goto menu_de_extraccion
						if "!select!"=="b" goto home
					)
				)
			)
		)
	)
    cls
	set ext=null
	call :banner
	echo.
	%cl%   {47} Extraccion menu {#}
	echo.
	echo.
	set count=0
	for %%f in (%current%\*) do (
		set ext=%%~xf
		set /a count=!count!+1
		if !count! leq 9 ( echo   !count!] %%~nxf )
	)
	%cl%   {06}r) Reload{#}
	echo.
	%cl%   {05}b) Back{#}
	echo.
	echo.
	set filenumber=rr
	set file=n
	set /p filenumber=# Select any option: 
	set filenumber=%filenumber: =x%
	set filenumber=%filenumber:,=x%
	set filenumber=%filenumber:"=x%
	if "!filenumber!"=="r" goto menu_de_extraccion
	if "!filenumber!"=="b" goto home
	set count=0
	for /f "delims=" %%f in ('tools\bin\find %current%/*  ^| !busybox! tr / \\') do (
		set /a count=!count!+1
		if !count! ==%filenumber% (
			:: Ejemplo: .zip
			set file_ext=%%~xf
			:: Ejemplo: %current%\Place\Archivo.zip
			set file_rom=%%f
			:: Ejemplo: Archivo.zip
			set file_rom_base=%%~nf%%~xf
			:: Ejemplo: Archivo
			set file_noext=%%~nf
		)
	)
	if "!file_ext!"==".zip" (
		cls
		echo decompilando %file_rom_base%
		call :decompilacion_base %file_rom% %file_rom_base%
		goto menu_de_extraccion
	)
	if "!file_ext!"==".img" ( 
		echo !file_noext!.IMG Selecionado
	)
	if "!file_ext!"==".tar" ( 
		echo !file_noext!.TAR Selecionado
	)
	if "!file_ext!"==".lz4" ( 
		echo !file_noext!.LZ4 Selecionado
	)
	if "!file_ext!"==".md5" ( 
		echo !file_noext!.md5 Selecionado
	)
	pause>nul
	goto menu_de_extraccion




:Informacion
    cls
	title Scarlett Kitchen - Information
	call :banner2
	call :datos
	call :variables_de_respaldo
	echo.
	%cl%                                           {70}Project Informacion{#}
	echo.
	echo.
	%cl%          {33}##################{#}               {03}Device:{#} !dispositivo!
	echo.
	%cl%          {33}##################{#}               {03}Model:{#} !modelo!
	echo.
	%cl%          {33}####{#}                             {03}Arch:{#} !arquitectura!
	echo.
	%cl%          {33}####{#}                             {03}Android Version:{#} !android_version!
	echo.
	%cl%          {33}##################{#}               {03}No. Compilation:{#} !pda!
	echo.
	%cl%          {33}##################{#}               {03}Chipset:{#} !chipset!
	echo.
	%cl%                        {33}####{#}               
	echo.
	%cl%                        {33}####{#}               {70}Project Status{#}
	echo.
	%cl%          {33}##################{#}
	echo.
	%cl%          {33}##################{#}               {0A}Debloat:{#} !bloat_status!
	echo.
	%cl%                                           {0A}Deodex:{#} !deodex_status!
	echo.
	%cl%                                           {0A}Deknox:{#} !knox_status!
	echo.
	%cl%                                           {0A}META-INF:{#} !installer_status!
	echo.
	%cl%   {0F}r) Reload Information{#}
	echo.
	%cl%   {06}b) Back{#}
	echo.
	echo.
	set /p select=# Select any option: 
	if "!select!"=="r" goto Informacion
	if "!select!"=="b" goto herramientas_del_proyecto
	) else (
		goto Informacion
	)


:menu_de_compilacion
    cls
    title Scarlett Kitchen - build menu
	call :banner
	%cl%   {47} Build menu {#}
	echo.
	echo.
	%cl%   {0F}1) Build in Ext4 img{#}
	echo.
	%cl%   {08}2) Build final zip for flash{#}
	echo.
	%cl%   {03}3) Build tar for odin{#}
	echo.
	%cl%   {08}4) Build md5 for odin{#}
	echo.
	%cl%   {06}b) Back{#}
	echo.
	echo.
	set /p select=# Select any option: 
	if "!select!"=="1" goto compilar_img_menu
	if "!select!"=="2" goto compilar_zip
	if "!select!"=="3" goto compilar_tar_menu
	if "!select!"=="4" goto compilar_md5_menu
	if "!select!"=="b" goto herramientas_del_proyecto
	) else (
        goto menu_de_compilacion
    )
:reescribir_meta
	if exist "%current%\META-INF" (
		del /s /q "%current%\META-INF" >nul
	)
	for /f "Tokens=2* Delims==" %%# in ('type "%system%\build.prop" ^| findstr "ro.build.version.incremental="') do ( set "pda=%%#")
	for /f "Tokens=2* Delims==" %%# in ('type "%system%\build.prop" ^| findstr "ro.product.system.model="') do ( set "modelo=%%#")
	for /f "Tokens=2* Delims==" %%# in ('type "%data%\user_data" ^| findstr "project_name="') do ( set "project_name=%%#")
	for /f "Tokens=2* Delims==" %%# in ('type "%data%\user_data" ^| findstr "user_name="') do ( set "user_name=%%#")
    xcopy /y tools\build\system_root %current% /s >nul 2>nul
    set updater-script=%current%\META-INF\com\google\android\updater-script
	%bin%\sfk replace %updater-script% "/#ROMNAME/%project_name%/" -yes > nul
	%bin%\sfk replace %updater-script% "/#PDA/%pda%/" -yes > nul
	%bin%\sfk replace %updater-script% "/#AUTHOR/%user_name%/" -yes > nul
	%bin%\sfk replace %updater-script% "/#DEVICE/%modelo%/" -yes > nul
	goto herramientas_del_proyecto

:: --- --- --- compilar img_raw --- --- --- ::
:compilar_img_menu
	cls
    title Scarlett Kitchen - Choose folder for compile
	call :banner
	%cl%   {47} Select folder {#}
	echo.
	echo.
	set count=0
	for /f %%s in ('dir %current% /ad /b' ) do (
		if not "%%s"=="META-INF" (
		set /a count=!count!+1
		if !count! leq 9 echo   !count!] %%s
		if !count! geq 10 echo  !count!] %%s
		)
	)
	%cl%   {06}b) Back{#}
	echo.
	echo.
	set selectproject=sele
	set projectselected=null
	set /p selectproject=# Select any option: 
	if "!selectproject!"=="b" goto menu_de_compilacion
	set selectproject=!selectproject:"=!
	set count=0
	for /f %%a in ('dir %current%\ /ad /b' ) do (
		if not "%%a"=="META-INF" (
		set /a count=!count!+1
			if "!count!" == "!selectproject!" (
				set projectselected=%%a 
			)
			if "!projectselected!"=="system " (
				goto compilar_system
			)
			if "!projectselected!"=="vendor " (
				goto compilar_vendor
			)
			if "!projectselected!"=="product " (
				goto compilar_product
			)
		)
	)
	goto compilar_img_menu

:compilar_system
	if exist "%current%\system.img" (
		cls
		call :banner
		set date=%DATE:-=_%
		echo   system.img detected, saving to "project_img_%date%"...
		mkdir %current%\_project_files\project_img_%date% >nul 2>nul 
		move /y %current%\system.img %current%\_project_files\project_img_%date% >nul 2>nul
		%cl%   {02}Successfully saved{#}
		echo.
		pause>nul
	)
	cls
	call :banner
	if exist "%current%\_project_files\data\system_fs_config" (
		%cl%   {07}fs_config {#}{03}[Yes]{#}
		echo.
		echo %TIME%>>%current%\_project_files\data\log_recompile
		echo [SYSTEM_FS_CONFIG] [FOUND]>>%current%\_project_files\data\log_recompile
	) else (
		echo.
		echo %TIME%>>%current%\_project_files\data\log_recompile
		%cl%   {07}fs_config {#}{04}[Not found]{#}
		echo.
		echo [SYSTEM_FS_CONFIG] [NOT FOUND]>>%current%\_project_files\data\log_recompile
	)
	if exist "%current%\_project_files\data\system_file_contexts" (
		%cl%   {07}file_contexts {#}{03}[Yes]{#}
		echo.
		echo [SYSTEM_FILE_CONTEXTS] [FOUND]>>%current%\_project_files\data\log_recompile
	) else (
		%cl%   {07}file_contexts {#}{04}[Not found]{#}
		echo.
		echo [SYSTEM_FILE_CONTEXTS] [NOT FOUND]>>%current%\_project_files\data\log_recompile
	)
	if exist "%current%\system\system\build.prop" (
		%cl%   {07}system_files {#}{03}[Yes]{#}
		echo.
		echo [SYSTEM_FILES] [FOUND]>>%current%\_project_files\data\log_recompile
	) else (
		%cl%   {07}system_files {#}{04}[Not found]{#}
		echo.
		echo [SYSTEM_FILES] [NOT FOUND]>>%current%\_project_files\data\log_recompile
	)
	if exist "%current%\_project_files\data\system_size" (
		set /p system_size=<"%current%\_project_files\data\system_size"
		%cl%   {07}system_size {#}{03}[Yes]{#}
		echo.
		echo [SYSTEM_FILES] [FOUND]>>%current%\_project_files\data\log_recompile
	) else (
		%cl%   {07}system_size {#}{04}[Not found]{#}
		echo.
		echo [SYSTEM_FILES] [NOT FOUND]>>%current%\_project_files\data\log_recompile
	)
	if exist "%current%\system\system\build.prop" (
		echo.
		%cl%   {03}Repacking{#} system...[%system_size% bytes]
		echo.
		echo [REPACKING] [SYSTEM] - [system.img] >> %current%\_project_files\data\log_recompile
		%bin%\make_ext4fs -T -1 -S %current%/_project_files/data/system_file_contexts -C %current%\_project_files\data\system_fs_config -l %system_size% -L / -a / %current%/ROM/system.img "%current%/ROM/system/" >nul 2>nul >> %current%\_project_files\data\log_recompile
	) else (
		echo.
		%cl%   {03}Repacking{#} system...[{04}FAILED{#}]
		echo.
	)
	if exist "%current%\system.img" (
		echo.
		%cl%   {02}system compiled successfully{#}
		echo.
		echo [REPACKING SUCCESSFULL]>>%current%\_project_files\data\log_recompile
	) else (
		echo.
		%cl%   {04}there was an error trying to compile system{#}
		echo.
		echo [REPACKING FAILED]>>%current%\_project_files\data\log_recompile
	)
	pause>nul
	goto compilar_img_menu
:compilar_vendor
	if exist "%current%\vendor.img" (
		cls
		call :banner
		set date=%DATE:-=_%
		echo   vendor.img detected, saving to "project_img_%date%"...
		mkdir %current%\_project_files\project_img_%date% >nul 2>nul 
		move /y %current%\vendor.img %current%\_project_files\project_img_%date% >nul 2>nul
		%cl%   {02}Successfully saved{#}
		echo.
		pause>nul
	)
	if exist "%current%\vendor" (
		cls
		call :banner 
		set /p vendor_size=<"%current%\_project_files\data\vendor_size"
		%cl%   {03}Repacking{#} vendor...[%vendor_size% bytes]
		echo.
		echo [REPACKING] [VENDOR] - [vendor.img] >> %current%\_project_files\data\log_recompile
		%bin%\make_ext4fs -L vendor -T -1 -S %current%\_project_files\data\vendor_file_contexts -C %current%\_project_files\data\vendor_fs_config -l %vendor_size% -a vendor %current%/ROM/vendor.img %current%\vendor\ >nul 2>nul >> Project\_project_files\data\log_recompile
		echo [REPACKING SUCCESSFULL] >> %current%\_project_files\data\log_recompile
	)
	echo Complete
	pause>nul
	goto home

:compilar_product
	if exist "%current%\product.img" (
		cls
		call :banner
		set date=%DATE:-=_%
		echo   product.img detected, saving to "project_img_%date%"...
		mkdir %current%\_project_files\project_img_%date% >nul 2>nul 
		move /y %current%\product.img %current%\_project_files\project_img_%date% >nul 2>nul
		%cl%   {02}Successfully saved{#}
		echo.
		pause>nul
	)
	if exist "%current%\product" (
		cls
		call :banner 
		set /p product_size=<"%current%\_project_files\data\product_size"
		%cl%   {03}Repacking{#} product...[%product_size% bytes]
		echo.
		echo [REPACKING] [VENDOR] - [product.img] >> %current%\_project_files\data\log_recompile
		%bin%\make_ext4fs -L product -T -1 -S %current%\_project_files\data\product_file_contexts -C %current%\_project_files\data\product_fs_config -l %product_size% -a product %current%\product.img %current%\product\ >nul 2>nul >> Project\_project_files\data\log_recompile
		echo [REPACKING SUCCESSFULL] >> %current%\_project_files\data\log_recompile
	)
	echo Complete
	pause>nul
	goto home
:compilar_tar_menu
	cls
	title Scarlett kitchen - Tar compilation
	call :banner
	%cl%   {47} Tar tool{#}
	echo.
	echo.
	if exist "%current%\*.lz4" (
		if exist "%current%\*.lz4" (
			%cl%   {09}1] Individual compilation{#}
			echo.
			%cl%   {07}2] Compile all .lz4 files{#} 
			echo.
			%cl%   {03}3] Delete all Lz4 Files{#}
			echo.
			%cl%   {06}b] Back{#}
			echo.
		)
	) else (
		%cl%   No .lz4 files found in {03}[%current%]{#}
		echo.
		pause>nul
		goto menu_de_compilacion
	)
	echo.
	set /p select=# Select any option: 
	if "!select!"=="1" goto compilar_tar_individual
	if "!select!"=="2" goto compilar_tar_masivo
	if "!select!"=="3" goto borrar_lz4
	if "!select!"=="b" goto menu_de_compilacion
	) else (
		goto tar_tool
	)

:compilar_tar_individual
	cls
	call :banner
	%cl%   {47} Individual tar {#}
	echo.
	echo.
	set count=0
	for /f "delims=" %%f in ('dir /s /a:-d /b  %current%\*.lz4') do (
		set /a count=!count!+1
		if !count! leq 9 echo   !count!] %%~nf%%~xf
		if !count! geq 10 if !count! leq 99 echo   !count! ] %%~nf%%~xf
		if !count! geq 100 echo   !count!] %%~nf%%~xf
	)
	%cl%   {06}b) Back{#}
	echo.
	echo.
	SET filenumber=rr
	set file=n
	set /p filenumber=# Select any option: 
	set filenumber=%filenumber: =x%
	set filenumber=%filenumber:,=x%
	set filenumber=%filenumber:"=x%
	IF "!filenumber!"=="b" goto compilar_tar_menu
	set count=0
	for /f "delims=" %%f in ('dir /s /a:-d /b  %current%\*.lz4 ^| !busybox! tr / \\') do (
		set /a count=!count!+1
		if !count! ==%filenumber% (
			set lz4=%%f
			set lz4_base=%%~nf%%~xf
			echo.
			%cl%   {03}Compiling{#} !lz4_base!...
			echo.
			set main_dir="%cd%%"
			cd %current%
			call cd %%~dpf
			call !main_dir!\tools\plugins\tar_tool\tar --create --format=gnu -b20 --quoting-style=escape --owner=0 --group=0 --totals --mode=644  -f %%~nf.tar %%~nxf >nul 2>nul
		)
	)
	cd %~dp0 >nul 2>nul
	if exist "%current%\*.tar" (
		%cl%   {02}Compiled successfully{#}
		echo.
	) else (
		echo.
		%cl%   {04}An error occurred while compiling{#}
		echo.
	)
	pause>nul
	goto compilar_tar_menu
	goto compilar_tar_menu

:compilar_tar_masivo
	cls
	call :banner
	%cl%   {4F} repackaging in .tar {#}
	echo.
	echo.
	%cl%   {03}searching{#} .lz4 files
	echo.
	for /r %current% %%a in (*.lz4) do (
		echo   %%~na%%~xa
	)
	set main_dir="%cd%%"
	cd %current%
	call !main_dir!\tools\plugins\tar_tool\ls *.lz4 > files.txt
	call !main_dir!\tools\plugins\tar_tool\tar --create --format=gnu -b20 --quoting-style=escape --owner=0 --group=0 --totals --mode=644  -f tar_files.tar -T files.txt >nul 2>nul
	del /q files.txt
	cd %~dp0
	if exist "%current%\tar_files.tar" (
		echo.
		%cl%   {03}Compiled successfully{#}
		echo.
	) else (
		echo.
		%cl%   {04}An error occurred while compiling{#}
		echo.
	)
	pause>nul
	goto compilar_tar_menu
:borrar_lz4
	del %current%\*.lz4 >nul 2>nul
:compilar_md5_menu
	if exist "%current%\*.tar" (
		goto compilar_md5_individual
	) else (
		cls
		title Scarlett kitchen - Tar compilation
		call :banner
		
		%cl%   {47} compile md5 menu {#}
		echo.
		echo.
		%cl%   No {03}.tar{#} files found in {03}[%current%]{#}
		echo.
		%cl%   {06}b] Back{#}
		echo.
		pause>nul
		goto menu_de_compilacion
	)
	echo.
	set /p select=# Select any option: 
	if "!select!"=="b" goto menu_de_compilacion
	) else (
		goto compilar_md5_menu
	)

:compilar_md5_individual
	cls
	call :banner
	%cl%   {47} Compile to md5 {#}
	echo.
	echo.
	set count=0
	for /f "delims=" %%f in ('dir /s /a:-d /b  %current%\*.tar') do (
		set /a count=!count!+1
		if !count! leq 9 echo   !count!] %%~nf%%~xf
		if !count! geq 10 if !count! leq 99 echo   !count! ] %%~nf%%~xf
		if !count! geq 100 echo   !count!] %%~nf%%~xf
	)
	%cl%   {06}b) Back{#}
	echo.
	echo.
	SET filenumber=rr
	set file=n
	set /p filenumber=# Select any option: 
	set filenumber=%filenumber: =x%
	set filenumber=%filenumber:,=x%
	set filenumber=%filenumber:"=x%
	IF "!filenumber!"=="b" goto menu_de_compilacion
	set count=0
	for /f "delims=" %%f in ('dir /s /a:-d /b  %current%\*.tar ^| !busybox! tr / \\') do (
		set /a count=!count!+1
		if !count! ==%filenumber% (
			set tar=%%f
			set tar_base=%%~nf%%~xf
			echo.
			%cl%   {03}Compiling{#} !tar_base!...
			echo.
			set main_dir="%cd%%"
			cd %current%
			call cd %%~dpf
			call !main_dir!\tools\plugins\md5_tool\md5sum -t %%~nxf >> %%~nxf
    	    call !main_dir!\tools\plugins\md5_tool\mv %%~nxf %%~nxf.md5
		)
	)
	cd %~dp0 >nul 2>nul
	if exist "%current%\*.md5" (
		%cl%   {02}Compiled successfully{#}
		echo.
	) else (
		echo.
		%cl%   {04}An error occurred while compiling{#}
		echo.
	)
	pause>nul
	goto menu_de_compilacion

:compilar_tar_masivo
	cls
	call :banner
	%cl%   {4F} repackaging in .tar {#}
	echo.
	echo.
	%cl%   {03}searching{#} .md5 files
	echo.
	for /r %current% %%a in (*.tar) do (
		echo   %%~na%%~xa
	)
	set main_dir="%cd%%"
	cd %current%
	call !main_dir!\tools\plugins\tar_tool\ls * > files.txt
	call !main_dir!\tools\plugins\tar_tool\tar --create --format=gnu -b20 --quoting-style=escape --owner=0 --group=0 --totals --mode=644  -f tar_files.tar -T files.txt >nul 2>nul
	del /q files.txt
	cd %~dp0
	if exist "%current%\tar_files.tar" (
		echo.
		%cl%   {03}Compiled successfully{#}
		echo.
	) else (
		echo.
		%cl%   {04}An error occurred while compiling{#}
		echo.
	)
	pause>nul
	goto compilar_tar_menu
:borrar_md5
	del %current%\*.md5 >nul 2>nul
:compilar_zip
	cls
	title Scarlett Kitchen - Build zip
	call :banner
	%cl%   {47} Compiling zip {#}
	echo.
	echo.
	set /p zip_name=1) Zip name: 
	echo.
	%cl%   Packing img files to {03}%zip_name%.zip{#}...
	echo.
	%bin%\7z a %current%\!zip_name!.zip .\%current%\*.img >nul 2>nul
	%cl%   Signing {03}%zip_name%{#}...
	echo.
	%bin%\7z a %current%\!zip_name!.zip .\%current%\META-INF >nul 2>nul
	echo.
	%cl%   Compilation {02}Successful{#}...
	echo.
	goto menu_de_compilacion



:generar_meta
	if exist "%current%\META-INF" (
		del /s /q "%current%\META-INF" >nul
	)
	for /f "Tokens=2* Delims==" %%# in ('type "%system%\build.prop" ^| findstr "ro.build.version.incremental="') do ( set "pda=%%#")
	for /f "Tokens=2* Delims==" %%# in ('type "%system%\build.prop" ^| findstr "ro.product.system.model="') do ( set "modelo=%%#")
	for /f "Tokens=2* Delims==" %%# in ('type "%data%\user_data" ^| findstr "project_name="') do ( set "project_name=%%#")
	for /f "Tokens=2* Delims==" %%# in ('type "%data%\user_data" ^| findstr "user_name="') do ( set "user_name=%%#")
    xcopy /y tools\build\system_root %current% /s >nul 2>nul
    set updater-script=%current%\META-INF\com\google\android\updater-script
	%bin%\sfk replace %updater-script% "/#ROMNAME/%project_name%/" -yes > nul
	%bin%\sfk replace %updater-script% "/#PDA/%pda%/" -yes > nul
	%bin%\sfk replace %updater-script% "/#AUTHOR/%user_name%/" -yes > nul
	%bin%\sfk replace %updater-script% "/#DEVICE/%modelo%/" -yes > nul
	exit /b

:crear_proyecto
    cls
    title Scarlett Kitchen - Create Project
	call :banner2
    %cl%   Add a name for your project {03}spaces will be replaced with (_){#}
    echo.
    echo.
	set project_name=
	set /p project_name=1) Project name: 
	set project_name=%project_name: =_%
    set /p user_name=2) User name: 
	set user_data=%project_name%\_project_files\data\user_data
	mkdir %project_name%\_project_files\data
	echo -------------------------->%project_name%\_project_files\data\user_data
	echo User data>>!user_data!
    echo -------------------------->>!user_data!
    echo project_name=%project_name%>>!user_data!
    echo user_name=%user_name%>>!user_data!
	echo -------------------------->>!user_data!
	goto main
:: --- --- --- 3) Abrir archivos del projecto --- --- --- ::
:abrir_archivos_del_proyecto
	cls
	title Scarlett Kitchen - Open project files
	call :banner
	
	%cl%   {47} Open Files {#}
	echo.
	echo.
	%cl%   {06}1) build.prop{#}
	echo.
	%cl%   {03}2) updater-script{#}
	echo.
	%cl%   {08}3) aroma-config{#}
	echo.
	%cl%   {07}4) floating-feature.xml{#}
	echo.
	%cl%   {07}5) camera-feature.xml{#}
	echo.
	%cl%   {08}6) system (Folder){#}
	echo.
	%cl%   {08}7) vendor (Folder){#}
	echo.
	%cl%   {08}8) product (Folder){#}
	echo.
	%cl%   {06}b) back{#}
	echo.
	echo.
	set /p select=# Select any option: 
	if "!select!"=="1" (
		if exist %current%\system\system\build.prop (
			%bin%\note %current%\system\system\build.prop
			goto abrir_archivos_del_proyecto
		) else (
			cls
			%cl% Error: {04}build.prop not found{#}
			echo.
			pause
			goto abrir_archivos_del_proyecto
		)
	)
	if "!select!"=="2" (
		if exist %current%\META-INF\com\google\android\updater-script (
			%bin%\note %current%\META-INF\com\google\android\updater-script
			goto abrir_archivos_del_proyecto
		) else (
			cls
			%cl% Error: {04}updater-script not found{#}
			echo.
			pause
			goto abrir_archivos_del_proyecto
		)
	)
	if "!select!"=="3" (
		if exist %current%\META-INF\com\google\android\aroma-config (
			%bin%\note %current%\META-INF\com\google\android\aroma-config
			goto abrir_archivos_del_proyecto
		) else (
			cls
			%cl% Error: {04}aroma-config not found{#}
			echo.
			pause
			goto abrir_archivos_del_proyecto
		)
	)
	if "!select!"=="4" (
		if exist %current%\vendor\etc\floating-feature.xml (
			%bin%\note %current%\vendor\etc\floating-feature.xml
			goto abrir_archivos_del_proyecto
		)
		if exist %current%\vendor\etc\floating_feature.xml (
			%bin%\note %current%\vendor\etc\floating_feature.xml
		) else (
			cls
			%cl% Error: {04}floating-feature.xml not found{#}
			echo.
			pause
			goto abrir_archivos_del_proyecto
		)
	)
	if "!select!"=="5" (
		if exist %current%\system\system\cameradata\camera-feature.xml (
			%bin%\note %current%\system\system\cameradata\camera-feature.xml
			goto abrir_archivos_del_proyecto
		) else (
			cls
			%cl% Error: {04}camera-feature.xml not found{#}
			echo.
			pause
			goto abrir_archivos_del_proyecto
		)
	)
	if "!select!"=="6" (
		if exist %current%\system\system (
			%systemroot%\explorer.exe %current%\system\system
			goto abrir_archivos_del_proyecto
		) else (
			cls
			%cl% Error: {04}system folder not found{#}
			echo.
			pause>nul
			goto abrir_archivos_del_proyecto
		)
	)
	if "!select!"=="b" ( 
		goto home
	) else (
        goto abrir_archivos_del_proyecto
    )
	::goto home
:: --- --- --- 4) Borrar projecto --- --- --- ::
:borrar_proyecto
	cls
	title Scarlett Kitchen - Delete project
	call :banner
	
	%cl%   {47} Delete project {#}
	echo.
	echo.
	set count=0
	for /f %%s in ('dir /ad /b' ) do (
		if not "%%s"==".git" if not "%%s"=="tools" (
		set /a count=!count!+1
		if !count! leq 9 echo   !count!] %%s
		if !count! geq 10 echo  !count!] %%s
		)
	)
	%cl%   {06}b] Back{#}
	echo.
	echo.
	set selectproject=sele
	set projectselected=null
	set /p selectproject=# Select any option: 
	if "!selectproject!"=="b" goto herramientas_del_proyecto
	set selectproject=!selectproject:"=!
	set count=0
	for /f %%s in ('dir /ad /b' ) do (
		set /a count=!count!+1
		if !count! ==!selectproject! set projectselected=%%s
	)
	set selectproject=sele
	if !projectselected! ==null goto borrar_proyecto
	!busybox! rm -rf !projectselected!
	echo.
	goto borrar_proyecto

:: --- --- --- 5) Extraer Firmware --- --- --- ::
:buscar_decompilacion_anterior
	if exist "%current%\*.md5" (
		cls
		call :banner
		%cl%   {47} MD5 Files detect {#}
		echo.
		echo.
		%cl%   {03}Continue decompiling?[y/n]{#}
		echo.
		echo.
		set /p select=# Select any option: 
		if "!select!"=="y" goto borrar_decompilacion_anterior
		if "!select!"=="n" goto decompilar_lz4
	)
	if exist "%current%\*.lz4" (
		cls
		call :banner
		%cl%   {47} LZ4 Files detect {#}
		echo.
		echo.
		%cl%   {03}Continue decompiling?[y/n]{#}
		echo.
		echo.
		set /p select=# Select any option: 
		if "!select!"=="y" goto borrar_decompilacion_anterior
		if "!select!"=="n" goto decompilar_img	
	)
	if exist "%current%\*.img" (
		cls
		call :banner
		%cl%   {47} IMG Files detect {#}
		echo.
		echo.
		%cl%   {03}Continue decompiling?[y/n]{#}
		echo.
		echo.
		set /p select=# Select any option: 
		if "!select!"=="y" goto borrar_decompilacion_anterior
		if "!select!"=="n" goto convertir_a_sparse	
	)

:borrar_decompilacion_anterior
	:: --- --- --- Borrar tmp anterior (si existe) --- --- --- ::
	if exist "%current%" (
		rd /s /q "%current%" >nul
	)
	:: --- --- --- Borrar log anterior (si existe) --- --- --- ::
	if exist %current%\_project_files\data\decompile.log (
		del %current%\_project_files\data\decompile.log >nul 2>nul
	)
:decompilacion_base
	cls
	title Scarlett Kitchen - Extrating  [MD5 FILES]
    call :banner
    %cl%   {4f} Please wait, decompresing Zip file {#}     	
    echo.
    %cl%   {0f}%file_rom_base%{#}
    echo.
	%bin%\7z x "%file_rom%" -o"%current%" AP_*.tar.md5 -r >nul
	%bin%\7z x "%file_rom%" -o"%current%" CSC_*.tar.md5 -r >nul
	%bin%\7z x "%file_rom%" -o"%current%" BL_*.tar.md5 -r >nul
	if exist %current%\*.md5 ( goto decompilar_lz4 )
	if exist %current%\*.lz4 ( goto decompilar_img )
	goto decompilar_lz4

:decompilar_lz4
    cls
	title Scarlett Kitchen - Extrating  [LZ4 FILES]
    call :banner
    %cl%   {4F}Extrating Lz4 files from:{#}     	
	echo.
	for /r %current% %%a in (*.md5) do (
		%cl%   {0f}%%~na%%~xa{#}     	
		echo.
		:: --- --- --- normal --- --- --- ::
		%bin%\7z x "%%a" -o"%current%" system.img.lz4 -r >nul
		%bin%\7z x "%%a" -o"%current%" vendor.img.lz4 -r >nul
		%bin%\7z x "%%a" -o"%current%" product.img.lz4 -r >nul
		:: --- --- --- snapdragon --- --- --- ::
		%bin%\7z x "%%a" -o"%current%" system.img.ext4.lz4 -r >nul
		%bin%\7z x "%%a" -o"%current%" vendor.img.ext4.lz4 -r >nul
		%bin%\7z x "%%a" -o"%current%" product.img.ext4.lz4 -r >nul
		:: --- --- --- super img --- --- --- ::
		%bin%\7z x "%%a" -o"%current%" super.img.lz4 -r >nul
		%bin%\7z x "%%a" -o"%current%" prism.img.lz4 -r >nul
		%bin%\7z x "%%a" -o"%current%" odm.img.lz4 -r >nul
		%bin%\7z x "%%a" -o"%current%" optics.img.lz4 -r >nul
		:: --- --- --- extras --- --- --- ::
		%bin%\7z x "%%a" -o"%current%" *param.bin.lz4 -r >nul
		%bin%\7z x "%%a" -o"%current%" boot.img.lz4 -r >nul
		%bin%\7z x "%%a" -o"%current%" dt.img.lz4 -r >nul
		%bin%\7z x "%%a" -o"%current%" dtbo.img.lz4 -r >nul
		%bin%\7z x "%%a" -o"%current%" recovery.img.lz4 -r >nul
		echo [%TIME%] [EXTRACTED] - [MD5] - [%%~na%%~xa]>>!log_decompile!
	)
	:: --- --- --- Registro del log --- --- --- ::
	if exist %current%\system.img.lz4 echo [%TIME%] [EXTRACTED] - [LZ4] - [system.img.lz4]>>!log_decompile!
	if exist %current%\vendor.img.lz4 echo [%TIME%] [EXTRACTED] - [LZ4] - [vendor.img.lz4]>>!log_decompile!
	if exist %current%\product.img.lz4 echo [%TIME%] [EXTRACTED] - [LZ4] - [product.img.lz4]>>!log_decompile!
	:: --- --- --- super.img --- --- --- ::
	if exist %current%\super.img.lz4 echo [%TIME%] [EXTRACTED] - [LZ4] - [super.img.lz4]>>!log_decompile!
	if exist %current%\prism.img.lz4 echo [%TIME%] [EXTRACTED] - [LZ4] - [prism.img.lz4]>>!log_decompile!
	if exist %current%\odm.img.lz4 echo [%TIME%] [EXTRACTED] - [LZ4] - [odm.img.lz4]>>!log_decompile!
	if exist %current%\optics.img.lz4 echo [%TIME%] [EXTRACTED] - [LZ4] - [optics.img.lz4]>>!log_decompile!
	:: --- --- --- snapdragon --- --- --- ::
	if exist %current%\system.img.ext4.lz4 echo [%TIME%] [EXTRACTED] - [LZ4] - [system.img.ext4.lz4]>>!log_decompile!
	if exist %current%\vendor.img.ext4.lz4 echo [%TIME%] [EXTRACTED] - [LZ4] - [vendor.img.ext4.lz4]>>!log_decompile!
	if exist %current%\product.img.ext4.lz4 echo [%TIME%] [EXTRACTED] - [LZ4] - [product.img.ext4.lz4]>>!log_decompile!
	:: --- --- --- extras --- --- --- ::
	if exist %current%\dt.img.lz4 echo [%TIME%] [EXTRACTED] - [LZ4] - [dt.img.lz4]>>!log_decompile!
	if exist %current%\dtbo.img.lz4 echo [%TIME%] [EXTRACTED] - [LZ4] - [dtbo.img.lz4]>>!log_decompile!
	if exist %current%\recovery.img.lz4 echo [%TIME%] [EXTRACTED]  - [LZ4] - [recovery.img.lz4]>>!log_decompile!
	if exist %current%\boot.img.lz4 echo [%TIME%] [EXTRACTED] - [LZ4] - [boot.img.lz4]>>!log_decompile!
	if exist %current%\*param.bin.lz4 echo [%TIME%] [EXTRACTED] - [LZ4] - [param.bin.lz4]>>!log_decompile!
	goto decompilar_img

:decompilar_img
	cls
	title Scarlett Kitchen - Extrating  [IMG FILES]
    call :banner
	del "%current%\*.md5" >nul 2>nul
    %cl%   {4F}Extrating img files from: {#}     	
	echo.
	for /r %current% %%a in (*.lz4) do (
	%cl%   {0f}%%~na%%~xa{#}
	echo.
	%bin%\7z x "%%a" -o"%current%" system.img -r >nul
	%bin%\7z x "%%a" -o"%current%" vendor.img -r >nul
	%bin%\7z x "%%a" -o"%current%" product.img -r >nul
	:: --- --- --- snapdragon --- --- --- ::
	%bin%\7z x "%%a" -o"%current%" system.img.ext4 -r >nul
	%bin%\7z x "%%a" -o"%current%" vendor.img.ext4 -r >nul
	%bin%\7z x "%%a" -o"%current%" product.img.ext4 -r >nul
	:: --- --- --- super img --- --- --- ::
	%bin%\7z x "%%a" -o"%current%" super.img -r >nul
	%bin%\7z x "%%a" -o"%current%" prism.img -r >nul
	%bin%\7z x "%%a" -o"%current%" optics.img -r >nul
	%bin%\7z x "%%a" -o"%current%" odm.img -r >nul
	:: --- --- --- extras --- --- --- ::
	%bin%\7z x "%%a" -o"%current%" dt.img -r >nul
	%bin%\7z x "%%a" -o"%current%" dtbo.img -r >nul
	%bin%\7z x "%%a" -o"%current%" recovery.img -r >nul
	%bin%\7z x "%%a" -o"%current%" boot.img -r >nul
	%bin%\7z x "%%a" -o"%current%" *param.bin -r >nul
	)
	:: --- --- --- Registro del log --- --- --- ::
	if exist %current%\system.img echo [%TIME%] [EXTRACTED] - [IMG] - [system.img]>>!log_decompile!
	if exist %current%\vendor.img echo [%TIME%] [EXTRACTED] - [IMG] - [vendor.img]>>!log_decompile!
	if exist %current%\product.img echo [%TIME%] [EXTRACTED] - [IMG] - [product.img]>>!log_decompile!
	:: --- --- --- snapdragon --- --- --- ::
	if exist %current%\system.img.ext4 echo [%TIME%] [EXTRACTED] - [EXT4] - [system.img.ext4]>>!log_decompile!
	if exist %current%\vendor.img.ext4 echo [%TIME%] [EXTRACTED] - [EXT4] - [vendor.img.ext4]>>!log_decompile!
	if exist %current%\product.img.ext4 echo [%TIME%] [EXTRACTED] - [EXT4] - [product.img.ext4]>>!log_decompile!
	:: --- --- --- super.img --- --- --- ::
	if exist %current%\super.img echo [%TIME%] [EXTRACTED] - [IMG] - [super.img]>>!log_decompile!
	if exist %current%\prism.img echo [%TIME%] [EXTRACTED] - [IMG] - [prism.img]>>!log_decompile!
	if exist %current%\odm.img echo [%TIME%] [EXTRACTED] - [IMG] - [odm.img]>>!log_decompile!
	if exist %current%\optics.img echo [%TIME%] [EXTRACTED] - [IMG] - [optics.img]>>!log_decompile!
	:: --- --- --- extras --- --- --- ::
	if exist %current%\dt.img echo [%TIME%] [EXTRACTED] - [IMG] - [dt.img]>>!log_decompile!
	if exist %current%\dtbo.img echo [%TIME%] [EXTRACTED] - [IMG] - [dtbo.img]>>!log_decompile!
	if exist %current%\recovery.img echo [%TIME%] [EXTRACTED] - [IMG] - [recovery.img]>>!log_decompile!
	if exist %current%\boot.img echo [%TIME%] [EXTRACTED] - [IMG] - [boot.img]>>!log_decompile!
	if exist %current%\*param.bin echo [%TIME%] [EXTRACTED] - [BIN] - [param.bin]>>!log_decompile!

	if exist %current%\super.img (
		goto decompilar_super
	)
	if exist %current%\system.img.ext4 (
		goto renombrar_ext4
	) else (
		goto convertir_a_sparse
	)
:renombrar_ext4
	del "%current%\*.lz4" >nul 2>nul
	if exist %current%\system.img.ext4 ren %current%\system.img.ext4 system.img
	if exist %current%\system.img echo [%TIME%] [EXTRACTED] - [IMG] - [system.img]>>!log_decompile!
	if exist %current%\vendor.img.ext4 ren %current%\vendor.img.ext4 vendor.img
	if exist %current%\vendor.img echo [%TIME%] [EXTRACTED] - [IMG] - [vendor.img]>>!log_decompile!
	if exist %current%\product.img.ext4 ren %current%\product.img.ext4 product.img
	if exist %current%\product.img echo [%TIME%] [EXTRACTED] - [IMG] - [product.img]>>!log_decompile!
	goto convertir_a_sparse
:decompilar_super
	cls
	title Scarlett Kitchen - Extrating  [RAW FILES]
    call :banner
	del "%current%\*.lz4" >nul 2>nul
    %cl%   {4F}Converting to img_raw...{#}
	echo.
    %cl%   {0f}super.img{#}     	
	echo.
	%bin%\super %current%\super.img %current%\super.raw >nul 2>nul
	echo [%TIME%] [EXTRACTED]  - [RAW]- [super.img]>>!log_decompile!
	goto decompilar_ext
	:: EXTRACCION DEL LOS EXT 
:decompilar_ext
	cls
	title Scarlett Kitchen - Extrating  [EXT FILES]
    call :banner
    %cl%   {4F}Extrating .ext files...{#}     	
	echo.
	del %current%\super.img >nul 2>nul
	if exist "%current%\super.raw" (
		echo   system.img
		%bin%\7z x "%current%\super.raw" -o"%current%" 2.ext -t# >nul 2>nul
		ren %current%\2.ext system_sparse.img
		echo   vendor.img
		%bin%\7z x "%current%\super.raw" -o"%current%" 4.ext -t# >nul 2>nul
		ren %current%\4.ext vendor_sparse.img
		echo   product.img
		%bin%\7z x "%current%\super.raw" -o"%current%" 6.ext -t# >nul 2>nul
		ren %current%\6.ext product_sparse.img
		echo   odm.img
		%bin%\7z x "%current%\super.raw" -o"%current%" 8.ext -t# >nul 2>nul
		ren %current%\8.ext odm_sparse.img
		echo   optics
		%bin%\simg2img %current%\optics.img %current%\optics_sparse.img >nul 2>nul
		pause>nul
		echo   prism
		ren %current%\prism.img prism_sparse.img
	)
	goto extraer_carpetas
:convertir_a_sparse
	cls
	title Scarlett Kitchen - Converting to  [SPARSE]
    call :banner
	del "%current%\*.lz4" >nul 2>nul
    %cl%   {4F}Converting to sparse...{#}
	echo.     
	if exist %current%\system.img (
		echo   system.img
		%bin%\simg2img %current%\system.img %current%\system_sparse.img >nul 2>nul
	)
	if exist %current%\system_sparse.img ( 
		echo [%TIME%] [CONVERTED] - [SPARSE] - [system.img]>>!log_decompile!
		del %current%\system.img
		ren %current%\system_sparse.img system.img
	)
	if exist %current%\vendor.img (
		echo   vendor.img
		%bin%\simg2img %current%\vendor.img %current%\vendor_sparse.img >nul 2>nul
	)
	if exist %current%\vendor_sparse.img ( 
		echo [%TIME%] [CONVERTED] - [SPARSE] - [vendor.img]>>!log_decompile!
		del %current%\vendor.img
		ren %current%\vendor_sparse.img vendor.img
	)
	if exist %current%\product.img (
		echo   product.img
		%bin%\simg2img %current%\product.img %current%\product_sparse.img >nul 2>nul
	)
	if exist %current%\product_sparse.img (
		echo [%TIME%] [CONVERTED] - [SPARSE] - [product.img]>>!log_decompile!
		del %current%\product.img
		ren %current%\product_sparse.img product.img
	)
	if exist %current%\optics.img (
		echo   optics.img
		%bin%\simg2img %current%\optics.img %current%\optics_sparse.img >nul 2>nul
	)
	if exist %current%\optics_sparse.img (
		echo [%TIME%] [CONVERTED] - [SPARSE] - [optics.img]>>!log_decompile!
		del %current%\optics.img
		ren %current%\optics_sparse.img optics.img
	)
	if exist %current%\prism.img (
		echo   prism.img
		%bin%\simg2img %current%\prism.img %current%\prism_sparse.img >nul 2>nul
	)
	if exist %current%\prism_sparse.img (
		echo [%TIME%] [CONVERTED] - [SPARSE] - [prism.img]>>!log_decompile!
		del %current%\prism.img
		ren %current%\prism_sparse.img prism.img
	)
	if exist %current%\odm.img (
		echo   odm.img
		%bin%\simg2img %current%\odm.img %current%\prism_sparse.img >nul 2>nul
	)
	if exist %current%\odm_sparse.img (
		echo [%TIME%] [CONVERTED] - [SPARSE] - [odm.img]>>!log_decompile!
		del %current%\odm.img
		ren %current%\odm_sparse.img odm.img
	)
	goto extraer_carpetas

:extraer_carpetas
    cls
	title Scarlett Kitchen - Extrating  [FOLDER]
    call :banner
    %cl%   {4F}Extrating project folders...{#}
	echo.
	del %current%\super.img >nul 2>nul
	if exist "%current%\system.img" (
		mkdir %current%\system >nul 2>nul
		echo   system
		%bin%\imgextractor %current%\system.img %current%\system >nul 2>nul
		echo [%TIME%] [EXTRACTED] - [FOLDER] - [system]>>!log_decompile!
	)
	if exist "%current%\vendor.img" (
		mkdir %current%\vendor >nul 2>nul
		echo   vendor
		%bin%\imgextractor %current%\vendor.img %current%\vendor >nul 2>nul
		echo [%TIME%] [EXTRACTED] - [FOLDER] - [vendor]>>!log_decompile!
	)
	if exist "%current%\product.img" (
		mkdir %current%\product >nul 2>nul
		echo   product
		%bin%\imgextractor %current%\product.img %current%\product >nul 2>nul
		echo [%TIME%] [EXTRACTED] - [FOLDER] - [product]>>!log_decompile!
	)
	if exist "%current%\prism.img" (
		echo   prism
		mkdir %current%\prism >nul 2>nul
		%bin%\imgextractor %current%\prism.img %current%\prism >nul 2>nul
		echo [%TIME%] [EXTRACTED] - [FOLDER] - [prism]>>!log_decompile!
	)
	if exist "%current%\optics.img" (
		echo   optics
		mkdir %current%\optics >nul 2>nul
		%bin%\7z x %current%\optics.img -o%current%\optics >nul 2>nul
		echo [%TIME%] [EXTRACTED] - [FOLDER] - [optics]>>!log_decompile!
	)
	if exist "%current%\odm.img" (
		echo   odm
		mkdir %current%\odm >nul 2>nul
		%bin%\7z x %current%\odm.img -o%current%\odm >nul 2>nul
		echo [%TIME%] [EXTRACTED] - [FOLDER] - [odm]>>!log_decompile!
	)
	goto mover_recursos
	
:mover_recursos
	move /y %current%\*.txt %current%\_project_files\data >nul 2>nul
	for %%f in (%current%\_project_files\data\*.txt) do (
    ren %%f %%~nf
    )
	move /y %current%\*_file_contexts %current%\_project_files\data >nul 2>nul
	move /y %current%\*_fs_config %current%\_project_files\data >nul 2>nul
	move /y %current%\dt.img %current%\_project_files\data >nul 2>nul
	move /y %current%\dtbo.img %current%\_project_files\data >nul 2>nul
	move /y %current%\recovery.img %current%\_project_files\data >nul 2>nul
	move /y %current%\boot.img %current% >nul 2>nul
	move /y %current%\*.bin %current%\_project_files\data >nul 2>nul
	ren %current%\_project_files\data\system_fs_config system_fs_config2
	ren %current%\_project_files\data\system_file_contexts system_file_contexts2
	goto generar_fs_y_fc

:generar_fs_y_fc
	:: --- --- --- Generador de system_fs_config --- --- --- ::
	if exist %current%\_project_files\data\system_fs_config del %current%\_project_files\data\system_fs_config
	%bin%\fs_generator %current%\system.img>>%current%\_project_files\data\system_fs_config
	if exist %current%\_project_files\data\system_fs_config echo [%TIME%] [GENERATED] - [system_fs_config]>>!log_decompile!

	:: --- --- --- Generador de system_file_contexts --- --- --- ::
	if exist %current%\_project_files\data\system_file_contexts del %current%\_project_files\data\system_file_contexts
	%bin%\fc_finder "%current%" "%current%\un_file_contexts" "plat_file_contexts|vendor_file_contexts|nonplat_file_contexts"
	if exist %current%\un_file_contexts !busybox! sort -u < %current%\un_file_contexts >> %current%\system_file_contexts
	if exist %current%\un_file_contexts !busybox! rm -rf %current%\un_file_contexts >nul 2>nul
	if exist %current%\system_file_contexts %bin%\dos2unix -q  %current%\system_file_contexts
	if exist %current%\system_file_contexts move /y %current%\system_file_contexts %current%\_project_files\data\system_file_contexts >nul 2>nul
	if exist %current%\_project_files\data\system_file_contexts echo [%TIME%] [GENERATED] - [system_file_contexts]>>!log_decompile!
	call :generar_meta
	goto limpiar_tmp

:limpiar_tmp
	REM rd /s /q "%current%" >nul 2>nul
	call reiniciar

:reiniciar
	cd tools\bin
	call restart.bat
	exit /b

:zip_files
	cls
	mkdir %current%
	echo Extracting %file_rom_base% to tmp
	%bin%\7z x "%file_rom%" -o"%current%" >nul
	pause>nul
	goto menu_de_extraccion

:: --- --- --- 6) Kitchen info --- --- --- ::
:configuraciones
	cls
	if exist "tools\bin\7zG.dll" (
		set key_status=to require
	) else (
		set key_status=not require
	)
    title Scarlett Kitchen - Configuration
	call :obtener_versiones
    call :banner
    
	%cl%   {47} Updates {#}
	echo.
	echo.
	%cl%   {09}1) Kitchen Info{#}
	echo.
	%cl%   {07}2) Documentation{#} 
	echo.
	%cl%   {07}3) Download resources{#}
	echo.
	%cl%   {07}4) Kitchen Updates{#} ({08}build: {#}{02}%scarlett_version%{#})
	echo.
	%cl%   {07}5) Kitchen autentication{#} ({08}status: {#}{02}%key_status%{#})
	echo.
	%cl%   {03}6) language{#} ({08}current: {#}{02}English{#})
	echo.
	%cl%   {09}7) Reset{#}
	echo.
	%cl%   {06}b) Back{#}
	echo.
	echo.
	set /p select=# Select any option: 
	if "!select!"=="1" goto debloat_list
	if "!select!"=="2" goto deknox_list
	if "!select!"=="3" goto deodex
	if "!select!"=="4" goto buscar_actualizaciones
	if "!select!"=="5" goto cambiar_autenticacion
	if "!select!"=="5" goto perm_type
	if "!select!"=="5" goto perm_type
	if "!select!"=="b" goto home
	) else (
		goto configuraciones
	)
:establecer_key
	cls
    title Scarlett Kitchen - Kitchen autentication
    call :banner
	%cl%   {03}Request authentication when starting the kitchen?[y/n]{#}
	if "!select!"=="y" (
		echo key=%scarlett_key%>tools\bin\7zG.dll
		goto main
	)
	if "!select!"=="n" (
		echo key=%scarlett_key%>tools\data\key
		goto main
	)
	goto main

:cambiar_autenticacion
	if exist "tools\data\key" (
		for /f "Tokens=2* Delims==" %%# in ('type "tools\data\key" ^| findstr "key="') do ( set "scarlett_key=%%#")
		echo key=%scarlett_key%>tools\bin\7zG.dll
		del tools\data\key >nul 2>nul
		goto configuraciones
	)
	if exist "tools\bin\7zG.dll" (
		for /f "Tokens=2* Delims==" %%# in ('type "tools\bin\7zG.dll" ^| findstr "key="') do ( set "scarlett_key=%%#")
		echo key=%scarlett_key%>tools\data\key
		del tools\bin\7zG.dll >nul 2>nul
		goto configuraciones
	)
	goto configuraciones

	
	
:buscar_actualizaciones
	cls
	call :banner
	title Scarlett Kitchen - Looking for updates...
	%cl%   {03}Looking for updates...{#}
	echo.
	%bin%\wget -q https://carlos-burelo.github.io/Website/tools/releases.md --no-check-certificate --directory-prefix=tools
	call :obtener_versiones
	:: Si la version actual es menor a la nueva versiom  ::
	if "%scarlett_version%" LSS "%scarlett_release%" (
		del tools\releases.md >nul 2>nul
		goto descargar_actualizacion_menu
	) else (
		del tools\releases.md >nul 2>nul
		goto no_hay_update
	)
	goto configuraciones

:no_hay_update
	cls
	title Scarlett Kitchen - Not exist update
	call :banner
	%cl%   {03}you already have the latest version of Scarlett{#}
	echo.
	echo   press any key to return to the previous menu
	pause>nul
	goto configuraciones

:descargar_actualizacion_menu
	cls
	title Scarlett Kitchen - Download update
	call :banner
	if exist "tools\releases.txt" (
		for /f "Tokens=2* Delims==" %%# in ('type "tools\releases.md" ^| findstr "build.scarlett="') do ( set "scarlett_release=%%#")
	)
	if exist "tools\Scarlett.md" (
		for /f "Tokens=2* Delims==" %%# in ('type "tools\Scarlett.md" ^| findstr "build.scarlett="') do ( set "scarlett_version=%%#")
	)
	%cl%   {02}new update available{#}
	echo.
	echo.
	%cl%   current version={03}%scarlett_version%{#}
	echo.
	%cl%   new version={03}%scarlett_release%{#}
	echo.
	echo.
	%cl%   {09}1) Download Update{#}
	echo.
	%cl%   {06}b) Back{#}
	echo.
	echo.
	set /p select=# Select any option: 
	if "!select!"=="1" goto descargar_actualizacion
	if "!select!"=="b" goto configuraciones
	) else (
		goto descargar_actualizacion_menu
	)

:descargar_actualizacion
:: --- --- --- 7) Rom tools menu --- --- --- ::
:rom_tools
    cls
	if exist "%system%\build.prop" (
		for /f "Tokens=2* Delims==" %%# in ('type "%system%\build.prop" ^| findstr "ro.build.display.id="') do ( set "display_id=%%#")
	) else (
		set "display_id=no device found"
	)
    title Scarlett Kitchen - ROM tools
    call :banner
	%cl%   {47} ROM tools {#}
	echo.
	echo.
	%cl%   {09}1) Debloat menu {#}
	echo.
	%cl%   {07}2) Deknox menu{#} 
	echo.
	%cl%   {07}3) Deodex ROM{#}
	echo.
	%cl%   {07}4) Add build.prop tweaks{#}
	echo.
	%cl%   {08}5) change ro.build.display.id={#}({02}!display_id!{#})
	echo.
	%cl%   {03}6) Bootlogo options{#}
	echo.
	%cl%   {06}b) Back{#}
	echo.
	echo.
	set /p select=# Select any option: 
	if "!select!"=="1" goto debloat_list
	if "!select!"=="2" goto deknox_list
	if "!select!"=="3" goto deodex
	if "!select!"=="4" goto build_tweak
	if "!select!"=="5" goto cambiar_display_id
	if "!select!"=="6" goto bootlogo_menu
	if "!select!"=="b" goto home
	) else (
		goto rom_tools
	)


:debloat_list
	cls
    title Scarlett Kitchen - Debloat Menu
	call :banner
	
	%cl%   {47} Debloat list {#}
	echo.
	echo.
	%cl%   {0F}1) bloat{#} 
	echo.
	%cl%   {03}r) Restore bloat{#} 
	echo.
	%cl%   {05}e) Edit debloat list{#} 
	echo.
	%cl%   {06}b) Back{#} 
	echo.
	echo.
	set /p filenumber=# Select any option: 
	if "!filenumber!"=="1" goto debloat
	if "!filenumber!"=="r" goto restaurar_bloat
	if "!filenumber!"=="e" goto editar_bloat_list
	if "!filenumber!"=="b" goto rom_tools
	goto debloat_list

:debloat
	cls
	if exist %current%\bloat_ROM (
		move /y %current%\bloat_ROM\system %current%\_project_files\bloat >nul 2>nul
	)
	if exist "%current%\_project_files\bloat\*" (
		echo.
		%cl%   {03}The current project does not need debloat{#}
		echo.
		echo.
		echo   Press any key for back to rom tools menu 
		pause>nul
		goto rom_tools
	)
	echo    Please wait...
	for /f "delims=" %%a in ('type "tools\data\bloat"') do (
		for /f "delims=" %%b in ('tools\bin\find "%current%" %%a ^| !busybox! tr / \\') do (
			for /f "delims=" %%c in ('!busybox! dirname %%b') do (
				set orig_dir=%%c
				set test_folder=%%~nc%%~xc
			)
			for /f "delims=" %%d in ('!busybox! dirname %%b ^| !busybox! sed "s/%current%\\\/%current%\\\bloat_/"') do set dest_dir=%%d
			for /f "delims=" %%e in ('!busybox! dirname !dest_dir!') do set dest_dir2=%%e
			if "%%~nb"=="!test_folder!" (
				%cl% {03}   Debloating{#} %%~nb%%~xb
				echo.
				mkdir !dest_dir2! >nul 2>nul
				move !orig_dir! !dest_dir! >nul 2>nul
			)
		)
	)
	move /y %current%\bloat_ROM\system %current%\_project_files\bloat >nul 2>nul
	echo.
	echo    Press any key for to back menu
	pause>nul
	goto debloat_list

:restaurar_bloat
    move "%current%\_project_files\bloat\system" "%current%\"
	rd /s /q "%current%\_project_files\bloat"
	pause>nul
	goto debloat_list

:editar_bloat_list
	start %bin%\note tools\data\bloat
	goto debloat_list
:deknox_list
	cls
    title Scarlett Kitchen - Deknox Menu
    call :banner
	%cl%   {47} Deknox list {#}
	echo.
	echo.
    %cl%   {0F}1) knox{#} 
	echo.
	%cl%   {03}r) Restore knox{#} 
	echo.
	%cl%   {05}c) Edit debloat list{#} 
	echo.
	%cl%   {06}b) Back{#} 
	echo.
	echo.
	set filenumber=r
	set /p filenumber=# Select any option: 
	set filenumber=%filenumber: =x%
	if "!filenumber!"=="1" goto deknox
	if "!filenumber!"=="r" goto restaurar_knox
	if "!filenumber!"=="e" goto editar_knox_list
	if "!filenumber!"=="b" goto rom_tools
	goto deknox_list

:deknox
	cls
	for /f "delims=" %%a in ('type "tools\data\knox"') do (
		for /f "delims=" %%b in ('tools\bin\find "%current%\system" -name %%a ^| !busybox! tr / \\') do (
			for /f "delims=" %%c in ('!busybox! dirname %%b') do (
				set orig_dir=%%c
				set test_folder=%%~nc%%~xc
			)
			for /f "delims=" %%d in ('!busybox! dirname %%b ^| !busybox! sed "s/ROM\\\system/ROM\\\knox/g"') do set dest_dir=%%d
			for /f "delims=" %%e in ('!busybox! dirname !dest_dir!') do set dest_dir2=%%e
			if "%%~nb"=="!test_folder!" (
				%cl% {03}   Removing{#} [%%~nb%%~xb]
				echo.
				mkdir !dest_dir2! >nul 2>nul
				move !orig_dir! !dest_dir! >nul 2>nul
			)
		)
	)
	mkdir %current%\knox >nul
	move /y "%current%\knox\system" "%current%\_project_files\knox">nul 2>nul
	echo.
	echo    Press any key for to back menu
	pause>nul
	goto deknox_list




:restaurar_knox
    move /y %current%\_project_files\knox\system %current%\system\system
	rd /s /q "%current%\_project_files\knox"
	goto deknox_list


:editar_knox_list
	start %bin%\note tools\data\knox
	goto deknox_list
:build.prop_tweaks
	cls
:cambiar_display_id
	cls
	for /f "Tokens=2* Delims==" %%# in (
	    'type "%system%\build.prop" ^| findstr "ro.build.display.id="'
	) do (
    	set "display_id=%%#"
	)
	title Scarlett Kitchen - ROM tools
    call :banner
	%cl%   {47} ROM tools {#}
	echo.
	echo.
	echo.
	%cl%   {08}Current ro.build.display.id={#}{03}!display_id!{#}
	echo.
	echo.
	set /p display_id_new=# enter a name for new ro.build.display.id=: 
	%bin%\sfk replace %system%\build.prop "/!display_id!/!display_id_new!/" -yes > nul
	goto rom_tools



:apktool_menu
	mkdir %current%\Addons\apktool\in_apk
	mkdir %current%\Addons\apktool\out_apk
	cls
    title Scarlett Kitchen - Apktool
    call :banner
	%cl%   {47} Plugins {#}
	echo.
	echo.
	%cl%   {09}2) Decompile APK{#}
	echo.
	%cl%   {09}3) Recompile APK{#}
	echo.
	%cl%   {0f}4) Clean Folders{#}
	echo.
	%cl%   {0f}5) View Logs{#}
	echo.
	%cl%   {03}6) Main menu{#}
	echo.
	%cl%   {04}4) Exit{#}
	echo.
	echo.
	set /p select=# Select any option: 
	if "!select!"=="1" goto apktool_decompile
	if "!select!"=="2" goto apktool_menu
	if "!select!"=="3" goto adbtool
	if "!select!"=="4" goto recovery_tar
	if "!select!"=="5" goto odin
	if "!select!"=="6" goto Logcat_Reader
	if "!select!"=="7" goto scripts
	if "!select!"=="m" goto home
	if "!select!"=="e" goto salir

:apktool_decompile
	:: Valores y recursos
	set apk_log_decompile=%current%\Addons\apktool\decompile_log.txt
	set in_apk=%current%\Addons\apktool\in_apk
	set out_apk=%current%\Addons\apktool\out_apk

	:: Comprobacion de existencia de archivos
	for /f "delims=" %%a in ('tools\bin\find %current%\Addons\apktool\in_apk -name *.apk ^| !busybox! wc -l') do if "%%a"=="0" (
		echo.
		%cl%  {04}No apk files found in [in_apk]{#}
		echo.
		pause>nul
		echo.
		echo.
		goto apktool_menu
	)
	cls
    title Scarlett Kitchen - Apktool
	call :banner
	%cl%   {47} Apk Tool {#}
	echo.
	echo.
	set count=0
	for /f "delims=" %%f in ('tools\bin\find %current%\Addons\apktool\in_apk -name *.apk') do (
		set /a count=!count!+1
		if !count! leq 9 echo   !count!] %%~nf%%~xf
		if !count! geq 10 if !count! leq 99 echo   !count! ] %%~nf%%~xf
		if !count! geq 100 echo   !count!] %%~nf%%~xf
	)
	%cl%   {03}m) Main menu{#}
	echo.
	%cl%   {04}b) Back{#}
	echo.
	echo.
	SET filenumber=rr
	set file=n
	set /p filenumber=# Select your apk file: 
	set filenumber=%filenumber: =x%
	set filenumber=%filenumber:,=x%
	set filenumber=%filenumber:"=x%
	if "!filenumber!"=="m" goto home
	IF "!filenumber!"=="b" goto apktool_menu
	set count=0
	for /f "delims=" %%f in ('tools\bin\find %current%\Addons\apktool\in_apk -name *.apk ^| !busybox! tr / \\') do (
		set /a count=!count!+1
		if !count! ==%filenumber% (
			:: Apk con ruta y extencion
			set apk=%%f
			:: Apk sin ruta y con extencion
			set apk_base=%%~nf%%~xf
			:: Apk sin ruta y sin extencion
			set apk_folder=%%~nf
		)
	)
	echo.
	echo Decompilig !apk_base!...
	echo [!apk_base!]>>%current%\Addons\apktool\decompile_log.txt
	java -jar tools\plugins\apk_tool\bin\apktool_2.4.1.jar d -f -o "%current%\Addons\apktool\in_apk\!apk_folder!" !apk! >>!apk_log_decompile! >nul
	pause
	goto apktool_decompile

:adb_tool
	cls


:abrir_odin
	cd tools\plugins\odin3
	start odin3.exe
	cd %~dp0

:Logcat_reader
	cls
	title Scarlett Kitchen - Logcat reader
    call :banner
	%cl%   {47} Logcat options {#}
	echo.
	echo.
	%cl%   {03}1) Complete{#} (Basiclly everything)
	echo.
	%cl%   {03}2) Kernel{#} (On active system)
	echo.
	%cl%   {03}3) Filtered out{#} (Bootloops/App crashes)
	echo.
	%cl%   {03}4) Bootloop{#} (Stuck at splash screen)
	echo.
	%cl%   {03}5) Logcat ril{#} (for simcard issues and no signal)
	echo.
	%cl%   {03}m) Main menu{#}
	echo.
	%cl%   {04}e) Exit{#}
	echo.
	echo.
	set /p select=# Select any option: 
	if "!select!"=="1" goto log_all
	if "!select!"=="2" goto log_dmesg
	if "!select!"=="3" goto log_error
	if "!select!"=="4" goto log_kmsg
	if "!select!"=="6" goto log_ril
	if "!select!"=="m" goto home
	if "!select!"=="e" goto salir

:soporte_root
    xcopy /y tools\utils\root_support %current% /s >nul 2>nul
    %bin%\rpc "!updater-script!" "#ROOT_SUPPORT_1" "################################################################" >nul
    %bin%\rpc "!updater-script!" "#ROOT_SUPPORT_2" "#               ROOT METHOD" >nul
    %bin%\rpc "!updater-script!" "#ROOT_SUPPORT_3" "################################################################" >nul
    %bin%\rpc "!updater-script!" "#ROOT_SUPPORT_4" "ui_print("-- Installing Magisk");" >nul
	%bin%\rpc "!updater-script!" "#ROOT_SUPPORT_5" "package_extract_dir("root", "/tmp/root");" >nul
    %bin%\rpc "!updater-script!" "#ROOT_SUPPORT_6" "run_program("/tmp/install/bin/busybox", "unzip", "/tmp/root/magisk.zip", "META-INF/com/google/android/*", "-d", "/tmp/root");" >nul
    %bin%\rpc "!updater-script!" "#ROOT_SUPPORT_7" "run_program("/tmp/install/bin/busybox", "sh", "/tmp/root/META-INF/com/google/android/update-binary", "dummy", "1", "/tmp/root/magisk.zip");" >nul
    pause>nul
    goto home

	del %current%\*.lz4 >nul
	goto compilar_tar_menu
:: --- --- --- 8) boot tools --- --- --- ::
:boot_recovery_tools
    title Scarlett Kitchen - Boot/Recovery tools
    cls
    call :banner
	%cl%   {47} Boot/recovery menu {#}
	echo.
	echo.
	%cl%   {09}1) Unpack/Repack Boot.img{#}
	echo.
	%cl%   {07}2) Add/Remove forceencrypt{#} 
	echo.
	%cl%   {07}3) Insecure/Secure the boot.img{#} 
	echo.
	%cl%   {06}4) Remove dm-verity{#}
	echo.
	%cl%   {03}5) Repack recovery_tar{#}
	echo.
	%cl%   {03}m) Main menu{#}
	echo.
	%cl%   {04}e) Exit{#}
	echo.
	echo.
	set /p select=# Select any option: 
	if "!select!"=="1" goto decidir_aik
	if "!select!"=="2" goto deknox
	if "!select!"=="3" goto deodex
	if "!select!"=="4" goto build_tweak
	if "!select!"=="5" goto perm_type
	if "!select!"=="m" goto home
	if "!select!"=="e" goto salir
	
:decidir_aik
    if exist "%current%\Addons\kernel_unpacked\ramdisk" if exist "%current%\Addons\kernel_unpacked\split_img" (
       ::set kernel_status_1=Unpacked
		 goto empaquetar_boot
	 ) else (
		 ::set kernel_status_1=Packaged
       goto desempaquetar_boot
	 )

:desempaquetar_boot
    title Scarlett Kitchen - Unpacking kernel
		set aik_folder="tools\plugins\aik_boot"
    if not exist "%current%\Addons\kernel_unpacked" (
		mkdir %current%\Addons\kernel_unpacked
	) 
    copy /y %current%\boot.img tools\plugins\aik_boot >nul 2>nul
    set aik_unpack=tools\plugins\aik_boot\unpackimg.bat
	call !aik_unpack! >nul 2>nul
	move /y "tools\plugins\aik_boot\split_img" "%current%\Addons\kernel_unpacked" >nul 2>nul
	move /y "tools\plugins\aik_boot\ramdisk" "%current%\Addons\kernel_unpacked" >nul 2>nul
	::del "tools\plugins\aik_boot\*.img" >nul 2>nul
	goto boot_recovery_tools

:empaquetar_boot
    title Scarlett Kitchen - Repacking kernel
	set aik_folder="tools\plugins\aik_boot"
	mkdir !aik_folder!\split_img
	mkdir !aik_folder!\ramdisk
	xcopy /y %current%\Addons\kernel_unpacked\split_img tools\plugins\aik_boot\split_img /s >nul 2>nul
	xcopy /y %current%\Addons\kernel_unpacked\ramdisk tools\plugins\aik_boot\ramdisk /s >nul 2>nul
	set aik_repack=tools\plugins\aik_boot\repackimg.bat
	call !aik_repack! >nul 2>nul
	move /y tools\plugins\aik_boot\*new.img %current%\Addons\kernel_unpacked >nul 2>nul
	move /y tools\plugins\aik_boot\*.empty %current%\Addons\kernel_unpacked >nul 2>nul
	rd /s /q tools\plugins\aik_boot\split_img >nul 2>nul
	rd /s /q tools\plugins\aik_boot\ramdisk >nul 2>nul
	del /s /q "tools\plugins\aik_boot\*.img"
	goto boot_recovery_tools

:bootlogo_menu
	cls
	title Scarlett Kitchen - Remove boot alert
	call :banner
	echo.
	%cl%   {03}1) Patch param.bin{#} (Only Fix)
	echo.
	%cl%   {03}2) Customize param.bin{#} (Customize bootlogo)
	echo.
	%cl%   {06}b) Back{#}
	echo.
	echo.
	set /p select=# Select any option: 
	if "!select!"=="1" goto reparar_bootlogo
	if "!select!"=="2" goto cambiar_bootlogo
	if "!select!"=="m" goto home
	) else (
		goto remover_boot_alert
	)
	
:reparar_bootlogo
	cls
	title Scarlett Kitchen - Patching Bootlogo
	call :banner
	%cl%   {47} Bootlogo Fixer {#}
	echo.
	echo.
	if exist "%current%\_project_files\data\param.bin" (
		echo   Please wait....
		%cl%   {03}Param.bin detect{#}...
		echo.
		copy %current%\_project_files\data\param.bin %current%\_project_files\data\param_tmp.bin >nul 2>nul
		%cl%   {03}creating temporary param{#}...
		echo.
		%bin%\7z a %current%\_project_files\data\param_tmp.bin .\tools\plugins\param_patch\booting_warning.jpg >nul 2>nul
		ren %current%\_project_files\data\param_tmp.bin param_patched.bin
		if exist "%current%\_project_files\data\param_patched.bin" (
			echo.
			%cl%   {02}Param successfully patched{#}
			echo.
			pause>nul
			goto rom_tools
		) else (
			echo.
			%cl%   {04}an error occurred during rebuilding{#}
			echo.
			pause>nul
			goto rom_tools
		)
	) else (
		echo.
		%cl%   {04}no param was detected in: %current%\_project_files\data\{#}
		echo.
		pause>nul
		goto rom_tools
	)

:cambiar_bootlogo
	cls

    for /f %%a in ('dir %current%\product\omc\ /ad /b' ) do (
		java -jar tools\plugins\omc_decoder\omc-decoder.jar -e -i %current%\product\omc -o %current%\product\omc >nul
		java -jar tools\plugins\omc_decoder\omc-decoder.jar -e -i %current%\product\omc\single -o %current%\product\omc\single >nul
		%cl%  {03}Encoding{#} product\omc\%%a
		echo.
	)
	del %current%\_project_files\data\omc_status 
	%bin%\sfk replace %data%\user_data "/sk.omc.status=decoded/sk.omc.status=encoded/" -yes > nul
	pause
	goto plugins
:: --- --- --- 9) Plugin menu --- --- --- ::
:plugin_check
	if not exist "tools\plugins\*" (
		cls
		call :banner
		%cl%   {04}Not plugins detect{#}
		echo.
		echo.
		%cl%   {03}d] Download{#} plugins
		echo.
		%cl%   {05}b] Back{#}
		echo.
		echo.
		set /p select=# Select any option: 
	) else (
		goto plugins_menu
	)
		if "!select!"=="d" (
			goto descargar_plugins
		)
		if "!select!"=="b" ( 
			goto home
		) else (
			goto plugin_check
		)
:plugins_menu
	cls
	title Scarlett Kitchen - Plugin Menu
	call :banner
	%cl%   {47}Plugin menu{#}
	echo.
	echo.
	%cl%   {03}1) Run{#} plugin
	echo.
	%cl%   {03}2) Download{#} plugin
	echo.
	%cl%   {03}3) Delete{#} plugin
	echo.
	%cl%   {06}b] Back{#}
	echo.
	echo.
	set /p select=# Select any option: 
	if "!select!"=="1" goto ejecutar_plugins
	if "!select!"=="2" goto descargar_plugins
	if "!select!"=="3" goto borrar_plugins
	if "!select!"=="b" goto home
	) else (
		goto plugins_menu
	)
:ejecutar_plugins
	cls
    title Scarlett Kitchen - Run plugins
	call :banner
	%cl%   {47} Run plugin {#}
	echo.
	echo.
	if exist "tools\plugins\omc_decoder\omc-decoder.jar" (
		%cl%   {09}1] omc decoder/enconde{#}
		echo.
	)
	if exist "tools\plugins\apk_tool\apktool.jar" (
		%cl%   {07}2] apk_tool{#}
		echo.
	)
	if exist "tools\plugins\adb_tool\adb.exe" (
		%cl%   {07}3] adb_tool{#}
		echo.
	)
	if exist "tools\plugins\tar_tool\tar.exe" (
		%cl%   {07}4] tar_tool{#} 
		echo.
	)
	if exist "tools\plugins\odin_3\odin3.exe" (
		%cl%   {06}5] Odin 3.14{#}
		echo.
	)
	if exist "tools\plugins\adb_tool\adb.exe" (
		%cl%   {03}6] Logcat_Reader{#}
		echo.
	)
	if exist "tools\plugins\param\logo.png" (
		%cl%   {03}7] Remove boot warning{#}
		echo.
	)
	if exist "tools\plugins\tar_tool\md5sum.exe" (
		%cl%   {03}8] md5 compiler{#}
		echo.
	)
	%cl%   {06}b] Back{#}
	echo.
	echo.
	set /p select=# Select any option: 
	if "!select!"=="1" goto omc_decoder_menu
	if "!select!"=="2" goto apktool_menu
	if "!select!"=="3" goto adbtool
	if "!select!"=="4" goto compilar_tar
	if "!select!"=="5" goto driver_check
	if "!select!"=="6" goto Logcat_Reader
	if "!select!"=="7" goto remover_boot_alert
	if "!select!"=="8" goto md5_tool
	if "!select!"=="9" goto frija_tool
	if "!select!"=="b" goto home
	) else (
		goto ejecutar_plugins
	)

:descargar_plugins
	cls
    title Scarlett Kitchen - Download Plugins
	call :banner
	%cl%   {47} Download plugins {#}
	echo.
	echo.
	if exist "tools\plugins\omc_decoder\omc-decoder.jar" (
		%cl%   {03}1] omc decoder{#} [Installed]
		echo.
	) else (
		%cl%   {06}1] omc decoder{#} [58.5 KB]
		echo.
	)
	if exist "tools\plugins\apk_tool\apktool.jar" (
		%cl%   {03}2] apk_tool{#} [Installed]
		echo.
	) else (
		%cl%   {06}2] apk_tool{#} [16.8 MB]
		echo.
	)
	if exist "tools\plugins\adb_tool\adb.exe" (
		%cl%   {03}3] adb_tool{#} [Installed]
		echo.
	) else (
		%cl%   {06}3] adb_tool{#} [1.57 MB]
		echo.
	) 
	if exist "tools\plugins\tar_tool\tar.exe" (
		%cl%   {03}4] tar_tool{#} [Installed]
		echo.
	) else (
		%cl%   {06}4] tar_tool{#} [5.21 MB]
		echo.
	)
	if exist "tools\plugins\odin_3\odin3.exe" (
		%cl%   {03}5] Odin 3.14{#} [Installed]
		echo.
	) else (
		%cl%   {06}5] Odin 3.14{#} [3.02 MB]
		echo.
	)
	if exist "tools\plugins\adb_tool\adb.exe" (
		%cl%   {03}6] Logcat_Reader{#} [Installed]
		echo.
	) else (
		%cl%   {06}6] Logcat_Reader{#} [1.57 MB]
		echo.
	)
	if exist "tools\plugins\build\buildpatcher.exe" (
		%cl%   {03}7] BuildPatcher{#}
		echo.
	) else (
		%cl%   {06}7] BuildPatcher{#} [60 KB]
		echo.
	)
	if exist "tools\plugins\tar_tool\md5sum.exe" (
		%cl%   {03}8] md5 Compiler{#}
		echo.
	) else (
		%cl%   {06}8] Md5 compiler{#} [229 KB]
		echo.
	)
	if exist "tools\plugins\frija_tool\frija.exe" (
		%cl%   {03}9] Frija{#}
		echo.
	) else (
		%cl%   {06}9] Frija{#} [229 KB]
		echo.
	)
	%cl%   {06}b) Back{#}
	echo.
	echo.
	set /p select=# Select any option: 
	if "!select!"=="1" goto omc_download
	if "!select!"=="2" goto apktool_download
	if "!select!"=="3" goto adb_download
	if "!select!"=="4" goto tar_tool_download
	if "!select!"=="5" goto odin_download
	if "!select!"=="6" goto logcat_download
	if "!select!"=="7" goto buildpatcher_download
	if "!select!"=="8" goto md5_compiler_download
	if "!select!"=="9" goto frija_download
	if "!select!"=="b" goto plugins_menu
	) else (
		goto descargar_plugins
	)

:: --- --- --- omc-decoder -- plugin --- --- --- ::
:omc_decoder_menu
	if not exist "tools\plugins\omc_decoder\omc-decoder.jar" (
		cls
		call :banner
		%cl%   {09}The plugin has not yet been downloaded{#}
		echo.
		pause>nul
		goto ejecutar_plugins
	)
	if not exist "C:\Program Files (x86)\Java" (
		cls
		call :banner
		%cl%   {09}This plugin cannot be run as the computer does not have Java{#}
		echo.
		pause>nul
		goto ejecutar_plugins
		)

		cls
		title Scarlett Kitchen - OMC decoder menu
		call :banner
		%cl%   {47} OMC Decoder/Encoder {#}
		echo.
		echo.
		%cl%   {07}1] Decode OMC{#} 
		echo.
		%cl%   {07}2] Encode OMC{#}
		echo.
		%cl%   {06}b] Back{#}
		echo.
		echo.
		set /p select=# Select any option: 
		if "!select!"=="1" goto decodificar_omc
		if "!select!"=="2" goto codificar_omc
		if "!select!"=="b" goto ejecutar_plugins
		) else (
			goto omc_decoder_menu
		)

:decodificar_omc
	if exist "%current%\product\omc" (
		cls
		call :banner
		for /f %%a in ('dir %current%\product\omc\ /ad /b' ) do (
			%cl%  {03}Decoding{#} %current%\product\omc\%%a\conf\cscfeature.xml
			echo.
			%cl%  {03}Decoding{#} %current%\product\omc\%%a\conf\cscfeature_network.xml
			echo.
			java -jar tools\plugins\omc_decoder\omc-decoder.jar -i %current%\product\omc -o %current%\product\omc >nul
			java -jar tools\plugins\omc_decoder\omc-decoder.jar -i %current%\product\omc\single -o %current%\product\omc\single >nul
		)
	)
	if exist "%current%\optics\configs\carriers" (
		cls
		call :banner
		for /f %%a in ('dir %current%\optics\configs\carriers\ /ad /b' ) do (
			%cl%  {03}Decoding{#} %current%\optics\configs\carriers\%%a\conf\cscfeature.xml
			echo.
			%cl%  {03}Decoding{#} %current%\optics\configs\carriers\%%a\conf\cscfeature_network.xml
			echo.
			java -jar tools\plugins\omc_decoder\omc-decoder.jar -i %current%\optics\configs\carriers -o %current%\optics\configs\carriers >nul
			java -jar tools\plugins\omc_decoder\omc-decoder.jar -i %current%\optics\configs\carriers\single -o %current%\optics\configs\carriers\single >nul
		)
	) else (
		echo.
		%cl%   {04}Error: omc not found{#}
		echo.
		pause>nul
		goto omc_decoder_menu
	)
	goto omc_decoder_menu

:codificar_omc
	if exist "%current%\product\omc" (
		cls
		call :banner
		for /f %%a in ('dir %current%\product\omc\ /ad /b' ) do (
			%cl%  {03}Encoding{#} %current%\optics\configs\carriers\%%a\conf\cscfeature.xml
			echo.
			%cl%  {03}Encoding{#} %current%\optics\configs\carriers\%%a\conf\cscfeature_network.xml
			echo.
			java -jar tools\plugins\omc_decoder\omc-decoder.jar -e -i %current%\product\omc -o %current%\product\omc >nul
			java -jar tools\plugins\omc_decoder\omc-decoder.jar -e -i %current%\product\omc\single -o %current%\product\omc\single >nul
		)
	)
	if exist "%current%\optics\configs\carriers" (
		cls
		call :banner
		for /f %%a in ('dir %current%\optics\configs\carriers\ /ad /b' ) do (
			%cl%  {03}Encoding{#} %current%\optics\configs\carriers\%%a\conf\cscfeature.xml
			echo.
			%cl%  {03}Encoding{#} %current%\optics\configs\carriers\%%a\conf\cscfeature_network.xml
			echo.
			java -jar tools\plugins\omc_decoder\omc-decoder.jar -e -i %current%\optics\configs\carriers -o %current%\optics\configs\carriers >nul
			java -jar tools\plugins\omc_decoder\omc-decoder.jar -e -i %current%\optics\configs\carriers\single -o %current%\optics\configs\carriers\single >nul
		)
	) else (
		echo.
		%cl%   {04}Error: omc not found{#}
		echo.
		pause>nul
		goto omc_decoder_menu
	)
	goto omc_decoder_menu
:: --- --- --- descargas (recursos) --- --- --- ::
:java_Download
	cls
	call :banner
	%cl%  {03}Downloading{#} java...
	echo.
	%bin%\wget -q https://github.com/carlos-burelo/Scarlett/raw/master/tools/plugins/Java_setup.exe --no-check-certificate --directory-prefix=tools\bin
	echo.
	set /p select=# do you want to install it now? [y/n]: 
	if "!select!"=="y" start tools\bin\Java_setup.exe
	if "!select!"=="n" goto home
	echo
	exit /b

:adb_Download
	cls
	call :banner
	
	%cl%  {03}Downloading{#} adb...
	echo.
	%bin%\wget -q https://github.com/carlos-burelo/Scarlett/raw/master/tools/plugins/adb_setup.exe --no-check-certificate --directory-prefix=tools\bin
	echo.
	set /p select=# do you want to install it now? [y/n]: 
	if "!select!"=="y" start tools\bin\Java_setup.exe
	if "!select!"=="n" goto home
	echo
	exit /b
:driver_Download
	%cl%  {03}Downloading{#} driver_setup... !java_status!
	echo.
	%bin%\wget -q https://developer.samsung.com/mobile/file/68b2dc40-3833-4a8b-b58e-32f7aca25c00 --no-check-certificate --directory-prefix=tools\bin
	echo.
	set /p select=# do you want to install it now? [y/n]: 
	if "!select!"=="y" start tools\bin\Java_setup.exe
	if "!select!"=="n" goto home
	echo
	exit /b
:: --- --- --- descargas (plugins) --- --- --- ::
:omc_download
	cls
	call :banner
	%cl%  {03}Downloading{#} omc_decoder.jar...
	echo.
	%bin%\wget -q https://github.com/carlos-burelo/Scarlett/raw/master/tools/plugins/omc_decoder/omc-decoder.jar --no-check-certificate --directory-prefix=tools\plugins\omc_decoder
	echo.
	goto descargar_plugins
:apktool_download
	cls
	call :banner
	%cl%  {03}Downloading{#} apk_tool.jar...
	echo.
	%bin%\wget -q https://github.com/carlos-burelo/Scarlett/raw/master/tools/plugins/apk_tool/apktool.jar --no-check-certificate --directory-prefix=tools\plugins\apk_tool
	echo.
	goto descargar_plugins
:adb_download
	call :banner
	%cl%  {03}Downloading{#} adb.exe...
	echo.
	%bin%\wget -q https://github.com/carlos-burelo/Scarlett/raw/master/tools/plugins/adb_tool/adb.exe --no-check-certificate --directory-prefix=tools\plugins\adb_tool
	%bin%\wget -q https://github.com/carlos-burelo/Scarlett/raw/master/tools/plugins/adb_tool/AdbWinApi.dll --no-check-certificate --directory-prefix=tools\plugins\adb_tool
	%bin%\wget -q https://github.com/carlos-burelo/Scarlett/raw/master/tools/plugins/adb_tool/AdbWinUsbApi.dll --no-check-certificate --directory-prefix=tools\plugins\adb_tool
	echo.
	goto descargar_plugins
:odin_download
	call :banner
	%cl%  {03}Downloading{#} odin3.exe...
	echo.
	%bin%\wget -q https://github.com/carlos-burelo/Scarlett/raw/master/tools/plugins/odin_3/odin3.exe --no-check-certificate --directory-prefix=tools\plugins\odin_3
	%bin%\wget -q https://github.com/carlos-burelo/Scarlett/raw/master/tools/plugins/odin_3/odin3.ini --no-check-certificate --directory-prefix=tools\plugins\odin_3
	echo.
	goto descargar_plugins

:tar_tool_download
	cls
	call :banner
	%cl%   {03}Downloading{#} tar.exe...
	echo.
	%bin%\wget -q https://github.com/carlos-burelo/Scarlett/raw/master/tools/plugins/tar_tool/tar.exe --no-check-certificate --directory-prefix=tools\plugins\tar_tool
	%bin%\wget -q https://github.com/carlos-burelo/Scarlett/raw/master/tools/plugins/tar_tool/cyggcc_s-1.dll --no-check-certificate --directory-prefix=tools\plugins\tar_tool
	%bin%\wget -q https://github.com/carlos-burelo/Scarlett/raw/master/tools/plugins/tar_tool/cygiconv-2.dll --no-check-certificate --directory-prefix=tools\plugins\tar_tool
	%bin%\wget -q https://github.com/carlos-burelo/Scarlett/raw/master/tools/plugins/tar_tool/cygintl-8.dll --no-check-certificate --directory-prefix=tools\plugins\tar_tool
	%bin%\wget -q https://github.com/carlos-burelo/Scarlett/raw/master/tools/plugins/tar_tool/cygwin1.dll --no-check-certificate --directory-prefix=tools\plugins\tar_tool
	%bin%\wget -q https://github.com/carlos-burelo/Scarlett/raw/master/tools/plugins/tar_tool/ls.exe --no-check-certificate --directory-prefix=tools\plugins\tar_tool
	goto descargar_plugins
:md5_compiler_download
	cls
	call :banner
	%cl%   {03}Downloading{#} md5.exe...
	echo.
	%bin%\wget -q https://github.com/carlos-burelo/Scarlett/raw/master/tools/plugins/md5_tool/md5sum.exe --no-check-certificate --directory-prefix=tools\plugins\tar_tool
	%bin%\wget -q https://github.com/carlos-burelo/Scarlett/raw/master/tools/plugins/md5_tool/mv.exe --no-check-certificate --directory-prefix=tools\plugins\tar_tool
	goto descargar_plugins


:: --- --- --- comprobadores --- --- --- ::
:adb_check
	if exist "C:\Program Files (x86)\ClockworkMod\Universal Adb Driver" (
		set adb_test=Yes
	) else (
		echo.
		%cl% {04} Samsung drivers are not intalled{#}
		echo.
		call :adb_Download
	)
	exit /b
:driver_check
	if exist "C:\Program Files\Samsung\SamsungUSBDrivers" (
		set driver_test=Yes
		goto abrir_odin
	) else (
		echo.
		%cl% {04} Samsung drivers are not intalled{#}
		echo.
		call :driver_Download
	)

:java_check
	cls
	call :banner
	
	echo.
	%cl%   {04} Java are not intalled{#}
	echo.
	echo.
	%cl%   {07}Do you want to download Java?{#} [y/n]
	echo.
	echo.
	set /p select=# Select any option: 
	if "!select!"=="y" goto java_Download
	if "!select!"=="n" exit /b
:: --- --- --- extras --- --- --- ::
:banner
	%cl% {08}-----------------------------------------------------------------------------------------------{#}
    echo.
    %cl% {80}   Scarlett Kitchen (Full edition)                                                             {#}
    echo.
    %cl% {80}   By Carlos Burelo                                                                            {#}
    echo.
    %cl% {08}-----------------------------------------------------------------------------------------------{#}
    echo.
	echo.
	%cl%   {03}Build Version:{#} !pda!           {03}Project Name:{#} !current!
	echo.
	%cl%   {0a}Android Version:{#} {07}!android_version!{#}
	echo.
	echo.
	exit /b
:banner2
	%cl% {08}-----------------------------------------------------------------------------------------------{#}
    echo.
    %cl% {80}   Scarlett Kitchen (Full edition)                                                             {#}
    echo.
    %cl% {80}   By Carlos Burelo                                                                            {#}
    echo.
    %cl% {08}-----------------------------------------------------------------------------------------------{#}
    echo.
	echo.
	

:obtener_versiones
	if exist "tools\Scarlett.md" (
		for /f "Tokens=2* Delims==" %%# in ('type "tools\Scarlett.md" ^| findstr "build.scarlett="') do ( set "scarlett_version=%%#")
	)
	if exist "tools\releases.md" (
		for /f "Tokens=2* Delims==" %%# in ('type "tools\releases.md" ^| findstr "build.scarlett="') do ( set "scarlett_release=%%#")
	)
	exit /b

:variables_de_respaldo
	if not exist "%current%\system\system\build.prop" (
		set pda=Unknown
		set dispositivo=Unknown
		set modelo=Unknown
		set arquitectura=Unknown
		set android_version=Unknown
		set chipset=Unknown
		set security_patch=Unknown
	)
	if not exist "%current%\_project_files\data\user_data" (
		set project_name=Unknown
		set project_autor=Unknown
	)
	exit /b

:datos
	::build.prop
	if exist "%current%\system\system\build.prop" (
		for /f "Tokens=2* Delims==" %%# in ('type "%current%\system\system\build.prop" ^| findstr "ro.build.version.incremental="') do ( set "pda=%%#")
		for /f "Tokens=2* Delims==" %%# in ('type "%current%\system\system\build.prop" ^| findstr "ro.build.version.release="') do ( set "android_version=%%#")
		for /f "Tokens=2* Delims==" %%# in ('type "%current%\system\system\build.prop" ^| findstr "ro.product.system.device="') do ( set "dispositivo=%%#")
		for /f "Tokens=2* Delims==" %%# in ('type "%current%\system\system\build.prop" ^| findstr "ro.product.system.model="') do ( set "modelo=%%#")
		for /f "Tokens=2* Delims==" %%# in ('type "%current%\system\system\build.prop" ^| findstr "ro.product.cpu.abi="') do ( set "arquitectura=%%#")
		for /f "Tokens=2* Delims==" %%# in ('type "%current%\system\system\build.prop" ^| findstr "ro.hardware.chipname="') do ( set "chipset=%%#")
		for /f "Tokens=2* Delims==" %%# in ('type "%current%\system\system\build.prop" ^| findstr "ro.build.version.security_patch="') do ( set "security_patch=%%#")
	)
	::user_data
	if exist "%current%\_project_files\data\user_data" (
		for /f "Tokens=2* Delims==" %%# in ('type "%data%\user_data" ^| findstr "project_name="') do ( set "project_name=%%#")
		for /f "Tokens=2* Delims==" %%# in ('type "%data%\user_data" ^| findstr "project_dev="') do ( set "project_autor=%%#")
	)
	::status
	if exist "%current%" (
		:: Installer Detect
		if exist "%current%\META-INF" (
			set installer_status=Generated
		) else (
			set installer_status=Not Exist
		)
		:: Bloat Detect
		if exist "%current%\_project_files\bloat" (
			set bloat_status=Debloated
		) else (
			set bloat_status=Bloated
		)
		:: Knox Detect
		if exist "%current%\_project_files\knox" (
			set knox_status=Deknoxed
		) else (
			set knox_status=Knoxed
		)
		:: Deodex Detect
		if exist %current%\system\system\framework\*.vdex (
			set deodex_status=Odexed
		) else (
			set deodex_status=Deodexed
		)
	)
	exit /b

