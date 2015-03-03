#!/bin/bash
# PGP
# I did not create the actual ASCII art, I just acquired it from the internet, mashed it together, and colored it up.

bold=$(tput bold)
cr=$(tput setaf 1)
cg=$(tput setaf 2)
cy=$(tput setaf 3)
cb=$(tput setaf 4)
cc=$(tput setaf 6)
cw=$(tput setaf 7)
re="${bold}$(tput sgr0)${bold}"

echo -e "${bold}${cy}     .               /
      \\       I     
                  /
        \\  ,g88R${re}_
          ${cy}d888${re}(\`  )${cy}.
 -  --==  888${re}(     )${cy}.=--${re}
)         ${cy}Y8P${re}(       '\`.
        ${cy}.+${re}(\`(      .   )     .--
       ((    (..__.:'-'   .=(   )
\`.     \`(       ) )       (   .  )
  )      \` __.:'   )     (   (   ))
)  )  ( )       --'       \`- __.' 
.-'  (_.'          .')
                  (_  )

${cb}--..,___.--,--'\`,---..-.--+--.,,-
${cc}~         ~~          __${re}
       _T${cc}      .,,.    ~--~ ^^${re}
${cc} ^^${re}   // \\                ${cc}    ~${re}
      ][O]    ${cc}^^${re}      ,-~ ~
   /''-I_I         _II____
__/_  /   \\ ______/ ''   /'\\_${cg},${re}__
  | II--'''' \\${cg},--${re}:--..,_/,.-${cg}{ },${re}
${cg};${re} '/__\\,.--';|   |[] .-.| O${cg}{ _ }${re}
${cg}:'${re} |  | []  -|   ''--:.;[,.'${cg}\\,/${re}
${cg}'${re}  |[]|,.--'' ${cg}'',   ''-,.    |${re}
${cg}  ..    ..-'' ${re}/ \\${cg};       ''. '${re}
             /   \\
${cr}][${cy}----${cr}][${cy}----${cr}]     [${cy}----${cr}][${cy}----${cr}][${re}
            /     \\
         Welcome Home${re}
"
