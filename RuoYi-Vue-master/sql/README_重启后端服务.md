# 重启后端服务说明

## 📋 背景

已添加课程（Course）相关的后端API接口，需要重启后端服务才能生效。

---

## 🆕 新增的后端文件

### 1. Domain层
- `ruoyi-system/src/main/java/com/ruoyi/system/domain/Course.java`
  - 课程实体类

### 2. Mapper层
- `ruoyi-system/src/main/java/com/ruoyi/system/mapper/CourseMapper.java`
  - 课程Mapper接口
- `ruoyi-system/src/main/resources/mapper/system/CourseMapper.xml`
  - 课程Mapper XML配置

### 3. Service层
- `ruoyi-system/src/main/java/com/ruoyi/system/service/ICourseService.java`
  - 课程Service接口
- `ruoyi-system/src/main/java/com/ruoyi/system/service/impl/CourseServiceImpl.java`
  - 课程Service实现类

### 4. Controller层
- `ruoyi-admin/src/main/java/com/ruoyi/web/controller/system/CourseController.java`
  - 课程Controller，提供REST API接口

---

## 🔌 提供的API接口

### 1. 查询课程列表
```
GET /system/course/list
参数：
  - status: 课程状态（进行中/未开始/已结束）
  - courseType: 课程类型（必修课/选修课）
  - isDeleted: 是否删除（0=未删除, 1=已删除）
  - title: 课程名称（模糊查询）
  - term: 学期
  - teacherUserId: 教师ID
```

### 2. 获取课程详情
```
GET /system/course/{id}
```

### 3. 新增课程
```
POST /system/course
```

### 4. 修改课程
```
PUT /system/course
```

### 5. 删除课程
```
DELETE /system/course/{ids}
```

---

## 🚀 重启后端服务

### 方法1：在IDEA中重启

1. 在IDEA中找到运行的后端服务
2. 点击红色停止按钮停止服务
3. 点击绿色运行按钮重新启动服务
4. 等待服务启动完成（看到"Started RuoYiApplication"日志）

### 方法2：使用命令行重启

#### 停止服务
```powershell
# 查找Java进程
Get-Process | Where-Object {$_.ProcessName -like "*java*"}

# 停止后端进程（替换PID为实际的进程ID）
Stop-Process -Id 28944 -Force
```

#### 启动服务
```powershell
# 进入后端目录
cd RuoYi-Vue-master/ruoyi-admin

# 使用Maven启动
mvn spring-boot:run

# 或者如果已经打包，使用jar启动
java -jar target/ruoyi-admin.jar
```

---

## ✅ 验证服务启动成功

### 1. 查看日志
等待看到以下日志：
```
Started RuoYiApplication in X.XXX seconds
```

### 2. 测试API接口
在浏览器或Postman中访问：
```
http://localhost:8080/system/course/list?status=进行中&isDeleted=0
```

应该返回课程列表数据。

### 3. 测试前端页面
1. 刷新浏览器（Ctrl + Shift + R）
2. 访问课程选择页面
3. 应该能看到8门课程的卡片

---

## ⚠️ 常见问题

### 1. 端口被占用
**错误信息**：
```
Port 8080 was already in use
```

**解决方法**：
```powershell
# 查找占用8080端口的进程
netstat -ano | findstr :8080

# 停止该进程（替换PID）
Stop-Process -Id <PID> -Force
```

### 2. 数据库连接失败
**错误信息**：
```
Could not connect to database
```

**解决方法**：
- 检查MySQL服务是否启动
- 检查数据库配置（application.yml）
- 检查数据库用户名密码

### 3. Mapper找不到
**错误信息**：
```
Invalid bound statement (not found): com.ruoyi.system.mapper.CourseMapper.selectCourseList
```

**解决方法**：
- 确认CourseMapper.xml文件位置正确
- 确认namespace配置正确
- 重新编译项目（mvn clean compile）

---

## 📝 权限配置

课程API需要以下权限：
- `system:course:list` - 查询课程列表
- `system:course:query` - 查询课程详情
- `system:course:add` - 新增课程
- `system:course:edit` - 修改课程
- `system:course:remove` - 删除课程
- `system:course:export` - 导出课程

**注意**：当前课程选择页面使用的是 `system:question:list` 权限，学生角色应该已经有这个权限。

如果需要单独配置课程权限，可以在数据库中添加：

```sql
-- 添加课程菜单权限
INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time)
VALUES 
('课程管理', 5, 3, 'course', 'system/course/index', 1, 0, 'C', '0', '0', 'system:course:list', 'education', 'admin', NOW());
```

---

## 🎉 完成后

重启后端服务后：
1. 前端课程选择页面应该能正常加载课程列表
2. 可以看到8门课程的卡片
3. 点击"开始练习"可以进入题目练习页面
4. 所有功能正常工作

---

**创建日期**：2025-11-20  
**维护者**：AI Assistant

