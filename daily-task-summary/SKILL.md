# Daily Task Summary Skill

每日从 ROADMAP.md 和 TODO.md 整理最有价值的任务并发送 Telegram 消息。

## 参数配置

此 skill 需要通过对话配置参数，不使用硬编码值。

### 参数定义

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| chat_id | string | 是 | 发送目标 Telegram chat_id |
| schedule | string | 否 | 定时执行时间（cron 格式） |
| enabled | boolean | 否 | 是否启用定时任务（默认 true） |

### 配置流程

Agent 在首次使用此 skill 时，应该：

1. **检查配置是否存在**
   - 配置路径：`.eue/config/daily-task-summary.json`
   - 如不存在，向用户询问参数

2. **询问用户**
   ```
   📝 需要配置 daily-task-summary：
   
   请问发送到哪个 chat？
   - 当前群组（推荐）
   - 私人聊天
   
   请回复选项或直接提供 chat_id。
   ```

3. **写入配置文件**
   ```json
   {
     "chat_id": "-1002246024089",
     "schedule": "0 11 * * *",
     "enabled": true
   }
   ```

4. **后续使用**
   - 从配置文件读取参数
   - 用户可随时要求修改配置

## 前置条件

- ROADMAP.md 存在于项目根目录
- TODO.md 存在于项目根目录
- EUE_TELEGRAM_TOKEN 环境变量已设置
- 配置文件 `.eue/config/daily-task-summary.json` 已创建

## 执行流程

1. 读取配置文件 `.eue/config/daily-task-summary.json`
2. 读取 ROADMAP.md，筛选 `[PENDING]` 任务
3. 读取 TODO.md，筛选 `[ ]` 未完成任务
4. 分析任务价值（优先级排序标准）：
   - PENDING 任务优先（在 roadmap 中明确规划）
   - 阻塞其他任务的任务优先
   - 用户直接相关的任务优先
5. 选取前 3 个最有价值的任务
6. 使用配置的 chat_id 发送 Telegram 消息

## 使用方式

### Agent 调用
```
用户：每天早上9点发送任务提醒

Agent：
1. 检查配置文件是否存在
2. 如不存在，询问 chat_id
3. 写入配置文件
4. 调用 scheduler skill 设置定时任务
```

### 手动执行（测试）
```bash
# 确保配置文件存在
cat .eue/config/daily-task-summary.json

# 执行脚本
.eue/skills/daily-task-summary/daily_task_summary.sh
```

## 输出格式

```
📋 今日 Top 3 任务

1️⃣ [ROADMAP] A226 Add near-realtime progress streaming...
2️⃣ [TODO] 代码块支持「点击复制」
3️⃣ [TODO] EUE 支持语音聊天

💪 开始行动吧！
```

## 配置管理

### 查看当前配置
```bash
cat .eue/config/daily-task-summary.json
```

### 修改配置
用户可以通过对话要求 Agent 修改：
```
用户：把任务提醒改发到私人聊天
Agent：好的，请提供私人聊天的 chat_id。
用户：940788576
Agent：✅ 已更新配置，任务将发送到私人聊天。
```

## 依赖

- telegram-send skill
- scheduler skill
