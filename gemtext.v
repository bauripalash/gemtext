module main

const (
	version = '0.0.1'
)

pub fn get_version() string {
	return version
}


const (
	
	l_list = "* "
	l_blockquote = "> "

)

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

type GemtextToken = T_Blockquote | T_Heading | T_Link | T_List | T_PlainText | T_PrefText | T_EmptyLine

pub struct GemScanner{

pub mut:
	source string [required]
	tokens []GemtextToken

}

pub fn new_scanner(source string) &GemScanner{
	
	return &GemScanner{source:source, tokens:[]GemtextToken{}}

}

pub fn (mut s GemScanner) parse(){
	mut inside_preftext := false

	
	for line in s.source.split_into_lines(){
		
		if !inside_preftext{
			
			mut tok := GemtextToken(T_EmptyLine{})
			mut trimmed := line.trim(" ")

			if trimmed.starts_with(l_list){
				tok = GemtextToken(T_List{text:trimmed.trim_string_left(l_list)})
				//s.tokens << tok
			}else if trimmed.starts_with(l_blockquote){
				
				tok = GemtextToken(T_Blockquote{text:trimmed.trim_string_left(l_blockquote)})
				

			}
			
			s.tokens << tok


		}

	}

}

fn main() {
	//mut t := GemtextToken(T_List{text:"hello"})
	//println("$t")

	src := "* text one\n> hello world\n* another one"

	mut myscanner := new_scanner(src)
	myscanner.parse()
	println(myscanner.tokens)
}

