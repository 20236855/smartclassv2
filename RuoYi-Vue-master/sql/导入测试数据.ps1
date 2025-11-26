# PowerShell脚本 - 导入测试数据
# 使用方法：右键点击此文件，选择"使用PowerShell运行"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  测试数据导入工具" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# MySQL连接信息
$MYSQL_HOST = "localhost"
$MYSQL_PORT = "3306"
$MYSQL_USER = "root"
$MYSQL_DB = "ry-vue"

# 读取密码
$MYSQL_PASSWORD = Read-Host "请输入MySQL密码" -AsSecureString
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($MYSQL_PASSWORD)
$PlainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

Write-Host ""
Write-Host "正在导入测试数据..." -ForegroundColor Yellow
Write-Host ""

# 获取当前脚本所在目录
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SqlFile = Join-Path $ScriptDir "test_data.sql"

# 执行SQL脚本
$mysqlCmd = "mysql -h$MYSQL_HOST -P$MYSQL_PORT -u$MYSQL_USER -p$PlainPassword $MYSQL_DB"

try {
    Get-Content $SqlFile | & mysql -h$MYSQL_HOST -P$MYSQL_PORT -u$MYSQL_USER -p$PlainPassword $MYSQL_DB
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  ✓ 测试数据导入成功！" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "已导入：" -ForegroundColor White
    Write-Host "  - 20道题目 (ID: 1001-1020)" -ForegroundColor White
    Write-Host "  - 10个作业 (ID: 2001-2010)" -ForegroundColor White
    Write-Host ""
    Write-Host "现在可以启动系统进行测试了！" -ForegroundColor Green
    Write-Host ""
}
catch {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "  ✗ 导入失败，请检查：" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "  1. MySQL服务是否启动" -ForegroundColor Yellow
    Write-Host "  2. 数据库名称是否正确 (ry-vue)" -ForegroundColor Yellow
    Write-Host "  3. 用户名和密码是否正确" -ForegroundColor Yellow
    Write-Host "  4. 表结构是否已创建" -ForegroundColor Yellow
    Write-Host "  5. mysql命令是否在PATH中" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "错误信息：$_" -ForegroundColor Red
    Write-Host ""
}

Write-Host "按任意键退出..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

