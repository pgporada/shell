#!/usr/bin/env bash

RED=$(tput setaf 1)
CLEAR=$(tput sgr0)
start() {
echo "Stop"
sleep 1
echo "Drop"
sleep 1
echo -n "+ Is there a fire? [yn]: "
read fire
if [ ${fire} == "y" ]; then
    echo "Roll"
echo "${RED}
            (  .      )
        )           (              )
              .  '   .   '  .  '  .
     (    , )       (.   )  (   ',    )
      .' ) ( . )    ,  ( ,     )   ( .
   ). , ( .   (  ) ( , ')  .' (  ,    )
  (_,) . ), ) _) _,')  (, ) '. )  ,. (' )${CLEAR}
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
"
    exit
else
    sleep 1
    echo "Stop, drop, shut 'em down open up shop"
    echo "Oh, no"
    echo "That's how Ruff Ryders roll"
    echo
    sleep 1
    start
fi
}
start
