# get the current directory of this script
function scriptpath() {
  cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd 
}
