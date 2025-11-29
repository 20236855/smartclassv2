package com.ruoyi.framework.web.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;
import com.ruoyi.common.constant.CacheConstants;
import com.ruoyi.common.core.redis.RedisCache;
import com.ruoyi.common.utils.StringUtils;

import javax.mail.MessagingException;
import javax.mail.internet.MimeMessage;
import java.util.Random;
import java.util.concurrent.TimeUnit;

/**
 * 邮件服务
 * 
 * @author ruoyi
 */
@Service
public class EmailService
{
    private static final Logger log = LoggerFactory.getLogger(EmailService.class);

    @Autowired
    private JavaMailSender mailSender;

    @Autowired
    private RedisCache redisCache;

    @Value("${spring.mail.username}")
    private String fromEmail;

    /**
     * 发送邮箱验证码
     * 
     * @param toEmail 目标邮箱
     * @return 是否发送成功
     */
    public boolean sendVerifyCode(String toEmail)
    {
        if (StringUtils.isEmpty(toEmail))
        {
            return false;
        }

        // 生成6位随机验证码
        String code = generateVerifyCode();

        try
        {
            // 创建邮件
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");

            helper.setFrom(fromEmail);
            helper.setTo(toEmail);
            helper.setSubject("【智慧课程系统】注册验证码");

            // 邮件内容
            String content = buildEmailContent(code);
            helper.setText(content, true);

            // 发送邮件
            mailSender.send(message);

            // 将验证码存入Redis，有效期5分钟
            String redisKey = CacheConstants.EMAIL_CODE_KEY + toEmail;
            redisCache.setCacheObject(redisKey, code, 5, TimeUnit.MINUTES);

            log.info("邮箱验证码发送成功: {}", toEmail);
            return true;
        }
        catch (MessagingException e)
        {
            log.error("邮箱验证码发送失败: {}", e.getMessage());
            return false;
        }
    }

    /**
     * 验证邮箱验证码
     * 
     * @param email 邮箱
     * @param code 验证码
     * @return 是否验证通过
     */
    public boolean verifyCode(String email, String code)
    {
        if (StringUtils.isEmpty(email) || StringUtils.isEmpty(code))
        {
            return false;
        }

        String redisKey = CacheConstants.EMAIL_CODE_KEY + email;
        String cachedCode = redisCache.getCacheObject(redisKey);

        if (StringUtils.isEmpty(cachedCode))
        {
            return false;
        }

        boolean result = code.equalsIgnoreCase(cachedCode);

        // 验证成功后删除验证码
        if (result)
        {
            redisCache.deleteObject(redisKey);
        }

        return result;
    }

    /**
     * 生成6位随机验证码
     */
    private String generateVerifyCode()
    {
        Random random = new Random();
        StringBuilder code = new StringBuilder();
        for (int i = 0; i < 6; i++)
        {
            code.append(random.nextInt(10));
        }
        return code.toString();
    }

    /**
     * 发送重置密码验证码
     *
     * @param toEmail 目标邮箱
     * @return 是否发送成功
     */
    public boolean sendResetPwdCode(String toEmail)
    {
        if (StringUtils.isEmpty(toEmail))
        {
            return false;
        }

        // 生成6位随机验证码
        String code = generateVerifyCode();

        try
        {
            // 创建邮件
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");

            helper.setFrom(fromEmail);
            helper.setTo(toEmail);
            helper.setSubject("【智慧课程系统】重置密码验证码");

            // 邮件内容
            String content = buildResetPwdEmailContent(code);
            helper.setText(content, true);

            // 发送邮件
            mailSender.send(message);

            // 将验证码存入Redis，有效期5分钟，使用不同的key前缀
            String redisKey = CacheConstants.EMAIL_CODE_KEY + "reset:" + toEmail;
            redisCache.setCacheObject(redisKey, code, 5, TimeUnit.MINUTES);

            log.info("重置密码验证码发送成功: {}", toEmail);
            return true;
        }
        catch (MessagingException e)
        {
            log.error("重置密码验证码发送失败: {}", e.getMessage());
            return false;
        }
    }

