/*
 * Conway's game of life Prolog implementation.
 *
 * To start the game run start_game(+InputFramePath, +GenNumber).
 * - InputFramePath is a path to the file with initiall field,
 * containing for example:
 * 101
 * 010
 * 101
 * - GenNumber is a number of generations to run
 *
 * Create folder 'frames' to store fields of each generation in the
 * same format as shown above.
 */

start_game(InputFramePath, GenNumber) :- read_field(InputFramePath, InitField),
                                         nb_setval(gen_number, GenNumber),
                                         start_game_(0, InitField).

start_game_(GenIndex, _) :- nb_getval(gen_number, GenNumber),
                            GenIndex=:=GenNumber.

start_game_(GenIndex, Field) :- writef('Generation %d:\n', [GenIndex]),
                                write_field(Field, GenIndex),
                                populate_field(Field, 0, 0, NewField),
                                GenIndex_ is GenIndex+1,
                                start_game_(GenIndex_, NewField).



populate_field(_, _, Y, []) :- nb_getval(height, Height),
                               Y=:=Height.

populate_field(Field, X, Y, [NewRow|NewFieldRest]) :- populate_row(Field, X, Y, NewRow),
                                                      Y_ is Y+1,
                                                      populate_field(Field, X, Y_, NewFieldRest).



populate_row(_, X, _, []) :- nb_getval(width, Width),
                             X=:=Width.

populate_row(Field, X, Y, [NewCell|NewRowRest]) :- populate_cell(Field, X, Y, NewCell),
                                                   X_ is X+1,
                                                   populate_row(Field, X_, Y, NewRowRest).



populate_cell(Field, X, Y, NewCell) :- count_neighbours(Field, X, Y, NeighboursCount),
                                       get_cell(Field, X, Y, Cell),
                                       update_cell(Cell, NeighboursCount, NewCell).



count_neighbours(Field, X, Y, NeighboursCount) :- N is Y-1,
                                                  S is Y+1,
                                                  W is X-1,
                                                  E is X+1,
                                                  get_cell(Field, X, N, NCell),
                                                  get_cell(Field, X, S, SCell),
                                                  get_cell(Field, W, Y, WCell),
                                                  get_cell(Field, E, Y, ECell),
                                                  get_cell(Field, E, N, NECell),
                                                  get_cell(Field, W, N, NWCell),
                                                  get_cell(Field, E, S, SECell),
                                                  get_cell(Field, W, S, SWCell),
                                                  NeighboursCount is NCell+SCell+WCell+ECell+NECell+NWCell+SECell+SWCell.



update_cell(Cell, NeighboursCount, NewCell) :- Cell=:=0,
                                               NeighboursCount=:=3,
                                               NewCell is 1.

update_cell(Cell, NeighboursCount, NewCell) :- Cell =:= 1,
                                               NeighboursCount<2,
                                               NewCell is 0.

update_cell(Cell, NeighboursCount, NewCell) :- Cell =:= 1,
                                               NeighboursCount>3,
                                               NewCell is 0.

update_cell(Cell, _, NewCell) :- NewCell is Cell.



get_cell(Field, X, Y, Cell) :- nb_getval(width, Width),
                               nb_getval(height, Height),
                               Width_ is Width-1,
                               Height_ is Height-1,
                               between(0, Width_, X),
                               between(0, Height_, Y),
                               nth0(Y, Field, Row),
                               nth0(X, Row, Cell_),
                               Cell is Cell_.

get_cell(_, _, _, Cell) :- Cell is 0.



read_field(FilePath, Field) :- open(FilePath, read, Stream),
                               read_field_(Stream, Field),
                               length(Field, Height),
                               nb_setval(height, Height),
                               close(Stream).

read_field_(Stream, []) :- at_end_of_stream(Stream).

read_field_(Stream, [FirstRow|FieldRest]):- read_row(Stream, FirstRow),
                                            length(FirstRow, Width),
                                            nb_setval(width, Width),
                                            read_field_(Stream, FieldRest).



read_row(Stream, Row) :- read_line_to_codes(Stream, Line),
                         atom_codes(Line_codes, Line),
                         atom_chars(Line_codes, Line_chars),
                         maplist(atom_number, Line_chars, Row).



write_field(Field, GenNumber) :- atom_concat('frames/frame', GenNumber, FilePath),
                                 open(FilePath, append, Stream),
                                 write_field_(Stream, Field),
                                 close(Stream).



write_field_(_, []).

write_field_(Stream, [Row|FieldRest]) :- write_row(Stream, Row),
                                         writef('\n'),
                                         write(Stream, '\n'),
                                         write_field_(Stream, FieldRest).



write_row(_, []).

write_row(Stream, [Cell|RowRest]) :- writef('%d ', [Cell]),
                                     write(Stream, Cell),
                                     write_row(Stream, RowRest).

