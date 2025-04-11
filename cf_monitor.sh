#!/bin/bash

# 脚本：根据选择使用IPv4或IPv6请求 http://cp.cloudflare.com/generate_204

# 清屏
clear

# 提示用户选择IPv4或IPv6
echo "请选择IP协议版本:"
echo "1) IPv4"
echo "2) IPv6"
echo "3) 自动选择(系统默认)"
read -p "请输入选项 [1-3]: " ip_version

# 验证IP版本选择
while ! [[ "$ip_version" =~ ^[1-3]$ ]]; do
    echo "错误: 请输入1, 2或3"
    read -p "请输入选项 [1-3]: " ip_version
done

# 设置间隔时间
read -p "请输入请求间隔(秒，支持小数，如0.1): " interval

# 检查输入是否为数字
while ! [[ "$interval" =~ ^[0-9]*\.?[0-9]+$ ]]; do
    echo "错误: 间隔必须是数字"
    read -p "请输入请求间隔(秒，支持小数，如0.1): " interval
done

# 设置IP版本参数
case $ip_version in
    1)
        ip_param="-4"
        ip_text="IPv4"
        ;;
    2)
        ip_param="-6"
        ip_text="IPv6"
        ;;
    3)
        ip_param=""
        ip_text="自动"
        ;;
esac

# 清屏
clear

# 输出当前时间和开始信息
echo "开始监测 http://cp.cloudflare.com/generate_204"
echo "协议版本: $ip_text"
echo "请求间隔: ${interval}秒"
echo "按 Ctrl+C 停止脚本"
echo "----------------------------------------"

# 计数器
count=1

# 无限循环，每interval秒执行一次
while true; do
    # 获取当前时间，精确到毫秒
    current_time=$(date "+%Y-%m-%d %H:%M:%S.%3N")
    
    # 执行curl请求并记录状态码和响应时间
    if [ -z "$ip_param" ]; then
        # 自动模式
        response=$(curl -s -o /dev/null -w "%{http_code},%{time_total},%{local_ip}" http://cp.cloudflare.com/generate_204 2>/dev/null) || response="000,0.000,连接失败"
    else
        # 指定IP版本
        response=$(curl $ip_param -s -o /dev/null -w "%{http_code},%{time_total},%{local_ip}" http://cp.cloudflare.com/generate_204 2>/dev/null) || response="000,0.000,连接失败"
    fi
    
    # 分离结果
    status_code=$(echo $response | cut -d',' -f1)
    time_taken=$(echo $response | cut -d',' -f2)
    used_ip=$(echo $response | cut -d',' -f3)
    
    # 判断IP类型
    if [[ "$used_ip" == "连接失败" ]]; then
        actual_ip_version="失败"
    elif [[ $used_ip =~ ":" ]]; then
        actual_ip_version="IPv6"
    else
        actual_ip_version="IPv4"
    fi
    
    # 输出结果
    echo "[$count] $current_time - 状态码: $status_code, 响应时间: ${time_taken}s, IP: $used_ip ($actual_ip_version)"
    
    # 增加计数器
    count=$((count+1))
    
    # 等待指定间隔
    sleep $interval
done
