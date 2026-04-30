/**
 * highlight.js grammar for directory tree listings.
 * Author: Martin Sosic.
 *
 * Example of dir tree listing formats for which this highlighting will work nicely:
 * foo/
 * ├── bar/
 * │   ├── buzz.txt # Some file.
 * │   └── fizz/fuzz.sh
 * └── README.md
 *
 * or just:
 * foo/
 *   bar/
 *     buzz.txt # Some file.
 *     fizz/fuzz.sh
 *   README.md
 */
function hljsDirTree(_hljs) {
  return {
    name: 'Dir tree',
    contains: [
      // Comment: # till end of line.
      {
        match: /#.*/,
        className: 'comment'
      },
      // Box-drawing characters: must be a sequence at the start of a line (with optional leading or
      // interjecting whitespace).
      {
        match: /^\s*[├└│─╭╰┌┐┘┤┬┴┼╮╯╰╭ ]+/,
        className: 'comment'
      },
      // Directory name: must end with /.
      {
        match: /.*\//,
        className: 'section'
      }
    ]
  };
};

if (typeof module !== 'undefined') {
  module.exports = hljsDirTree;
}
