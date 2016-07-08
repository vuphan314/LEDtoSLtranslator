/* LED Library */

/* exporting */

public  
    Val, Numb, 
    add, biMinus, uMinus, mult, div, flr, clng, ab, md, exp,
    numlToNumb, numbToNuml;
        
/* value type */

Val ::= 
    (typ: char(1), 
    trth: bool, numb: Numb, atm: char(1), 
    lst: Val(1), lmbd: (Val(1) -> Val));
    
valToTyp: Val -> char(1);
valToTyp(v) :=
    v.typ;
    
valTypTrth: char(1);
valTypTrth :=
    "trth";
    
valTypNumb: char(1);
valTypNumb :=
    "numb";
    
trthToVal: bool -> Val;
trthToVal(t) :=
    (typ: valTypTrth, trth: t);
    
valIsNumb: Val -> bool;
valIsNumb(v) :=
    equalList(valToTyp(v), valTypNumb);
    
valToNumb: Val -> Numb;
valToNumb(v) :=
    v.numb;
    
numbToVal: Numb -> Val;
numbToVal(n) :=
    (typ: valTypNumb, numb: n);

numlToVal: char(1) -> Val;
numlToVal(n(1)) :=
    numbToVal(numlToNumb(n));
    
/* number type */

Numb ::= 
    (Numr: int64, Denr: int64);

intsToNumb: int64 * int64 -> Numb;
intsToNumb(i1, i2) :=
    reduce(i1, i2);

numbToNumr: Numb -> int64;
numbToNumr(numb) :=
    numb.Numr;
    
numbToDenr: Numb -> int64;
numbToDenr(numb) :=
    numb.Denr;
    
/* integer pseudotype */

intToNumb: int64 -> Numb;
intToNumb(i) :=
    intsToNumb(i, 1);
    
numbToInt: Numb -> int64;
numbToInt(numb) :=
    numbToNumr(numb);
    
numbIsInt: Numb -> bool;
numbIsInt(numb) :=
    numbToDenr(numb) = 1;
    
/* set operations */
    
// biUnion: Val * Val -> Val;
// biUnion(valSet1, valSet2) :=
    // let set1 := valSet1.set;
        // set2 := valSet2.set;
    // in (typ: typeSet, set: Set::union(set1, set2));
    
// nrval: Numb * Numb -> Val;
// nrval(n1(1), n2(1)) :=
    // let int1 := n1.num;
        // int2 := n2.num;
        // list := nrvalList(int1, int2);
    // in (typ: typeSet, set: list);    

// nrvalList: int64 * int64 -> Val(1);
// nrvalList(int1, int2)[i] :=
    // let n := [i, 1];
    // in (typ: typeNumber, number: n)
    // foreach i within int1 ... int2;
    
/* equality */

// todo
eq: Val * Val -> bool;
eq(v1, v2) :=
    let
        bothNumbs := valIsNumb(v1) and valIsNumb(v2);
    in
        eqNumb(valToNumb(v1), valToNumb(v2)) when bothNumbs else
        false;
    
uneq: Val * Val -> bool;
uneq(v1, v2) :=
    not eq(v1, v2);

eqNumb: Numb * Numb -> bool;
eqNumb(numb1, numb2) :=
    sgn(biMinus(numb1, numb2)) = 0;
    
uneqNumb: Numb * Numb -> bool;
uneqNumb(numb1, numb2) :=
    not eqNumb(numb1, numb2);
    
/* relational */

less: Numb * Numb -> bool;
less(numb1, numb2) :=
    sgn(biMinus(numb1, numb2)) < 0;

greater: Numb * Numb -> bool;
greater(numb1, numb2) :=
    not (less(numb1, numb2) or eqNumb(numb1, numb2));

lessEq: Numb * Numb -> bool;
lessEq(numb1, numb2) :=
    less(numb1, numb2) or eqNumb(numb1, numb2);

greaterEq: Numb * Numb -> bool;
greaterEq(numb1, numb2) :=
    greater(numb1, numb2) or eqNumb(numb1, numb2);

