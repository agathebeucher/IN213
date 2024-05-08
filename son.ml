(* son.ml *)

open Musicast
open Musicparser
open Musiclexer
open Sonast

let parse_with_error lexbuf =
  try Musicparser.main Musiclexer.token lexbuf with
  | Failure msg -> 
    prerr_endline (Printf.sprintf "%s at %d" msg lexbuf.lex_curr_p.pos_lnum);
    exit (-1)
  | Parsing.Parse_error ->
    prerr_endline (Printf.sprintf "Parse error at %d" lexbuf.lex_curr_p.pos_lnum);
    exit (-1)

let parse filename =
  let inx = open_in filename in
  let lexbuf = Lexing.from_channel inx in
  parse_with_error lexbuf

let () =
  if Array.length Sys.argv <> 2 then begin
    prerr_endline "Usage: son <input_file>";
    exit (-1)
  end else begin
    let filename = Sys.argv.(1) in
    let music = parse filename in
    play_music music
  end