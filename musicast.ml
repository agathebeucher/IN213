(* musicast.ml *)
type note = 
  | Silence of { duration: float; tie: string option }
  | Note of {
    pitch : string;
    octave : int;
    accidental : string;
    duration : float;
    tie : string option;
  }

type measure = note list

type music = {
  title : string;
  composer : string;
  tempo : string;
  beats : int;
  beat_type : int;
  key_signature_opt : string option;
  notes : note list;
}

let float_to_string f =
  if f -. floor f = 0. then
    string_of_int (int_of_float f)
  else
    string_of_float f
let string_of_note = function
  | Silence {duration;_} -> Printf.sprintf "Silence: Duration: %f" duration
  | Note {pitch; octave; accidental;duration} ->
    Printf.sprintf "Pitch: %s, Octave: %d, Accidental: %s, Duration: %f" pitch octave accidental duration

(* Fonctions pour séléctionner les n premiers éléments*)
let rec take n = function
| [] -> []
| h :: tl -> if n = 0 then [] else h :: take (n-1) tl

let key_signature_to_altered_notes key_signature =
  match key_signature with
  | None -> []
  | Some key_signature ->
    let sharps = ["F"; "C"; "G"; "D"; "A"; "E"; "B"] in
    let flats = List.rev sharps in
    if String.length key_signature < 2 then
      failwith "Invalid key signature"
    else
      let num = int_of_string (String.sub key_signature 1 ((String.length key_signature) - 1)) in
      if key_signature.[0] = '+' then
        take num sharps
      else if key_signature.[0] = '-' then
        take num flats
      else
        failwith "Invalid key signature"

let string_of_measure (measure : measure) =
  measure |> List.map string_of_note |> String.concat "; "

let tempo_string_to_float = function
  | "largo" -> 40.0
  | "adagio" -> 60.0
  | "andante" -> 80.0
  | "moderato" -> 100.0
  | "allegro" -> 120.0
  | "presto" -> 140.0
  | _ -> failwith "Unsupported tempo"

let duration_to_type = function
  | 4.0 -> "whole"    (* ronde *)
  | 2.0 -> "half"     (* blanche *)
  | 1.0 -> "quarter"  (* noire *)
  | 0.5 -> "eighth" (* croche *)
  | 0.25 -> "sixteenth" (* double croche *)
  | _ -> failwith "Unsupported duration"

let beat_type_to_duration = function
  | 1 -> 4.0
  | 2 -> 2.0
  | 4 -> 1.0
  | 8 -> 0.5
  | 16 -> 0.25
  | _ -> failwith "Unsupported beat type"

let notes_to_measures beats beat_type notes =
  let max_duration = float_of_int beats *. beat_type_to_duration beat_type in
  let rec aux measures measure measure_duration = function
    | [] -> 
        if measure_duration > 0.0 then List.rev (List.rev measure :: measures) else List.rev measures
    | note :: rest ->
        let note_duration = match note with
        | Silence {duration;_} -> duration
        | Note {pitch;octave;duration} -> duration 
        in
        if measure_duration +. note_duration > max_duration then
          let remaining_duration = measure_duration +. note_duration -. max_duration in
          let note1 = match note with
          | Silence _ -> Silence { duration = max_duration -. measure_duration; tie = Some "\"start\""}
          | Note note -> Note { note with duration = max_duration -. measure_duration; tie = Some "\"start\"" } in
          let note2 = match note with
            | Silence _ -> Silence { duration = remaining_duration; tie = Some "\"stop\"" }
            | Note note -> Note { note with duration = remaining_duration; tie = Some "\"stop\"" } in
          aux (List.rev (note1 :: measure) :: measures) [note2] remaining_duration rest
        else if measure_duration +. note_duration = max_duration then
          aux (List.rev (note :: measure) :: measures) [] 0.0 rest
        else
          aux measures (note :: measure) (measure_duration +. note_duration) rest
  in
  aux [] [] 0.0 notes

let note_to_xml key_signature = function
  | Silence { duration; tie } ->
    let note_type = duration_to_type duration in
    let tie_xml = match tie with
      | Some tie -> Printf.sprintf "<tie type=%s/>\n" tie
      | None -> "" in
    let notations_xml = match tie with
    | Some tie -> Printf.sprintf "<notations>\n      <tied type=%s/>\n      </notations>\n" tie
    | None -> "" in
    Printf.sprintf "<note>
      <rest/>
      <duration>%s</duration>
      %s      <type>%s</type>
      %s</note>" (float_to_string duration) tie_xml note_type notations_xml
