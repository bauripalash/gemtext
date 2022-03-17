module gemtext

const (
	version      = '0.0.1'

	l_list       = '* '
	l_blockquote = '> '
	l_h1         = '# '
	l_h2         = '## '
	l_h3         = '### '
	l_link       = '=> '
	l_preftext   = '```'
)

pub fn get_version() string {
	return version
}

// Gemtext token types

struct T_PlainText {
	text string
}

struct T_Link {
	link string
	text string
}

struct T_Heading {
	level int
	text  string
}

struct T_List {
	text string
}

struct T_Blockquote {
	text string
}

struct T_PrefText {
	alt  string
	text string
}

struct T_EmptyLine {}

type GemtextToken = T_Blockquote
	| T_EmptyLine
	| T_Heading
	| T_Link
	| T_List
	| T_PlainText
	| T_PrefText

pub struct GemScanner {
pub mut:
	source string         [required]
	tokens []GemtextToken
}

pub fn new_scanner(source string) &GemScanner {
	return &GemScanner{
		source: source
		tokens: []GemtextToken{}
	}
}

pub fn (mut s GemScanner) parse() {
	mut inside_preftext := false
	mut pref_text_alt := ''
	mut pref_text_string := ''

	for line in s.source.split_into_lines() {
		if !inside_preftext {
			mut tok := GemtextToken(T_EmptyLine{})
			mut trimmed := line.trim('\t').trim(' ')

			if trimmed.starts_with(l_list) {
				tok = GemtextToken(T_List{
					text: trimmed.trim_string_left(l_list)
				})
				// s.tokens << tok
			} else if trimmed.starts_with(l_blockquote) {
				tok = GemtextToken(T_Blockquote{
					text: trimmed.trim_string_left(l_blockquote)
				})
			} else if trimmed.starts_with(l_h3) {
				tok = GemtextToken(T_Heading{
					level: 3
					text: trimmed.trim_string_left(l_h3)
				})
			} else if trimmed.starts_with(l_h2) {
				tok = GemtextToken(T_Heading{
					level: 2
					text: trimmed.trim_string_left(l_h2)
				})
			} else if trimmed.starts_with(l_h1) {
				tok = GemtextToken(T_Heading{
					level: 1
					text: trimmed.trim_string_left(l_h1)
				})
			} else if trimmed.starts_with(l_link) {
				link_alt := trimmed.trim_string_left(l_link).split(' ')
				if link_alt.len == 2 && link_alt[1].len > 0 {
					tok = GemtextToken(T_Link{
						link: link_alt[0]
						text: link_alt[1]
					})
				} else {
					tok = GemtextToken(T_Link{
						link: link_alt[0]
						text: ''
					})
				}
			} else if trimmed.starts_with(l_preftext) {
				inside_preftext = true
				pref_text_alt = trimmed.trim_string_left(l_preftext)
				continue
			} else if trimmed.len > 0 {
				tok = GemtextToken(T_PlainText{
					text: trimmed
				})
			}

			s.tokens << tok
		} else {
			trim := line.trim('\t').trim(' ')
			if trim.starts_with(l_preftext) {
				s.tokens << GemtextToken(T_PrefText{
					alt: pref_text_alt
					text: pref_text_string
				})
				pref_text_string = ''
				pref_text_alt = ''
				inside_preftext = false
			} else {
				pref_text_string += line
				pref_text_string += '\n'
			}
		}
	}
}

pub fn (s GemScanner) html() string {
	mut output := ''
	for item in s.tokens {
		match item {
			T_PlainText {
				output += '<p>$item.text</p>\n'
			}
			T_Heading {
				output += '<h$item.level>$item.text</h$item.level>\n'
			}
			T_List {
				output += '<li>$item.text</li>\n'
			}
			T_Blockquote {
				output += '<blockquote>$item.text</blockquote>\n'
			}
			T_Link {
				mut tmp := ''
				if item.text.len > 0 {
					tmp = '<a href="$item.link">$item.text</a>'
				} else {
					tmp += '<a href="$item.link">$item.link<a>'
				}
				output += '$tmp\n</br>'
			}
			T_PrefText {
				mut tmp := ''
				if item.alt.len > 0 {
					tmp = '<pre class="$item.alt">'
				} else {
					tmp = '<pre>'
				}
				output += tmp + '\n' + item.text + '</pre>\n'
			}
			T_EmptyLine {
				output += '</br>\n'
			}
		}
	}
	return output
}

fn main() {
	src := '* text one
	> hello world
	* another one
	# header 1
	## header 2
	### d 
	plain text hello
	mew mew

	bingo
	=> https://google.com
	=> https://palashbauri.in my_website
	```myalt
	youhuu
```

	```
	mewme
	dfjdhfjsd
	## hello
	```
	'

	mut myscanner := new_scanner(src)
	myscanner.parse()
	println(myscanner.html())
}
