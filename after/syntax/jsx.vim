"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Vim syntax file
"
" Language: JSX (JavaScript)
" Maintainer: @kylpo
" Depends: pangloss/vim-javascript
"
" CREDITS: Fork of jsx.vim and default xml syntax
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let s:xml_cpo_save = &cpo
set cpo&vim

syn case match

" mark illegal characters
syn match xmlError "[<&]"

" strings (inside tags) aka VALUES
"
" EXAMPLE:
"
" <tag foo.attribute = "value">
"                      ^^^^^^^
syn region  xmlString contained start=+"+ end=+"+ contains=xmlEntity,@Spell display
syn region  xmlString contained start=+'+ end=+'+ contains=xmlEntity,@Spell display


" punctuation (within attributes) e.g. <tag xml:foo.attribute ...>
"                                              ^   ^
" syn match   xmlAttribPunct +[-:._]+ contained display
syn match   xmlAttribPunct +[:.]+ contained display

" no highlighting for xmlEqual (xmlEqual has no highlighting group)
syn match   xmlEqual +=+ display


" attribute, everything before the '='
"
" PROVIDES: @xmlAttribHook
"
" EXAMPLE:
"
" <tag foo.attribute = "value">
"      ^^^^^^^^^^^^^
"
syn match   xmlAttrib
      \ +[-'"<]\@1<!\<[a-zA-Z:_][-.0-9a-zA-Z:_]*\>\%(['"]\@!\|$\)+
      \ contained
      \ contains=xmlAttribPunct,@xmlAttribHook
      \ display

syn match   commentedXmlAttrib
      \ +\/\/.*+
      \ contained
      \ contains=xmlAttribPunct,@xmlAttribHook
      \ display


" tag name
"
" PROVIDES: @xmlTagHook
"
" EXAMPLE:
"
" <tag foo.attribute = "value">
"  ^^^
"
syn match   xmlTagName
      \ +<\@1<=[^ /!?<>"']\++
      \ contained
      \ contains=xmlNamespace,xmlAttribPunct,@xmlTagHook
      \ display

" EXAMPLE:
"
" <tag_ foo.attribute = "value">
"  ^^^^
"
syn match   xmlTagNameModifier
      \ +<\@1<=_\@<![^ /!?<>"']\+_+
      \ contained
      \ contains=xmlNamespace,xmlAttribPunct,@xmlTagHook
      \ display


" EXAMPLE:
"
" <_tag_ foo.attribute = "value">
"  ^^^^^
"
syn match   xmlTagNameNull
      \ +<\@1<=_[^ /!?<>"']\+_+
      \ contained
      \ contains=xmlNamespace,xmlAttribPunct,@xmlTagHook
      \ display


" EXAMPLE:
"
" <tag foo.attribute = "value">
" ^                           ^
"
syn region   xmlTag
      \ matchgroup=xmlTag start=+<[^_][^ /!?<>"']\@=+
      \ matchgroup=xmlTag end=+>+
      \ contains=xmlError,xmlTagName,xmlTagNameModifier,commentedXmlAttrib,xmlAttrib,xmlEqual,xmlString,@xmlStartTagHook


" EXAMPLE:
"
" <tag_ foo.attribute = "value">
" ^                            ^
"
syn region   xmlModifierTag
      \ matchgroup=xmlModifierTag start=+<[^_][^ /!?<>"']\+_\@=[^ /!?<>"']\@=+
      \ matchgroup=xmlModifierTag end=+>+
      \ contains=xmlError,xmlTagNameModifier,commentedXmlAttrib,xmlAttrib,xmlEqual,xmlString,@xmlStartTagHook


" EXAMPLE:
"
" <_tag_ foo.attribute = "value">
" ^                             ^
"
syn region   xmlNullTag
      \ matchgroup=xmlNullTag start=+<_[^ /!?<>"']\+_\@=[^ /!?<>"']\@=+
      \ matchgroup=xmlNullTag end=+>+
      \ contains=xmlError,xmlTagNameModifier,xmlTagNameNull,commentedXmlAttrib,xmlAttrib,xmlEqual,xmlString,@xmlStartTagHook


" EXAMPLE:
"
" </tag>
" ^^^^^^
"
syn match   xmlEndTag
      \ +</[^ /!?<>"']\+>+
      \ contains=xmlNamespace,xmlAttribPunct,@xmlTagHook


" EXAMPLE:
"
" </tag_>
" ^^^^^^^
"
syn match   xmlModifierEndTag
      \ +</[^ /!?<>"']\+_>+
      \ contains=xmlNamespace,xmlAttribPunct,@xmlTagHook

syn match   xmlEntity                 "&[^; \t]*;" contains=xmlEntityPunct
syn match   xmlEntityPunct  contained "[&.;]"

syn sync minlines=100


" Identifier = red
" keywork = pink
"
" The default highlighting.
hi def link xmlTodo		Todo
hi def link xmlTag		Function
hi def link xmlTagName		Function
hi def link xmlEndTag		Function
hi def link xmlModifierTag		Operator
hi def link xmlTagNameModifier		Operator
hi def link xmlModifierEndTag		Operator
hi def link xmlNullTag		Identifier
hi def link xmlTagNameNull		Identifier
if !exists("g:xml_namespace_transparent")
  hi def link xmlNamespace	Tag
endif
hi def link xmlEntity		Statement
hi def link xmlEntityPunct	Type

hi def link xmlAttribPunct	Comment
hi def link xmlAttrib		Type
hi def link commentedXmlAttrib		Comment

hi def link xmlString		String
hi def link xmlError		Error

hi def link xmlProcessingDelim	Comment

" let b:current_syntax = "xml"

let &cpo = s:xml_cpo_save
unlet s:xml_cpo_save


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Officially, vim-jsx depends on the pangloss/vim-javascript syntax package
" (and is tested against it exclusively).  However, in practice, we make some
" effort towards compatibility with other packages.
"
" These are the plugin-to-syntax-element correspondences:
"
"   - pangloss/vim-javascript:      jsBlock, jsExpression
"   - jelera/vim-javascript-syntax: javascriptBlock
"   - othree/yajs.vim:              javascriptNoReserved


" JSX attributes should color as JS.  Note the trivial end pattern; we let
" jsBlock take care of ending the region.
syn region xmlString contained start=+{+ end=++ contains=jsBlock,javascriptBlock

" JSX child blocks behave just like JSX attributes, except that (a) they are
" syntactically distinct, and (b) they need the syn-extend argument, or else
" nested XML end-tag patterns may end the outer jsxRegion.
syn region jsxChild contained start=+{+ end=++ contains=jsBlock,javascriptBlock
  \ extend

" Highlight JSX regions as XML; recursively match.
"
" Note that we prohibit JSX tags from having a < or word character immediately
" preceding it, to avoid conflicts with, respectively, the left shift operator
" and generic Flow type annotations (http://flowtype.org/).
syn region jsxRegion
  \ contains=@Spell,xmlTag,xmlNullTag,xmlModifierTag,xmlEndTag,xmlModifierEndTag,xmlNullEndTag,Region,xmlEntity,xmlProcessing,@xmlRegionHook,jsxRegion,jsxChild,jsBlock,javascriptBlock
  \ start=+\%(<\|\w\)\@<!<\z(\h[a-zA-Z0-9:\-.]*\)+
  \ end=+</\z1\_\s\{-}>+
  \ end=+/>+
  \ keepend
  \ extend

" Add jsxRegion to the lowest-level JS syntax cluster.
syn cluster jsExpression add=jsxRegion

" Allow jsxRegion to contain reserved words.
syn cluster javascriptNoReserved add=jsxRegion
