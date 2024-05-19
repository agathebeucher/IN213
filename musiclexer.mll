{
open Musicparser
}

let pitch = ['A'-'G']
let digit = ['0'-'9']
let octave = digit
let duration = '-' digit+ ('.' digit*)?
let silence = '_' duration
let space = [' ' '\t']
let non_quote = [^'"'] 
let time_signature = digit '/' digit
let accidental = ['b' '#']?

rule token = parse
  | "Title:\"" { TITLE (get_string lexbuf) }
  | "Composer:\"" { COMPOSER (get_string lexbuf) }
  | "Tempo:\"" { TEMPO (get_string lexbuf) }
  | "Key_signature:\"" { KEY_SIGNATURE (get_string lexbuf) }
  | time_signature as s { TIME_SIGNATURE (s) }
  | pitch octave accidental duration as s { NOTE (s) }
  | silence as s { SILENCE (s) }
  | '|' ('\n' | eof) { token lexbuf }
  | '|' { BAR }
  | '\n' { token lexbuf }
  | eof { EOF }
  | _ { raise (Failure(Printf.sprintf "Unexpected character: %s" (Lexing.lexeme lexbuf))) }

and get_string = parse
  | non_quote* '"' { String.sub (Lexing.lexeme lexbuf) 0 ((String.length (Lexing.lexeme lexbuf)) - 1) }
  | _ { raise (Failure "Expected closing quote for title") }