/**
 * highlight.js grammar for ascii diagrams.
 * Author: Martin Sosic.
 */
function hljsAsciiDiagram(_hljs) {
  return {
    name: 'Ascii diagram',
    contains: [
      { // Horizontal lines.
        match: /(?<=^|\s)[-+=<>#|~/\\]{3,}(?=$|\s)/,
        className: 'symbol'
      },
      { // Vertical lines.
        match: /(?<=^|\s)[|vV^#](?=$|\s)/,
        className: 'symbol'
      }
    ]
  };
};

if (typeof module !== 'undefined') {
  module.exports = hljsAsciiDiagram;
}
