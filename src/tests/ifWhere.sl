////////// ////////// ////////// ////////// ////////// //////////

import * from "../libLED.sl" as *;

a1 := 
		nu("0");

a2 := 
	let
		x := nu("0");
	in
		x;

a3 := 
	let
		x := nu("0");
		y := x;
	in
		y;

f1(x) := 
		nu("1") when valToTrth(greater(x, nu("0")));

f2(x) := 
		nu("1") when valToTrth(greater(x, nu("0"))) else
		nu("0") when valToTrth(eq(x, nu("0")));

f3(x) := 
		nu("1") when valToTrth(greater(x, nu("0"))) else
		nu("0") when valToTrth(eq(x, nu("0"))) else
		uMns(nu("1"));

c1 := 
		f1(nu("1"));

c2 := 
		f2(nu("0"));

c3 := 
		f3(uMns(nu("1")));

f(x, y) := 
	let
		z1 := bMns(x, y);
		z2 := z1;
		z3 := z2;
	in
		z1 when valToTrth(greater(x, y)) else
		z2 when valToTrth(eq(x, y)) else
		z3;

d1 := 
		f(nu("1"), nu("0"));

d2 := 
		f(nu("0"), nu("0"));

d3 := 
		f(uMns(nu("1")), nu("0"));

r(x, y, z) := 
	let
		t := starOp(starOp(x, y), z);
	in
		eq(t, nu("0"));

e := 
		r(uMns(nu("1")), nu("0"), nu("1"));

////////// ////////// ////////// ////////// ////////// //////////

/** Copy/paste the block below into SequenceL interpreter to test:

pp(a1)
pp(a2)
pp(a3)
pp(c1)
pp(c2)
pp(c3)
pp(d1)
pp(d2)
pp(d3)
pp(e)

(pp: pretty-print) */
