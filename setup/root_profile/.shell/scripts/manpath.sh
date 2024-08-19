
MANPATH=$(grep -Ev "#|^[[:space:]]*$" ~/.shell/conf/manpath.conf | xargs | sed -re 's/\s+/:/g')

export MANPATH

