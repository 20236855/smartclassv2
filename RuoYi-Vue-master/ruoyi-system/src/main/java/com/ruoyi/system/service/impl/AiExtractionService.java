package com.ruoyi.system.service.impl;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.LinkedHashMap;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

/**
 * AI 抽取服务：优先尝试调用千问（Qianwen），否则回退到占位实现。
 */
@Service
public class AiExtractionService {

    private static final Logger logger = LoggerFactory.getLogger(AiExtractionService.class);

    @Value("${qianwen.api.url:}")
    private String qianwenApiUrl;

    @Value("${qianwen.api.key:}")
    private String qianwenApiKey;

    @Value("${qianwen.api.model:Qwen/QwQ-32B}")
    private String qianwenApiModel;

    private RestTemplate rest = new RestTemplate();

    /**
     * 从文本中抽取知识点候选（优先调用千问；若未配置或调用失败，使用本地占位实现）
     * 返回 List of maps: {"name":"知识点名","definition":"简短定义","confidence":0.9}
     */
    public List<Map<String,Object>> extractKnowledgePoints(String text) {
        Map<String,Object> result = extractKnowledgePointsWithRelations(text);
        return (List<Map<String,Object>>) result.get("candidates");
    }

    /**
     * 从文本中抽取知识点和关系（优先调用千问；若未配置或调用失败，使用本地占位实现）
     * 返回 Map: {
     *   "candidates": List of maps {"name":"知识点名","definition":"简短定义","confidence":0.9},
     *   "relations": List of maps {"source":"知识点A","target":"知识点B","type":"prerequisite","confidence":0.8}
     * }
     */
    public Map<String,Object> extractKnowledgePointsWithRelations(String text) {
        logger.info("extractKnowledgePointsWithRelations 被调用，文本长度: {}", text != null ? text.length() : 0);
        Map<String,Object> result = new HashMap<>();
        result.put("candidates", new ArrayList<>());
        result.put("relations", new ArrayList<>());

        if (text == null || text.trim().isEmpty()) {
            return result;
        }

        // 如果配置了 qianwenApiUrl，则尝试调用远端服务（使用优化后的中文提示词）
        if (qianwenApiUrl != null && !qianwenApiUrl.trim().isEmpty()) {
            try {
                return callQianwenWithRelations(text);
            } catch (Exception ex) {
                logger.warn("调用 Qianwen 抽取失败，回退到本地增强实现：{}", ex.getMessage());
            }
        }

        // 本地增强回退：基于数学关键词与正则的启发式抽取
        result.put("candidates", localRegexExtract(text));
        result.put("relations", new ArrayList<>()); // 本地实现暂不支持关系抽取
        return result;
    }

