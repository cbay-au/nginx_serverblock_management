# Troubleshooting .bashrc mkdir function

## The Error
```
-bash: .bashrc: line 138: syntax error near unexpected token `('
-bash: .bashrc: line 138: `mkdir() {'
```

## Possible Causes and Solutions

### 1. Shell Compatibility Issue
The function syntax might not be compatible with your shell version.

**Try this version instead:**
```bash
function mkdir {
    if [ $# -eq 0 ]; then
        echo "Usage: mkdir <directory_name>"
        return 1
    fi
    
    command mkdir -p "$1" && cd "$1"
}
```

### 2. Hidden Characters or Encoding Issues
Sometimes copying/pasting can introduce hidden characters.

**Manually type this version:**
```bash
mkdir() {
    if [ $# -eq 0 ]; then
        echo "Usage: mkdir <directory_name>"
        return 1
    fi
    command mkdir -p "$1" && cd "$1"
}
```

### 3. Alternative: Use an Alias Instead
If functions don't work, try this alias approach:
```bash
alias mkcd='_mkcd(){ command mkdir -p "$1" && cd "$1"; }; _mkcd'
```

### 4. Most Compatible Version
This should work on almost all bash versions:
```bash
mkcd() {
    if test $# -eq 0; then
        echo "Usage: mkcd <directory_name>"
        return 1
    fi
    command mkdir -p "$1" && cd "$1"
}
```

## Debugging Steps

1. **Check your shell:**
   ```bash
   echo $SHELL
   echo $BASH_VERSION
   ```

2. **Test the function in isolation:**
   ```bash
   # Create a test file
   cat > test_function.sh << 'EOF'
   #!/bin/bash
   mkdir() {
       if [ $# -eq 0 ]; then
           echo "Usage: mkdir <directory_name>"
           return 1
       fi
       command mkdir -p "$1" && cd "$1"
   }
   EOF
   
   # Test it
   source test_function.sh
   ```

3. **Check for syntax errors around line 138:**
   ```bash
   # Check lines around the error
   sed -n '135,140p' ~/.bashrc
   ```

## Recommended Solution
Use this safer version that works with most bash versions:

```bash
# Create directory and change into it
mkcd() {
    if [ -z "$1" ]; then
        echo "Usage: mkcd <directory_name>"
        return 1
    fi
    command mkdir -p "$1" && cd "$1"
}
```

Note: I changed the function name from `mkdir` to `mkcd` to avoid potential conflicts with the system mkdir command.