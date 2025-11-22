# Setup course images directory
# Run this script in PowerShell

$uploadPath = "D:\ruoyi\uploadPath\courses"

# Create directory
if (-not (Test-Path $uploadPath)) {
    New-Item -ItemType Directory -Path $uploadPath -Force
    Write-Host "Directory created: $uploadPath" -ForegroundColor Green
} else {
    Write-Host "Directory already exists: $uploadPath" -ForegroundColor Yellow
}

# Show directory info
Write-Host "`nDirectory Info:" -ForegroundColor Cyan
Get-Item $uploadPath | Format-List FullName, CreationTime, LastWriteTime

# Check for image files
$imageFiles = Get-ChildItem -Path $uploadPath -Filter "*.jpg" -ErrorAction SilentlyContinue
if ($imageFiles.Count -gt 0) {
    Write-Host "`nFound $($imageFiles.Count) image files:" -ForegroundColor Green
    $imageFiles | ForEach-Object {
        Write-Host "  - $($_.Name)" -ForegroundColor White
    }
} else {
    Write-Host "`nNo image files found in directory" -ForegroundColor Yellow
    Write-Host "Please copy course images (.jpg format) to this directory" -ForegroundColor Yellow
}

Write-Host "`nSuggested image names:" -ForegroundColor Cyan
Write-Host "  course-1.jpg"
Write-Host "  course-2.jpg"
Write-Host "  course-3.jpg"
Write-Host "  course-4.jpg"
Write-Host "  course-5.jpg"
Write-Host "  course-6.jpg"
Write-Host "  course-7.jpg"
Write-Host "  course-8.jpg"

Write-Host "`nNext steps:" -ForegroundColor Cyan
Write-Host "1. Copy image files to: $uploadPath"
Write-Host "2. Execute SQL script: RuoYi-Vue-master\sql\update_course_images.sql"
Write-Host "3. Refresh browser to see changes"

