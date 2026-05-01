# 🛠️ Emuladores de Utilitários Unix para Windows

> **16 utilitários UNIX independentes** escritos em [V](https://vlang.io/) — preenchendo a lacuna entre Windows e ambientes shell UNIX para agentes de IA e ferramentas de desenvolvimento.
>
> 🇺🇸 [Read in English](README.md)

![Tools](https://img.shields.io/badge/ferramentas-16-blue)
![Language](https://img.shields.io/badge/linguagem-V-5D87BF)
![Platform](https://img.shields.io/badge/plataforma-Windows-0078D6)
![Tests](https://img.shields.io/badge/testes-55+-green)

---

## Índice

- [Por Que Isso Existe](#por-que-isso-existe)
- [Início Rápido](#início-rápido)
- [Referência das Ferramentas](#referência-das-ferramentas)
  - [Listagem & Inspeção de Arquivos](#listagem--inspeção-de-arquivos)
  - [Conteúdo de Arquivos](#conteúdo-de-arquivos)
  - [Busca & Filtro](#busca--filtro)
  - [Operações com Arquivos](#operações-com-arquivos)
  - [Utilitários](#utilitários)
- [Política de Argumentos](#política-de-argumentos)
- [Testes](#testes)
- [Arquitetura](#arquitetura)
- [Compilação](#compilação)

---

## Por Que Isso Existe

O Windows não tem equivalentes nativos dos comandos UNIX padrão (`ls`, `grep`, `find`, etc.). Embora o PowerShell ofereça aliases, eles são incompatíveis com programas externos que esperam executáveis reais no `PATH`. Este projeto fornece **binários `.exe` independentes** que:

1. **Funcionam como executáveis reais** — podem ser chamados de qualquer shell, script ou ferramenta externa (ex: `rtk`, agentes de IA como Codex/Gemini)
2. **Retornam códigos de saída POSIX** — `0` para sucesso, `1` para nenhuma correspondência/erro, `2` para erros de uso
3. **Suportam flags comuns do GNU/UNIX** — implementando progressivamente as flags mais usadas
4. **Tratam caminhos do Windows** — normalização de barras invertidas e barras comuns, suporte a `PATHEXT`

---

## Início Rápido

### Pré-requisitos
- [Compilador V](https://vlang.io/) instalado e no PATH

### Compilar Tudo
```powershell
cd executables
.\build.bat
# ou
powershell -File .\build.ps1
```

### Compilar Uma Ferramenta
```powershell
cd executables\exe_ls
.\build.bat
```

Os binários são instalados em `c:\Users\andre\bin\`, que deve estar no seu `PATH`.

### Primeiro Uso
```powershell
ls -la .
grep -rn "TODO" ./src --include="*.v"
find . -iname "*.txt" -type f
cat -n arquivo.txt | head -n 20
sort dados.csv | uniq -c
```

---

## Referência das Ferramentas

### Listagem & Inspeção de Arquivos

#### `ls` — Lista o conteúdo de diretórios
```
ls [OPÇÕES] [ARQUIVO...]
```

| Flag | Descrição |
|------|-----------|
| `-a`, `--all` | Mostra arquivos ocultos (iniciando com `.`) |
| `-A`, `--almost-all` | Como `-a` mas exclui `.` e `..` |
| `-l`, `--long` | Formato longo com permissões, tamanho, data |
| `-h`, `--human-readable` | Tamanhos legíveis (1K, 234M, 2G) com `-l` |
| `--si` | Como `-h` mas usa potências de 1000 |
| `-r`, `--reverse` | Inverte a ordem de ordenação |
| `-R`, `--recursive` | Lista subdiretórios recursivamente |
| `-1`, `--one-line` | Um arquivo por linha |
| `-m`, `--commas` | Lista separada por vírgulas |
| `-S` | Ordena por tamanho (maior primeiro) |
| `-t` | Ordena por data de modificação (mais recente primeiro) |
| `-v` | Ordenação natural de versões (`arquivo2` antes de `arquivo10`) |
| `-X` | Ordena alfabeticamente por extensão |
| `-U` | Não ordena (ordem do diretório) |
| `-F`, `--classify` | Acrescenta indicador (`*/=>@|`) às entradas |
| `-p`, `--slash` | Acrescenta `/` aos diretórios |
| `--group-directories-first` | Agrupa diretórios antes dos arquivos |
| `-i`, `--inode` | Mostra número do inode |
| `-s`, `--size` | Mostra tamanho alocado em blocos |
| `-n`, `--numeric-uid-gid` | IDs numéricos de usuário/grupo |
| `-g`, `--no-owner` | Como `-l` mas oculta o proprietário |
| `-G`, `--no-group` | Oculta o grupo na listagem longa |
| `-o` | Como `-l` mas oculta o grupo |
| `-d`, `--directory` | Lista os próprios diretórios, não o conteúdo |
| `-Q`, `--quote-name` | Coloca nomes entre aspas duplas |
| `-b`, `--escape` | Escape estilo C para caracteres não gráficos |
| `--color=QUANDO` | Coloriza a saída (`always`, `auto`, `never`) |
| `--time-style=ESTILO` | Formato de hora (`full-iso`, `long-iso`, `iso`, `locale`) |
| `--full-time` | Como `-l --time-style=full-iso` |
| `-u` | Ordena/mostra hora de acesso |
| `-c` | Ordena/mostra hora de mudança de status |

---

#### `pwd` — Mostra o diretório de trabalho atual
```
pwd [OPÇÕES]
```

| Flag | Descrição |
|------|-----------|
| `-L` | Usa PWD do ambiente (padrão) |
| `-P` | Resolve todos os links simbólicos (stub) |

Produz caminhos com barra comum para compatibilidade UNIX.

---

#### `which` — Localiza um comando
```
which [OPÇÕES] COMANDO...
```

| Flag | Descrição |
|------|-----------|
| `-a`, `--all` | Mostra todos os caminhos correspondentes |

Busca nos diretórios do `PATH` e respeita `PATHEXT` no Windows.

---

### Conteúdo de Arquivos

#### `cat` — Concatena e exibe arquivos
```
cat [OPÇÕES] [ARQUIVO...]
```

| Flag | Descrição |
|------|-----------|
| `-n`, `--number` | Numera todas as linhas de saída |
| `-b`, `--number-nonblank` | Numera apenas linhas não vazias (substitui `-n`) |
| `-s`, `--squeeze-blank` | Suprime linhas vazias repetidas |
| `-E`, `--show-ends` | Exibe `$` no final de cada linha |
| `-T`, `--show-tabs` | Exibe TAB como `^I` |
| `-A`, `--show-all` | Equivalente a `-vET` |

Lê da stdin quando nenhum arquivo é especificado ou o arquivo é `-`.

---

#### `head` — Exibe a primeira parte dos arquivos
```
head [OPÇÕES] [ARQUIVO...]
```

| Flag | Descrição |
|------|-----------|
| `-n K`, `--lines=K` | Exibe as primeiras K linhas (padrão: 10) |
| `-c K`, `--bytes=K` | Exibe os primeiros K bytes |
| `-v`, `--verbose` | Sempre mostra cabeçalhos com nome do arquivo |
| `-q`, `--quiet` | Nunca mostra cabeçalhos com nome do arquivo |

---

#### `tail` — Exibe a última parte dos arquivos
```
tail [OPÇÕES] [ARQUIVO...]
```

| Flag | Descrição |
|------|-----------|
| `-n K`, `--lines=K` | Exibe as últimas K linhas (padrão: 10) |
| `-f`, `--follow` | Exibe dados anexados conforme o arquivo cresce |
| `-s N`, `--sleep-interval=N` | Aguarda N segundos entre iterações do follow |
| `-v`, `--verbose` | Sempre mostra cabeçalhos com nome do arquivo |
| `-q`, `--quiet` | Nunca mostra cabeçalhos com nome do arquivo |

> **Performance**: Usa abordagem seek-from-end — suporta arquivos de múltiplos GB sem carregá-los na memória.

---

### Busca & Filtro

#### `grep` — Busca por padrões em arquivos
```
grep [OPÇÕES] PADRÃO [ARQUIVO...]
```

| Flag | Descrição |
|------|-----------|
| `-i`, `--ignore-case` | Ignora diferenças entre maiúsculas e minúsculas |
| `-v`, `--invert-match` | Seleciona linhas que NÃO correspondem |
| `-n`, `--line-number` | Mostra números de linha |
| `-c`, `--count` | Mostra apenas a contagem de correspondências por arquivo |
| `-l`, `--files-with-matches` | Mostra apenas nomes de arquivos com correspondências |
| `-L`, `--files-without-matches` | Mostra apenas nomes de arquivos sem correspondências |
| `-r`, `-R`, `--recursive` | Busca em diretórios recursivamente |
| `-w`, `--word-regexp` | Corresponde apenas palavras inteiras |
| `-x`, `--line-regexp` | Corresponde apenas linhas inteiras |
| `-F`, `--fixed-strings` | Trata o padrão como string literal |
| `-o`, `--only-matching` | Mostra apenas a parte correspondente das linhas |
| `-H`, `--with-filename` | Mostra nome do arquivo na saída |
| `-h`, `--no-filename` | Suprime o prefixo do nome do arquivo |
| `-A N`, `--after-context=N` | Mostra N linhas após cada correspondência |
| `-B N`, `--before-context=N` | Mostra N linhas antes de cada correspondência |
| `-C N`, `--context=N` | Mostra N linhas de contexto (antes + depois) |
| `-m N`, `--max-count=N` | Para após N correspondências por arquivo |
| `-q`, `--quiet` | Suprime toda a saída |
| `-s`, `--silent` | Suprime mensagens de erro |
| `--color=QUANDO` | Coloriza correspondências (`always`, `auto`, `never`) |
| `--exclude=GLOB` | Pula arquivos que correspondem ao GLOB |
| `--exclude-dir=DIR` | Pula diretórios que correspondem a DIR |
| `--include=GLOB` | Busca apenas arquivos que correspondem ao GLOB |

> **Performance**: Detecta automaticamente padrões literais para evitar o engine de regex, buffer circular para linhas de contexto (O(1) vs O(n) para before-context), exclui automaticamente `node_modules`/`.git`/`vendor`/etc em scans recursivos, travessia de diretórios baseada em BFS iterativo.

---

#### `find` — Busca arquivos na hierarquia de diretórios
```
find [CAMINHO...] [OPÇÕES]
```

| Flag | Descrição |
|------|-----------|
| `-name PADRÃO` | Corresponde nome do arquivo (glob sensível a maiúsculas) |
| `-iname PADRÃO` | Corresponde nome do arquivo (glob insensível a maiúsculas) |
| `-type TIPO` | Filtra por tipo (`f` = arquivo, `d` = diretório) |
| `-empty` | Corresponde arquivos/diretórios vazios |
| `-maxdepth N` | Desce no máximo N níveis |
| `-delete` | Exclui arquivos correspondentes |
| `-o`, `-or` | Operador OR entre grupos de filtros |

Suporta combinar múltiplos filtros com `-o` (lógica OR). Padrões glob usam `*` e `?`.

> **Performance**: Padrões regex são pré-compilados uma vez na inicialização, não por arquivo.

---

#### `sort` — Ordena linhas de arquivos de texto
```
sort [OPÇÕES] [ARQUIVO...]
```

| Flag | Descrição |
|------|-----------|
| `-r`, `--reverse` | Inverte a ordem de ordenação |
| `-n`, `--numeric-sort` | Compara por valor numérico |
| `-u`, `--unique` | Exibe apenas linhas únicas |

---

#### `uniq` — Filtra linhas duplicadas adjacentes
```
uniq [OPÇÕES] [ENTRADA [SAÍDA]]
```

| Flag | Descrição |
|------|-----------|
| `-c`, `--count` | Prefixa linhas com contagem de ocorrências |
| `-d`, `--repeated` | Exibe apenas linhas duplicadas |
| `-u`, `--unique` | Exibe apenas linhas únicas |
| `-i`, `--ignore-case` | Comparação insensível a maiúsculas/minúsculas |

---

### Operações com Arquivos

#### `cp` — Copia arquivos e diretórios
```
cp [OPÇÕES] ORIGEM... DESTINO
```

| Flag | Descrição |
|------|-----------|
| `-r`, `-R`, `--recursive` | Copia diretórios recursivamente |
| `-f`, `--force` | Força sobrescrita |
| `-i`, `--interactive` | Pergunta antes de sobrescrever |
| `-n`, `--no-clobber` | Não sobrescreve arquivos existentes |
| `-v`, `--verbose` | Explica o que está sendo feito |

---

#### `mv` — Move/renomeia arquivos
```
mv [OPÇÕES] ORIGEM... DESTINO
```

| Flag | Descrição |
|------|-----------|
| `-f`, `--force` | Não pergunta antes de sobrescrever |
| `-i`, `--interactive` | Pergunta antes de sobrescrever |
| `-n`, `--no-clobber` | Não sobrescreve arquivos existentes |
| `-v`, `--verbose` | Explica o que está sendo feito |

---

#### `rm` — Remove arquivos e diretórios
```
rm [OPÇÕES] ARQUIVO...
```

| Flag | Descrição |
|------|-----------|
| `-r`, `-R`, `--recursive` | Remove diretórios recursivamente |
| `-f`, `--force` | Ignora arquivos inexistentes, nunca pergunta |
| `-i`, `--interactive` | Pergunta antes de cada remoção |
| `-v`, `--verbose` | Explica o que está sendo feito |
| `-d`, `--dir` | Remove diretórios vazios |

---

#### `mkdir` — Cria diretórios
```
mkdir [OPÇÕES] DIRETÓRIO...
```

| Flag | Descrição |
|------|-----------|
| `-p`, `--parents` | Cria diretórios pai conforme necessário |
| `-v`, `--verbose` | Mostra mensagem para cada diretório criado |

---

#### `touch` — Atualiza timestamps de arquivos
```
touch [OPÇÕES] ARQUIVO...
```

| Flag | Descrição |
|------|-----------|
| `-c`, `--no-create` | Não cria nenhum arquivo |
| `-a` | Altera apenas a hora de acesso |
| `-m` | Altera apenas a hora de modificação |

---

### Utilitários

#### `xargs` — Constrói e executa comandos a partir da stdin
```
xargs [OPÇÕES] [COMANDO [ARGS...]]
```

| Flag | Descrição |
|------|-----------|
| `-0`, `--null` | Itens de entrada separados por NUL (para `find -print0`) |
| `-I SUBSTITUIR` | Substitui SUBSTITUIR nos args por cada item de entrada |
| `-n MAX` | Usa no máximo MAX argumentos por comando |
| `-t`, `--verbose` | Mostra comandos antes da execução |
| `-r`, `--no-run-if-empty` | Não executa comando se a stdin estiver vazia |

**Exemplos:**
```bash
find . -name "*.txt" | xargs grep "TODO"
find . -print0 | xargs -0 wc -l
echo arquivo1 arquivo2 | xargs -I {} cp {} /backup/
ls *.log | xargs -n 2 echo "Lote:"
```

---

## Política de Argumentos

Para qualquer flag que **ainda não foi implementada**, as ferramentas retornam uma mensagem de erro padronizada:

```
TODO (UNIX WINDOWS): THIS ARGUMENT HAS NOT YET BEEN IMPLEMENTED.
USE AN ALTERNATIVE METHOD, AS THE "ls" COMMAND DOES NOT YET HAVE THIS ARGUMENT "-la".
```

Esta mensagem foi projetada para que agentes de IA possam entender e usar abordagens alternativas.

---

## Testes

Cada ferramenta possui testes de integração no diretório `tests/`:

```powershell
# Executar testes de uma ferramenta específica
cd executables\exe_grep
v test tests/

# Executar todos os testes
Get-ChildItem -Directory exe_* | ForEach-Object {
    Write-Host "Testando $($_.Name)..."
    Push-Location $_.FullName
    v test tests/
    Pop-Location
}
```

Os testes usam `os.execute()` para executar o binário compilado e verificar códigos de saída e conteúdo da saída. Novas funcionalidades e otimizações exigem novos testes — veja [AGENTS.md](AGENTS.MD) para a política completa de testes.

---

## Arquitetura

```
executables/
├── AGENTS.MD          # Documentação voltada para agentes e política de testes
├── README.md          # Este arquivo (inglês)
├── README.pt-br.md    # Versão em português brasileiro
├── build.ps1          # Compila todas as ferramentas
├── build.bat          # Wrapper para build.ps1
├── exe_ls/            # Cada ferramenta em seu próprio diretório
│   ├── main.v         # Ponto de entrada e parsing de argumentos
│   ├── lister.v       # Lógica principal (listagem de diretórios)
│   ├── filedata.v     # Estruturas de dados
│   ├── options.v      # Struct de opções
│   ├── utils.v        # Funções utilitárias
│   ├── build.bat      # Script de compilação individual
│   └── tests/
│       └── ls_test.v  # Testes de integração
├── exe_grep/
│   ├── main.v
│   ├── matcher.v      # Engine de correspondência regex/string fixa
│   ├── processor.v    # Processamento de arquivos e saída
│   ├── filters.v      # Tratamento de --exclude/--include
│   ├── options.v
│   └── tests/
│       ├── grep_test.v
│       ├── context_test.v
│       ├── exclude_test.v
│       ├── literal_test.v
│       └── autoexclude_test.v
└── ...                # Mais 14 ferramentas seguindo o mesmo padrão
```

### Convenções

- **Nomeação de diretórios**: `exe_<comando>` (ex: `exe_ls`, `exe_grep`)
- **Saída da compilação**: Cada `build.bat` compila para `../../<comando>.exe` (a raiz do `bin/`)
- **Flags de compilação**: Todas as compilações usam `-prod` para binários otimizados
- **Módulo**: Todos os arquivos usam `module main`
- **Opções**: Analisadas com o módulo `flag` do V, armazenadas em uma struct `Options`

---

## Compilação

### Uma Ferramenta
```powershell
cd executables\exe_ls
v -prod -o "..\..\ls.exe" .
```

### Todas as Ferramentas
```powershell
cd executables
.\build.ps1
```

### Desenvolvimento (rápido, sem otimizações)
```powershell
cd executables\exe_ls
v -o "..\..\ls.exe" .
```

---

## Licença

Ferramenta interna — parte do ecossistema `rtk`.