/* arithmetic-valued functions */

add: Numb * Numb -> Numb;
add(numb1, numb2) :=
    let
        numr := 
            numbToNumr(numb1) * numbToDenr(numb2) + 
            numbToDenr(numb1) * numbToNumr(numb2);
        denr := numbToDenr(numb1) * numbToDenr(numb2);
    in
        intsToNumb(numr, denr);
        
biMinus: Numb * Numb -> Numb;
biMinus(numb1, numb2) :=
    add(numb1, uMinus(numb2));
    
uMinus: Numb -> Numb;
uMinus(numb) :=    
    intsToNumb(-numbToNumr(numb), numbToDenr(numb));
    
mult: Numb * Numb -> Numb;
mult(numb1, numb2) :=
    let
        numr := numbToNumr(numb1) * numbToNumr(numb2);
        denr := numbToDenr(numb1) * numbToDenr(numb2);
    in
        intsToNumb(numr, denr);
        
div: Numb * Numb -> Numb;
div(numb1, numb2) := 
    mult(numb1, recipr(numb2));

flr: Numb -> int64;
flr(numb) := 
    let        
        quot := numbToNumr(numb) / numbToDenr(numb);
        badCase := not numbIsInt(numb) and sgn(numb) < 0;
    in
        quot - 1 when badCase else
        quot;
        
clng: Numb -> int64;
clng(numb) :=
    numbToInt(numb) when numbIsInt(numb) else
    flr(numb) + 1;
        
ab: Numb -> Numb;
ab(numb) :=
    intsToNumb(Math::abs(numbToNumr(numb)), numbToDenr(numb));
        
md: int64 * int64 -> int64;
md(i1, i2) :=
    i1 mod i2;
    
exp: Numb * int64 -> Numb;
exp(numb, i) :=
    numbOne when i = 0 else
    mult(numb, exp(numb, i - 1)) when i > 0 else
    exp(recipr(numb), -i);

/* arithmetic helpers */

recipr: Numb -> Numb;
recipr(numb) :=
    intsToNumb(numbToDenr(numb), numbToNumr(numb));

sgn: Numb -> int8;
sgn(numb) :=
    Math::sign(numbToNumr(numb));
    
reduce: int64 * int64 -> Numb;
reduce(i1, i2) :=
    let
        signOfNumb := Math::sign(i1) * Math::sign(i2);
        absNumr := Math::abs(i1); absDenr := Math::abs(i2);
        gcdNumb := gcd(absNumr, absDenr);
        redAbsNumr := absNumr / gcdNumb; redAbsDenr := absDenr / gcdNumb;
        redNumr := signOfNumb * redAbsNumr;
    in
        (Numr: redNumr, Denr: redAbsDenr);

gcd: int64 * int64 -> int64;
gcd(i1, i2) :=
    i1 when i2 = 0 else
    gcd(i2, i1 mod i2);

/* some numbers */

numbOne: Numb;
numbOne := 
    intToNumb(1);
    
numbTen: Numb;
numbTen :=
    intToNumb(10);

/* numeral to number */

numlToNumb: char(1) -> Numb;
numlToNumb(numl(1)) :=
    let 
        dot := Sequence::firstIndexOf(numl, '.');
        iN := Sequence::take(numl, dot - 1);
        f := Sequence::drop(numl, dot - 1);
        numbIN := intNumlToNumb(iN);
        numbF := frToNumb(f);
    in  
        intNumlToNumb(numl) when dot = 0 else
        frToNumb(numl) when dot = 1 else
        add(numbIN, numbF);
        
frToNumb: char(1) -> Numb;
frToNumb(f(1)) :=
    let 
        lPar := Sequence::firstIndexOf(f, '(');
    in  
        frNRepToNumb(f) when lPar = 0 else
        frRepToNumb(f);
    
