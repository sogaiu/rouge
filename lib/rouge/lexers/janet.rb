# -*- coding: utf-8 -*- #
# frozen_string_literal: true

module Rouge
  module Lexers
    class Janet < RegexLexer
      title "Janet"
      desc "The Janet programming language (janet-lang.org)"

      tag 'janet'
      aliases 'janet'

      filenames '*.janet', '*.jdn'

      mimetypes 'text/x-janet', 'application/x-janet'

      def self.specials
        @specials ||= Set.new %w(
          break def do fn if quote quasiquote splice set unquote var while
        )
      end

      def self.bundled
        @bundled ||= Set.new %w(
          % %= * *= + ++ += - -- -= -> ->> -?> -?>> / /= < <= = > >=
          abstract? accumulate accumulate2 all all-bindings
          all-dynamics and apply array array/concat array/ensure
          array/fill array/insert array/new array/new-filled
          array/peek array/pop array/push array/remove array/slice
          array? as-> as?-> asm assert bad-compile bad-parse band
          blshift bnot boolean? bor brshift brushift buffer buffer/bit
          buffer/bit-clear buffer/bit-set buffer/bit-toggle
          buffer/blit buffer/clear buffer/fill buffer/format
          buffer/new buffer/new-filled buffer/popn buffer/push-byte
          buffer/push-string buffer/push-word buffer/slice buffer?
          bxor bytes? case cfunction? chr cli-main comment comp
          compare compare= compare< compare<= compare> compare>=
          compile complement comptime cond coro count debug
          debug/arg-stack debug/break debug/fbreak debug/lineage
          debug/stack debug/stacktrace debug/step debug/unbreak
          debug/unfbreak debugger-env dec deep-not= deep= default
          default-peg-grammar def- defer defmacro defmacro- defn defn-
          defglobal describe dictionary? disasm distinct doc doc*
          doc-format dofile drop drop-until drop-while dyn each eachk
          eachp eachy edefer eflush empty? env-lookup eprin eprinf
          eprint eprintf error errorf eval eval-string even? every?
          extreme false? fiber/can-resume? fiber/current fiber/getenv
          fiber/maxstack fiber/new fiber/root fiber/setenv
          fiber/setmaxstack fiber/status fiber? file/close file/flush
          file/open file/popen file/read file/seek file/temp
          file/write filter find find-index first flatten flatten-into
          flush for forv freeze frequencies function? gccollect
          gcinterval gcsetinterval generate gensym get get-in getline
          hash idempotent? identity import import* if-let if-not
          if-with in inc indexed? int/s64 int/u64 int? interleave
          interpose invert janet/build janet/config-bits janet/version
          juxt juxt* keep keys keyword keyword? kvs label last length
          let load-image load-image-dict loop macex macex1 make-env
          make-image make-image-dict map mapcat marshal math/-inf
          math/abs math/acos math/acosh math/asin math/asinh math/atan
          math/atan2 math/atanh math/cbrt math/ceil math/cos math/cosh
          math/e math/erf math/erfc math/exp math/exp2 math/expm1
          math/floor math/gamma math/hypot math/inf math/log
          math/log10 math/log1p math/log2 math/next math/pi math/pow
          math/random math/rng math/rng-buffer math/rng-int
          math/rng-uniform math/round math/seedrandom math/sin
          math/sinh math/sqrt math/tan math/tanh math/trunc match max
          mean merge merge-into min mod module/add-paths module/cache
          module/expand-path module/find module/loaders module/loading
          module/paths nan? nat? native neg? net/chunk net/close
          net/connect net/read net/server net/write next nil? not not=
          number? odd? one? or os/arch os/cd os/chmod os/clock
          os/cryptorand os/cwd os/date os/dir os/environ os/execute
          os/exit os/getenv os/link os/lstat os/mkdir os/mktime
          os/perm-int os/perm-string os/readlink os/realpath os/rename
          os/rm os/rmdir os/setenv os/shell os/sleep os/stat
          os/symlink os/time os/touch os/umask os/which pairs parse
          parser/byte parser/clone parser/consume parser/eof
          parser/error parser/flush parser/has-more parser/insert
          parser/new parser/produce parser/state parser/status
          parser/where partial partition peg/compile peg/match pos?
          postwalk pp prewalk prin prinf print printf product prompt
          propagate protect put put-in quit range reduce reduce2
          repeat repl require resume return reverse reversed root-env
          run-context scan-number seq setdyn shortfn signal slice
          slurp some sort sort-by sorted sorted-by spit stderr stdin
          stdout string string/ascii-lower string/ascii-upper
          string/bytes string/check-set string/find string/find-all
          string/format string/from-bytes string/has-prefix?
          string/has-suffix? string/join string/repeat string/replace
          string/replace-all string/reverse string/slice string/split
          string/trim string/triml string/trimr string? struct struct?
          sum symbol symbol? table table/clone table/getproto
          table/new table/rawget table/setproto table/to-struct table?
          take take-until take-while tarray/buffer tarray/copy-bytes
          tarray/length tarray/new tarray/properties tarray/slice
          tarray/swap-bytes thread/close thread/current thread/new
          thread/receive thread/send trace tracev true? truthy? try
          tuple tuple/brackets tuple/setmap tuple/slice
          tuple/sourcemap tuple/type tuple? type unless unmarshal
          untrace update update-in use values var- varfn varglobal
          walk walk-ind walk-dict when when-let when-with with
          with-dyns with-syms with-vars yield zero? zipcoll
        )
      end

      # XXX: from janet.vim !$%&*+-./:<=>?@A-Z^_a-z
      # XXX: reduce repetition somehow?
      symbol = %r([!$%&*+./<=>?@^_A-Za-z-][!$%&*+./:<=>?@^_A-Za-z0-9-]*)
      keyword = %r(:[!$%&*+./:<=>?@^_A-Za-z0-9-]+)

      def name_token(name)
        return Keyword if self.class.specials.include?(name)
        return Name::Builtin if self.class.bundled.include?(name)
        nil
      end

      state :root do
        rule %r/#.*?$/, Comment::Single
        rule %r/\s+/m, Text::Whitespace

        # exactly where underscores can go is not regular
        # not going to try to restrict initial number to be between 2 and 36
        rule %r/[+-]?\d+r[0-9a-zA-Z][0-9a-zA-Z_]*(&[+-]?[0-9a-zA-Z]+)?/, Num::Float
        rule %r/[+-]?0x[0-9a-fA-F][_0-9a-fA-F]*(\.[0-9a-fA-F_]+)?/, Num::Hex
        # this covers integers as well
        rule %r/[+-]?\d[\d_]*(\.[\d_]+)?([eE][+-]?\d+)?/, Num::Float
        rule %r/[+-]?\.\d[\d_]*([eE][+-]?\d+)?/, Num::Float

        rule %r/@?"(\\.|[^"])*"/, Str
        rule %r/@?(`+).*?\1/m, Str::Heredoc

        rule %r/true|false|nil/, Name::Constant
        rule %r/'#{symbol}/, Str::Symbol
        rule %r/#{keyword}/, Name::Constant

        rule %r/[\'#~,;\|]/, Operator

        rule %r/(\()(\s*)(#{symbol})/m do |m|
          token Punctuation, m[1]
          token Text::Whitespace, m[2]
          token(name_token(m[3]) || Name::Function, m[3])
        end

        rule symbol do |m|
          token name_token(m[0]) || Name
        end

        # tuples (and arrays if preceded by @)
        rule %r/[\[\]]/, Punctuation

        # structs (and tables if preceded by @)
        rule %r/[{}]/, Punctuation

        # tuples
        rule %r/[()]/, Punctuation
      end
    end
  end
end
