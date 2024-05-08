%{
open Musicast
%}

%token <string> NOTE TITLE TEMPO TIME_SIGNATURE SILENCE COMPOSER KEY_SIGNATURE 
%token BAR
%token EOF

%start main
%type <Musicast.music> main

%%

main:
  | music EOF { $1 }

notes:
  | note { [$1] }
  | note BAR notes { $1 :: $3 }
  | note notes { $1 :: $2 }

note:
  | NOTE {
        let s = $1 in
        let pitch, rest = String.(sub s 0 1, sub s 1 (length s - 1)) in
        match String.split_on_char '-' rest with
        | octave_accidental :: duration :: _ -> 
          let octave, accidental = 
            if String.length octave_accidental > 1 then
              String.(sub octave_accidental 0 1, sub octave_accidental 1 (length octave_accidental - 1))
            else
              octave_accidental, ""
          in
          Note { pitch = pitch;  octave = int_of_string octave; accidental = accidental;duration = float_of_string duration; tie=None }
        | _ -> failwith "Invalid note format"
      }
  | SILENCE {
        let s = $1 in
        match String.split_on_char '-' s with
        | _ :: duration :: _ -> Silence {duration=(float_of_string duration); tie=None} 
        | _ -> failwith "Invalid silence format"
  }

key_signature_opt:
  | KEY_SIGNATURE { Some $1 }
  | { None }

music:
  | TITLE COMPOSER TEMPO TIME_SIGNATURE key_signature_opt notes { 
      let time_signature = $4 in
      let parts = String.split_on_char '/' time_signature in
      match parts with
      | beats :: beat_type :: [] -> { title = $1; composer = $2; tempo = $3; beats = int_of_string beats; beat_type = int_of_string beat_type; key_signature_opt = $5; notes = $6 }
      | _ -> failwith "Invalid time signature format"
    }
