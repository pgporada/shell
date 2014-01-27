#!/bin/bash
#
# Tetris Game  Version 5.0 
# Developed by YongYe <expertshell@gmail.com>
# 11/01/2011   BeiJing China  [Updated 01/22/2012]
# Download Link1:  http://bash.webofcrafts.net/Tetris_Game.sh
# Download Link2:  http://bbs.chinaunix.net/thread-3614425-1-1.html

box0=(4 30) # shape definition 
box1=(4 30 5 30)
box2=(4 28 4 30 4 32)
box3=(4 28 4 30 5 30)
box4=(4 30 4 32 5 28 5 30)
box5=(4 30 5 28 5 30 5 32)
box6=(4 32 5 28 5 30 5 32)
box7=(4 30 5 30 6 30 7 30)
box8=(4 28 5 28 5 30 5 32)
box9=(4 28 4 30 5 30 5 32)
box10=(4 28 4 30 5 28 5 30)
box11=(4 26 4 28 4 30 4 32 4 34)
box12=(4 30 4 32 5 30 6 28 6 30)
box13=(4 30 5 28 5 30 5 32 6 30)
box14=(4 28 4 32 5 30 6 28 6 32)
box15=(4 28 4 32 5 28 5 30 5 32)
box16=(4 28 4 30 5 30 6 30 6 32)
box17=(4 28 5 28 6 28 6 30 6 32)
box18=(4 28 4 30 5 30 5 32 6 32)
box19=(4 26 4 34 5 28 5 30 5 32)
box20=(4 26 4 34 5 28 5 32 6 30)
box21=(4 26 5 28 6 30 7 32 8 34)
box22=(4 28 4 32 5 26 5 30 5 34)
box23=(4 28 4 34 5 30 5 32 6 30 6 32 7 28 7 34)
box24=(4 30 5 28 5 32 6 26 6 30 6 34 7 28 7 32 8 30)
box25=(4 30 5 28 5 30 5 32 6 26 6 28 6 30 6 32 6 34 7 28 7 30 7 32 8 30)

mrx=[] # piece definition
modh=3 # height of the top area
modw=5 # width of the left area
score=0 # current score
level=0 # current level
width=25 # width of the game area
height=30 # height of the game area
((hh=2*width+modw+6)) # width of the preview area on the left 
coltab=(1\;{30..37}\;{40..47}m) # color definition of the pieces

for signal in Rotate Left Right Down AllDown Exit Transf
do  
    ((sig${signal}=++gis+24)) # signal definition
done

value(){ echo $?; }  # the return value
piece(){ box=(${!1}); } # current block definition 
serxy(){ kbox="${sup}"; } # vertical and horizontal coordinates 
first(){ ((map[u/2-modh]=0)); } # empty the first row of the background pieces
kisig(){ kill -${sigExit} ${pid}; } # signal transfer for exit 
radom(){ echo -n $((RANDOM/coredata)); } # generate the randomly number between zero and $1 passed to $0
color(){ echo -n ${coltab[RANDOM/512]}; } # generate the randomly number between zero and sisty-three
hdbox(){ echo -e "${oldbox//[]/  }\e[0m"; } # erase the old pieces
check(){ (( map[(i-modh-1)*width+j/2-modh] == 0 )) && break; } # check the current row whether it's fully filled up with pieces
pause(){ (( ${2} == 0 )) && kill -s STOP ${1} || kill -s CONT ${1}; } # invoked for pausing and resuming the game

resume()
{  # restore to the normal stty settings
   stty ${STTY}
   echo -e "\e[?25h\e[36;4H" 
}

ptbox()
{  # draw the current pieces
   oldbox="${cdn}"
   echo -e "\e[${colbox}${cdn}\e[0m" 
}

regxy()
{  # invoke the ptbox function and get the coordinates 
   ptbox
   locus="${sup}" 
}

equation()
{  # core algorithm used for doubling and halving the coordinates
   [[ ${cdx} ]] && ((y=cy+(ccy-cdy)${2}2))
   eval ${1}+=\"${x} ${y} \"
}