    /**
     * 调用千问 API 抽取知识点和关系
     */
    @SuppressWarnings("unchecked")
    private Map<String,Object> callQianwenWithRelations(String text) throws Exception {
        logger.info("调用 Qianwen 接口（含关系抽取）: {}", qianwenApiUrl);
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        if (qianwenApiKey != null && !qianwenApiKey.trim().isEmpty()) {
            headers.set("Authorization", "Bearer " + qianwenApiKey);
        }

        // 构造符合 SiliconFlow/Qwen 的请求体
        Map<String,Object> body = new HashMap<>();
        body.put("model", qianwenApiModel != null && !qianwenApiModel.isEmpty() ? qianwenApiModel : "Qwen/QwQ-32B");
        List<Map<String,String>> messages = new ArrayList<>();
        Map<String,String> userMsg = new HashMap<>();
        userMsg.put("role", "user");

        // 使用通用的知识点抽取提示词，支持题目和视频内容
        String prompt = "你是一个智慧课堂知识点抽取器（批量处理模式）。\n\n"
            + "【输入说明】\n"
            + "输入可能包含以下类型的教学内容，每条内容以 === 题目 ID === 分隔：\n"
            + "1. 教学题目：包含题干、选项、答案、解析等\n"
            + "2. 视频内容：包含视频标题、视频描述、视频讲解内容等（可能来自语音识别，存在识别错误）\n"
            + "3. 课程资源：包含资源标题、资源描述、资源内容等\n"
            + "内容可能涉及数学、物理、化学、生物、语文、英语、历史、地理、计算机等各个学科。\n\n"
            + "【任务要求】\n"
            + "请从输入的所有内容中抽取知识点和知识点之间的关系，返回纯JSON格式。\n\n"
            + "【返回格式】\n"
            + "返回格式为一个对象 {\"candidates\": [...], \"relations\": [...] }。\n\n"
            + "【candidates数组说明】\n"
            + "每个候选（candidate）是对象，必须包含以下字段：\n"
            + "- \"title\"（知识点名称）：简洁的知识点名称，如\"面向对象编程\"、\"牛顿第一定律\"、\"光合作用\"\n"
            + "- \"definition\"（定义）：一句话定义该知识点，如\"面向对象编程是一种程序设计范式，使用对象来设计应用程序\"\n"
            + "- \"evidence\"（证据）：从原文中摘录的关键表达，证明该知识点的存在\n"
            + "- \"confidence\"（置信度）：0.0-1.0的浮点数，表示该知识点的可信度\n\n"
            + "【置信度评估标准】（重要！）\n"
            + "根据以下标准严格评估每个知识点的置信度：\n\n"
            + "★ 高置信度 (0.7-1.0)：\n"
            + "  - 原文明确提到该知识点的定义、概念或详细解释\n"
            + "  - 有充分的证据支持（如题目解析、视频详细讲解）\n"
            + "  - 知识点表述清晰、准确、完整\n"
            + "  - 示例：题目解析中明确说明的概念、视频中详细讲解的知识点\n\n"
            + "★ 中置信度 (0.4-0.7)：\n"
            + "  - 原文提到该知识点，但解释不够详细\n"
            + "  - 可以从上下文推断出该知识点，但不是直接表述\n"
            + "  - 视频语音识别可能有误，但大致意思清楚\n"
            + "  - 示例：题干中隐含的概念、视频简要提及的知识点\n\n"
            + "★ 低置信度 (0.0-0.4)：\n"
            + "  - 仅从标题或简短描述推测的知识点\n"
            + "  - 证据不足，主要靠推断\n"
            + "  - 视频语音识别质量差，内容不确定\n"
            + "  - 示例：仅从视频标题推测的知识点、模糊的相关概念\n\n"
            + "【抽取规则】\n"
            + "1. 从所有内容中综合抽取知识点，去除重复\n"
            + "2. 最多返回30个候选知识点（包含各置信度级别）\n"
            + "3. 优先抽取高置信度知识点，但也要包含中低置信度的知识点\n"
            + "4. 如果没有明确的知识点，返回 {\"candidates\":[], \"relations\":[] }\n"
            + "5. 对于专业表达式（数学公式、化学方程式、物理定律、代码片段等）保留原式作为evidence\n"
            + "6. 在title中使用规范化的学术名称\n"
            + "7. 对于视频内容，即使语音识别有误，也尝试推断知识点（标记为中低置信度）\n"
            + "8. 置信度必须严格按照上述标准评估，不要都给高分\n\n"
            + "【relations数组说明】\n"
            + "如果能够推断知识点之间的关系，请放在relations数组中，格式：\n"
            + "{\n"
            + "  \"source\": \"知识点A名称\",\n"
            + "  \"target\": \"知识点B名称\",\n"
            + "  \"type\": \"prerequisite|uses|related_method|similar\",\n"
            + "  \"confidence\": 0.0-1.0,\n"
            + "  \"evidence\": \"推断依据\"\n"
            + "}\n\n"
            + "关系类型说明：\n"
            + "- prerequisite：前置关系（A是B的前置知识）\n"
            + "- uses：应用关系（A应用了B）\n"
            + "- related_method：相关方法（A和B是相关的方法）\n"
            + "- similar：相似概念（A和B是相似的概念）\n\n"
            + "【关系置信度评估】\n"
            + "- 高置信度 (≥0.7)：原文明确说明的关系（如\"A是B的基础\"、\"需要先学习A才能理解B\"）\n"
            + "- 中置信度 (0.4-0.7)：从上下文可以推断的关系（如A和B在同一段落中讨论）\n"
            + "- 低置信度 (<0.4)：基于常识推断的关系（如两个相关概念可能有联系）\n\n"
            + "【置信度示例】\n"
            + "示例1 - 高置信度 (0.9)：\n"
            + "原文：\"面向对象编程（OOP）是一种程序设计范式，它使用'对象'来设计应用程序。对象包含数据（属性）和代码（方法）。\"\n"
            + "抽取：{\"title\":\"面向对象编程\", \"definition\":\"使用对象来设计应用程序的程序设计范式\", \"evidence\":\"面向对象编程（OOP）是一种程序设计范式，它使用'对象'来设计应用程序\", \"confidence\":0.9}\n\n"
            + "示例2 - 中置信度 (0.6)：\n"
            + "原文：\"这个视频讲解了Java的类和对象的概念...\"\n"
            + "抽取：{\"title\":\"类和对象\", \"definition\":\"Java中的基本概念\", \"evidence\":\"讲解了Java的类和对象的概念\", \"confidence\":0.6}\n\n"
            + "示例3 - 低置信度 (0.3)：\n"
            + "原文：\"【视频标题】Java入门教程\"\n"
            + "抽取：{\"title\":\"Java基础\", \"definition\":\"Java编程语言的基础知识\", \"evidence\":\"Java入门教程\", \"confidence\":0.3}\n\n"
            + "【重要提示】\n"
            + "1. 只返回纯JSON，不要有任何其他文字\n"
            + "2. 确保JSON格式正确，可以被解析\n"
            + "3. 如果内容太少或没有明确知识点，返回空数组\n"
            + "4. 置信度必须真实反映证据的充分程度，不要都给高分\n"
            + "5. 对于视频内容，考虑到语音识别可能有误，适当降低置信度\n\n"
            + "【待抽取的原文】\n" + text;
        userMsg.put("content", prompt);
        messages.add(userMsg);
        body.put("messages", messages);

        HttpEntity<Map<String,Object>> entity = new HttpEntity<>(body, headers);
        Map<String,Object> resp = null;
        try {
            resp = rest.postForObject(qianwenApiUrl, entity, Map.class);
        } catch (org.springframework.web.client.HttpClientErrorException | org.springframework.web.client.HttpServerErrorException httpEx) {
            String respBody = null;
            try { respBody = httpEx.getResponseBodyAsString(); } catch (Exception e) { respBody = httpEx.getMessage(); }
            logger.warn("Qianwen HTTP error: status={} body={}", httpEx.getStatusCode(), respBody);
            throw new Exception("Qianwen HTTP error: " + httpEx.getStatusCode() + " response: " + respBody);
        } catch (org.springframework.web.client.ResourceAccessException rae) {
            logger.warn("Qianwen resource access error: {}", rae.getMessage());
            throw new Exception("Qianwen resource access error: " + rae.getMessage());
        } catch (Exception ex) {
            logger.warn("调用 Qianwen 时出现异常：{}", ex.getMessage());
            throw ex;
        }

        Map<String,Object> result = new HashMap<>();
        List<Map<String,Object>> candidates = new ArrayList<>();
        List<Map<String,Object>> relations = new ArrayList<>();
        result.put("candidates", candidates);
        result.put("relations", relations);

        if (resp == null) {
            logger.warn("Qianwen 返回空响应");
            return result;
        }

        // 解析响应
        try {
            Object choicesObj = resp.get("choices");
            if (choicesObj instanceof List) {
                List choices = (List) choicesObj;
                if (!choices.isEmpty() && choices.get(0) instanceof Map) {
                    Object messageObj = ((Map) choices.get(0)).get("message");
                    String content = null;
                    if (messageObj instanceof Map) {
                        Object c = ((Map) messageObj).get("content");
                        if (c != null) content = c.toString();
                    } else if (((Map) choices.get(0)).get("text") != null) {
                        content = ((Map) choices.get(0)).get("text").toString();
                    }

                    if (content != null) {
                        // 尝试解析 content 为 JSON 对象
                        com.fasterxml.jackson.databind.ObjectMapper mapper = new com.fasterxml.jackson.databind.ObjectMapper();
                        try {
                            Map<String,Object> parsed = mapper.readValue(content, new com.fasterxml.jackson.core.type.TypeReference<Map<String,Object>>(){});

                            // 提取 candidates
                            Object candidatesObj = parsed.get("candidates");
                            if (candidatesObj instanceof List) {
                                List candidatesList = (List) candidatesObj;
                                logger.info("AI返回的candidates数量：{}", candidatesList.size());
                                for (Object candidateObj : candidatesList) {
                                    if (candidateObj instanceof Map) {
                                        Map<String,Object> candidateMap = (Map<String,Object>) candidateObj;
                                        logger.info("AI返回的知识点数据：{}", candidateMap);

                                        // 遍历所有字段，看看实际有什么
                                        candidateMap.forEach((key, value) -> {
                                            logger.info("候选字段：{} = {}", key, value);
                                        });

                                        candidates.add(candidateMap);
                                    }
                                }
                            }

                            // 提取 relations
                            Object relationsObj = parsed.get("relations");
                            if (relationsObj instanceof List) {
                                List<Map<String,Object>> parsedRelations = (List<Map<String,Object>>) relationsObj;
                                for (Map<String,Object> item : parsedRelations) {
                                    Map<String,Object> rel = new HashMap<>();
                                    rel.put("source", item.getOrDefault("source", "").toString());
                                    rel.put("target", item.getOrDefault("target", "").toString());
                                    rel.put("type", item.getOrDefault("type", "related").toString());
                                    Object conf = item.get("confidence");
                                    try { rel.put("confidence", conf!=null?Double.parseDouble(conf.toString()):0.0); } catch (Exception e) { rel.put("confidence", 0.0); }
                                    rel.put("evidence", item.getOrDefault("evidence", "").toString());
                                    relations.add(rel);
                                }
                            }

                            logger.info("Qianwen 返回 {} 条候选，{} 条关系", candidates.size(), relations.size());
                            return result;
                        } catch (Exception ex) {
                            logger.warn("解析 Qianwen content 为 JSON 失败：{}", ex.getMessage());
                        }
                    }
                }
            }
        } catch (Exception ex) {
            logger.warn("解析 Qianwen 响应失败：{}", ex.getMessage());
        }

        return result;
    }

