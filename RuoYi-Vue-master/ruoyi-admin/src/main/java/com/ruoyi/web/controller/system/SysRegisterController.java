package com.ruoyi.web.controller.system;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.common.annotation.Anonymous;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.domain.model.RegisterBody;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.framework.web.service.SysRegisterService;
import com.ruoyi.framework.web.service.EmailService;
import com.ruoyi.system.service.ISysConfigService;
import com.ruoyi.system.service.IUserSyncService;
import com.ruoyi.system.service.ISysUserService;
import com.ruoyi.system.domain.User;
import com.ruoyi.common.core.domain.entity.SysUser;
import com.ruoyi.common.utils.SecurityUtils;

/**
 * 注册验证
 *
 * @author ruoyi
 */
@RestController
public class SysRegisterController extends BaseController
{
    @Autowired
    private SysRegisterService registerService;

    @Autowired
    private ISysConfigService configService;

    @Autowired
    private IUserSyncService userSyncService;

    @Autowired
    private ISysUserService userService;

    @Autowired
    private EmailService emailService;

    /**
     * 发送邮箱验证码
     */
    @Anonymous
    @PostMapping("/sendEmailCode")
    public AjaxResult sendEmailCode(@RequestParam("email") String email)
    {
        if (StringUtils.isEmpty(email))
        {
            return error("邮箱不能为空");
        }
        // 简单的邮箱格式验证
        if (!email.matches("^[a-zA-Z0-9_-]+@[a-zA-Z0-9_-]+(\\.[a-zA-Z0-9_-]+)+$"))
        {
            return error("邮箱格式不正确");
        }
        boolean result = emailService.sendVerifyCode(email);
        return result ? success("验证码发送成功") : error("验证码发送失败，请稍后重试");
    }

    @PostMapping("/register")
    public AjaxResult register(@RequestBody RegisterBody user)
    {
        if (!("true".equals(configService.selectConfigByKey("sys.account.registerUser"))))
        {
            return error("当前系统没有开启注册功能！");
        }
        String msg = registerService.register(user);
        return StringUtils.isEmpty(msg) ? success() : error(msg);
    }

    /**
     * 验证用户同步状态
     *
     * @param username 用户名
     * @return 同步状态信息
     */
    @GetMapping("/verifySyncStatus")
    public AjaxResult verifySyncStatus(@RequestParam("username") String username)
    {
        try {
            // 查询 sys_user 表
            SysUser sysUser = userService.selectUserByUserName(username);
            if (sysUser == null) {
                return error("用户不存在");
            }

            // 查询 user 表
            User user = userSyncService.getUserBySysUserId(sysUser.getUserId());

            AjaxResult ajax = AjaxResult.success();
            ajax.put("sysUser", sysUser);
            ajax.put("user", user);
            ajax.put("synced", user != null);

            if (user != null) {
                // 验证关键字段
                boolean usernameMatch = username.equals(user.getUsername());
                boolean sysUserIdMatch = sysUser.getUserId().equals(user.getSysUserId());

                ajax.put("usernameMatch", usernameMatch);
                ajax.put("sysUserIdMatch", sysUserIdMatch);
                ajax.put("syncSuccess", usernameMatch && sysUserIdMatch);
            } else {
                ajax.put("syncSuccess", false);
                ajax.put("message", "user表中未找到对应记录");
            }

            return ajax;
        } catch (Exception e) {
            return error("验证同步状态失败: " + e.getMessage());
        }
    }

    /**
     * 通过邮箱查询用户名
     */
    @Anonymous
    @GetMapping("/getUserByEmail")
    public AjaxResult getUserByEmail(@RequestParam("email") String email)
    {
        if (StringUtils.isEmpty(email))
        {
            return error("邮箱不能为空");
        }
        // 简单的邮箱格式验证
        if (!email.matches("^[a-zA-Z0-9_-]+@[a-zA-Z0-9_-]+(\\.[a-zA-Z0-9_-]+)+$"))
        {
            return error("邮箱格式不正确");
        }
        // 验证邮箱是否存在对应的用户
        SysUser sysUser = userService.selectUserByEmail(email);
        if (sysUser == null)
        {
            return error("该邮箱未绑定任何账号");
        }
        AjaxResult ajax = AjaxResult.success();
        ajax.put("userName", sysUser.getUserName());
        ajax.put("nickName", sysUser.getNickName());
        return ajax;
    }

    /**
     * 发送重置密码验证码（通过邮箱）
     */
    @Anonymous
    @PostMapping("/sendResetPwdCode")
    public AjaxResult sendResetPwdCode(@RequestParam("email") String email)
    {
        if (StringUtils.isEmpty(email))
        {
            return error("邮箱不能为空");
        }
        // 简单的邮箱格式验证
        if (!email.matches("^[a-zA-Z0-9_-]+@[a-zA-Z0-9_-]+(\\.[a-zA-Z0-9_-]+)+$"))
        {
            return error("邮箱格式不正确");
        }
        // 验证邮箱是否存在对应的用户
        SysUser sysUser = userService.selectUserByEmail(email);
        if (sysUser == null)
        {
            return error("该邮箱未绑定任何账号");
        }
        boolean result = emailService.sendResetPwdCode(email);
        if (result) {
            AjaxResult ajax = AjaxResult.success("验证码发送成功");
            ajax.put("userName", sysUser.getUserName());
            ajax.put("nickName", sysUser.getNickName());
            return ajax;
        }
        return error("验证码发送失败，请稍后重试");
    }

    /**
     * 通过邮箱验证码重置密码
     */
    @Anonymous
    @PostMapping("/resetPwdByEmail")
    public AjaxResult resetPwdByEmail(@RequestBody java.util.Map<String, String> params)
    {
        String email = params.get("email");
        String code = params.get("code");
        String newPassword = params.get("newPassword");

        if (StringUtils.isEmpty(email))
        {
            return error("邮箱不能为空");
        }
        if (StringUtils.isEmpty(code))
        {
            return error("验证码不能为空");
        }
        if (StringUtils.isEmpty(newPassword))
        {
            return error("新密码不能为空");
        }
        if (newPassword.length() < 5 || newPassword.length() > 20)
        {
            return error("密码长度必须在5到20个字符之间");
        }

        // 验证邮箱验证码
        if (!emailService.verifyResetPwdCode(email, code))
        {
            return error("验证码错误或已过期");
        }

        // 查找用户
        SysUser sysUser = userService.selectUserByEmail(email);
        if (sysUser == null)
        {
            return error("该邮箱未绑定任何账号");
        }

        // 重置密码
        String encryptedPassword = SecurityUtils.encryptPassword(newPassword);
        int result = userService.resetUserPwd(sysUser.getUserName(), encryptedPassword);

        if (result > 0)
        {
            return success("密码重置成功，请使用新密码登录");
        }
        return error("密码重置失败，请稍后重试");
    }
}