Quit()
{  # function used for exiting invocation
   case $# in
        0) echo -e "\e[?25h\e[36;26HGame Over!\e[0m" ;;
        1) kisig
           resume ;;
        2) resume ;;
   esac
           exit
}

customization()
{  # customize the kinds of the pieces
   local i j k
   j=32767
   k=${1:-25}
   (( k <= 0 || k > 25 )) && ((coredata=j+1)) || {
   for((i=j/k; i>0; --i))
   do 
        if (( j/i == k && j/(i-1) == k+1 )); then
           ((coredata=i))
           return
        fi
   done
   }
}

lowerside()
{  # function used for getting the coordinates of the lower side of the pieces
   local i a b
   set -- ${box[@]} 
   a[$2]=${1} 
   b[$2]="${1} ${2}" && shift 2
   while (( ${#} > 0 ))
   do
         (( a[$2] < ${1} )) && a[$2]=${1}
         b[$2]="${a[$2]} ${2}"
         shift 2
   done
   echo ${b[@]}
}

initialization()
{  # initial all the background pieces to be empty 
   local rsyx
   ((rsyx=(i-modh-1)*width+j/2-modh))
   ((map[rsyx]=0))
   ((pam[rsyx]=0))
}
 
background()
{  # draw the background pieces
   local rsxy rsyx
   rsyx="\e[${i};${j}H"
   ((rsxy=(i-modh-1)*width+j/2-modh))
   (( map[rsxy] == 0 )) && echo -ne "${rsyx}  " || echo -ne "${rsyx}\e[${pam[rsxy]}${mrx}\e[0m"
}

posmap()
{  # map the current pieces into background pieces 
   local srx sry
   ((srx=(j-modh)*width+u/2-modh))
   ((sry=(j-modh-1)*width+u/2-modh))
   ((map[srx]=map[sry]))
   eval pam[srx]=\"${pam[sry]}\"
}

loop()
{  # a shared loop structure used for invocation
   local i j
   for((i=modh+1; i<=height+modh; ++i))
   do
        for((j=modw+1; j<=2*(width-1)+modw+1; j+=2))
        do
             ${1}
        done
        ${2}  
   done
}

iteration()
{  # a shared itera structure used for invocation
   local u 
   for((u=modw+1; u<=2*(width-1)+modw+1; u+=2))
   do
          ${1} 
   done
}

mapbox()
{  # sum the lines which are fully filled up with pieces and invoke the iteration function
   (( j <= 2*(width-1)+modw+1 )) && continue
   ((++line))
   for((j=i-1; j>=modh+1; --j))
   do
         iteration posmap
   done
         iteration first
}

preview()
{  # preview the next N pieces (the default value of N is six)
   local vor clo clu i
   vor=(${!1})
   for((i=0; i<${#vor[@]}; i+=2))
   do
       ((clo=${vor[i+1]}+${hh}-${3}))
       smobox+="\e[$((vor[i]-1));${clo}H${mrx}"
   done
   clu="${!2}"
   echo -e "${clu//[]/  }\e[${!4}${smobox}\e[0m"
}

pipebox()
{  # core function used for piping the output of one preview to the input of the next one
   smobox=""
   (( ${5} != 0 )) && {
   piece box$(radom)[@]
   eval ${1}="(${box[@]})"
   colbox="$(color)"
   eval ${6}=\"${colbox}\"
   preview box[@] ${3} ${4} colbox
   } || {
   eval ${1}="(${!2})"
   eval ${6}=\"${!7}\"
   preview ${2} ${3} ${4} ${7}
   }
   eval ${3}=\"${smobox}\"
}

invoke() 
{  # a highly abstracted  function intended for invoking the pipebox                
   local aryA aryB aryC i
   aryA=(m{c..h}box)
   for((i=0; i<5; ++i))
   do
        aryB=(r${aryA[i]} r${aryA[i+1]}[@] ${aryA[i]})
        aryC=($((12*(2-i))) ${1} s${aryB[0]} sr${aryA[i+1]}) 
        pipebox ${aryB[@]} ${aryC[@]} 
   done
}

showbox()
{  # draw the pieces used for preview
   local smobox 
   colbox="${srmcbox}"
   olbox=(${rmcbox[@]})
   invoke ${#}
   smobox=""
   piece box$(radom)[@]
   rmhbox=(${box[@]})
   srmhbox="$(color)"
   preview box[@] crsbox -36 srmhbox
   crsbox="${smobox}"
   box=(${olbox[@]})
}

drawbox()
{  # draw the current pieces
   (( $# == 1 )) && {
        piece box$(radom)[@] 
        colbox="$(color)"
        coordinate box[@] regxy 
   } || {
   colbox="${srmcbox}"
   coordinate rmcbox[@] regxy 
   }
   oldbox="${cdn}"
   if ! movebox locus; then
      kill -${sigExit} ${PPID}
      kisig
      Quit
   fi
}

bomb()
{  # the bomb used for erasing the other pieces 
   scn=""
   for((j=0; j<${#calcu[@]}; j+=2))
   do
       ((p=calcu[j]))
       ((q=calcu[j+1]))
       ((mus=(p-modh-1)*width+q/2-modh))
       boolp="p > modh && p <= height+modh"
       boolq="q <= 2*width+modw && q > modw"
       if (( boolp && boolq )); then
          scn+="\e[${p};${q}H${sbos}"
          ((map[mus]=0))
          ((pam[mus]=0))
       fi
   done
   sleep 0.03
   echo -e "${scn}"
}

offset()
{  # calculate the current score, level and erase the background pieces when necessary
   local i j x y p q yox sbos line vor mus calcu scn boolp boolq
   sbos="\040\040"
   vor=(${locus})
   calcu=(x y-4 x y-2 x y x y+2 x y+4 x+1 y x+1 y-2 x+1 y+2)
   for((i=0; i<${#vor[@]}; i+=2))
   do
       ((x=vor[i])) 
       ((y=vor[i+1]))
       ((yox=(x-modh-1)*width+y/2-modh))
       if (( ${#vor[@]} == 16 )); then
             bomb
       else 
             ((map[yox]=1))
             pam[yox]="${colbox}"
       fi
   done
   line=0
   loop check  mapbox
   (( line == 0 )) && return
   echo -e "\e[1;34m\e[$((modh+6));${hh}H$((score+=line*200-100))"
   (( score%5000 < line*200-100 && level < 20 )) && echo -e "\e[1;34m\e[$((modh+8));${hh}H$((++level))"
   echo -e "\e[0m"
   loop background
}        

showtime()
{  # show the total time consumed since the script has been invoked in form of HH:MM:SS
   local i h m s vir Time
   trap "Quit" ${sigExit} 
   h=0
   m=0
   s=0
   vir=--------
   colot="\e[1;33m"
   echo -e "\e[2;6H${colot}${vir}${vir}[\e[0m"
   echo -e "\e[2;39H${colot}]${vir}${vir}\e[0m"
   while :
   do
         (( s == 60 )) && { ((++m)); s=0; }
         (( m == 60 )) && { ((++h)); m=0; }
         for i in h m s
         do
                if (( $(eval echo \${#${i}}) != 2 )); then
                      Time[i]="0${!i}"
                else
                      Time[i]="${!i}"
                fi
         done    
         echo -e "\e[2;24H${colot}Time  ${Time[h]}:${Time[m]}:${Time[s]}\e[0m"
         sleep 1
         ((++s))
   done
}

persig()
{  # deal with the detected signals
   local sigSwap pid
   pid=${1} 
   showbox 0
   drawbox 0 
   for i in sigRotate sigTransf sigLeft sigRight sigDown sigAllDown
   do
        trap "sig=${!i}" ${!i}
   done
   trap "kisig; Quit" ${sigExit} 
   while :
   do
       for ((i=0; i<20-level; ++i))
       do
            sleep 0.02
            sigSwap=${sig}
            sig=0
            case ${sigSwap} in
            ${sigRotate} )  transform 0     ;;
            ${sigTransf} )  transform 1     ;;
            ${sigLeft}   )  transform 0 -2  ;;
            ${sigRight}  )  transform 0  2  ;;
            ${sigDown}   )  transform 1  0  ;;
            ${sigAllDown})   
            transform $(value $(bottom)) 0  ;;
            esac
       done
       transform 1  0
   done
}

getsig()
{  # deal with the input messages
   local pid key arry pool STTY sig
   pid=${1}
   arry=(0 0 0)
   pool=$(echo -ne "\e")
   STTY=$(stty -g)
   trap "Quit 0" INT TERM
   trap "Quit 0 0" ${sigExit}
   echo -ne "\e[?25l"
   while :
   do
           read -s -n 1 key
           arry[0]=${arry[1]}
           arry[1]=${arry[2]}
           arry[2]=${key}
           sig=0
           if   [[ ${key} == ${pool} && ${arry[1]} == ${pool} ]];then Quit 0
           elif [[ "[${key}]" == ${mrx} ]]; then sig=${sigAllDown}       
           elif [[ ${arry[0]} == ${pool} && ${arry[1]} == "[" ]]; then
                     case ${key} in
                     A)    sig=${sigRotate}    ;;
                     B)    sig=${sigDown}      ;;
                     D)    sig=${sigLeft}      ;;
                     C)    sig=${sigRight}     ;;
                     esac
           else
                    case ${key} in
                     W|w)  sig=${sigRotate}    ;;
                     T|t)  sig=${sigTransf}    ;;
                     S|s)  sig=${sigDown}      ;;
                     A|a)  sig=${sigLeft}      ;;
                     D|d)  sig=${sigRight}     ;; 
                     P|p)  pause ${pid}  0     ;;
                     R|r)  pause ${pid}  1     ;;
                     Q|q)  Quit 0              ;;
                     esac
           fi
                     (( sig != 0 )) && kill -${sig} ${pid}
   done
}

bottom()
{  # drop all the pieces down to the bottom
   local max boolc boolr i j 
   max=($(lowerside))
   for((i=0; i<height; ++i))
   do
       for((j=0; j<${#max[@]}; j+=2))
       do 
           boolr="max[j]+i == height+modh"
           boolc="map[(max[j]+i-modh)*width+max[j+1]/2-modh] == 1"
           (( boolc || boolr )) && return ${i}
       done 
   done
}

movebox()
{  # detect whether it's possible to move the pieces to a new position   
   local x y i j xoy vor boolx booly 
   vor=(${!1})
   smu=${#vor[@]}
   for((i=0; i<${#vor[@]}; i+=2))
   do    
        ((x=vor[i]+dx))
        ((y=vor[i+1]+dy))
        ((xoy=(x-modh-1)*width+y/2-modh))
        (( xoy < 0 )) && return 1
        boolx="x <= modh || x > height+modh"
        booly="y > 2*width+modw || y <= modw"
        (( boolx || booly )) && return 1
        if (( map[xoy] == 1 )); then
           if (( smu == 2 )); then
              for((j=height+modh; j>x; --j))
              do
                   (( map[(j-modh-1)*width+y/2-modh] == 0 )) && return 0
              done
           fi
           return 1
        fi
   done 
   return 0  
}

across()
{  # move the 1x1 block in a special manner           
   local i j m one 
   one=(${locus})
   ((i=one[0]))
   ((j=one[1]))
   ((m=(i-modh-1)*width+j/2-modh))
   (( map[m] == 1 )) && echo -e "\e[${i};${j}H\e[${pam[m]}${mrx}\e[0m"
}

coordinate()
{  # locate the coordinates of the pieces on the terminal
   local i sup vor
   vor=(${!1})
   for((i=0; i<${#vor[@]}; i+=2))
   do    
       cdn+="\e[${vor[i]};${vor[i+1]}H${mrx}"
       sup+="${vor[i]} ${vor[i+1]} "
   done
   ${2} 
}

increment()
{  # add the increment of the coordinates according to the direction that pieces will move to
   local v
   for((v=0; v<${#box[@]}; v+=2))
   do
      ((box[v]+=dx))
      ((box[v+1]+=dy))
   done
   nbox=(${box[@]})
   coordinate box[@] regxy
   box=(${nbox[@]})
}

parallelbox()
{  # move the pieces or generate new one when the bottom is the current position
   if movebox locus; then
        hdbox
        (( smu == 2 )) && across
        increment
   else
        (( dx == 1 )) && {
        offset  
        drawbox 
        showbox
        }
   fi
}

centralpoint()
{  # get the central coordinates of the pieces
   BOX=(${!1})
   if (( ${#BOX[@]}%4 == 0 )); then
        ((${2}=BOX[${#BOX[@]}/2]))
        ((${3}=BOX[${#BOX[@]}/2+1]))
   else
        ((${3}=BOX[${#BOX[@]}/2]))
        ((${2}=BOX[${#BOX[@]}/2-1]))
   fi
}

multiple()
{  # transformation between double and a half of the coordinates
   local x y cy ccx ccy cdx cdy vor 
   vor=(${!1})
   for((i=0; i<${#vor[@]}; i+=2))
   do
       ((x=vor[i])) 
       ((y=vor[i+1]))
       ((ccx=x))
       ((ccy=y))
       ${2} ${3} "${4}"
       ((cy=y))
       ((cdx=ccx))
       ((cdy=ccy))    
   done 
}

algorithm()
{  # the most core algorithm used for pieces rotation and matrix transposition
   local row col 
   for((i=0; i<${#vbox[@]}; i+=2))
   do
          ((row=m+vbox[i+1]-n))  # row=(x-m)*zoomx*cos(a)-(y-n)*zoomy*sin(a)+m
       if (( dx != 1 )); then    # col=(x-m)*zoomx*sin(a)+(y-n)*zoomy*cos(a)+n
          ((col=m-vbox[i]+n))    # a=-pi/2 zoomx=+1 zoomy=+1 dx=0 dy=0 
       else                      # a=-pi/2 zoomx=-1 zoomy=+1 dx=0 dy=0
          ((col=vbox[i]-m+n))    # a=+pi/2 zoomx=+1 zoomy=-1 dx=0 dy=0
       fi
          mbox+="${row} ${col} " 
   done
}

component()
{  # add the difference of two central coordinates        
   local i
   for((i=0; i<${#tbox[@]}; i+=2))
   do
       ((tbox[i]+=mp-p))
       ((tbox[i+1]+=nq-q))
   done
}

procedure()
{  # function invocation
   multiple ${1} ${2} ${3} "${4}"
   eval ${3}="(${!3})"
   centralpoint ${3}[@] ${5} ${6} 
}

rotate()
{  # rotate or transpose the pieces
   local m n p q mp nq tbox mbox vbox kbox 
   centralpoint box[@] mp nq 
   procedure box[@]  equation vbox "/" m n
   algorithm 
   mbox=(${mbox})
   procedure mbox[@] equation tbox "*" p q
   component
   coordinate tbox[@] serxy
   dx=0
   if movebox kbox; then
       hdbox
       locus="${kbox}"
       ptbox
       box=(${kbox})
   fi
}

transform()
{  # function invocation
   local dx dy cdn smu
   dx=${1}
   dy=${2}
   (( $# == 2 )) && parallelbox || rotate 
}

matrix()
{  # matrix equation of the core algorithm 
   one=" "
   sr="\e[0m"
   two="${one}${one}"
   tre="${one}${two}"
   cps="${two}${tre}"
   spc="${cps}${cps}"         
   colbon="\e[1;36m"
   mcol="\e[1;33;40m"
   trx="${mrx}${mrx}"
   fk0="${colbon}${mrx}${sr}"
   fk1="${colbon}${trx}${sr}"
   fk2="${colbon}${mrx}${trx}${sr}"
   fk3="${colbon}${trx}${trx}${sr}"
   fk4="${mcol}${mrx}${sr}"
   fk5="${spc}${spc}"
   fk6="${mcol}${mrx}${trx}${sr}"
   fk="${tre}${fk0}${two}${fk3}${two}${fk3}"
   fk7="${fk1}${one}${fk1}${fk}${fk4}${two}${two}"
   fk8="${fk0}${one}row${one}${fk0}${tre}${fk0}${two}${fk0}${one}(x-m)*zoomx${two}"
   fk9="${one}=${one}${fk0}${two}${fk0}${spc}${tre}${one}${fk0}${tre}*${two}"
   fk10="${spc}${cps}${two}${fk0}${two}${fk0}${one}+${one}${fk0}${cps}${fk0}"
   fk11="${tre}${one}${fk0}${two}cos(a)${one}sin(a)${two}${fk0}${two}${fk0}${tre}${fk0}${two}m${two}${fk0}"
   fk12="${one}col${one}${fk0}${tre}${fk0}${two}${fk0}${one}(y-n)*zoomy${two}${fk0}${cps}${one}"
   fk13="${one}-sin(a)${one}cos(a)${two}${fk0}${two}${fk0}${tre}${fk0}${two}n${two}${fk0}"
   fk14="${fk1}${one}${fk1}${fk}${cps}${one}"
   fk15="${fk1}${two}${fk0}${tre}${fk1}${one}${fk1}"
   echo -e "\e[$((modh+23));${hh}HAlgorithm:${sr}${two}${fk2}${one}${fk5}${fk5}${fk2}${fk4}"
   echo -e "\e[$((modh+30));${hh}H${spc}${two}${fk0}${two}${two}${cps}${fk5}${fk5}${fk0}"
   echo -e "\e[$((modh+25));${hh}H${fk7}${fk1}${spc}${tre}${fk1}${two}${fk0}${tre}${fk1}${one}${fk1}"
   echo -e "\e[$((modh+26));${hh}H${fk8}${fk0}${fk4}${fk11}\e[$((modh+28));${hh}H${fk0}${fk12}${fk0}${fk13}"
   echo -e "\e[$((modh+24));${hh}H${two}${spc}${fk0}${spc}${tre}${two}${tre}${fk6}${fk5}${cps}${fk0}${fk4}"
   echo -e "\e[$((modh+22));${hh}H${tre}${fk5}${fk5}${fk5}${fk6}\e[$((modh+29));${hh}H${fk14}${fk1}${spc}${tre}${fk15}"
   echo -e "\e[$((modh+27));${hh}H${fk0}${cps}${fk0}${fk9}${fk0}${fk10}\e[$((modh+31));${hh}H${spc}${two}${fk2}${fk5}${fk5} ${fk2}"
}

boundary()
{  # the boundary of the game area 
   clear
   boncol="\e[1;36m"
   for((i=modw+1; i<=2*width+modw; i+=2))
   do
        echo -e "${boncol}\e[${modh};${i}H==\e[$((height+modh+1));${i}H==\e[0m"
   done
   for((i=modh; i<=height+modh+1; ++i))
   do
        echo -e "${boncol}\e[${i};$((modw-1))H||\e[${i};$((2*width+modw+1))H||\e[0m"
   done
}

instruction()
{  # basic information   
   echo -e "\e[1;31m\e[$((modh+5));${hh}HScore\e[1;31m\e[$((modh+7));${hh}HLevel\e[0m"
   echo -e "\e[1;34m\e[$((modh+6));${hh}H${score}\e[1;34m\e[$((modh+8));${hh}H${level}\e[0m"
   echo -e "\e[$((modh+14));${hh}HT|t          ===   transpose"
   echo -e "\e[$((modh+10));${hh}HQ|q|ESC      ===   exit"
   echo -e "\e[$((modh+11));${hh}HP|p          ===   pause\e[$((modh+12));${hh}HR|r          ===   resume"
   echo -e "\e[$((modh+13));${hh}HW|w|up       ===   rotate\e[$((modh+15));${hh}HS|s|down     ===   one step down"
   echo -e "\e[$((modh+16));${hh}HA|a|left     ===   one step left\e[$((modh+17));${hh}HD|d|right    ===   one step right"
   echo -e "\e[$((modh+18));${hh}HSpace|enter  ===   drop all down\e[1;36m\e[$((modh+19));${hh}HTetris Game  Version 5.0"
   echo -e "\e[$((modh+20));${hh}HYongYe <expertshell@gmail.com>\e[$((modh+21));${hh}H11/01/2011 BeiJing China  [Updated 01/22/2012]"
}

   [[ "x${1}" == "xRun" ]] && {
       customization ${2}
       loop initialization 
       boundary
       instruction
       matrix
       showtime &
       persig $! 
   } || { 
       bash $0 Run ${1} &
       getsig $!
   }