    /**
     * 示范性调用千问 API 的模板实现（仅返回知识点列表，兼容旧接口）
     */
    @SuppressWarnings("unchecked")
    private List<Map<String,Object>> callQianwen(String text) throws Exception {
        logger.info("调用 Qianwen 接口: {}", qianwenApiUrl);
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        if (qianwenApiKey != null && !qianwenApiKey.trim().isEmpty()) {
            headers.set("Authorization", "Bearer " + qianwenApiKey);
        }

        // 构造符合 SiliconFlow/Qwen 的请求体：{model, messages:[{role,user,content:prompt}]}
        Map<String,Object> body = new HashMap<>();
        body.put("model", qianwenApiModel != null && !qianwenApiModel.isEmpty() ? qianwenApiModel : "Qwen/QwQ-32B");
        List<Map<String,String>> messages = new ArrayList<>();
        Map<String,String> userMsg = new HashMap<>();
        userMsg.put("role", "user");
        // 使用优化后的中文提示词，要求返回纯 JSON，以便直接解析
        String prompt = "你是一个数学题知识点抽取器（专业模式）。输入为题目文本（题干、选项、解析等）。请按照下述要求只返回纯 JSON：\n"
            + "返回格式为一个对象 {\"candidates\": [...], \"primary\": {...}, \"relations\": [...] }。\n"
            + "每个候选（candidate）是对象，必须包含字段：\"name\"（知识点名），\"definition\"（一句定义），\"evidence\"（题目中摘录的一句话或数学表达），\"evidence_source\"（title|explanation|options|context），\"confidence\"（0.0-1.0 浮点）。\n"
            + "最多返回 6 个候选；如果没有明确候选，返回 {\"candidates\":[] }。\n"
            + "对数学表达式（如 lim, \\\\lim, sin, cos, ≈, →）保留原式作为 evidence，并在 name 中使用规范化名（例如：\"小角度近似 (sin kx ≈ kx)\"、\"洛必塔法则\"）。\n"
            + "如果能够推断知识点之间的关系（例如 prerequisite, uses, related_method），请把关系放在 relations 数组中，格式 {source, target, type, confidence, evidence}。\n"
            + "不要输出任何除 JSON 之外的文本。下面是待抽取的原文（请严格以 JSON 返回）：\n" + text;
        userMsg.put("content", prompt);
        messages.add(userMsg);
        body.put("messages", messages);

        HttpEntity<Map<String,Object>> entity = new HttpEntity<>(body, headers);
        Map<String,Object> resp = null;
        try {
            resp = rest.postForObject(qianwenApiUrl, entity, Map.class);
        } catch (org.springframework.web.client.HttpClientErrorException | org.springframework.web.client.HttpServerErrorException httpEx) {
            String respBody = null;
            try { respBody = httpEx.getResponseBodyAsString(); } catch (Exception e) { respBody = httpEx.getMessage(); }
            logger.warn("Qianwen HTTP error: status={} body={}", httpEx.getStatusCode(), respBody);
            throw new Exception("Qianwen HTTP error: " + httpEx.getStatusCode() + " response: " + respBody);
        } catch (org.springframework.web.client.ResourceAccessException rae) {
            logger.warn("Qianwen resource access error: {}", rae.getMessage());
            throw new Exception("Qianwen resource access error: " + rae.getMessage());
        } catch (Exception ex) {
            logger.warn("调用 Qianwen 时出现异常：{}", ex.getMessage());
            throw ex;
        }
        List<Map<String,Object>> result = new ArrayList<>();
        if (resp == null) {
            logger.warn("Qianwen 返回空响应");
            return result;
        }
        // 首先尝试解析标准 OpenAI-like response -> choices[0].message.content
        try {
            Object choicesObj = resp.get("choices");
            if (choicesObj instanceof List) {
                List choices = (List) choicesObj;
                if (!choices.isEmpty() && choices.get(0) instanceof Map) {
                    Object messageObj = ((Map) choices.get(0)).get("message");
                    String content = null;
                    if (messageObj instanceof Map) {
                        Object c = ((Map) messageObj).get("content");
                        if (c != null) content = c.toString();
                    } else if (((Map) choices.get(0)).get("text") != null) {
                        content = ((Map) choices.get(0)).get("text").toString();
                    }

                    if (content != null) {
                        // 尝试解析 content 为 JSON 数组
                        com.fasterxml.jackson.databind.ObjectMapper mapper = new com.fasterxml.jackson.databind.ObjectMapper();
                        try {
                            List<Map<String,Object>> parsed = mapper.readValue(content, new com.fasterxml.jackson.core.type.TypeReference<List<Map<String,Object>>>(){});
                            // 规范化 confidence 字段并返回
                            for (Map<String,Object> item : parsed) {
                                Map<String,Object> kv = new HashMap<>();
                                kv.put("name", item.getOrDefault("name", "").toString());
                                kv.put("definition", item.getOrDefault("definition", "").toString());
                                Object conf = item.get("confidence");
                                try { kv.put("confidence", conf!=null?Double.parseDouble(conf.toString()):0.0); } catch (Exception e) { kv.put("confidence", 0.0); }
                                result.add(kv);
                            }
                            logger.info("Qianwen 返回 {} 条候选（解析自 content）", result.size());
                            if (!result.isEmpty()) return result;
                        } catch (Exception ex) {
                            logger.warn("解析 Qianwen content 为 JSON 失败，将尝试回退解析：{}", ex.getMessage());
                        }
                    }
                }
            }
        } catch (Exception ex) {
            logger.warn("解析 Qianwen 响应 choices 失败：{}", ex.getMessage());
        }

        // 回退：尝试解析 resp 中的 candidates/items/data/result 等字段
        Object itemsObj = resp.get("candidates");
        if (itemsObj == null) itemsObj = resp.get("items");
        if (itemsObj == null) itemsObj = resp.get("data");
        if (itemsObj == null) itemsObj = resp.get("result");

        if (itemsObj instanceof List) {
            List<Object> items = (List<Object>) itemsObj;
            for (Object it : items) {
                if (it instanceof Map) {
                    Map<String,Object> m = (Map<String,Object>) it;
                    Map<String,Object> kv = new HashMap<>();
                    Object name = m.get("name");
                    if (name == null) name = m.get("label");
                    if (name == null) name = m.get("title");
                    Object def = m.get("definition");
                    if (def == null) def = m.get("desc");
                    Object conf = m.get("confidence");
                    if (conf == null) conf = m.get("score");
                    kv.put("name", name != null ? name.toString() : "");
                    kv.put("definition", def != null ? def.toString() : "");
                    try {
                        kv.put("confidence", conf != null ? Double.parseDouble(conf.toString()) : 0.0);
                    } catch (Exception ex) {
                        kv.put("confidence", 0.0);
                    }
                    result.add(kv);
                }
            }
        } else {
            // 如果返回格式不是列表，尝试将返回体的若干文本段落作为候选
            String asText = resp.toString();
            String[] parts = asText.split("[。；;\\n]");
            int cnt = Math.min(parts.length, 3);
            for (int i = 0; i < cnt; i++) {
                String p = parts[i].trim();
                if (p.length() < 4) continue;
                Map<String,Object> m = new HashMap<>();
                m.put("name", p.length() > 10 ? p.substring(0, Math.min(10, p.length())) : p);
                m.put("definition", p.length() > 60 ? p.substring(0, 60) : p);
                m.put("confidence", 0.5);
                result.add(m);
            }
        }

        logger.info("Qianwen 回退解析返回 {} 条候选", result.size());
        return result;
    }

