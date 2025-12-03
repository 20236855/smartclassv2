import request from '@/utils/request'

/**
 * 调用AI教学助手
 */
export function callAIAssistant(data) {
  return request({
    url: '/ai/assistant/chat',
    method: 'post',
    data: data,
    timeout: 300000  // 5分钟超时，AI语音生成需要较长时间
  })
}
