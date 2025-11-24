@echo off
chcp 65001 >nul
REM 知识图谱功能演示脚本 (Windows)
REM 用于快速测试知识图谱生成和可视化功能

echo ==========================================
echo 知识图谱功能演示脚本
echo ==========================================
echo.

REM 配置
set API_BASE_URL=http://localhost:8080
set COURSE_ID=33
set CHAPTER_ID=1

REM 步骤 1: 检查后端服务
echo [步骤 1] 检查后端服务...
curl -s "%API_BASE_URL%/system/graph/list" >nul 2>&1
if %errorlevel% equ 0 (
    echo [√] 后端服务运行正常
) else (
    echo [×] 后端服务未启动，请先启动后端服务
    echo     cd ruoyi-admin ^&^& mvn spring-boot:run
    pause
    exit /b 1
)
echo.

REM 步骤 2: 导入测试数据
echo [步骤 2] 导入测试数据...
echo 请手动执行以下命令导入测试数据：
echo     mysql -u root -p ry-vue ^< sql/test_knowledge_graph.sql
set /p confirm="已导入测试数据？(y/n) "
if /i not "%confirm%"=="y" (
    echo [×] 请先导入测试数据
    pause
    exit /b 1
)
echo [√] 测试数据已导入
echo.

REM 步骤 3: 生成课程知识图谱
echo [步骤 3] 生成课程知识图谱...
echo 调用 API: POST %API_BASE_URL%/system/graph/extract/course/%COURSE_ID%
curl -s -X POST "%API_BASE_URL%/system/graph/extract/course/%COURSE_ID%" -H "Content-Type: application/json"
echo.
echo [√] 已提交课程知识图谱生成任务
echo 等待 5 秒让任务完成...
timeout /t 5 /nobreak >nul
echo.

REM 步骤 4: 生成章节知识图谱
echo [步骤 4] 生成章节知识图谱...
echo 调用 API: POST %API_BASE_URL%/system/graph/extract/chapter/%COURSE_ID%/%CHAPTER_ID%
curl -s -X POST "%API_BASE_URL%/system/graph/extract/chapter/%COURSE_ID%/%CHAPTER_ID%" -H "Content-Type: application/json"
echo.
echo [√] 已提交章节知识图谱生成任务
echo 等待 5 秒让任务完成...
timeout /t 5 /nobreak >nul
echo.

REM 步骤 5: 查询生成的知识图谱
echo [步骤 5] 查询生成的知识图谱...
echo 调用 API: GET %API_BASE_URL%/system/graph/list?courseId=%COURSE_ID%
curl -s "%API_BASE_URL%/system/graph/list?courseId=%COURSE_ID%"
echo.
echo [√] 知识图谱查询完成
echo.

REM 步骤 6: 查看数据库中的知识点
echo [步骤 6] 查看数据库中的知识点...
echo 请执行以下 SQL 查询：
echo.
echo -- 查看知识点
echo SELECT id, title, description, level FROM knowledge_point WHERE course_id = %COURSE_ID%;
echo.
echo -- 查看知识点关系
echo SELECT 
echo     kp1.title AS source,
echo     kp2.title AS target,
echo     r.relation_type,
echo     r.ai_generated
echo FROM kp_relation r
echo JOIN knowledge_point kp1 ON r.from_kp_id = kp1.id
echo JOIN knowledge_point kp2 ON r.to_kp_id = kp2.id
echo WHERE kp1.course_id = %COURSE_ID%;
echo.

REM 步骤 7: 打开前端可视化页面
echo [步骤 7] 打开前端可视化页面...
echo 正在打开浏览器...
start http://localhost/system/graph/visualize?courseId=%COURSE_ID%^&chapterId=%CHAPTER_ID%
echo.
echo 操作步骤：
echo   1. 选择课程 ID: %COURSE_ID%
echo   2. 选择章节 ID: %CHAPTER_ID%
echo   3. 点击'加载知识图谱'按钮
echo   4. 查看交互式知识图谱可视化
echo.

REM 完成
echo ==========================================
echo [√] 演示完成！
echo ==========================================
echo.
echo 预期结果：
echo   - 生成了课程级和章节级知识图谱
echo   - 数据库中保存了知识点和关系
echo   - 前端可以可视化展示知识图谱
echo.
echo 如果遇到问题，请查看：
echo   - 后端日志: ruoyi-admin\logs\sys-info.log
echo   - 前端控制台: 浏览器 F12 开发者工具
echo   - 数据库: 检查 knowledge_point 和 kp_relation 表
echo.
echo 更多信息请参考：
echo   - README_KG_RELATIONS.md
echo   - 知识图谱可视化使用指南.md
echo   - 知识图谱功能实现总结.md
echo.
pause

