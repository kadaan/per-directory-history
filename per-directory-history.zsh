#!/usr/bin/env zsh

# An implementation of per-directory history.
# See README.md for more information.

[[ -z $_per_directory_history_is_global ]] && _per_directory_history_is_global=true
[[ -z $PER_DIRECTORY_HISTORY_BASE ]] && PER_DIRECTORY_HISTORY_BASE="$HOME/.zsh_history_dirs"
[[ -z $PER_DIRECTORY_HISTORY_FILE ]] && PER_DIRECTORY_HISTORY_FILE="zsh-per-directory-history"
[[ -z $PER_DIRECTORY_HISTORY_TOGGLE ]] && PER_DIRECTORY_HISTORY_TOGGLE='^g'

#-------------------------------------------------------------------------------
# toggle global/directory history used for searching - Ctrl-g by default
#-------------------------------------------------------------------------------

function per-directory-history-toggle-history() {
	if $_per_directory_history_is_global
	then
		_per-directory-history-set-directory-history
	else
		_per-directory-history-set-global-history
	fi
	if [[ "$(zle -l | grep hsmw | wc -l)" -gt 5 ]]; then
		__hsmw_hcw_restart="1"
		if [[ "$__hsmw_ctx" -eq 0 ]]; then
			_hsmw_simulate_widget
		fi
	fi
	if [[ "$(zle -l | grep p9k | wc -l)" -gt 4 ]]; then
		_p9k_refresh_reason=history_type
		_p9k_set_prompt
		_p9k_refresh_reason=''
		_p9k_reset_prompt
    fi
}

autoload per-directory-history-toggle-history
zle -N per-directory-history-toggle-history
bindkey $PER_DIRECTORY_HISTORY_TOGGLE per-directory-history-toggle-history

#-------------------------------------------------------------------------------
# implementation details
#-------------------------------------------------------------------------------

_per_directory_history_path="$PER_DIRECTORY_HISTORY_BASE${PWD:A}/$PER_DIRECTORY_HISTORY_FILE"

function _per-directory-history-change-directory() {
	_per_directory_history_path="$PER_DIRECTORY_HISTORY_BASE${PWD:A}/$PER_DIRECTORY_HISTORY_FILE"
	if ! $_per_directory_history_is_global
	then
		fc -P
		mkdir -p ${_per_directory_history_path:h}
		fc -p $_per_directory_history_path
	fi
}

function _per-directory-history-addhistory() {
	# respect hist_ignore_space
	if [[ -o hist_ignore_space ]] && [[ "$1" == \ * ]]
	then
		return
	fi

	# Can't write to history (print -S) from addhistory,
	# save command to be added later from preexec hook
	_per_directory_history_pending_cmd="${1%%$'\n'}"
}

_per_directory_history_last_cmd=''

function _per-directory-history-preexec() {
	if [[ -v _per_directory_history_pending_cmd ]]
	then
		if [[ "$_per_directory_history_pending_cmd" != "$_per_directory_history_last_cmd" ]]
		then
			local fn
			if $_per_directory_history_is_global
			then
				mkdir -p ${_per_directory_history_path:h}
				fn=$_per_directory_history_path
			else
				fn=$_per_directory_history_main_histfile
			fi

			fc -p
			print -Sr -- $_per_directory_history_pending_cmd
			SAVEHIST=1
			fc -A $fn
			fc -P

			_per_directory_history_last_cmd=$_per_directory_history_pending_cmd
		fi

		unset _per_directory_history_pending_cmd
	fi
}


function _per-directory-history-set-directory-history() {
	fc -P

	mkdir -p ${_per_directory_history_path:h}
	fc -p $_per_directory_history_path
	_per_directory_history_is_global=false
}
function _per-directory-history-set-global-history() {
	fc -P

	fc -p $_per_directory_history_main_histfile
	_per_directory_history_is_global=true
}


#add functions to the exec list for chpwd and zshaddhistory
autoload -U add-zsh-hook
add-zsh-hook chpwd _per-directory-history-change-directory
add-zsh-hook zshaddhistory _per-directory-history-addhistory
add-zsh-hook preexec _per-directory-history-preexec

_per_directory_history_main_histfile=$HISTFILE
unset HISTFILE

#start in global mode
_per-directory-history-set-global-history
