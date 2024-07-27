# init:: and exit:: 
# settings for individual functions or sections of script not entire file.
# initialized items need to be exited
init::verbose() { set -x; }
init::strict() { set -euo pipefail; }
init::posix() { set -o posix; }
init::pipefail() { set -o pipefail; }
init::onecmd() { set -o oneccmd; }
init::noclobber() { set -o noclobber; }
init::nounset() { set -o nounset; }
init::noglob() { set -o noglob; }
init::noexec() { set -n; }
init::jobcontrol() { set -m; }
init::errtrace() { set -o errtrace; }
init::errexit() { set -o errexit; }
init::allexport() { set -o allexport; }
#--
exit::verbose() { set +x; }
exit::strict() { set +euo pipefail; }
exit::posix() { set +o posix; }
exit::pipefail() { set +o pipefail; }
exit::onecmd() { set +o oneccmd; }
exit::noclobber() { set +o noclobber; }
exit::nounset() { set +o nounset; }
exit::noglob() { set +o noglob; }
exit::noexec() { set +n; }
exit::jobcontrol() { set +m; }
exit::errtrace() { set +o errtrace; }
exit::errexit() { set +o errexit; }
exit::allexport() { set +o allexport; }