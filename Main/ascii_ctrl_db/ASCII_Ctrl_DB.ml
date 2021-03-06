(** {1 The initial opening statement} *)
open OCanren;;

(** {1 Type definitions and utilities} *)

(** {2 The ASCII control characters type} *)
module ASCII_Ctrl = struct      
  @type t = NUL (** Null *)
          | SOH (** Start of heading *)
          | STX (** Start of text *)
          | ETX (** End of text *)
          | EOT (** End of transmission *)
          | ENQ (** Enquiry *)
          | ACK (** Ackonwledge *)
          | BEL (** Bell *)
          | BS  (** Back space *)
          | HT  (** Horizontal tab *)
          | LF  (** Line Feed *)
          | VT  (** Vertical tab *)
          | FF  (** Form feed *)
          | CR  (** Carriage return *)
          | SO  (** Shift out *)
          | SI  (** Shift in *)
          | DLE (** Data line escape *)
          | DC1 (** Device control 1 *)
          | DC2 (** Device control 2 *)
          | DC3 (** Device control 3 *)
          | DC4 (** Device control 4 *)
          | NAK (** Negative ack. *)
          | SYN (** Synchronous idle *)
          | ETB (** End of block *)
          | CAN (** Cancel *)
          | EM  (** End of medium *)
          | SUB (** Substitute *)
          | ESC (** Escape *)
          | FS  (** File separator *)
          | GS  (** Group separator *)
          | RS  (** Record separator*)
          | US  (** Unit separator *)
  with show;;
  @type ground = t with show;;
  @type logic = t OCanren.logic   with show;;
  type groundi = (ground, logic) injected;;

  (** {3 Injection utilities} *)                                                       
  module Inj : sig
    val nUL : unit -> groundi
    val sOH : unit -> groundi
    val sTX : unit -> groundi
    val eTX : unit -> groundi
    val eOT : unit -> groundi
    val eNQ : unit -> groundi
    val aCK : unit -> groundi
    val bEL : unit -> groundi
    val bS  : unit -> groundi
    val hT  : unit -> groundi
    val lF  : unit -> groundi
    val vT  : unit -> groundi
    val fF  : unit -> groundi
    val cR  : unit -> groundi
    val sO  : unit -> groundi
    val sI  : unit -> groundi
    val dLE : unit -> groundi
    val dC1 : unit -> groundi
    val dC2 : unit -> groundi
    val dC3 : unit -> groundi
    val dC4 : unit -> groundi
    val nAK : unit -> groundi
    val sYN : unit -> groundi
    val eTB : unit -> groundi
    val cAN : unit -> groundi
    val eM  : unit -> groundi
    val sUB : unit -> groundi
    val eSC : unit -> groundi
    val fS  : unit -> groundi
    val gS  : unit -> groundi
    val rS  : unit -> groundi
    val uS  : unit -> groundi
  end = struct  
    let nUL () = !! NUL
    let sOH () = !! SOH
    let sTX () = !! STX
    let eTX () = !! ETX
    let eOT () = !! EOT
    let eNQ () = !! ENQ
    let aCK () = !! ACK
    let bEL () = !! BEL
    let bS () = !! BS
    let hT () = !! HT
    let lF () = !! LF
    let vT () = !! VT
    let fF () = !! FF
    let cR () = !! CR
    let sO () = !! SO
    let sI () = !! SI
    let dLE () = !! DLE
    let dC1 () = !! DC1
    let dC2 () = !! DC2
    let dC3 () = !! DC3
    let dC4 () = !! DC4
    let nAK () = !! NAK
    let sYN () = !! SYN
    let eTB () = !! ETB
    let cAN () = !! CAN
    let eM () = !! EM
    let sUB () = !! SUB
    let eSC () = !! ESC
    let fS () = !! FS
    let gS () = !! GS
    let rS () = !! RS
    let uS () = !! US
  end;;
end;;

(** {2  The logic string type} *)
module LString = struct
  @type t = GT.string with show;;
  @type ground = t with show;;
  @type logic = t OCanren.logic with show;;
  type groundi = (ground, logic) injected;;
end;;

(** {1 The data base as a relation} *)
let ascii_ctrl :
      ASCII_Ctrl.groundi -> Std.Nat.groundi -> LString.groundi -> goal
  = fun c n s ->
  let open ASCII_Ctrl.Inj in
  ocanren{ c == NUL  & n == 0  & s == "Null"
         | c == SOH  & n == 1  & s == "Start of heading"
         | c == STX  & n == 2  & s == "Start of text"
         | c == ETX  & n == 3  & s == "End of text"
         | c == EOT  & n == 4  & s == "End of transmission"
         | c == ENQ  & n == 5  & s == "Enquiry"
         | c == ACK  & n == 6  & s == "Ackonwledge"
         | c == BEL  & n == 7  & s == "Bell"
         | c == BS   & n == 8  & s == "Back space"
         | c == HT   & n == 9  & s == "Horizontal tab"
         | c == LF   & n == 10 & s == "Line Feed"
         | c == VT   & n == 11 & s == "Vertical tab"
         | c == FF   & n == 12 & s == "Form feed"
         | c == CR   & n == 13 & s == "Carriage return"
         | c == SO   & n == 14 & s == "Shift out"
         | c == SI   & n == 15 & s == "Shift in"
         | c == DLE  & n == 16 & s == "Data line escape"
         | c == DC1  & n == 17 & s == "Device control 1"
         | c == DC2  & n == 18 & s == "Device control 2"
         | c == DC3  & n == 19 & s == "Device control 3"
         | c == DC4  & n == 20 & s == "Device control 4"
         | c == NAK  & n == 21 & s == "Negative ack."
         | c == SYN  & n == 22 & s == "Synchronous idle"
         | c == ETB  & n == 23 & s == "End of block"
         | c == CAN  & n == 24 & s == "Cancel"
         | c == EM   & n == 25 & s == "End of medium"
         | c == SUB  & n == 26 & s == "Substitute"
         | c == ESC  & n == 27 & s == "Escape"
         | c == FS   & n == 28 & s == "File separator"
         | c == GS   & n == 29 & s == "Group separator"
         | c == RS   & n == 30 & s == "Record separator"
         | c == US   & n == 31 & s == "Unit separator"};;

(** {1 Some queries on the data base} *)

(** Find the control characters in a given range *)
let _ =
  List.iter print_endline @@
    Stream.take ~n:18 @@ 
      run q (fun s ->
          ocanren {fresh c,n in Std.Nat.(<=) 0 n
                                & Std.Nat.(<=) n 10
                                & ascii_ctrl c n s}) project;;

(** ad-hoc type definition for use below *)
@type p = ASCII_Ctrl.ground * LString.ground with show;;

(** Given an integer id, print the control char's short and long names *)
let _ =
  List.iter (fun x -> print_endline @@ GT.show(p) x) @@
    Stream.take ~n:1 @@ 
      run qr (fun c s -> ocanren {ascii_ctrl c 23 s}) (fun c s -> project c, project s);;


