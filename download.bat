@echo off

:: Verifica se o script está sendo executado como administrador
net session >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Este script precisa ser executado como administrador.
    echo Reiniciando com permissões de administrador...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: Links para download
set JAVA_URL=https://download.oracle.com/java/21/latest/jdk-21_windows-x64_bin.msi
set JAVA_MSI=jdk-21_windows-x64_bin.msi
set GIT_URL=https://github.com/git-for-windows/git/releases/download/v2.47.1.windows.1/Git-2.47.1-64-bit.exe
set GIT_INSTALLER=Git-2.47.1-64-bit.exe
set GOV_APP_URL=https://aplicacoes.autenticacao.gov.pt/apps/Autenticacao.gov_Win_x64_signed.msi
set GOV_APP_MSI=Autenticacao.gov_Win_x64_signed.msi
set REPO_URL=https://github.com/Humanos-App/_public

:: Diretórios de instalação
set JAVA_INSTALL_DIR="C:\Program Files\Java\jdk-21"
set GIT_INSTALL_DIR="C:\Program Files\Git"
set GOV_APP_DIR="C:\Program Files\Portugal Identity Card"
set APP_INSTALL_DIR="C:\Program Files\HumanosApp"
set TEMP_DIR=%TEMP%\Installer

:: Cria o diretório temporário
if not exist "%TEMP_DIR%" (
    mkdir "%TEMP_DIR%"
)

:: Navega para o diretório temporário
cd /d "%TEMP_DIR%"

:: Verifica e instala o Java
if not exist "%JAVA_INSTALL_DIR%\bin\java.exe" (
    echo Java não encontrado. Instalando...
    powershell -Command "Invoke-WebRequest -Uri %JAVA_URL% -OutFile %TEMP_DIR%\%JAVA_MSI%"
    msiexec /i "%TEMP_DIR%\%JAVA_MSI%" /quiet /norestart
    if %ERRORLEVEL% neq 0 (
        echo Erro ao instalar o Java.
        pause
        exit /b 1
    )
    echo Java instalado com sucesso.
) else (
    echo Java já está instalado.
)

:: Verifica e instala o Git
if not exist "%GIT_INSTALL_DIR%\bin\git.exe" (
    echo Git não encontrado. Instalando...
    powershell -Command "Invoke-WebRequest -Uri %GIT_URL% -OutFile %TEMP_DIR%\%GIT_INSTALLER%"
    start /wait "%TEMP_DIR%\%GIT_INSTALLER%" /SILENT
    if %ERRORLEVEL% neq 0 (
        echo Erro ao instalar o Git.
        pause
        exit /b 1
    )
    echo Git instalado com sucesso.
) else (
    echo Git já está instalado.
)

:: Verifica e instala a aplicação do Governo
if not exist "%GOV_APP_DIR%" (
    echo Aplicação do Portugal Identity Card não encontrada. Instalando...
    powershell -Command "Invoke-WebRequest -Uri %GOV_APP_URL% -OutFile %TEMP_DIR%\%GOV_APP_MSI%"
    msiexec /i "%TEMP_DIR%\%GOV_APP_MSI%" /quiet /norestart
    if %ERRORLEVEL% neq 0 (
        echo Erro ao instalar a aplicação do Portugal Identity Card.
        pause
        exit /b 1
    )
    echo Aplicação do Portugal Identity Card instalada com sucesso.
) else (
    echo Aplicação do Portugal Identity Card já está instalada.
)

:: Clona o repositório do GitHub
if not exist "%APP_INSTALL_DIR%" (
    echo Clonando o repositório da aplicação...
    mkdir "%APP_INSTALL_DIR%"
    cd "%APP_INSTALL_DIR%"
    "%GIT_INSTALL_DIR%\bin\git.exe" clone %REPO_URL% .
    if %ERRORLEVEL% neq 0 (
        echo Erro ao clonar o repositório.
        pause
        exit /b 1
    )
    echo Repositório clonado com sucesso.
) else (
    echo O repositório já foi clonado.
)

:: Cria um arquivo .bat no desktop para executar o Server-all.jar
set DESKTOP_DIR=%USERPROFILE%\Desktop
set START_BAT=%DESKTOP_DIR%\Start_Server.bat

if exist "%APP_INSTALL_DIR%\Server-all.jar" (
    echo Criando atalho no desktop para executar Server-all.jar...
    echo @echo off > "%START_BAT%"
    echo cd /d "%APP_INSTALL_DIR%" >> "%START_BAT%"
    echo java -jar Server-all.jar >> "%START_BAT%"
    echo Atalho criado com sucesso no desktop.
) else (
    echo O arquivo Server-all.jar não foi encontrado no diretório da aplicação.
)

:: Limpa o diretório temporário
echo Limpando arquivos temporários...
rd /s /q "%TEMP_DIR%"

:: Conclusão
echo Instalação e configuração concluídas com sucesso!
pause
exit
