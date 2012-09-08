" pacman program output syntax rules for Clam.vim

syn match packageName "/\S\+\>"

syn keyword packageGroupExtra extra
syn keyword packageGroupCommunity community
syn keyword packageGroupMultilib multilib
syn keyword packageInstalledMark installed


hi def link packageGroupCommunity Type
hi def link packageGroupExtra     Type
hi def link packageGroupMultilib  Type
hi def link packageInstalledMark  Error
hi def link packageName           String
