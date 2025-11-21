# 测试题目API是否返回options字段
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "测试题目API - 检查options字段" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 1. 检查后端服务是否运行
Write-Host "1. 检查后端服务状态..." -ForegroundColor Yellow
$javaProcesses = Get-Process | Where-Object {$_.ProcessName -like "*java*"}
if ($javaProcesses) {
    Write-Host "   ✓ 后端服务正在运行" -ForegroundColor Green
    $javaProcesses | ForEach-Object {
        Write-Host "     进程ID: $($_.Id), 启动时间: $($_.StartTime)" -ForegroundColor Gray
    }
} else {
    Write-Host "   ✗ 后端服务未运行！" -ForegroundColor Red
    Write-Host "   请先启动后端服务" -ForegroundColor Red
    exit 1
}
Write-Host ""

# 2. 检查编译后的Mapper文件
Write-Host "2. 检查编译后的Mapper文件..." -ForegroundColor Yellow
$mapperPath = "RuoYi-Vue-master\ruoyi-admin\target\classes\mapper\system\QuestionMapper.xml"
if (Test-Path $mapperPath) {
    $mapperFile = Get-Item $mapperPath
    Write-Host "   ✓ Mapper文件存在" -ForegroundColor Green
    Write-Host "     路径: $mapperPath" -ForegroundColor Gray
    Write-Host "     最后修改时间: $($mapperFile.LastWriteTime)" -ForegroundColor Gray
    
    # 检查是否包含GROUP_CONCAT
    $content = Get-Content $mapperPath -Raw
    if ($content -match "GROUP_CONCAT") {
        Write-Host "   ✓ Mapper包含GROUP_CONCAT查询" -ForegroundColor Green
    } else {
        Write-Host "   ✗ Mapper不包含GROUP_CONCAT查询！需要重新编译！" -ForegroundColor Red
    }
} else {
    Write-Host "   ✗ 编译后的Mapper文件不存在！" -ForegroundColor Red
    Write-Host "   需要在IDEA中执行 Build -> Rebuild Project" -ForegroundColor Red
}
Write-Host ""

# 3. 测试API（需要登录token）
Write-Host "3. 测试API返回数据..." -ForegroundColor Yellow
Write-Host "   注意：此测试需要登录token，可能返回401" -ForegroundColor Gray
Write-Host "   请手动测试：" -ForegroundColor Yellow
Write-Host "   1. 打开浏览器，登录系统" -ForegroundColor White
Write-Host "   2. 按F12打开开发者工具" -ForegroundColor White
Write-Host "   3. 切换到Network标签" -ForegroundColor White
Write-Host "   4. 进入题目练习，选择课程" -ForegroundColor White
Write-Host "   5. 找到 /system/question/list 请求" -ForegroundColor White
Write-Host "   6. 查看Response，检查是否有options字段" -ForegroundColor White
Write-Host ""

# 4. 检查源文件
Write-Host "4. 检查源文件..." -ForegroundColor Yellow
$sourceMapperPath = "RuoYi-Vue-master\ruoyi-system\src\main\resources\mapper\system\QuestionMapper.xml"
if (Test-Path $sourceMapperPath) {
    $sourceFile = Get-Item $sourceMapperPath
    Write-Host "   ✓ 源Mapper文件存在" -ForegroundColor Green
    Write-Host "     最后修改时间: $($sourceFile.LastWriteTime)" -ForegroundColor Gray
    
    $sourceContent = Get-Content $sourceMapperPath -Raw
    if ($sourceContent -match "GROUP_CONCAT") {
        Write-Host "   ✓ 源Mapper包含GROUP_CONCAT查询" -ForegroundColor Green
    } else {
        Write-Host "   ✗ 源Mapper不包含GROUP_CONCAT查询！" -ForegroundColor Red
    }
}
Write-Host ""

# 5. 给出建议
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "建议操作步骤：" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "1. 在IDEA中停止后端服务（红色方块按钮）" -ForegroundColor White
Write-Host "2. 点击菜单：Build -> Rebuild Project" -ForegroundColor White
Write-Host "3. 等待编译完成" -ForegroundColor White
Write-Host "4. 重新启动后端服务（绿色播放按钮）" -ForegroundColor White
Write-Host "5. 等待看到：Started RuoYiApplication" -ForegroundColor White
Write-Host "6. 刷新浏览器（Ctrl + Shift + R）" -ForegroundColor White
Write-Host "7. 测试多选题是否显示选项" -ForegroundColor White
Write-Host ""

