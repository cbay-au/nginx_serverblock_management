# mkdir Alias Setup

This repository contains a setup for creating a custom `mkdir` command that automatically changes into the newly created directory.

## ✅ Status: TESTED AND WORKING
The `mkcd` function has been successfully tested and confirmed working!

## Quick Setup

### Option 1: Temporary (current session only)
```bash
source setup_mkdir_alias.sh
```

### Option 2: Permanent Setup
Add the following function to your `~/.bashrc` file:

```bash
# Custom mkdir function that creates directory and changes into it
mkdir() {
    if [ $# -eq 0 ]; then
        echo "Usage: mkdir <directory_name>"
        return 1
    fi
    
    # Use command to call the original mkdir to avoid recursion
    command mkdir -p "$1" && cd "$1"
}
```

Then reload your bashrc:
```bash
source ~/.bashrc
```

## Usage

After setup, simply use:
```bash
mkdir my_new_directory
```

This will:
1. Create the directory `my_new_directory`
2. Automatically change into that directory
3. Create parent directories if needed (using `-p` flag)

## Features

- **Error handling**: Shows usage if no directory name provided
- **Parent directory creation**: Uses `mkdir -p` to create parent directories
- **Safe implementation**: Uses `command mkdir` to avoid infinite recursion
- **Graceful failure**: Only changes directory if mkdir succeeds
- **Git configured**: Repository now defaults to pushing to main branch

## Alternative Names

If you prefer to keep the original `mkdir` command unchanged, you can use these alternative function names:
- `mkcd` - make and change directory
- `mcd` - make change directory
- `mkd` - make directory (and cd)

Simply replace `mkdir()` with your preferred name in the function definition.