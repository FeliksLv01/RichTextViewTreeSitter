import Foundation

public enum RichTreeSitterLanguageSupport: Equatable, Sendable {
    case treeSitter(canonicalLanguage: String)
    case plainTextCompatible
    case unknown
}

public enum RichTreeSitterLanguageCatalog {
    public static let highlightJSIdentifiers: Set<String> = Set(highlightJSIdentifierSource.split(separator: "\n").map(String.init))

    public static func canonicalIdentifier(for identifier: String) -> String {
        let normalized = identifier.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return aliases[normalized] ?? normalized
    }

    public static func support(
        for identifier: String,
        registry: RichTreeSitterLanguageRegistry = .standard
    ) -> RichTreeSitterLanguageSupport {
        if let language = registry.language(for: identifier) {
            return .treeSitter(canonicalLanguage: language.canonicalIdentifier)
        }
        let normalized = identifier.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return highlightJSIdentifiers.contains(normalized) ? .plainTextCompatible : .unknown
    }

    public static let aliases: [String: String] = [
        "1c": "bsl",
        "armasm": "asm",
        "avrasm": "asm",
        "capnproto": "capnp",
        "clojure-repl": "clojure",
        "delphi": "pascal",
        "django": "htmldjango",
        "dos": "batch",
        "dts": "devicetree",
        "erb": "embeddedtemplate",
        "erlang-repl": "erlang",
        "gradle": "groovy",
        "irpf90": "fortran",
        "julia-repl": "julia",
        "lisp": "commonlisp",
        "makefile": "make",
        "mathematica": "wolfram",
        "mipsasm": "asm",
        "mojolicious": "perl",
        "node-repl": "javascript",
        "objectivec": "objc",
        "pgsql": "postgres",
        "php-template": "php",
        "processing": "java",
        "protobuf": "proto",
        "python-repl": "python",
        "qml": "qmljs",
        "reasonml": "reason",
        "shell": "bash",
        "vbnet": "vb",
        "vbscript": "vb",
        "vbscript-html": "html",
        "wasm": "wat",
        "x86asm": "asm",
        "zephir": "php"
    ]

    private static let highlightJSIdentifierSource = """
    1c
    abnf
    accesslog
    actionscript
    ada
    angelscript
    apache
    applescript
    arcade
    arduino
    armasm
    asciidoc
    aspectj
    autohotkey
    autoit
    avrasm
    awk
    axapta
    bash
    basic
    bnf
    brainfuck
    c
    cal
    capnproto
    ceylon
    clean
    clojure
    clojure-repl
    cmake
    coffeescript
    coq
    cos
    cpp
    crmsh
    crystal
    csharp
    csp
    css
    d
    dart
    delphi
    diff
    django
    dns
    dockerfile
    dos
    dsconfig
    dts
    dust
    ebnf
    elixir
    elm
    erb
    erlang
    erlang-repl
    excel
    fix
    flix
    fortran
    fsharp
    gams
    gauss
    gcode
    gherkin
    glsl
    gml
    go
    golo
    gradle
    graphql
    groovy
    haml
    handlebars
    haskell
    haxe
    hsp
    http
    hy
    inform7
    ini
    irpf90
    isbl
    java
    javascript
    jboss-cli
    json
    julia
    julia-repl
    kotlin
    lasso
    latex
    ldif
    leaf
    less
    lisp
    livecodeserver
    livescript
    llvm
    lsl
    lua
    makefile
    markdown
    mathematica
    matlab
    maxima
    mel
    mercury
    mipsasm
    mizar
    mojolicious
    monkey
    moonscript
    n1ql
    nestedtext
    nginx
    nim
    nix
    node-repl
    nsis
    objectivec
    ocaml
    openscad
    oxygene
    parser3
    perl
    pf
    pgsql
    php
    php-template
    plaintext
    pony
    powershell
    processing
    profile
    prolog
    properties
    protobuf
    puppet
    purebasic
    python
    python-repl
    q
    qml
    r
    reasonml
    rib
    roboconf
    routeros
    rsl
    ruby
    ruleslanguage
    rust
    sas
    scala
    scheme
    scilab
    scss
    shell
    smali
    smalltalk
    sml
    sqf
    sql
    stan
    stata
    step21
    stylus
    subunit
    swift
    taggerscript
    tap
    tcl
    thrift
    tp
    twig
    typescript
    vala
    vbnet
    vbscript
    vbscript-html
    verilog
    vhdl
    vim
    wasm
    wren
    x86asm
    xl
    xml
    xquery
    yaml
    zephir
    """
}
