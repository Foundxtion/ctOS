{ osConfig, lib, pkgs, ... }:

let
  mapleadersDefinitions = ''
    " These definitions are repeated in every block that uses <leader> or
    " <localleader> bindings. This is because home-manager's extraConfig text
    " appears too late in the generated config file, so if I define map leaders
    " only in extraConfig, it will appear after the plugin configurations, who
    " sometimes need the definition.
    let mapleader = ","
    let maplocalleader = "\\"
  '';
in
with lib;
{
  programs.neovim = mkIf osConfig.fndx.packages.vim.enable {
    defaultEditor = true;
    enable = true;
    vimAlias = true;
    withNodeJs = true;
    withPython3 = true;
    extraPackages = with pkgs; [
      git
      jdk # for coc-java
      opam
      rustc # for coc-rust-analyzer
      ripgrep # for telescope live grep
    ];

    extraPython3Packages = (ps: with ps; [
      black
      flake8
      jedi
      pylint
    ]);

    plugins = with pkgs.vimPlugins; [
      # Engines
      {
        plugin = coc-nvim;
        config = ''
          ${mapleadersDefinitions}

          " Select autocompletion item with Tab and S-Tab, confirm with CR
          inoremap <silent><expr> <TAB>
              \ coc#pum#visible() ? coc#pum#next(1):
              \ CheckBackspace() ? "\<Tab>" :
              \ coc#refresh()
          inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"
          inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
          function! CheckBackspace() abort
            let col = col('.') - 1
            return !col || getline('.')[col - 1]  =~# '\s'
          endfunction

          " Code navigation
          nmap <leader>ld <Plug>(coc-definition)
          nmap <leader>lt <Plug>(coc-type-definition)
          nmap <leader>li <Plug>(coc-implementation)
          nmap <leader>lr <Plug>(coc-references-used)

          " Code actions
          vmap <leader>laf <Plug>(coc-format-selected)
          nmap <leader>laf <Plug>(coc-format)
          nmap <leader>lar <Plug>(coc-rename)
          nmap <leader>laq <Plug>(coc-fix-current)

          " Use K to show documentation in preview window.
          nnoremap <silent> K :call ShowDocumentation()<CR>

          function! ShowDocumentation()
            if CocAction('hasProvider', 'hover')
              call CocActionAsync('doHover')
            else
              call feedkeys('K', 'in')
            endif
          endfunction

          " Highlight other uses of the symbol currently under the cursor (needs
          " coc-highlight)
          autocmd CursorHold * silent call CocActionAsync('highlight')
          highlight CocHighlightText guibg=#4b5263

          " let g:opamshare = substitute(system('opam config var share'),'\n$',''\'''\',''\'''\'''\'''\')
          " execute "set rtp+=" . g:opamshare . "/merlin/vim"
        '';
      }
      {
        plugin = nvim-treesitter.withAllGrammars;
        config = ''
          lua << EOF
          require'nvim-treesitter.install'.compilers = {"${pkgs.clang}/bin/clang"}
          require'nvim-treesitter.configs'.setup {
            -- XXX: not sure if I need ensure_installed here or not
            highlight = {
              enable = true,
              -- I prefer the default nvim highlighter for certain languages
              -- vimtex also relies on its own syntax highlighting being used
              -- for some of its features
              disable = { "markdown", "latex" },
            },
          }
          EOF
        '';
      }

      # Themes and visuals
      vim-one
      vim-airline-themes
      vim-devicons
      {
          plugin = telescope-nvim;
          config = ''
          nnoremap <leader>ff <cmd>Telescope find_files<cr>
          nnoremap <leader>fg <cmd>Telescope live_grep<cr>
          '';
      }
      {
        plugin = vim-airline;
        config = "let g:airline_powerline_fonts = 1";
      }
      {
        plugin = indent-blankline-nvim;
        config = ''
          let g:indent_blankline_show_trailing_blankline_indent = v:false
          let g:indent_blankline_char_blankline = '┆'
          let g:indent_blankline_show_current_context = v:true
        '';
      }

      # Vim behaviors improvements
      vim-obsession
      targets-vim
      vim-suda
      vim-eunuch
      vim-togglelist

      # Language-agnostic editing improvements
      ctrlp-vim
      nerdtree
      {
        plugin = vim-easy-align;
        config = ''
          " Start interactive EasyAlign in visual mode (e.g. vipga)
          xmap ga <Plug>(EasyAlign)
          " Start interactive EasyAlign for a motion/text object (e.g. gaip)
          nmap ga <Plug>(EasyAlign)
        '';
      }

      # Language-specific improvements
      # TODO: some of these plugin could be removed if they only provide syntax
      # highlighting (treesitter does its own highlighting for the languages it
      # supports)
      # python-syntax
      # black
      vim-toml
      vim-python-pep8-indent
      vim-cpp-enhanced-highlight
      vim-nix
      {
        plugin = rust-vim;
        config = "let g:rust_cargo_use_clippy = 1";
      }
      {
        plugin = SimpylFold;
        config = ''
          let g:SimpylFold_docstring_preview = 1
          let g:SimpylFold_fold_docstring = 0
        '';
      }
      {
        plugin = vimtex;
        config = ''
          let g:vimtex_fold_enabled=1
          let g:vimtex_view_automatic=0

          " When in doubt between plaintex and latex, default to latex
          let g:tex_flavor = 'latex'

          " I redefine normmal mode mappings in ftplugin/tex.vim
          let g:vimtex_mappings_enabled=0

          " Deactivate insert mode mappings (TODO: reactivate but fix them)
          let g:vimtex_imaps_enabled=0

          " Ignore some latex warnings
          let g:vimtex_quickfix_ignore_filters = [
          \ 'Overfull',
          \ 'font',
          \ 'Underfull'
          \ ]
          '';
      }
      {
        plugin = vim-javascript;
        config = ''
            let g:javascript_plugin_jsdoc = 1
            augroup javascript_folding
            au!
            au FileType javascript setlocal foldmethod=syntax
            augroup END
        '';
      }

      coc-clangd
      coc-cmake
      coc-git
      coc-go
      coc-highlight
      # coc-java
      coc-json
      coc-markdownlint
      coc-pyright
      coc-rust-analyzer
      coc-texlab
      coc-tsserver
      coc-vimlsp
      coc-yaml

      # Dev tools
      vim-test
      {
        plugin = nerdcommenter;
        config = "let g:NERDSpaceDelims=1";
      }
    ];

    extraConfig = ''
      " General settings {{{
      set encoding=utf-8

      " Deactivate legacy vi compatibility
      set nocompatible

      " Set the prefix for many plugin commands
      ${mapleadersDefinitions}

      " Toggle g option by default on substition
      set gdefault

      " Increase the maximum tab number while launching vim with -p
      set tabpagemax=50

      " Split behavior
      set splitbelow
      set splitright

      " When scrolling, keep at list 5 lines visible on screen around the cursor
      set scrolloff=5

      " Make the backspace key have a sensible behavior
      set backspace=indent,eol,start

      " Check for vim settings embeded in the files we open
      set modeline
      set modelines=5

      " Show selection size in visual mode
      set showcmd

      " Use fold markers by default
      set fdm=marker

      " Enhance command line completion
      set wildmenu
      " Set completion behavior, see :help wildmode for details
      set wildmode=list:longest:full

      " Disable bell completely
      set visualbell
      set t_vb=

      " Highlight some special characters
      set list
      set listchars=tab:.\ ,nbsp:␣,precedes:«,extends:»

      " Briefly show matching braces, parenthesis, etc
      set showmatch

      " Better vertical separator
      set fillchars=vert:│

      " Always show status line
      set laststatus=2

      " Show line number relative to the current one, but show absolute number for the
      " current one
      set number
      set relativenumber

      " Highlight the cursor line
      set cursorline

      " Allow loading local .nvimrc files for custom configuration per project,
      " but disallow :autocmd in them
      set exrc
      set secure

      " Do not unload abandonned buffers, useful for Coc
      set hidden

      " Shorter time trigger for CursorHold (which makes coc-highlight show other uses
      " of the symbol currently under the cursor)
      set updatetime=1000

      " Disable concealing by default
      set conceallevel=0
      " }}}

      " Search options {{{

      " Ignore case on search
      set ignorecase

      " Ignore case unless there is an uppercase letter in the pattern
      set smartcase

      " Move cursor to the matched string
      set incsearch

      " Don't highlight matched strings
      set nohlsearch
      " }}}

      " Text formatting {{{
      " Set text width for automatic wrapping and highlighting of maximum column
      set textwidth=80
      " But don't automatically wrap text and comments to textwidth.
      set formatoptions-=tc
      " Also don't display lines longer than the screen wraped, make me scroll
      set nowrap
      " Color the column *after* textwidth
      set colorcolumn=+1
      " }}}

      " Persistent backups, undo files and cursor position {{{
      set backup
      set backupdir=~/.vimtmp/backup
      set directory=~/.vimtmp/temp//

      silent !mkdir -p ~/.vimtmp/backup
      silent !mkdir -p ~/.vimtmp/temp

      if version >= 703
      set undofile
      set undodir=~/.vimtmp/undo
      silent !mkdir -p ~/.vimtmp/undo
      endif

      " From the Vim wiki, restore cursor position
      " http://vim.wikia.com/wiki/Restore_cursor_to_file_position_in_previous_editing_session
      function! ResCur()
      if line("'\"") <= line("$")
        normal! g`"
        return 1
      endif
      endfunction

      augroup resCur
      autocmd!
      autocmd BufWinEnter * call ResCur()
      augroup END
      " }}}

      " Syntax highlighting {{{
      if has('syntax')
      " Add a rule to highlight trailing whitespaces on every colorscheme we load
      autocmd ColorScheme * highlight ExtraWhitespace ctermbg=darkgreen
      autocmd ColorScheme * match ExtraWhitespace /\s\+$/

      syntax enable

      " Truecolor handling
      set t_8f=[38;2;%lu;%lu;%lum
      set t_8b=[48;2;%lu;%lu;%lum
      set termguicolors

      " Colorscheme
      set background=dark
      let g:one_allow_italics=1
      colorscheme one
      let g:airline_theme='one'

      " Dim the default color for automatic inlay hints such as rust-analyzer's
      " type and chain hints
      hi CocHintSign ctermfg=12 guifg=#0b5963

      function! SwitchColorscheme()
        " Switch between a light and a dark colorscheme
        if &background ==# 'dark'
            set background=light
        else
            set background=dark
        endif
      endfunction
      noremap <F2> :call SwitchColorscheme()<CR>
      endif
      " }}}

      " Indentation options {{{

      " The display length of a tab character
      set tabstop=8

      " The number of spaces inserted when you press tab to indent with spaces
      set softtabstop=4

      " The number of spaces inserted/removed when using < or >
      set shiftwidth=4

      " Insert spaces instead of tabs
      set expandtab

      " When tabbing manually, use shiftwidth instead of tabstop and softtabstop
      set smarttab

      " Set basic indenting (i.e. copy the indentation of the previous line)
      " When filetype detection didn't find a fancy indentation scheme
      set autoindent

      " C indentation rules. See :help cinoptions-values for details
      set cinoptions=(0,u0,U0,t0,g0,N-s

      " }}}

      " Custom bindings {{{
      " English spelling
      noremap <F9> :setlocal spell spelllang=en<CR>
      " French spelling
      noremap <F10> :setlocal spell spelllang=fr<CR>

      " Binding to paste mode (might not be needed with the bracketed-paste plugin)
      noremap <F11> :set paste!<CR>
      inoremap <F11> <C-O>:set paste!<CR>

      " From Kalenz's Vim config: change pane with space key
      nnoremap <Space> <C-w>
      nnoremap <Space><Space> <C-w>w

      " From halfr's: save with space key
      nnoremap <Space><Return> :w<Return>
      nnoremap <Space><Backspace> :x<Return>

      " Bindings to save through sudo
      cnoreabbrev w!! w suda://%
      nmap <Space>! :w!!<Return>

      " Save and run make command on F5
      nnoremap <F5> :w<Return>:make<Return>

      " In addition to <leader>l and <leader>q from vim-togglelist, these bindings
      " jump to next and previous item in either list
      nnoremap <leader>nl :lnext<CR>
      nnoremap <leader>pl :lprev<CR>
      nnoremap <leader>nq :cnext<CR>
      nnoremap <leader>pq :cprev<CR>

      " One keystroke closer to command mode
      noremap ; :
      " More sensible yank bindings
      nnoremap Y y$
      " }}}
    '';
  };

  xdg.configFile."nvim/coc-settings.json".text = ''
      {
        "python.formatting.provider": "black",
        "python.linting.flake8Enabled": true,
        "python.pythonPath": "nvim-python3",

        "diagnostic.virtualText": true,
        "diagnostic.virtualTextPrefix": "  ~> ",

        "suggest.enablePreview": true,
        "suggest.enablePreselect": true,

        "codeLens.enable": true,
        "codeLens.separator": "‣",

        "highlight.colorNames.enable": false,

        "texlab.path": "${pkgs.texlab}/bin/texlab",

        "rust-analyzer.inlayHints.closureReturnTypeHints.enable": true,
        "rust-analyzer.server.path": "${pkgs.rust-analyzer}/bin/rust-analyzer",
        "rust-analyzer.updates.checkOnStartup": false,

        "languageserver": {
          "nix": {
              "command": "${pkgs.nixd}/bin/nixd",
              "filetypes": ["nix"]
          }
        }
      }
  '';

  # TODO: ideally find a way to dynamically change the vimtex command prefix
  # from <leader>l to <leader>x
  # TODO: this is using <leader> instead of the recommanded <localleader>
  xdg.configFile."nvim/ftplugin/tex.vim".text = ''
    ${mapleadersDefinitions}

    " Mappings from the vimtex plugin
    " start all mappings with 'x' instead of 'l'
    nmap <leader>xi  <plug>(vimtex-info)
    nmap <leader>xI  <plug>(vimtex-info-full)
    nmap <leader>xt  <plug>(vimtex-toc-open)
    nmap <leader>xT  <plug>(vimtex-toc-toggle)
    nmap <leader>xq  <plug>(vimtex-log)
    nmap <leader>xv  <plug>(vimtex-view)
    nmap <leader>xr  <plug>(vimtex-reverse-search)
    nmap <leader>xl  <plug>(vimtex-compile-ss)
    nmap <leader>xL  <plug>(vimtex-compile)
    nmap <leader>xk  <plug>(vimtex-stop)
    nmap <leader>xK  <plug>(vimtex-stop-all)
    nmap <leader>xe  <plug>(vimtex-errors)
    nmap <leader>xo  <plug>(vimtex-compile-output)
    nmap <leader>xg  <plug>(vimtex-status)
    nmap <leader>xG  <plug>(vimtex-status-all)
    nmap <leader>xc  <plug>(vimtex-clean)
    nmap <leader>xC  <plug>(vimtex-clean-full)
    nmap <leader>xm  <plug>(vimtex-imaps-list)
    nmap <leader>xx  <plug>(vimtex-reload)
    nmap <leader>xX  <plug>(vimtex-reload-state)
    nmap <leader>xs  <plug>(vimtex-toggle-main)
  '';
}
