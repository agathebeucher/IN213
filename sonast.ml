open Musicast

let play_sound f l =
  let l_ms = l /. 1000.0 in
  let command = Printf.sprintf "play -n synth %f sin %f" l_ms f in
  let ic = Unix.open_process_in command in
  try
    while true do
      let line = input_line ic in
      print_endline line
    done
  with End_of_file ->
    ignore (Unix.close_process_in ic)

let silence l =
  let _ =
    if Unix.fork () = 0 then
      Unix.execvp "sleep" [| "sleep" ; string_of_float l |]
    else
      Unix.wait ()
  in
  ()

(* Convertit le tempo bpm en s*)
let beats_to_ms tempo_bpm beats =
  let milliseconds_per_beat = 60000.0 /. tempo_bpm in
  let duration_in_ms = milliseconds_per_beat *. beats in
  duration_in_ms

let beats_to_s tempo_bpm beats =
  let duration_in_ms = beats_to_ms tempo_bpm beats in
  let duration_in_s = duration_in_ms /. 1000.0 in
  duration_in_s

let play_note music note =
  let tempo_bpm = (tempo_string_to_float music.tempo) in
  match note with
  | Silence {duration;_} -> silence (beats_to_s tempo_bpm duration)
  | Note {pitch; octave; duration} ->
    let base_freq = match pitch with
      | "C" -> 16.35
      | "D" -> 18.35
      | "E" -> 20.60
      | "F" -> 21.83
      | "G" -> 24.50
      | "A" -> 27.50
      | "B" -> 30.87
      | _ -> 0.0 (* En cas de note invalide *)
    in
    let key_signature_offset = match music.key_signature_opt with
    | None -> 0.0
    | Some key -> float_of_string key
    in
    let freq = (base_freq *. (2.0 ** float octave)) *. (2.0 ** (key_signature_offset /. 12.0)) in
    Printf.printf "Playing note: %s, octave: %d, duration: %f, frequency: %f\n" pitch octave (beats_to_ms tempo_bpm duration) freq;
  play_sound freq (beats_to_ms tempo_bpm duration)

let rec play_bar music bar =
  match bar with
  | [] -> ()
  | note :: rest ->
    play_note music note;
    play_bar music rest
  
let rec play_music music =
  match music.notes with
  | [] -> ()
  | note :: rest ->
    play_note music note;
    play_music {music with notes = rest}