    /**
     * 长文本分片抽取知识点，自动分段并合并去重。
     * chunkSize: 每片最大字符数（如 2000-3000），建议不超过模型上下文限制。
     */
    public List<Map<String,Object>> extractKnowledgePointsChunked(String text, int chunkSize) {
        if (text == null || text.trim().isEmpty()) return new ArrayList<>();
        List<String> chunks = new ArrayList<>();
        String t = text.trim();
        int len = t.length();
        int overlap = Math.min(200, chunkSize/10); // 片间重叠，防止边界遗漏
        for (int i = 0; i < len; i += chunkSize - overlap) {
            int end = Math.min(i + chunkSize, len);
            chunks.add(t.substring(i, end));
            if (end == len) break;
        }
        List<Map<String,Object>> all = new ArrayList<>();
        for (String chunk : chunks) {
            List<Map<String,Object>> candidates = extractKnowledgePoints(chunk);
            all.addAll(candidates);
        }
        // 简单去重：按 name+definition 合并
        Map<String, Map<String,Object>> dedup = new LinkedHashMap<>();
        for (Map<String,Object> kp : all) {
            String key = kp.getOrDefault("name","") + "|" + kp.getOrDefault("definition","");
            if (!dedup.containsKey(key)) dedup.put(key, kp);
        }
        return new ArrayList<>(dedup.values());
    }

