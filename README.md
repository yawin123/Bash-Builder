# Bash Builder
Bash Builder is a simple CLI application for grouping multiple bash scripts using the source command, preventing the same file from being included multiple times.

The builder itself is built using this system.

## Usage
> builder [OPTIONS]

- **-h**: Prints help
- **-e \<path\>**: The entrypoint to the bash script to bundle
- **-o \<path\>**: The output file to write to
- **-m**: Minify the output file (default: false)

### Notes about minifying
Currently, minification is done using the bash_bundler program. Below is a brief guide to installing this software.

#### Install `Go`
```bash
sudo apt update
sudo apt install golang-go
```

#### Install `bash_bundler`
```bash
go install github.com/malscent/bash_bundler@latest
```

#### Add `bash_bundler`to `.bashrc`

Add this line to your .bashrc file:

```bash
export PATH="$PATH:$(go env GOPATH)/bin"
```

Next, reload your configuration:
```bash
source ~/.bashrc
```
