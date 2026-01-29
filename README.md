# Claude Code Skills Collection

A personal collection of custom skills for AI coding agents that I've created and found useful. Feel free to use them in your own projects!

## What are Claude Code Skills?

Skills are reusable capabilities for AI agents. They let you automate complex workflows, integrate with external services, and customize Claude Code to fit your specific needs.

## Installation

Install skills using [skills.sh](https://skills.sh/), the universal skills directory:

```bash
# Install a specific skill
npx skills add ergunsh/skills/vercel-ai-gateway-setup

# Or install all skills from this repository
npx skills add ergunsh/skills
```

Skills will automatically be added to your `~/.claude/skills/` directory and become available in Claude Code.

## Available Skills

### vercel-ai-gateway-setup

**Installation:**
```bash
npx skills add ergunsh/skills/vercel-ai-gateway-setup
```

**Description:**
Set up Claude Code to route requests through Vercel AI Gateway for monitoring and observability.

**Features:**
- Configures Claude Code to use Vercel AI Gateway as a proxy
- Supports two modes: API Key mode and Claude Max mode
- Optionally stores credentials in macOS Keychain for extra security
- Automatically updates your shell configuration with proper environment variables
- Handles Claude Code logout when switching to API Key mode

**When to use it:**
- You want to monitor Claude Code API usage through Vercel AI Gateway
- You need observability and analytics for your Claude Code requests
- You want to route requests through a custom gateway for logging or rate limiting

**How to invoke:**
Just ask Claude Code naturally:
- "Set up Vercel AI Gateway"
- "Configure AI Gateway for monitoring"
- "Help me set up observability for Claude Code"

## Repository Structure

This repository follows the [standard skills.sh format](https://deepwiki.com/anthropics/skills/2.2-skill.md-format-specification):

```
vercel-ai-gateway-setup/
├── SKILL.md              # Skill definition (YAML frontmatter + instructions)
└── scripts/
    └── setup-vercel-ai-gateway.sh
```

Each skill contains:
- **SKILL.md** - Required skill definition with YAML frontmatter (name, description) and detailed instructions
- **scripts/** - Executable scripts for automation and complex workflows
- **references/** (optional) - Additional documentation, schemas, and specifications

## How Skills Work with skills.sh

When you install a skill using `npx skills add`:

1. The CLI downloads the skill from this GitHub repository
2. It copies the skill files to your `~/.claude/skills/` directory
3. The skill becomes immediately available to Claude Code
4. Anonymous telemetry tracks installations to rank skills on the [skills.sh leaderboard](https://skills.sh/)

No manual registration needed - skills appear on the leaderboard automatically as people use them!

## Creating Your Own Skills

Want to create your own skills? Here's how:

1. Create a GitHub repository with the standard structure
2. Add a `SKILL.md` file with YAML frontmatter:
   ```yaml
   ---
   name: my-skill-name
   description: One sentence describing when to use this skill with trigger phrases
   ---
   ```
3. Write detailed instructions in the Markdown body
4. Add any scripts or additional files
5. Share it with `npx skills add your-username/your-repo`

**Resources:**
- [SKILL.md Format Specification](https://deepwiki.com/anthropics/skills/2.2-skill.md-format-specification)
- [Browse popular skills](https://skills.sh/) for inspiration
- [Vercel Agent Skills](https://github.com/vercel-labs/agent-skills) - great examples

## License

MIT License - feel free to use, modify, and share these skills as you see fit!

## Questions or Issues?

If you run into any problems or have questions about these skills, feel free to open an issue in this repository.

---

**Learn more:**
- [skills.sh Documentation](https://skills.sh/docs)
- [Skills CLI Reference](https://skills.sh/docs/cli)
- [SKILL.md Format Specification](https://deepwiki.com/anthropics/skills/2.2-skill.md-format-specification)
