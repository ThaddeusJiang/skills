# EUE Skills

Custom skills for [EUE](https://github.com/ThaddeusJiang/eue) - an autonomous engineering agent.

## Available Skills

### nowledge-mem

Persistent memory management using [nowledge-mem](https://mem.nowledge.co) CLI.

**Features:**
- Add, search, delete memories
- Thread operations
- Importance-based ranking
- Category-based organization

**Usage:**
```
用户: 记住这个设计决策
EUE: [执行 nmem m add 并验证成功]
```

## Installation

```bash
# Clone to your EUE skills directory
git clone https://github.com/ThaddeusJiang/skills.git
cd skills

# Copy desired skill to your workspace
cp -r nowledge-mem /path/to/your/workspace/.eue/skills/
```

## License

MIT
