open Musicast
open Musicparser
open Musiclexer

let string_of_note note = match note with
  | Silence {duration;tie} -> 
    let tie_str = match tie with
      | Some t -> t
      | None -> "None"
    in
    Printf.sprintf "{ Silence; duration = %f; tie = %s}" duration tie_str
  | Note {pitch; octave; accidental;duration} -> 
    Printf.sprintf "{ pitch = %s; octave = %d; accidental=%s; duration = %f }" pitch  octave accidental duration
    
let string_of_music music =
  let string_of_notes = List.map string_of_note music.notes in
  Printf.sprintf "{ title = %s; tempo = %s; notes = [%s] }" music.title music.tempo (String.concat "; " string_of_notes)

let parse_with_error lexbuf =
  try 
    let result = Musicparser.main Musiclexer.token lexbuf in
    Printf.printf "Parsed result: %s\n" (string_of_music result); (* Print parsed result *)
    result
  with
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

let convert_to_pdf xml_file =
  let pdf_file = (Filename.remove_extension xml_file) ^ ".pdf" in
  let command = Printf.sprintf "mscore %s -o %s" xml_file pdf_file in
  let exit_status = Sys.command command in
  if exit_status = 0 then
    print_endline ("Successfully converted " ^ xml_file ^ " to " ^ pdf_file)
  else
    print_endline ("Failed to convert " ^ xml_file ^ " to " ^ pdf_file)

let () =
  let filename = Sys.argv.(1) in
  let inx = open_in filename in
  let lexbuf = Lexing.from_channel inx in
  let result = Musicparser.main Musiclexer.token lexbuf in
  let xml = Musicast.music_to_xml result in
  let outx = open_out (filename ^ ".xml") in
  output_string outx xml;
  close_out outx;  
  convert_to_pdf (filename ^ ".xml")