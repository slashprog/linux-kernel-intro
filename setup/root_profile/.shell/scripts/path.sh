
PATH=$(grep -Ev "#|^[[:space:]]*$" ~/.shell/conf/path.conf | xargs | sed -re 's/\s+/:/g')

export PATH 