    /**
     * 本地增强回退实现：基于通用学科关键词与正则的启发式抽取
     * 当 AI 服务不可用时使用此方法
     */
    private List<Map<String,Object>> localRegexExtract(String text) {
        List<Map<String,Object>> result = new ArrayList<>();
        if (text == null || text.trim().isEmpty()) {
            return result;
        }

        // 定义通用学科知识点关键词模式
        String[] generalKeywords = {
            // 数学
            "极限", "导数", "积分", "函数", "方程", "不等式", "几何", "代数",
            // 物理
            "力学", "电磁学", "热力学", "光学", "量子", "相对论", "能量", "动量",
            // 化学
            "化学反应", "化学键", "分子", "原子", "离子", "酸碱", "氧化还原", "有机化学",
            // 生物
            "细胞", "基因", "蛋白质", "DNA", "进化", "生态", "遗传", "新陈代谢",
            // 语文
            "语法", "修辞", "文学", "诗歌", "散文", "小说", "古文", "现代文",
            // 英语
            "语法", "时态", "语态", "从句", "词汇", "阅读理解", "写作", "听力",
            // 历史
            "朝代", "历史事件", "历史人物", "政治制度", "经济发展", "文化变迁",
            // 地理
            "地形", "气候", "人口", "城市", "农业", "工业", "环境", "资源"
        };

        // 搜索关键词
        for (String keyword : generalKeywords) {
            if (text.contains(keyword)) {
                Map<String,Object> kp = new HashMap<>();
                kp.put("name", keyword);

                // 尝试提取包含该关键词的句子作为定义
                String definition = extractSentenceContaining(text, keyword);
                kp.put("definition", definition);

                // 基于关键词位置和上下文设置置信度
                double confidence = 0.6;
                if (text.indexOf(keyword) < text.length() / 3) {
                    confidence = 0.7; // 出现在前部，可能更重要
                }
                kp.put("confidence", confidence);

                result.add(kp);

                // 限制返回数量
                if (result.size() >= 6) {
                    break;
                }
            }
        }

        // 如果没有找到任何知识点，返回一个通用的
        if (result.isEmpty()) {
            Map<String,Object> kp = new HashMap<>();
            kp.put("name", "综合知识点");
            kp.put("definition", "智慧课堂综合知识点");
            kp.put("confidence", 0.3);
            result.add(kp);
        }

        return result;
    }

