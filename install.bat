@echo off

:: Verifica se o script está sendo executado como administrador
net session >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Este script precisa ser executado como administrador.
    echo Reiniciando com permissões de administrador...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: Define o link de download e o nome do arquivo
set JAVA_URL=https://download.oracle.com/java/21/latest/jdk-21_windows-x64_bin.msi
set JAVA_MSI=jdk-21_windows-x64_bin.msi

:: Define o diretório de instalação
set JAVA_INSTALL_DIR="C:\Program Files\Java\jdk-21"

:: Diretório temporário para o download
set TEMP_DIR=%TEMP%\JavaInstall

:: Cria o diretório temporário
if not exist "%TEMP_DIR%" (
    mkdir "%TEMP_DIR%"
)

:: Navega para o diretório temporário
cd /d "%TEMP_DIR%"

:: Baixa o instalador MSI
echo Baixando o instalador do Java...
powershell -Command "Invoke-WebRequest -Uri %JAVA_URL% -OutFile %TEMP_DIR%\%JAVA_MSI%"

:: Verifica se o download foi bem-sucedido
if not exist "%TEMP_DIR%\%JAVA_MSI%" (
    echo Erro ao baixar o instalador do Java. Verifique sua conexão com a internet.
    pause
    exit /b 1
)

:: Executa o instalador MSI
echo Instalando o Java...
msiexec /i "%TEMP_DIR%\%JAVA_MSI%" /quiet /norestart

:: Verifica se a instalação foi bem-sucedida
if %ERRORLEVEL% neq 0 (
    echo Erro durante a instalação do Java. Código de erro: %ERRORLEVEL%.
    pause
    exit /b 1
)

:: Configura as variáveis de ambiente
echo Configurando variáveis de ambiente...
setx JAVA_HOME %JAVA_INSTALL_DIR% /m
setx PATH "%PATH%;%JAVA_INSTALL_DIR%\bin" /m

:: Limpa o diretório temporário
echo Limpando arquivos temporários...
rd /s /q "%TEMP_DIR%"

:: Verifica a instalação
echo Verificando a instalação do Java...
java -version
if %ERRORLEVEL% neq 0 (
    echo Ocorreu um erro ao verificar a instalação do Java.
    pause
    exit /b 1
)


:: Abre um novo terminal com permissões de administrador e executa o comando java -jar ./Server-all.jar
echo Abrindo um novo terminal com permissões de administrador...
powershell -Command "Start-Process cmd -ArgumentList '/k java -jar ./Server-all.jar' -Verb RunAs"

echo Java foi instalado e configurado com sucesso!
pause
exit