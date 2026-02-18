# Daily Task Summary Skill

每日从 ROADMAP.md 和 TODO.md 整理最有价值的任务并发送 Telegram 消息。

## 前置条件

- ROADMAP.md 存在于项目根目录
- TODO.md 存在于项目根目录
- EUE_TELEGRAM_TOKEN 环境变量已设置
- Telegram chat_id 已配置

## 执行流程

1. 读取 ROADMAP.md，筛选 `[PENDING]` 任务
2. 读取 TODO.md，筛选 `[ ]` 未完成任务
3. 分析任务价值（优先级排序标准）：
   - PENDING 任务优先（在 roadmap 中明确规划）
   - 阻塞其他任务的任务优先
   - 用户直接相关的任务优先
4. 选取前 3 个最有价值的任务
5. 使用 telegram-send skill 发送消息到指定 chat_id

## 使用方式

### 立即执行
```bash
# 在 EUE 中请求
"整理 roadmap 和 todo 的 top 3 任务发送给我"

# 或直接运行脚本
source ~/.eue/.env && .eue/skills/daily-task-summary/daily_task_summary.sh
```

### 定时执行（Crontab）
```bash
# 编辑 crontab
crontab -e

# 添加以下行（每天 11:00 执行）
0 11 * * * EUE_TELEGRAM_TOKEN=你的token /Users/amami/my2026/personal/eue/.eue/skills/daily-task-summary/daily_task_summary.sh >> /tmp/daily_task_summary.log 2>&1
```

### macOS Launchd（推荐）
```bash
# 创建 ~/Library/LaunchAgents/com.eue.daily-task-summary.plist
# 使用 launchctl load 加载
```

## 输出格式

```
📋 今日 Top 3 任务

1️⃣ [ROADMAP] A226 Add near-realtime progress streaming...
2️⃣ [TODO] 代码块支持「点击复制」
3️⃣ [TODO] EUE 支持语音聊天

💪 开始行动吧！
```

## 已配置

✅ launchd 定时任务已启用
- 任务标识: `com.eue.daily-task-summary`
- 执行时间: 每天 11:00
- 日志位置: `/tmp/daily_task_summary.log`

管理命令:
```bash
# 查看状态
launchctl list | grep eue

# 手动触发测试
launchctl start com.eue.daily-task-summary

# 停止
launchctl unload ~/Library/LaunchAgents/com.eue.daily-task-summary.plist

# 重新加载
launchctl load ~/Library/LaunchAgents/com.eue.daily-task-summary.plist
```

## 依赖

- telegram-send skill
- scheduler skill
