/**
 * Language: Elisp
 * Author: Martin Sosic, based on Vasily Polovnyov <vast@whiteants.net>'s lisp.
 */
function hljsElisp(hljs) {
  const ELISP_IDENT_RE = '[a-zA-Z_\\-+\\*\\/<=>&#][a-zA-Z0-9_\\-+*\\/<=>&#!]*';
  const MEC_RE = '\\|[^]*?\\|';
  const ELISP_SIMPLE_NUMBER_RE = '(-|\\+)?\\d+(\\.\\d+|\\/\\d+)?((d|e|f|l|s|D|E|F|L|S)(\\+|-)?\\d+)?';
  const LITERAL = {
    className: 'literal',
    begin: '\\b(t{1}|nil)\\b'
  };
  const NUMBER = {
    className: 'number',
    variants: [
      {
        begin: ELISP_SIMPLE_NUMBER_RE,
        relevance: 0
      },
      { begin: '#(b|B)[0-1]+(/[0-1]+)?' },
      { begin: '#(o|O)[0-7]+(/[0-7]+)?' },
      { begin: '#(x|X)[0-9a-fA-F]+(/[0-9a-fA-F]+)?' },
      {
        begin: '#(c|C)\\(' + ELISP_SIMPLE_NUMBER_RE + ' +' + ELISP_SIMPLE_NUMBER_RE,
        end: '\\)'
      }
    ]
  };
  const STRING = hljs.inherit(hljs.QUOTE_STRING_MODE, { illegal: null });
  const COMMENT = hljs.COMMENT(
    ';', '$',
    { relevance: 0 }
  );
  const VARIABLE = {
    begin: '\\*',
    end: '\\*'
  };
  const KEYWORD = {
    className: 'symbol',
    begin: '[:&]' + ELISP_IDENT_RE
  };
  const IDENT = {
    begin: ELISP_IDENT_RE,
    relevance: 0
  };
  const MEC = { begin: MEC_RE };
  const QUOTED_LIST = {
    begin: '\\(',
    end: '\\)',
    contains: [
      'self',
      COMMENT,
      LITERAL,
      STRING,
      NUMBER,
      KEYWORD,
      IDENT
    ]
  };
  const QUOTED = {
    contains: [
      COMMENT,
      NUMBER,
      STRING,
      VARIABLE,
      KEYWORD,
      QUOTED_LIST,
      IDENT
    ],
    variants: [
      {
        begin: '[\'`]\\(',
        end: '\\)'
      },
      {
        begin: '\\(quote ',
        end: '\\)',
        keywords: { name: 'quote' }
      },
      { begin: '\'' + MEC_RE }
    ]
  };
  const QUOTED_ATOM = { variants: [
    { begin: '\'' + ELISP_IDENT_RE },
    { begin: '#\'' + ELISP_IDENT_RE + '(::' + ELISP_IDENT_RE + ')*' }
  ] };
  const LIST = {
    begin: '\\(\\s*',
    end: '\\)'
  };
  const BODY = {
    endsWithParent: true,
    relevance: 0
  };
  LIST.contains = [
    {
      className: 'name',
      variants: [
        {
          begin: ELISP_IDENT_RE,
          relevance: 0,
        },
        { begin: MEC_RE }
      ]
    },
    BODY
  ];
  BODY.contains = [
    QUOTED,
    QUOTED_ATOM,
    LIST,
    LITERAL,
    NUMBER,
    STRING,
    COMMENT,
    VARIABLE,
    KEYWORD,
    MEC,
    IDENT
  ];

  return {
    name: 'Elisp',
    illegal: /\S/,
    contains: [
      NUMBER,
      hljs.SHEBANG(),
      LITERAL,
      STRING,
      COMMENT,
      QUOTED,
      QUOTED_ATOM,
      LIST,
      IDENT
    ]
  };
};

if (typeof module !== 'undefined') {
  module.exports = hljsElisp;
}