    /**
     * 验证重置密码验证码
     *
     * @param email 邮箱
     * @param code 验证码
     * @return 是否验证通过
     */
    public boolean verifyResetPwdCode(String email, String code)
    {
        if (StringUtils.isEmpty(email) || StringUtils.isEmpty(code))
        {
            return false;
        }

        String redisKey = CacheConstants.EMAIL_CODE_KEY + "reset:" + email;
        String cachedCode = redisCache.getCacheObject(redisKey);

        if (StringUtils.isEmpty(cachedCode))
        {
            return false;
        }

        boolean result = code.equalsIgnoreCase(cachedCode);

        // 验证成功后删除验证码
        if (result)
        {
            redisCache.deleteObject(redisKey);
        }

        return result;
    }

    /**
     * 构建邮件内容
     */
    private String buildEmailContent(String code)
    {
        return "<div style='padding: 30px; background: #f5f5f5;'>" +
               "  <div style='max-width: 500px; margin: 0 auto; background: #ffffff; border-radius: 10px; padding: 40px; box-shadow: 0 2px 10px rgba(0,0,0,0.1);'>" +
               "    <h2 style='color: #333; margin-bottom: 30px; text-align: center;'>智慧课程系统</h2>" +
               "    <p style='color: #666; font-size: 14px; line-height: 1.8;'>您好！</p>" +
               "    <p style='color: #666; font-size: 14px; line-height: 1.8;'>您正在注册智慧课程系统账号，验证码为：</p>" +
               "    <div style='text-align: center; margin: 30px 0;'>" +
               "      <span style='display: inline-block; padding: 15px 40px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: #fff; font-size: 28px; font-weight: bold; letter-spacing: 8px; border-radius: 8px;'>" + code + "</span>" +
               "    </div>" +
               "    <p style='color: #999; font-size: 12px; line-height: 1.8;'>验证码有效期为5分钟，请勿泄露给他人。</p>" +
               "    <p style='color: #999; font-size: 12px; line-height: 1.8;'>如果这不是您的操作，请忽略此邮件。</p>" +
               "    <hr style='border: none; border-top: 1px solid #eee; margin: 30px 0;'/>" +
               "    <p style='color: #bbb; font-size: 11px; text-align: center;'>此邮件由系统自动发送，请勿回复</p>" +
               "  </div>" +
               "</div>";
    }

    /**
     * 构建重置密码邮件内容
     */
    private String buildResetPwdEmailContent(String code)
    {
        return "<div style='padding: 30px; background: #f5f5f5;'>" +
               "  <div style='max-width: 500px; margin: 0 auto; background: #ffffff; border-radius: 10px; padding: 40px; box-shadow: 0 2px 10px rgba(0,0,0,0.1);'>" +
               "    <h2 style='color: #333; margin-bottom: 30px; text-align: center;'>智慧课程系统</h2>" +
               "    <p style='color: #666; font-size: 14px; line-height: 1.8;'>您好！</p>" +
               "    <p style='color: #666; font-size: 14px; line-height: 1.8;'>您正在重置密码，验证码为：</p>" +
               "    <div style='text-align: center; margin: 30px 0;'>" +
               "      <span style='display: inline-block; padding: 15px 40px; background: linear-gradient(135deg, #f56c6c 0%, #e74c3c 100%); color: #fff; font-size: 28px; font-weight: bold; letter-spacing: 8px; border-radius: 8px;'>" + code + "</span>" +
               "    </div>" +
               "    <p style='color: #999; font-size: 12px; line-height: 1.8;'>验证码有效期为5分钟，请勿泄露给他人。</p>" +
               "    <p style='color: #f56c6c; font-size: 12px; line-height: 1.8;'>如果这不是您本人的操作，请立即检查账号安全！</p>" +
               "    <hr style='border: none; border-top: 1px solid #eee; margin: 30px 0;'/>" +
               "    <p style='color: #bbb; font-size: 11px; text-align: center;'>此邮件由系统自动发送，请勿回复</p>" +
               "  </div>" +
               "</div>";
    }
}

