module gemtext

fn test_version() {
	assert get_version() == "0.0.1"
}

fn test_h1(){
	raw_test := "# hello             "
	mut gs := new_scanner(raw_test)
	gs.parse()

	assert gs.tokens.len == 1
	assert gs.tokens[0].type_name() == ".T_Heading"
	assert gs.html() == "<h1>hello</h1>\n"
}


fn test_h2(){
	raw_test := "##              hello             "
	mut gs := new_scanner(raw_test)
	gs.parse()
	assert gs.tokens.len == 1
	assert gs.tokens[0].type_name() == ".T_Heading"
	assert gs.html() == "<h2>             hello</h2>\n"
}

fn test_h2_no_space(){
	raw_test := "##hello"
	mut gs := new_scanner(raw_test)
	gs.parse()

	assert gs.tokens.len == 1
	assert gs.html() != "<h2>hello</h2>\n"
	assert gs.html() == "<p>##hello</p>\n"
}

fn test_h3(){
	raw_test := "### hello"
	mut gs := new_scanner(raw_test)
	gs.parse()

	assert gs.tokens.len == 1

	assert gs.tokens[0].type_name() == ".T_Heading"
	assert gs.html() == "<h3>hello</h3>\n"
}


