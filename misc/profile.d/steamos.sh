if [[ ! $EDITOR ]] && command -v vim >/dev/null
then
	EDITOR=vim
	export EDITOR
fi

if [[ ! $VISUAL ]] && command -v gvim >/dev/null
then
	VISUAL=gvim
	export VISUAL
fi