frRepToNumb: char(1) -> Numb;
frRepToNumb(fR(1)) :=
    let 
        lPar := Sequence::firstIndexOf(fR, '(');
        fNR := Sequence::take(fR, lPar - 1);
        numbFNR := frNRepToNumb(fNR);
        shift := size(fNR) - 1;
        factor := exp(numbTen, -shift);
        rB := Sequence::drop(fR, lPar - 1);
        numbRB := mult(factor, repBlToNumb(rB));
    in  
        add(numbFNR, numbRB);

repBlToNumb: char(1) -> Numb;
repBlToNumb(rB(1)) :=
    let 
        iN := rB[2 ... size(rB) - 3];
        rept := intNumlToNumb(iN);
        lenRept := size(iN);
        divisor := biMinus(exp(numbTen, lenRept), numbOne);
    in      
        div(rept, divisor);
        
frNRepToNumb: char(1) -> Numb;
frNRepToNumb(fNR(1)) :=
    let 
        iN := Sequence::drop(fNR, 1);
        lenIN := size(iN);
        factor := exp(numbTen, -lenIN);
    in 
        mult(factor, intNumlToNumb(iN));
    
intNumlToNumb: char(1) -> Numb;
intNumlToNumb(iN(1)) := 
    intToNumb(Conversion::stringToInt(iN));
    
/* number to numeral */
    
numbToNuml: Numb -> char(1);
numbToNuml(numb) :=
    let
        negative := sgn(numb) < 0;
        absNumr := Math::abs(numbToNumr(numb));
        denr := numbToDenr(numb);
    in
        "-" ++ getAbsNuml(absNumr, denr) when negative else
        getAbsNuml(absNumr, denr);
    
getAbsNuml: int64 * int64 -> char(1);
getAbsNuml(absNumr, denr) :=
    let
        integralPart := Conversion::intToString(absNumr / denr);        
        minAbsNumr := absNumr mod denr;        
    in
        integralPart when minAbsNumr = 0 else
        integralPart ++ getFr(minAbsNumr, denr);
        
getFr: int64 * int64 -> char(1);
getFr(minAbsNumr, denr) :=
    let
        remsQuots := getRemsQuots(denr, [minAbsNumr], []);
        rems := remsQuots.l1;
        lastRem := Sequence::last(rems);
        rep := lastRem /= 0;
        repRemPos := Sequence::firstIndexOf(rems, lastRem);
        quots := remsQuots.l2;
    in
        getFrRep(repRemPos, quots) when rep else
        getFrNRep(quots);
    
getFrRep: int64 * int64(1) -> char(1);
getFrRep(repRemPos, quots(1)) :=
    let
        nRepQuots := Sequence::take(quots, repRemPos - 1);
        repQuots := Sequence::drop(quots, repRemPos - 1);
    in
        getFrNRep(nRepQuots) ++ getRepBl(repQuots);
        
getRepBl: int64(1) -> char(1);
getRepBl(repQuots(1)) :=
    "(" ++ getIntNuml(repQuots) ++ "..)";

getFrNRep: int64(1) -> char(1);
getFrNRep(quots(1)) :=
    "." ++ getIntNuml(quots);
    
getIntNuml: int64(1) -> char(1);
getIntNuml(quots(1)) :=
    join(Conversion::intToString(quots));

getRemsQuots: int64 * int64(1) * int64(1) -> TwoIntLists;
getRemsQuots(divisor, rems(1), quots(1)) :=
    let
        dividend := Sequence::last(rems) * 10;
        rem := dividend mod divisor;
        rems2 := rems ++ [rem];
        quot := dividend / divisor;
        quots2 := quots ++ [quot];
        posRem := Sequence::firstIndexOf(rems, rem);
        rep := posRem > 0;
    in
        (l1: rems2, l2: quots2) when rem = 0 or rep else
        getRemsQuots(divisor, rems2, quots2);
        
TwoIntLists ::= 
    (l1: int64(1), l2: int64(1));
        
/* importing */

import <Utilities/Conversion.sl>;
import <Utilities/Math.sl>;
import <Utilities/Sequence.sl>;
import <Utilities/Set.sl>;