| Note {pitch; octave; accidental; duration; tie} ->
  let note_type = duration_to_type duration in
  let tie_xml = match tie with
    | Some tie -> Printf.sprintf "<tie type=%s/>\n" tie
    | None -> "" in
  let notations_xml = match tie with
    | Some tie -> Printf.sprintf "\n<notations>\n<tied type=%s/>\n</notations>\n" tie
    | None -> "" in
    let altered_notes = match key_signature with
    | None -> []
    | Some key_signature -> key_signature_to_altered_notes (Some key_signature) in
    let alter_value =
      match key_signature with
      | None -> "0"
      | Some key_signature -> if key_signature.[0] = '+' then "+1" else "-1" in
    let accidental_alter_value = match accidental with
      | "#" -> "+1"
      | "b" -> "-1"
      | "" -> "0" 
      | _ -> failwith "Invalid accidental" in
    let alter_xml = if List.mem pitch altered_notes then Printf.sprintf "<alter>%s</alter>" alter_value else if accidental_alter_value!="0" then Printf.sprintf "<alter>%s</alter>" accidental_alter_value else "" in 
    Printf.sprintf "<note>
      <pitch>
        <step>%s</step>
        %s<octave>%d</octave>
        </pitch>
      <duration>%s</duration>
      %s<type>%s</type>
    %s</note>" pitch alter_xml octave (float_to_string duration) tie_xml note_type notations_xml

let measure_to_xml (measure : measure) number tempo attributes key_signature =
  let notes_xml = measure |> List.map (note_to_xml key_signature) |> String.concat "\n" in
  let tempo_xml = if number = 1 then Printf.sprintf "<sound tempo=\"%d\"/>\n" tempo else "" in
  let attributes_xml = if number = 1 then attributes else "" in
  Printf.sprintf "<measure number=\"%d\">\n%s%s%s\n</measure>" number tempo_xml attributes_xml notes_xml

let music_to_xml (music : music) =
  let tempo = music.tempo in
  let measures = notes_to_measures music.beats music.beat_type music.notes in
  let key_signature_xml = match music.key_signature_opt with
    | None -> "" 
    | Some key_signature -> Printf.sprintf "<key>
      <fifths>%s</fifths>
      <mode>major</mode>
      </key>" key_signature in
  let attributes_xml = Printf.sprintf "<attributes>
  <divisions>2</divisions>
  %s<time>
    <beats>%d</beats>
    <beat-type>%d</beat-type>
    </time>
  <clef>
    <sign>G</sign>
    <line>2</line>
    </clef>
  </attributes>\n" key_signature_xml music.beats music.beat_type in
  let measures_xml = measures |> List.mapi (fun i measure -> 
    let measure_string = string_of_measure measure in
    Printf.printf "Measure %d: %s\n" (i+1) measure_string;
    let key_signature = match music.key_signature_opt with
      | Some ks -> Some ks
      | None -> None in
    measure_to_xml measure (i+1) (int_of_float(tempo_string_to_float tempo)) (if i = 0 then attributes_xml else "") key_signature
  ) |> String.concat "\n" in
  let tempo_xml = Printf.sprintf "<sound>
  <sound tempo=\"%d\"/>
  </sound>" (int_of_float (tempo_string_to_float tempo)) in
  Printf.sprintf "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE score-partwise PUBLIC \"-//Recordare//DTD MusicXML 2.0 Partwise//EN\" \"http://www.musicxml.org/dtds/partwise.dtd\">
<score-partwise>
  <movement-title>Prince Ali</movement-title>
  <identification>
    <creator type=\"composer\">%s</creator>
    <rights>All Rights Reserved</rights>
    <encoding>
      <software>MuseScore 1.3</software>
      <encoding-date>2016-01-03</encoding-date>
      </encoding>
    <source>http://wikifonia.org/node/22777/revisions/29946/view</source>
       <miscellaneous>
                    <miscellaneous-field name=\"download-source\">Downloaded on https://www.playthatsheet.com</miscellaneous-field>
                </miscellaneous>
            </identification>
  <defaults>
    <scaling>
      <millimeters>7</millimeters>
      <tenths>40</tenths>
      </scaling>
    <page-layout>
      <page-height>1691</page-height>
      <page-width>1289</page-width>
      <page-margins type=\"both\">
        <left-margin>14</left-margin>
        <right-margin>5</right-margin>
        <top-margin>30</top-margin>
        <bottom-margin>30</bottom-margin>
        </page-margins>
      </page-layout>
    </defaults>
  <credit page=\"1\">
    <credit-words default-x=\"644.5\" default-y=\"1661\" font-size=\"28\" justify=\"center\" valign=\"top\">%s</credit-words>
    </credit>
  <credit page=\"1\">
    <credit-words default-x=\"1284\" default-y=\"1594.26\" font-size=\"12\" justify=\"right\" valign=\"top\">%s</credit-words>
    </credit>
  <credit page=\"1\">
    <credit-words default-x=\"5\" default-y=\"1594.26\" font-size=\"12\" justify=\"left\" valign=\"top\">2</credit-words>
    </credit>
  <part-list>
    <score-part id=\"P1\">
      <part-name>MusicXML Part</part-name>
      <score-instrument id=\"P1-I3\">
        <instrument-name>MusicXML Part</instrument-name>
        </score-instrument>
      <midi-instrument id=\"P1-I3\">
        <midi-channel>1</midi-channel>
        <midi-program>1</midi-program>
        <volume>79.5276</volume>
        <pan>0</pan>
        </midi-instrument>
      </score-part>
    </part-list>
    <part id=\"P1\">
      %s
      %s
      %s
    </part>
  </score-partwise>" 
  music.composer music.title music.composer tempo_xml attributes_xml measures_xml