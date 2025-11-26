import request from '@/utils/request'

// 计算数字分身 (对应后端 DigitalTwinController.calculateDigitalTwin)
export function calculateDigitalTwin(query) {
  return request({
    url: '/system/digitalTwin/calculate', // 请根据你后端的实际接口地址修改这里
    method: 'get',
    params: query
  })
}