" Eiffel syntax file that is really for Dante Project *.e files.

syntax clear

syntax region	ddpString	start=/"/ end=/"/
syntax region	ddpEurString	start=/</ end=/>/
syntax region	ddpBold		start=/|/ end=/\~/
syntax region	ddpItalic	start=/\^/ end=/\~/ contains=ddpString

highlight link	ddpString	String
highlight link	ddpEurString	String
highlight	ddpBold		term=bold cterm=bold gui=bold
highlight	ddpItalic	term=underline cterm=underline gui=underline
