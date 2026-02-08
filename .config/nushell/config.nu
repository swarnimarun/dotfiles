# config.nu
#
# Installed by:
# version = "0.107.0"
#
# This file is used to override default Nushell settings, define
# (or import) custom commands, or run any other startup tasks.
# See https://www.nushell.sh/book/configuration.html
#
# Nushell sets "sensible defaults" for most configuration settings, 
# so your `config.nu` only needs to override these defaults if desired.
#
# You can open this file in your default editor using:
#     config nu
#
# You can also pretty-print and page through the documentation for configuration
# options using:
#     config nu --doc | nu-highlight | less -R

$env.config.shell_integration.osc133 = false
$env.config.show_banner = false 

# Source an environment from a batch file
def --env sourcebat [
  ...cmd: string # The batch command to run
] {
  let tmp = mktemp -t

  let cmd = ($cmd | append ["&&" "set" $">($tmp)"])

  # Run the command and print its output as it is running.
  # `str join` will block until EOF.
  let stdout = run-external cmd.exe /c ...$cmd | each { |line| print -n $line; $line } | str join
  
  let vars = open $tmp
  rm $tmp # Clean up the temp file.

  # Source: https://stackoverflow.com/questions/77383686/set-environment-variables-from-file-of-key-value-pairs-in-nu
  # Convert the output of `set` into a record.
  def "from env" []: string -> record {
    lines
      | split column '#'
      | get column1
      | where {($in | str length) > 0} 
      | parse "{key}={value}"
      | update value {str trim -c '"'}
      | transpose -r -d
  }

  let vars = $vars | from env | transpose | where { |in| $in.column0 != 'PWD' and $in.column0 != 'CURRENT_FILE' and $in.column0 != 'FILE_PWD' } | transpose -r -d;
  load-env $vars
}

# mkdir ~/.cache/starship; starship init nu | save -f ~/.cache/starship/init.nu
source ~/.cache/starship/init.nu
