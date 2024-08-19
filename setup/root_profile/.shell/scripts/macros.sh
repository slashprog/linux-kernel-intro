sw()
{
   if [[ $# -ne 2 ]]; then
      echo "usage: swap file1 file2"
      return
   fi
   mv -f $1 $1.swp
   mv -f $2 $1
   mv -f $1.swp $2
}

store_keys()
{
   cat ~/.ssh/id_rsa.pub | ssh "$@" 'mkdir -p ~/.ssh; cat >> ~/.ssh/authorized_keys'
}

s2n()
{
    sed 's/ /\n/g'
}

wpon()
{
    chattr -Rf +i * 
    chattr -Rf +i .[A-Za-z0-9]*
}

wpoff()
{
    chattr -Rf -i *
    chattr -Rf -i .[A-Za-z0-9]*
}

sloc()
{
    find . -name "*.[chS]" -print | xargs cat | nl -n "ln" | tail -1 | cut -f1 -d' '
}