    /**
     * 提取包含指定关键词的句子
     */
    private String extractSentenceContaining(String text, String keyword) {
        int index = text.indexOf(keyword);
        if (index == -1) {
            return keyword;
        }

        // 向前查找句子开始
        int start = index;
        while (start > 0 && text.charAt(start) != '。' && text.charAt(start) != '；'
               && text.charAt(start) != '.' && text.charAt(start) != '\n') {
            start--;
        }
        if (start > 0) start++; // 跳过标点符号

        // 向后查找句子结束
        int end = index;
        while (end < text.length() && text.charAt(end) != '。' && text.charAt(end) != '；'
               && text.charAt(end) != '.' && text.charAt(end) != '\n') {
            end++;
        }

        String sentence = text.substring(start, Math.min(end + 1, text.length())).trim();

        // 限制长度
        if (sentence.length() > 100) {
            sentence = sentence.substring(0, 100) + "...";
        }

        return sentence.isEmpty() ? keyword : sentence;
    }

    /**
     * 根据数学符号推断知识点名称
     */
    private String inferKnowledgePointName(String symbol) {
        if (symbol.contains("lim")) {
            return "极限";
        } else if (symbol.matches(".*sin|cos|tan.*")) {
            return "三角函数";
        } else if (symbol.contains("∫") || symbol.contains("int")) {
            return "积分";
        } else if (symbol.contains("∂") || symbol.contains("partial")) {
            return "偏导数";
        } else if (symbol.contains("∑") || symbol.contains("sum")) {
            return "级数求和";
        } else if (symbol.contains("∏") || symbol.contains("prod")) {
            return "连乘";
        } else if (symbol.contains("→") || symbol.contains("to") || symbol.contains("rightarrow")) {
            return "极限趋向";
        } else if (symbol.contains("≈") || symbol.contains("approx")) {
            return "近似计算";
        } else {
            return "数学运算";
        }
    }
}

