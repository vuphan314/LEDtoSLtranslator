////////// ////////// ////////// ////////// ////////// //////////

import * from "../libLED.sl" as *;

myTuple := tu([nu("1"), nu("2")]);

myTerm := setCompr(AUX_2_AGGR_);

/** AUXILIARY FUNCTIONS */

AUX_1_AGGR_ := solEqSymbs(myTuple);

AUX_2_AGGR_[i_] := 
	let
		b_ := AUX_1_AGGR_[i_];
		x := b_[1];
		y := b_[2];
	in
		add(x, y);

////////// ////////// ////////// ////////// ////////// //////////

/** Copy/paste the block below into SequenceL interpreter to test:

pp(myTuple)
pp(myTerm)

(pp means PrettyPrint) */
