# Test Question API
$response = Invoke-RestMethod -Uri "http://localhost:8080/dev-api/system/question/list?courseId=1&pageNum=1&pageSize=5" -Method Get
$response | ConvertTo-Json -Depth 5

