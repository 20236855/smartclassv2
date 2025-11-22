@echo off
REM Set code page to UTF-8
chcp 65001 >nul

echo ========================================
echo   Test Data Import Tool
echo ========================================
echo.

REM MySQL connection settings
set MYSQL_HOST=localhost
set MYSQL_PORT=3306
set MYSQL_USER=root
set MYSQL_DB=ry-vue

echo Please enter MySQL password:
set /p MYSQL_PASSWORD=

echo.
echo Importing test data...
echo.

REM Execute SQL script
mysql -h%MYSQL_HOST% -P%MYSQL_PORT% -u%MYSQL_USER% -p%MYSQL_PASSWORD% %MYSQL_DB% < test_data.sql

if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo   SUCCESS - Test data imported!
    echo ========================================
    echo.
    echo Imported:
    echo   - 20 questions (ID: 1001-1020)
    echo   - 10 assignments (ID: 2001-2010)
    echo.
    echo You can now start the system for testing!
    echo.
) else (
    echo.
    echo ========================================
    echo   FAILED - Please check:
    echo ========================================
    echo   1. Is MySQL service running?
    echo   2. Is database name correct?
    echo   3. Are username and password correct?
    echo   4. Are tables created?
    echo.
)

pause

