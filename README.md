# leetvim.nvim

🚀 **A lightning-fast Neovim plugin for LeetCode problem solving**

leetvim.nvim streamlines your Leetcode workflow by fetching problem templates from Leetcode directly into Neovim. No more context switching between browser and editor - just pure, focused coding.

![Demo](https://img.shields.io/badge/LeetCode-Templates-orange?style=flat-square) ![Neovim](https://img.shields.io/badge/Neovim-0.9+-green?style=flat-square) ![License](https://img.shields.io/badge/License-MIT-blue?style=flat-square)

---

## ✨ Features

- **🎨 Clean Templates**: Fetches any Leetcode problem templates along with simple test stubs
- **🔐 Secure Authentication**: Uses your Leetcode session cookie for seamless access
- **🔧 Extensible**: Easy to add support for new programming languages

---

## 📦 Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```
return {
  {
    "MuazTPM-YT/leetvim.nvim",
    name = "leetvim",
    cmd = { "LeetvimTemplate", "LeetvimAuth" },
    keys = {
      { "<leader>lt", ":LeetvimTemplate ", desc = "LeetVim Template" },
      { "<leader>la", ":LeetvimAuth<cr>", desc = "LeetCode Auth" },
    },
    config = function()
      require("leetvim").setup({
        base_dir = vim.fn.expand("~/leetcode"),
        filename_pattern = "{number:03d}-{slug}.{ext}",
        include_test_stub = true,
        default_language = "python",
        create_subdirs = false,
      })
    end,
  },
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```
use {
  "MuazTPM-YT/leetvim.nvim",
  config = function()
    require("leetvim").setup()
  end
}
```

---

## 🚀 Quick Start

### 1. Authenticate with LeetCode

First, get your LeetCode session cookie:
1. Log into [leetcode.com](https://leetcode.com) in your browser
2. Open Developer Tools (F12) → Console tab
3. Run: `document.cookie` and copy the output
4. In Neovim, run: `:LeetvimAuth` and paste the cookie

### 2. Generate Your First Template

```
:LeetvimTemplate python 1
```

```
class Solution(object):
    def twoSum(self, nums, target):
        """
        :type nums: List[int]
        :type target: int
        :rtype: List[int]
        """
if name == "main":
    solution = Solution()

    print(solution.twoSum())
```

Now, you're ready to code! 🎉

---

## ⚙️ Configuration

Customize leetvim.nvim in your setup:

```
require("leetvim").setup({
  -- Directory to save templates
  base_dir = vim.fn.expand("~/leetcode"),

  -- File naming pattern using variables
  filename_pattern = "{number:03d}-{slug}.{ext}",

  -- Default programming language to use if not specified in the command
  default_language = "python",

  -- Create language-specific subdirectories inside base_dir
  create_subdirs = true,

  -- LeetCode URL (can be changed to "https://leetcode.cn" for China)
  leetcode_url = "https://leetcode.com",

  -- File extensions for different languages
  language_extensions = {
    python = "py",
    -- add other languages here, e.g., cpp = "cpp"
  }
})
```

### Configuration Options

| Option | Description | Default |
|--------|-------------|---------|
| `base_dir` | Base directory for templates | `~/leetcode` |
| `filename_pattern` | File naming pattern | `{number:03d}-{slug}.{ext}` |
| `default_language` | Default language | `python` |
| `create_subdirs` | Create language folders | `true` |
| `leetcode_url` | LeetCode URL | `https://leetcode.com` |

### Filename Pattern Variables

- `{number}` - Problem number (e.g., `1`)
- `{number:03d}` - Zero-padded number (e.g., `001`)
- `{slug}` - Problem slug (e.g., `two-sum`)
- `{title}` - Problem title (e.g., `Two Sum`)
- `{ext}` - File extension based on language

---

## 🎯 Commands

| Command | Description | Example |
|---------|-------------|---------|
| `:LeetvimTemplate <lang> <num>` | Generate template | `:LeetvimTemplate python 42` |
| `:LeetvimAuth` | Set authentication cookie | `:LeetvimAuth` |

---

## 🌐 Supported Languages

Currently supported languages:
- **Python** (`python`)
- **JavaScript** (`javascript`)
- **Java** (`java`)
- **C++** (`cpp`)

Want more languages? Contributions welcome! 🤝

---

## 🔧 Troubleshooting

### Authentication Issues
- **Cookie expired**: Re-run `:LeetvimAuth` with a fresh cookie
- **Invalid cookie**: Make sure you copied the complete cookie string
- **Login required**: Ensure you're logged into Leetcode in your browser

### Template Issues
- **Problem not found**: Check if the problem number exists
- **Network errors**: Verify your internet connection
- **Empty template**: The problem might not support your chosen language

---

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

1. 🍴 Fork the repository
2. 🌟 Create a feature branch: `git checkout -b feature/your-feature`
3. 💻 Make your changes
4. ✅ Test thoroughly
5. 📝 Commit: `git commit -m 'Add features`
6. 🚀 Push: `git push origin feature/your-feature`
7. 🎯 Open a Pull Request

### Adding New Languages

To add support for a new language:

1. Create `lua/leetvim/languages/your_lang.lua`
2. Implement the required functions:
   - `matches_language(lang_slug)`
   - `generate_description_comment(problem_data)`
   - `generate_test_stub(problem_data, examples)`

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Happy Coding!** 🚀
