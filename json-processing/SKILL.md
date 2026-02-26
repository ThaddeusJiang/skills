# json-processing

处理 JSON 数据的技能。使用 jq 处理简单 JSON，用 JavaScript (bun/node) 处理复杂 JSON。

## 核心原则

1. **优先使用 jq** - 处理简单 JSON 查询、过滤、转换
2. **使用 JS 处理复杂任务** - 嵌套深、逻辑复杂、多步骤处理
3. **确保环境可用** - jq/bun/node 未安装则主动安装

## 安装检查

```bash
# 检查 jq
which jq || brew install jq

# 检查 bun
which bun || curl -fsSL https://bun.sh/install | bash

# 检查 node
which node || brew install node
```

## jq 用法（简单任务）

```bash
# 解析 JSON 数组
cat data.json | jq '.'

# 获取顶层键
cat data.json | jq 'keys'

# 获取嵌套值
cat data.json | jq '.user.name'

# 过滤数组
cat data.json | jq '.users[] | select(.age > 18)'

# 映射/转换
cat data.json | jq '[.items[] | {id: .id, title: .name}]'

# 条件判断
cat data.json | jq 'if .status == "active" then "启用" else "禁用" end'

# 统计数量
cat data.json | jq '[.items[] | select(.done == false)] | length'

# 格式化输出（美观的 JSON）
cat data.json | jq '.'

# 只获取值（不用键）
cat data.json | jq '.[].name'

# 组合多个操作
cat data.json | jq '[.users[] | {name: .name, city: .address.city}] | sort_by(.city)'
```

## JavaScript 用法（复杂任务）

创建临时脚本处理：

```bash
# 使用 bun 运行
cat > /tmp/process.mjs << 'EOF'
import fs from 'fs';
const data = JSON.parse(fs.readFileSync('/tmp/input.json', 'utf8'));

// 处理逻辑
const result = data.users
  .filter(u => u.active)
  .map(u => ({ name: u.name, email: u.email }));

console.log(JSON.stringify(result, null, 2));
EOF

bun /tmp/process.mjs
```

## 自动判断

| 任务类型 | 工具 |
|----------|------|
| 读取值、过滤、统计、简单转换 | jq |
| 多步骤复杂逻辑、嵌套循环、聚合 | JavaScript |
| 需要函数式编程能力 | JavaScript |
| 需要外部 API 调用 | JavaScript |

## 注意事项

- 始终先检查工具是否安装
- 复杂任务优先考虑用 JS 而非 jq（更易读好维护）
- 处理大文件时注意性能
- 始终清理临时文件