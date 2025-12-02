package com.ruoyi.web.controller.system;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.util.List;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.ruoyi.common.config.RuoYiConfig;
import com.ruoyi.common.utils.file.FileUtils;
import org.springframework.http.MediaType;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.common.annotation.Log;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.enums.BusinessType;
import com.ruoyi.system.domain.CourseResource;
import com.ruoyi.system.service.ICourseResourceService;
import com.ruoyi.common.utils.poi.ExcelUtil;
import com.ruoyi.common.core.page.TableDataInfo;

/**
 * 课程资源Controller
 * 
 * @author ruoyi
 * @date 2025-11-18
 */
@RestController
@RequestMapping("/system/resource")
public class CourseResourceController extends BaseController
{
    @Autowired
    private ICourseResourceService courseResourceService;

    /**
     * 查询课程资源列表
     */
    @PreAuthorize("@ss.hasPermi('system:resource:list')")
    @GetMapping("/list")
    public TableDataInfo list(CourseResource courseResource)
    {
        startPage();
        List<CourseResource> list = courseResourceService.selectCourseResourceList(courseResource);
        return getDataTable(list);
    }

    /**
     * 导出课程资源列表
     */
    @PreAuthorize("@ss.hasPermi('system:resource:export')")
    @Log(title = "课程资源", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(HttpServletResponse response, CourseResource courseResource)
    {
        List<CourseResource> list = courseResourceService.selectCourseResourceList(courseResource);
        ExcelUtil<CourseResource> util = new ExcelUtil<CourseResource>(CourseResource.class);
        util.exportExcel(response, list, "课程资源数据");
    }

    /**
     * 获取课程资源详细信息
     */
    @PreAuthorize("@ss.hasPermi('system:resource:query')")
    @GetMapping(value = "/{id}")
    public AjaxResult getInfo(@PathVariable("id") Long id)
    {
        return success(courseResourceService.selectCourseResourceById(id));
    }

    /**
     * 新增课程资源
     */
    @PreAuthorize("@ss.hasPermi('system:resource:add')")
    @Log(title = "课程资源", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@RequestBody CourseResource courseResource)
    {
        // 设置上传用户ID为当前登录用户
        courseResource.setUploadUserId(getUserId());
        // 设置创建者
        courseResource.setCreateBy(getUsername());
        return toAjax(courseResourceService.insertCourseResource(courseResource));
    }

    /**
     * 修改课程资源
     */
    @PreAuthorize("@ss.hasPermi('system:resource:edit')")
    @Log(title = "课程资源", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@RequestBody CourseResource courseResource)
    {
        return toAjax(courseResourceService.updateCourseResource(courseResource));
    }

    /**
     * 删除课程资源
     */
    @PreAuthorize("@ss.hasPermi('system:resource:remove')")
    @Log(title = "课程资源", businessType = BusinessType.DELETE)
	@DeleteMapping("/{ids}")
    public AjaxResult remove(@PathVariable Long[] ids)
    {
        return toAjax(courseResourceService.deleteCourseResourceByIds(ids));
    }

    /**
     * ⭐【核心改造】处理文件下载请求：增加下载次数 + 流式返回文件
     *
     * @param id 资源ID
     * @param response HttpServletResponse
     * @param request HttpServletRequest
     */
    @PreAuthorize("@ss.hasPermi('system:resource:list')") // 使用列表权限，确保登录用户可下载
    @Log(title = "课程资源下载", businessType = BusinessType.OTHER)
    @GetMapping("/download/{id}") // ⭐ 将方法改为 GET，更符合下载的语义
    public void resourceDownload(@PathVariable("id") Long id, HttpServletResponse response, HttpServletRequest request)
    {
        FileInputStream fis = null;
        OutputStream os = null;
        try
        {
            // 1. 增加下载次数
            courseResourceService.incrementDownloadCount(id);

            // 2. 查询资源信息
            CourseResource resource = courseResourceService.selectCourseResourceById(id);
            if (resource == null || resource.getFileUrl() == null)
            {
                logger.error("资源不存在，ID: {}", id);
                throw new Exception("资源文件不存在。");
            }

            logger.info("开始下载资源 - ID: {}, 名称: {}, 数据库路径: {}", id, resource.getName(), resource.getFileUrl());
            logger.info("RuoYiConfig.getProfile(): {}", RuoYiConfig.getProfile());

            // 3. 获取文件在服务器上的真实路径
            // resource.getFileUrl() 存储的是相对路径, 如 /profile/upload/2025/11/18/xxx.pdf
            String realPath = RuoYiConfig.getProfile() + resource.getFileUrl().replace("/profile", "");

            logger.info("文件真实路径: {}", realPath);
            logger.info("路径转换: {} -> {}", resource.getFileUrl(), realPath);

            // 4. 检查文件是否存在
            File file = new File(realPath);
            if (!file.exists())
            {
                logger.error("文件不存在: {}", realPath);
                throw new Exception("文件不存在: " + realPath);
            }

            if (!file.isFile())
            {
                logger.error("路径不是文件: {}", realPath);
                throw new Exception("路径不是文件: " + realPath);
            }

            logger.info("文件存在，大小: {} 字节", file.length());

            // 5. 获取文件名 (包含后缀)
            String downloadName = resource.getName();

            // ⭐ 优先从实际文件路径提取扩展名（最可靠）
            String actualFileName = file.getName();
            int dotIndex = actualFileName.lastIndexOf('.');

            if (dotIndex > 0)
            {
                String extension = actualFileName.substring(dotIndex + 1);
                logger.info("从实际文件提取扩展名: {}", extension);

                // 如果资源名称没有扩展名，添加扩展名
                if (!downloadName.contains("."))
                {
                    downloadName = downloadName + "." + extension;
                    logger.info("添加扩展名: {} -> {}", resource.getName(), downloadName);
                }
            }
            else if (!downloadName.contains(".") && resource.getFileType() != null && !resource.getFileType().isEmpty())
            {
                // 备用方案：使用数据库中的 file_type
                downloadName = downloadName + "." + resource.getFileType();
                logger.info("使用数据库file_type字段: {} -> {}", resource.getName(), downloadName);
            }

            // 6. 设置响应头
            response.reset();
            response.setCharacterEncoding("UTF-8");
            response.setContentType("application/octet-stream");
            response.setContentLengthLong(file.length());

            // 设置文件名（支持中文）
            String encodedFileName = java.net.URLEncoder.encode(downloadName, "UTF-8").replaceAll("\\+", "%20");
            response.setHeader("Content-Disposition", "attachment; filename=\"" + encodedFileName + "\"; filename*=utf-8''" + encodedFileName);
            response.setHeader("Access-Control-Expose-Headers", "Content-Disposition");

            logger.info("响应头设置完成 - Content-Type: application/octet-stream, 文件名: {}", downloadName);

            // 7. 读取文件并写入响应流
            fis = new FileInputStream(file);
            os = response.getOutputStream();

            byte[] buffer = new byte[8192];
            int bytesRead;
            long totalBytesRead = 0;

            logger.info("开始读取文件，文件大小: {} 字节", file.length());

            while ((bytesRead = fis.read(buffer)) != -1)
            {
                os.write(buffer, 0, bytesRead);
                totalBytesRead += bytesRead;
            }

            os.flush();

            logger.info("文件下载完成 - 文件实际大小: {}, 总共写入: {} 字节", file.length(), totalBytesRead);

            if (totalBytesRead != file.length())
            {
                logger.error("警告：写入字节数与文件大小不匹配！文件大小: {}, 写入字节: {}", file.length(), totalBytesRead);
            }
        }
        catch (Exception e)
        {
            logger.error("下载文件失败 - ID: {}, 错误: {}", id, e.getMessage(), e);
        }
        finally
        {
            // 关闭流
            if (fis != null)
            {
                try
                {
                    fis.close();
                }
                catch (IOException e)
                {
                    logger.error("关闭文件输入流失败", e);
                }
            }
            if (os != null)
            {
                try
                {
                    os.close();
                }
                catch (IOException e)
                {
                    logger.error("关闭输出流失败", e);
                }
            }
        }
    }

    /**
     * 获取资源预览信息
     *
     * @param id 资源ID
     * @return 预览信息（包含预览URL和预览类型）
     */
    @PreAuthorize("@ss.hasPermi('system:resource:list')")
    @GetMapping("/preview/{id}")
    public AjaxResult getPreviewInfo(@PathVariable("id") Long id)
    {
        try
        {
            CourseResource resource = courseResourceService.selectCourseResourceById(id);
            if (resource == null || resource.getFileUrl() == null)
            {
                return error("资源不存在");
            }

            String fileType = resource.getFileType() != null ? resource.getFileType().toLowerCase() : "";
            String fileUrl = resource.getFileUrl();

            // 构建完整的文件访问URL
            String baseUrl = "http://localhost:8082";
            String fullUrl = baseUrl + fileUrl;

            AjaxResult result = AjaxResult.success();
            result.put("resourceId", id);
            result.put("resourceName", resource.getName());
            result.put("fileType", fileType);
            result.put("fileUrl", fullUrl);

            // 根据文件类型确定预览方式
            if (isImageType(fileType))
            {
                result.put("previewType", "image");
                result.put("previewUrl", fullUrl);
            }
            else if ("pdf".equals(fileType))
            {
                result.put("previewType", "pdf");
                result.put("previewUrl", fullUrl);
            }
            else if (isOfficeType(fileType))
            {
                // 使用微软在线预览服务
                result.put("previewType", "office");
                result.put("previewUrl", "https://view.officeapps.live.com/op/embed.aspx?src=" + java.net.URLEncoder.encode(fullUrl, "UTF-8"));
            }
            else if (isVideoType(fileType))
            {
                result.put("previewType", "video");
                result.put("previewUrl", fullUrl);
            }
            else if (isAudioType(fileType))
            {
                result.put("previewType", "audio");
                result.put("previewUrl", fullUrl);
            }
            else if (isTextType(fileType))
            {
                result.put("previewType", "text");
                result.put("previewUrl", fullUrl);
            }
            else
            {
                result.put("previewType", "unsupported");
                result.put("previewUrl", null);
            }

            return result;
        }
        catch (Exception e)
        {
            logger.error("获取预览信息失败 - ID: {}, 错误: {}", id, e.getMessage(), e);
            return error("获取预览信息失败: " + e.getMessage());
        }
    }

    /**
     * 判断是否为图片类型
     */
    private boolean isImageType(String fileType)
    {
        return "jpg".equals(fileType) || "jpeg".equals(fileType) ||
               "png".equals(fileType) || "gif".equals(fileType) ||
               "bmp".equals(fileType) || "webp".equals(fileType);
    }

    /**
     * 判断是否为Office文档类型
     */
    private boolean isOfficeType(String fileType)
    {
        return "doc".equals(fileType) || "docx".equals(fileType) ||
               "xls".equals(fileType) || "xlsx".equals(fileType) ||
               "ppt".equals(fileType) || "pptx".equals(fileType);
    }

    /**
     * 判断是否为视频类型
     */
    private boolean isVideoType(String fileType)
    {
        return "mp4".equals(fileType) || "webm".equals(fileType) ||
               "ogg".equals(fileType) || "mov".equals(fileType);
    }

    /**
     * 判断是否为音频类型
     */
    private boolean isAudioType(String fileType)
    {
        return "mp3".equals(fileType) || "wav".equals(fileType) ||
               "ogg".equals(fileType) || "aac".equals(fileType);
    }

    /**
     * 判断是否为文本类型
     */
    private boolean isTextType(String fileType)
    {
        return "txt".equals(fileType) || "md".equals(fileType) ||
               "json".equals(fileType) || "xml".equals(fileType) ||
               "html".equals(fileType) || "css".equals(fileType) ||
               "js".equals(fileType);
    }
}
