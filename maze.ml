Random.self_init ();;

open Graphics

let rec power a b = 
  if b = 0 then 1 
  else a * power a (b-1)

let draw_square pas (i, j) color =
  let x = i * pas in
  let y = j * pas in
  set_color color;
  fill_rect x y pas pas

let draw_maze pas m = 
  for i = 0 to Array.length m - 1 do
    for j = 0 to Array.length m.(0) - 1 do 
      draw_square pas (i, j) 
      (if m.(i).(j) then white else black)
    done
  done

let rec draw_path pas path = 
  match path with 
    | [] -> ()
    | head :: rest -> 
        draw_square pas head yellow;
        draw_path pas rest 

let pile : (int * int) list ref = ref []

let push p x =
  p := x :: !p

let pop p = 
  match !p with 
  | [] -> raise (Failure "Pas de chemin possible.") 
  | head :: rest -> 
      p := rest;
      head 

let blocked m (i,j) = 
  if not m.(i-1).(j) && not m.(i).(j-1) && not m.(i+1).(j) && not m.(i).(j+1) then true else false

let next m (i,j) = 
    if m.(i-1).(j) then (i-1,j) 
    else if m.(i).(j-1) then (i,j-1) 
    else if m.(i+1).(j) then (i+1,j) 
    else (i,j+1) 

let walk step m d a = 
  let mcopy = Array.map Array.copy m in  
  let pos = ref d in 
  let p = ref [] in 
  mcopy.(fst !pos).(snd !pos) <- false; 
  draw_maze step m; 
  draw_square step !pos red; 
  while !pos <> a do 
    Unix.sleepf 0.01;  
    if not (blocked mcopy !pos) then (
      push p !pos; 
      pos := next mcopy !pos;
      mcopy.(fst !pos).(snd !pos) <- false; 
      draw_square step !pos red; 
    )
    else (
      draw_square step !pos white; 
      pos:= pop p; 
    )
  done;
  draw_square step a green  

let make_maze k = 
  let n = (power 2 k+1) in 
  let maze = Array.make_matrix n n true in 
  let rec subrecfunc (i0,j0) m = 
    if m >= 2 then (
      let subm = (power 2 m-1) in 

      for i = i0 to i0 + subm  do 
        maze.(i).(j0 + subm/2) <- false
      done ; 

      for j = j0 to j0 + subm do
        maze.(i0 + subm/2).(j) <- false 
      done ; 

      subrecfunc (i0,j0) (m - 1) ; 
      subrecfunc (i0 + subm/2 + 1 , j0) (m - 1) ; 
      subrecfunc (i0, j0 + subm/2 + 1) (m - 1) ; 
      subrecfunc (i0 + subm/2 + 1, j0 + subm/2 + 1) (m - 1) ; 

      let r = Random.int 4 in 
      let rand () = (Random.int (subm/4 + 1 )) * 2 in 
      
      if r != 0 then maze.(i0 + subm/2).(j0+rand())               <- true ; 
      if r != 1 then maze.(i0 + subm/2).(j0+ subm/2 + 1 + rand()) <- true ; 
      if r != 2 then maze.(i0 + rand()).(j0+ subm/2)              <- true ; 
      if r != 3 then maze.(i0 + subm/2 + 1 + rand()).(j0+ subm/2) <- true ; 
    )
  in

  subrecfunc (1,1) k ; 

  for x = 0 to (n - 1) do 
    maze.(x).(0) <- false ; 
    maze.(0).(x) <- false ; 
    maze.(x).(n-1) <- false ; 
    maze.(n-1).(x) <- false ; 
  done ; 
  maze

let () =
  let maze_size = 6 in
  let n = power 2 maze_size + 1 in
  let window_size = 1000 in
  let cell_size = window_size / n in
  open_graph (" " ^ string_of_int window_size ^ "x" ^ string_of_int window_size);
  let amazing = make_maze maze_size in
  draw_maze cell_size amazing;
  walk cell_size amazing (1,1) (n-2, n-2);
  ignore (read_key ());
  close_graph ()