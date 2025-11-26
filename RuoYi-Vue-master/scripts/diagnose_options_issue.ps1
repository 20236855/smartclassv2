# Diagnose why multiple choice options are not showing

Write-Host "=== Diagnosing Multiple Choice Options Issue ===" -ForegroundColor Cyan

# Step 1: Check database
Write-Host "`nStep 1: Checking database..." -ForegroundColor Yellow
Write-Host "Testing SQL query for question 3021..." -ForegroundColor White

$sqlQuery = @"
SELECT 
    q.id, 
    q.title, 
    q.question_type,
    GROUP_CONCAT(CONCAT(qo.option_label, ':', qo.option_text) ORDER BY qo.option_label SEPARATOR '||') as options
FROM question q
LEFT JOIN question_option qo ON q.id = qo.question_id
WHERE q.id = 3021
GROUP BY q.id;
"@

$result = mysql -uroot -p123456 smartclassv2 --default-character-set=utf8mb4 -e $sqlQuery 2>&1

if ($result -match "A:<header>") {
    Write-Host "✓ Database query works correctly" -ForegroundColor Green
    Write-Host "  Options found: A:<header>||B:<footer>||C:<nav>||D:<div>" -ForegroundColor White
} else {
    Write-Host "✗ Database query failed or returned no options" -ForegroundColor Red
    Write-Host $result
    exit 1
}

# Step 2: Check source files
Write-Host "`nStep 2: Checking source files..." -ForegroundColor Yellow

$questionJava = "RuoYi-Vue-master\ruoyi-system\src\main\java\com\ruoyi\system\domain\Question.java"
$mapperXml = "RuoYi-Vue-master\ruoyi-system\src\main\resources\mapper\system\QuestionMapper.xml"

if (Test-Path $questionJava) {
    $content = Get-Content $questionJava -Raw
    if ($content -match "private String options") {
        Write-Host "✓ Question.java has options field" -ForegroundColor Green
    } else {
        Write-Host "✗ Question.java missing options field" -ForegroundColor Red
    }
} else {
    Write-Host "✗ Question.java not found" -ForegroundColor Red
}

if (Test-Path $mapperXml) {
    $content = Get-Content $mapperXml -Raw
    if ($content -match "GROUP_CONCAT") {
        Write-Host "✓ QuestionMapper.xml has GROUP_CONCAT query" -ForegroundColor Green
    } else {
        Write-Host "✗ QuestionMapper.xml missing GROUP_CONCAT query" -ForegroundColor Red
    }
} else {
    Write-Host "✗ QuestionMapper.xml not found" -ForegroundColor Red
}

# Step 3: Check if backend is running
Write-Host "`nStep 3: Checking backend service..." -ForegroundColor Yellow

$javaProcesses = Get-Process | Where-Object {$_.ProcessName -like "*java*"}
if ($javaProcesses) {
    Write-Host "✓ Found $($javaProcesses.Count) Java process(es) running" -ForegroundColor Green
    $javaProcesses | ForEach-Object {
        Write-Host "  PID: $($_.Id) | Started: $($_.StartTime)" -ForegroundColor White
    }
} else {
    Write-Host "✗ No Java processes found - backend is not running!" -ForegroundColor Red
    Write-Host "  Please start the backend in IDEA" -ForegroundColor Yellow
    exit 1
}

# Step 4: Test API endpoint
Write-Host "`nStep 4: Testing API endpoint..." -ForegroundColor Yellow
Write-Host "Attempting to call: http://localhost:8080/dev-api/system/question/list" -ForegroundColor White

try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/dev-api/system/question/list?courseId=1&pageNum=1&pageSize=5" -Method Get -ErrorAction Stop
    
    if ($response.StatusCode -eq 200) {
        Write-Host "✓ API endpoint is accessible" -ForegroundColor Green
        
        $json = $response.Content | ConvertFrom-Json
        if ($json.rows -and $json.rows.Count -gt 0) {
            $firstQuestion = $json.rows[0]
            
            if ($firstQuestion.options) {
                Write-Host "✓ API returns options field!" -ForegroundColor Green
                Write-Host "  Sample: $($firstQuestion.options.Substring(0, [Math]::Min(50, $firstQuestion.options.Length)))..." -ForegroundColor White
            } else {
                Write-Host "✗ API does NOT return options field" -ForegroundColor Red
                Write-Host "  This means the backend needs to be restarted!" -ForegroundColor Yellow
            }
        } else {
            Write-Host "⚠ API returned no questions" -ForegroundColor Yellow
        }
    }
} catch {
    if ($_.Exception.Message -match "401") {
        Write-Host "⚠ API requires authentication (401)" -ForegroundColor Yellow
        Write-Host "  This is normal - you need to be logged in" -ForegroundColor White
    } else {
        Write-Host "✗ Cannot connect to API: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "  Make sure backend is running on port 8080" -ForegroundColor Yellow
    }
}

# Step 5: Check frontend
Write-Host "`nStep 5: Checking frontend files..." -ForegroundColor Yellow

$coursesVue = "RuoYi-Vue-master\ruoyi-ui\src\views\system\question\courses.vue"
if (Test-Path $coursesVue) {
    $content = Get-Content $coursesVue -Raw
    if ($content -match "parseOptions\(question\.options\)") {
        Write-Host "✓ Frontend has parseOptions function" -ForegroundColor Green
    } else {
        Write-Host "✗ Frontend missing parseOptions function" -ForegroundColor Red
    }
    
    if ($content -match "el-checkbox-group") {
        Write-Host "✓ Frontend has multiple choice rendering" -ForegroundColor Green
    } else {
        Write-Host "✗ Frontend missing multiple choice rendering" -ForegroundColor Red
    }
} else {
    Write-Host "✗ courses.vue not found" -ForegroundColor Red
}

# Summary
Write-Host "`n=== Summary ===" -ForegroundColor Cyan
Write-Host "If API does NOT return options field:" -ForegroundColor Yellow
Write-Host "  1. Stop backend in IDEA (red square button)" -ForegroundColor White
Write-Host "  2. Rebuild project (Ctrl+F9 or Build > Rebuild Project)" -ForegroundColor White
Write-Host "  3. Start backend again (green play button)" -ForegroundColor White
Write-Host "  4. Wait for 'Started RuoYiApplication' message" -ForegroundColor White
Write-Host "  5. Refresh browser (Ctrl+Shift+R)" -ForegroundColor White
Write-Host "`nIf API DOES return options field:" -ForegroundColor Yellow
Write-Host "  1. Open browser console (F12)" -ForegroundColor White
Write-Host "  2. Look for 'parseOptions' logs" -ForegroundColor White
Write-Host "  3. Check if question.options is null/undefined" -ForegroundColor White

