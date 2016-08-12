/* c := {[-x, -y, -z] | x in {1..2} & y in {10 * x, 100 * x}} & z in {-x, -y} */

S_p3(x, y) := [-x, -y];

S_p2(x) := [10 * x, 100 * x];

S_p1 := 1...2;

Sd[i1, i2, i3] :=
    let x := S_p1[i1];
        y := S_p2(x)[i2];
        z := S_p3(x, y)[i3];
    in [x, y, z];
       
S := join(join(Sd));

t(x, y, z) := [-x, -y, -z];

c[i] :=
    let b   := S[i];
        x   := b[1];
        y   := b[2];
        z   := b[3];
    in t(x, y, z);
    
/* 
LED library written in SequenceL
*/

////////// ////////// ////////// ////////// ////////// ////////// 
/* importing */

import <Utilities/Conversion.sl>;
import <Utilities/Math.sl>;
import <Utilities/Sequence.sl>;
import <Utilities/Set.sl>;
import <Utilities/String.sl>;

////////// ////////// ////////// ////////// ////////// ////////// 
/* exporting */

public 
    pp, // pretty print
    Val, Numb, // types
    someSet, allSet, valToSet, // quantification
    pip, // pipe
    setMem, sbset, unn, nrsec, diff, cross, powSet, card, // set
    equiv, impl, disj, conj, neg, // boolean
    eq, uneq, // equality
    less, greater, lessEq, greaterEq, // relational
    add, bMns, uMns, mult, div, flr, clng, md, exp, ab, // arithmetic
    tuConc, tuIn, tuSl, // tuple
    tu, // tuple to value
    se, // set to value
    iv, // interval to value
    at, // atom to value
    tr, // truth to value
    nu; // numeral to value
        
////////// ////////// ////////// ////////// ////////// ////////// 
/* testing */

pp(v) := prettyPrint(v);

prettyPrint: Val -> char(1);
prettyPrint(v) :=
    let
        a := valToAtm(v);
        numl := valToNuml(v);
        t := valToTrth(v);
        c := valToColl(v);
    in
        a when valOfKind(v, kindAtm) else
        numl when valOfKind(v, kindNumb) else
        Conversion::boolToString(t) when valOfKind(v, kindTrth) else
        prettyPrintColl(c, valToKind(v)); // collection

prettyPrintColl: Val(1) * char(1) -> char(1);
prettyPrintColl(vs(1), k(1)) :=
    let
        h := prettyPrint(head(vs));
        t := prettyPrintTail(tail(vs));
        s := h ++ join(t);
    in
        "{}" when size(vs) = 0 else
        "{" ++ s ++ "}" when equalList(k, kindSet) else
        "(" ++ s ++ ")"; // tuple

prettyPrintTail: Val(1) -> char(2);
prettyPrintTail(vs(1))[i] :=
    let
        v := vs[i];
        s := prettyPrint(v);
    in
        ", " ++ s;

// test(x) := debugPrint(x);
// test2(s(1), x) := debugPrint(s, x);

////////// ////////// ////////// ////////// ////////// ////////// 
/* type: value */

Val ::= 
    (kind: char(1), 
    atm: char(1), numb: Numb, trth: bool, coll: Val(1), 
    lmbd: (Val(1) -> Val));
        
valToKind: Val -> char(1);
valToKind(v) :=
    v.kind;

valOfKind: Val * char(1) -> bool;
valOfKind(v, k(1)) :=
    equalList(valToKind(v), k);
    
valsOfKind: Val * Val * char(1) -> bool;
valsOfKind(v1, v2, k(1)) :=
    valOfKind(v1, k) and valOfKind(v2, k);
    
////////// ////////// ////////// ////////// ////////// ////////// 
/* value to thing */

valToTrth: Val -> bool;
valToTrth(v) :=
    v.trth;
    
valToNuml: Val -> char(1);
valToNuml(v) :=
    numbToNuml(valToNumb(v));
    
valToNumb: Val -> Numb;
valToNumb(v) :=
    v.numb;
    
valToAtm: Val -> char(1);
valToAtm(v) :=
    v.atm;
    
valToColl: Val -> Val(1);
valToColl(v) :=
    v.coll;  
valToTpl: Val -> Val(1);
valToTpl(v) :=
    valToColl(v);
valToSet: Val -> Val(1);
valToSet(v) :=
    valToColl(v);

////////// ////////// ////////// ////////// ////////// ////////// 
/* thing to value */

numlToVal: char(1) -> Val;
numlToVal(n(1)) :=
    numbToVal(numlToNumb(n));
nu: char(1) -> Val;
nu(n(1)) :=
    numlToVal(n);
    
numbToVal: Numb -> Val;
numbToVal(n) :=
    (kind: kindNumb, numb: n);
    
trthToVal: bool -> Val;
trthToVal(t) :=
    (kind: kindTrth, trth: t);
tr: bool -> Val;
tr(t) :=
    trthToVal(t);
    
atmToVal: char(1) -> Val;
atmToVal(a(1)) :=
    (kind: kindAtm, atm: a);
at: char(1) -> Val;
at(a(1)) :=
    atmToVal(a);

tplToVal: Val(1) -> Val;
tplToVal(t(1)) :=
    (kind: kindTpl, coll: t);
tu: Val(1) -> Val;
tu(t(1)) :=
    tplToVal(t);
    
setToVal: Val(1) -> Val;
setToVal(s(1)) :=
    (kind: kindSet, coll: removeDups(s));
se: Val(1) -> Val;
se(s(1)) :=
    setToVal(s);
    
////////// ////////// ////////// ////////// ////////// ////////// 
/* quantification */

someSet: Val(1) -> Val;
someSet(vs(1)) :=
    let
        n := size(vs);
        h := head(vs);
        t := tail(vs);
    in
        valFalse when n = 0 else
        h when n = 1 else
        disj(h, someSet(t));

allSet: Val(1) -> Val;
allSet(vs(1)) :=
    let
        n := size(vs);
        h := head(vs);
        t := tail(vs);
    in
        valTrue when n = 0 else
        h when n = 1 else
        conj(h, allSet(t));
        
// someSet2: Val(2) -> Val;
// someSet2(vs(2)) :=
    // someSet(someSet(vs));

// allSet2: Val(2) -> Val;
// allSet2(vs(2)) :=
    // allSet(allSet(vs));

////////// ////////// ////////// ////////// ////////// ////////// 
/* tuple operations */

tuConc: Val * Val -> Val;
tuConc(v1, v2) :=
    let
        t1 := valToTpl(v1);
        t2 := valToTpl(v2);
        t := t1 ++ t2;
    in
        tplToVal(t);

tuIn: Val * Val -> Val;
tuIn(valT, valI) :=
    let
        tplT := valToTpl(valT);
        intI := valToInt(valI);
    in
        tplT[intI];
        
tuSl: Val * Val * Val -> Val;
tuSl(valT, valI1, valI2) :=
    let
        t := valToTpl(valT);
        i1 := valToInt(valI1);
        i2 := valToInt(valI2);
        t2 := t[i1...i2];
    in
        tplToVal(t2);

tuLen: Val -> Val;
tuLen(v) :=
    let
        t := valToTpl(v);
        n := size(t);
    in
        intToVal(n);
        
////////// ////////// ////////// ////////// ////////// ////////// 
/* equality operations */

eq: Val * Val -> Val;
eq(v1, v2) :=
    trthToVal(trthEq(v1, v2));
        
uneq: Val * Val -> Val;
uneq(v1, v2) :=
    trthToVal(not trthEq(v1, v2));

trthEq: Val * Val -> bool;
trthEq(v1, v2) :=
    let
        n1 := valToNumb(v1); n2 := valToNumb(v2);
        a1 := valToAtm(v1); a2 := valToAtm(v2);
        tr1 := valToTrth(v1); tr2 := valToTrth(v2);
        c1 := valToColl(v1); c2 := valToColl(v2);
    in
        eqNumb(n1, n2) when valsOfKind(v1, v2, kindNumb) else
        equalList(a1, a2) when valsOfKind(v1, v2, kindAtm) else
        tr1 = tr2 when valsOfKind(v1, v2, kindTrth) else
        equalList(c1, c2) when valsOfKind(v1, v2, kindTpl) else
        equalSet(c1, c2) when valsOfKind(v1, v2, kindSet) else
        false;
    
eqNumb: Numb * Numb -> bool;
eqNumb(numb1, numb2) :=
    sgn(bMnsNumb(numb1, numb2)) = 0;
    
////////// ////////// ////////// ////////// ////////// ////////// 
/* relational operations */

less: Val * Val -> Val;
less(v1, v2) :=
    stdNumbNumbToTrth(lessNumb, v1, v2);
    
lessNumb: Numb * Numb -> bool;
lessNumb(numb1, numb2) :=
    sgn(bMnsNumb(numb1, numb2)) < 0;

greater: Val * Val -> Val;
greater(v1, v2) :=
    stdNumbNumbToTrth(greaterNumb, v1, v2);
    
greaterNumb: Numb * Numb -> bool;
greaterNumb(numb1, numb2) :=
    not (lessNumb(numb1, numb2) or eqNumb(numb1, numb2));

lessEq: Val * Val -> Val;
lessEq(v1, v2) :=
    stdNumbNumbToTrth(lessEqNumb, v1, v2);
    
lessEqNumb: Numb * Numb -> bool;
lessEqNumb(numb1, numb2) :=
    lessNumb(numb1, numb2) or eqNumb(numb1, numb2);

greaterEq: Val * Val -> Val;
greaterEq(v1, v2) :=
    stdNumbNumbToTrth(greaterEqNumb, v1, v2);
    
greaterEqNumb: Numb * Numb -> bool;
greaterEqNumb(numb1, numb2) :=
    greaterNumb(numb1, numb2) or eqNumb(numb1, numb2);

////////// ////////// ////////// ////////// ////////// ////////// 
/* pipe operation */

pip: Val -> Val;
pip(v) :=
    card(v) when valOfKind(v, kindSet) else
    ab(v) when valOfKind(v, kindNumb) else
    tuLen(v); // tuple

////////// ////////// ////////// ////////// ////////// ////////// 
/* set operations (value) */

setMem: Val * Val -> Val;
setMem(v1, v2) :=
    stdValSetToTrth(setMemSet, v1, v2);
    
sbset: Val * Val -> Val;
sbset(v1, v2) :=
    stdSetSetToTrth(sbsetSet, v1, v2);

unn: Val * Val -> Val;
unn(v1, v2) :=
    stdSetSetToSet(unnSet, v1, v2);
    
nrsec: Val * Val -> Val;
nrsec(v1, v2) :=
    stdSetSetToSet(nrsecSet, v1, v2);
    
diff: Val * Val -> Val;
diff(v1, v2) :=
    stdSetSetToSet(diffSet, v1, v2);
    
cross: Val * Val -> Val;
cross(v1, v2) :=
    stdSetSetToSet(crossSet, v1, v2);
    
powSet: Val -> Val;
powSet(v) :=
    stdSetToSet(powSetSet, v);

card: Val -> Val;
card(v) :=
    stdSetToInt(cardSet, v);

////////// ////////// ////////// ////////// ////////// ////////// 
/* boolean operations (value) */

equiv: Val * Val -> Val;
equiv(v1, v2) :=
    stdTrthTrthToTrth(equivTrth, v1, v2);

impl: Val * Val -> Val;
impl(v1, v2) :=
    stdTrthTrthToTrth(implTrth, v1, v2);
    
disj: Val * Val -> Val;
disj(v1, v2) :=
    stdTrthTrthToTrth(disjTrth, v1, v2);
    
conj: Val * Val -> Val;
conj(v1, v2) :=
    stdTrthTrthToTrth(conjTrth, v1, v2);
    
neg: Val -> Val;
neg(v) :=
    stdTrthToTrth(negTrth, v);
    
////////// ////////// ////////// ////////// ////////// ////////// 
/* arithmetic operations (value) */

add: Val * Val -> Val;
add(v1, v2) :=
    stdNumbNumbToNumb(addNumb, v1, v2);

bMns: Val * Val -> Val;
bMns(v1, v2) :=
    stdNumbNumbToNumb(bMnsNumb, v1, v2);
        
uMns: Val -> Val;
uMns(v) :=
    stdNumbToNumb(uMnsNumb, v);
    
mult: Val * Val -> Val;
mult(v1, v2) :=
    stdNumbNumbToNumb(multNumb, v1, v2);
    
div: Val * Val -> Val;
div(v1, v2) :=
    stdNumbNumbToNumb(divNumb, v1, v2);
        
flr: Val -> Val;
flr(v) :=
    stdNumbToInt(flrNumb, v);

clng: Val -> Val;
clng(v) :=
    stdNumbToInt(clngNumb, v);
        
ab: Val -> Val;
ab(v) :=
    stdNumbToNumb(abNumb, v);
        
md: Val * Val -> Val;
md(v1, v2) :=
    stdIntIntToInt(mdNumb, v1, v2);
        
exp: Val * Val -> Val;
exp(v1, v2) :=
    stdNumbIntToNumb(expNumb, v1, v2);    

////////// ////////// ////////// ////////// ////////// ////////// 
/* interval */

intervalToVal: Val * Val -> Val;
intervalToVal(v1, v2) :=
    let
        i1 := valToInt(v1); 
        i2 := valToInt(v2); 
        s := twoIntsToSet(i1, i2);
    in
        setToVal(s);
iv: Val * Val -> Val;
iv(v1, v2) :=
    intervalToVal(v1, v2);

twoIntsToSet: int64 * int64 -> Val(1);
twoIntsToSet(i1, i2)[ind] :=
    intToVal(ind) foreach ind within i1...i2;

////////// ////////// ////////// ////////// ////////// ////////// 
/* type: number */

Numb ::= 
    (Numr: int64, Denr: int64);
    
twoIntsToNumbRed: int64 * int64 -> Numb;
twoIntsToNumbRed(i1, i2) :=
    reduce(i1, i2);
    
twoIntsToNumb: int64 * int64 -> Numb;
twoIntsToNumb(i1, i2) :=
    (Numr: i1, Denr: i2);

numbToNumr: Numb -> int64;
numbToNumr(numb) :=
    numb.Numr;
    
numbToDenr: Numb -> int64;
numbToDenr(numb) :=
    numb.Denr;
    
////////// ////////// ////////// ////////// ////////// ////////// 
/* pseudotype: integer */

numbIsInt: Numb -> bool;
numbIsInt(numb) :=
    numbToDenr(numb) = 1;
    
intToNumb: int64 -> Numb;
intToNumb(i) :=
    twoIntsToNumb(i, 1);
    
numbToInt: Numb -> int64;
numbToInt(numb) :=
    numbToNumr(numb);
    
intToVal: int64 -> Val;
intToVal(i) :=
    numbToVal(intToNumb(i));

valToInt: Val -> int64;
valToInt(v) :=
    numbToInt(valToNumb(v));
    
////////// ////////// ////////// ////////// ////////// ////////// 
/* kinds */
    
kindNumb: char(1);
kindNumb :=
    "numb";
    
kindTrth: char(1);
kindTrth :=
    "trth";
    
kindAtm: char(1);
kindAtm :=
    "atm";
    
kindTpl: char(1);
kindTpl :=
    "tpl";
    
kindSet: char(1);
kindSet :=
    "set";
    
////////// ////////// ////////// ////////// ////////// ////////// 
/* some values */

valTrue: Val;
valTrue :=
    trthToVal(true);
    
valFalse: Val;
valFalse :=
    trthToVal(false);

valOne: Val;
valOne :=
    numbToVal(numbOne);
    
valTen: Val;
valTen :=
    numbToVal(numbTen);
       
////////// ////////// ////////// ////////// ////////// ////////// 
/* some numbers */

numbOne: Numb;
numbOne := 
    intToNumb(1);
    
numbTen: Numb;
numbTen :=
    intToNumb(10);

////////// ////////// ////////// ////////// ////////// ////////// 
/* arithmetic helper functions */

recipr: Numb -> Numb;
recipr(numb) :=
    twoIntsToNumbRed(numbToDenr(numb), numbToNumr(numb));

sgn: Numb -> int8;
sgn(numb) :=
    Math::sign(numbToNumr(numb));
    
reduce: int64 * int64 -> Numb;
reduce(i1, i2) :=
    let
        signOfNumb := Math::sign(i1) * Math::sign(i2);
        absNumr := Math::abs(i1); 
        absDenr := Math::abs(i2);
        gcdNumb := gcd(absNumr, absDenr);
        redAbsNumr := absNumr / gcdNumb; 
        redAbsDenr := absDenr / gcdNumb;
        redNumr := signOfNumb * redAbsNumr;
    in
        twoIntsToNumb(redNumr, redAbsDenr);

gcd: int64 * int64 -> int64;
gcd(i1, i2) :=
    i1 when i2 = 0 else
    gcd(i2, i1 mod i2);

////////// ////////// ////////// ////////// ////////// ////////// 
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
    
////////// ////////// ////////// ////////// ////////// ////////// 
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
        addNumb(numbIN, numbF);
        
frToNumb: char(1) -> Numb;
frToNumb(f(1)) :=
    let 
        lParenth := Sequence::firstIndexOf(f, '(');
    in  
        frNRepToNumb(f) when lParenth = 0 else
        frRepToNumb(f);
    
frRepToNumb: char(1) -> Numb;
frRepToNumb(fR(1)) :=
    let 
        lParenth := Sequence::firstIndexOf(fR, '(');
        fNR := Sequence::take(fR, lParenth - 1);
        numbFNR := frNRepToNumb(fNR);
        shift := size(fNR) - 1;
        factor := expNumb(numbTen, -shift);
        rB := Sequence::drop(fR, lParenth - 1);
        numbRB := multNumb(factor, repBlToNumb(rB));
    in  
        addNumb(numbFNR, numbRB);

repBlToNumb: char(1) -> Numb;
repBlToNumb(rB(1)) :=
    let 
        iN := rB[2 ... size(rB) - 3];
        rept := intNumlToNumb(iN);
        lenRept := size(iN);
        divisor := bMnsNumb(expNumb(numbTen, lenRept), numbOne);
    in      
        divNumb(rept, divisor);
        
frNRepToNumb: char(1) -> Numb;
frNRepToNumb(fNR(1)) :=
    let 
        iN := Sequence::drop(fNR, 1);
        lenIN := size(iN);
        factor := expNumb(numbTen, -lenIN);
    in 
        multNumb(factor, intNumlToNumb(iN));
    
intNumlToNumb: char(1) -> Numb;
intNumlToNumb(iN(1)) := 
    intToNumb(Conversion::stringToInt(iN));
    
////////// ////////// ////////// ////////// ////////// ////////// 
/* standardizer functions */

stdValSetToTrth: (Val * Val(1) -> bool) * Val * Val -> Val;
stdValSetToTrth(f, v, v2) :=
    let
        s := valToSet(v2);
        t := f(v, s);
    in
        trthToVal(t);
        
stdSetSetToTrth: (Val(1) * Val(1) -> bool) * Val * Val -> Val;
stdSetSetToTrth(f, v1, v2) :=
    let
        s1 := valToSet(v1);
        s2 := valToSet(v2);
        t := f(s1, s2);
    in
        trthToVal(t);
        
stdSetSetToSet: (Val(1) * Val(1) -> Val(1)) * Val * Val -> Val;
stdSetSetToSet(f, v1, v2) :=
    let
        s1 := valToSet(v1);
        s2 := valToSet(v2);
        s := f(s1, s2);
    in
        setToVal(s);
        
stdSetToSet: (Val(1) -> Val(1)) * Val -> Val;
stdSetToSet(f, v) :=
    let
        s := valToSet(v);
        s2 := f(s);
    in
        setToVal(s2);
        
stdSetToInt: (Val(1) -> int64) * Val -> Val;
stdSetToInt(f, v) :=
    let
        s := valToSet(v);
        i := f(s);
    in
        intToVal(i);

stdTrthTrthToTrth: (bool * bool -> bool) * Val * Val -> Val;
stdTrthTrthToTrth(f, v1, v2) :=
    let
        t1 := valToTrth(v1);
        t2 := valToTrth(v2);
        t := f(t1, t2);
    in
        trthToVal(t);

stdTrthToTrth: (bool -> bool) * Val -> Val;
stdTrthToTrth(f, v) :=
    let 
        t := valToTrth(v);
        t2 := f(t);
    in
        trthToVal(t2);
    
stdNumbNumbToTrth: (Numb * Numb -> bool) * Val * Val -> Val;
stdNumbNumbToTrth(f, v1, v2) :=
    let
        n1 := valToNumb(v1);
        n2 := valToNumb(v2);
        t := f(n1, n2);
    in  
        trthToVal(t);
        
stdNumbNumbToNumb: (Numb * Numb -> Numb) * Val * Val -> Val;
stdNumbNumbToNumb(f, v1, v2) :=
    let
        n1 := valToNumb(v1);
        n2 := valToNumb(v2);
        n := f(n1, n2);
    in
        numbToVal(n);
        
stdNumbToNumb: (Numb -> Numb) * Val -> Val;
stdNumbToNumb(f, v) :=
    let
        n := valToNumb(v);
        n2 := f(n);
    in
        numbToVal(n2);
        
stdNumbToInt: (Numb -> int64) * Val -> Val;
stdNumbToInt(f, v) :=
    let
        n := valToNumb(v);
        i := f(n);
        n2 := intToNumb(i);
    in
        numbToVal(n2);
        
stdIntIntToInt: (int64 * int64 -> int64) * Val * Val -> Val;
stdIntIntToInt(f, v1, v2) :=
    let
        i1 := valToInt(v1);
        i2 := valToInt(v2);
        i := f(i1, i2);
    in
        intToVal(i);
        
stdNumbIntToNumb: (Numb * int64 -> Numb) * Val * Val -> Val;
stdNumbIntToNumb(f, v1, v2) :=
    let
        n := valToNumb(v1);
        i := valToInt(v2);
        n2 := f(n, i);
    in
        numbToVal(n2);

////////// ////////// ////////// ////////// ////////// ////////// 
/* set operations (non-value) */

setMemSet: Val * Val(1) -> bool;
setMemSet(v, vs(1)) :=
    Set::elementOf(v, vs);

sbsetSet: Val(1) * Val(1) -> bool;
sbsetSet(v1(1), v2(1)) :=
    subset(v1, v2);
    
unnSet: Val(1) * Val(1) -> Val(1);
unnSet(v1(1), v2(1)) :=
    Set::union(v1, v2);
    
nrsecSet: Val(1) * Val(1) -> Val(1);
nrsecSet(v1(1), v2(1)) :=
    Set::intersection(v1, v2);
    
diffSet: Val(1) * Val(1) -> Val(1);
diffSet(v1(1), v2(1))[i] :=
    let
        v := v1[i];
    in
        v when not setMemSet(v, v2);
        
crossSet: Val(1) * Val(1) -> Val(1);
crossSet(v1(1), v2(1)) :=
    let
        collSet := Set::cartesianProduct(v1, v2);
    in
        collSetToValSet(collSet, kindTpl);
        
powSetSet: Val(1) -> Val(1);
powSetSet(v(1)) :=
    let
        collSet := Set::powerSet(v);
    in
        collSetToValSet(collSet, kindSet);
        
collSetToValSet: Val(2) * char(1) -> Val(1);
collSetToValSet(M(2), k(1))[i] :=
    let
        c := M[i];
    in
        tplToVal(c) when equalList(k, kindTpl) else
        setToVal(c);
    
cardSet: Val(1) -> int64;
cardSet(v(1)) :=
    size(v);

////////// ////////// ////////// ////////// ////////// ////////// 
/* boolean operations (truth) */

equivTrth: bool * bool -> bool;
equivTrth(t1, t2) :=
    let
        if := implTrth(t1, t2);
        onlyIf := implTrth(t2, t1);
    in
        conjTrth(if, onlyIf);

implTrth: bool * bool -> bool;
implTrth(t1, t2) :=
    disjTrth(negTrth(t1), t2);

disjTrth: bool * bool -> bool;
disjTrth(t1, t2) :=
    true when t1 else
    t2;

conjTrth: bool * bool -> bool;
conjTrth(t1, t2) :=
    false when not t1 else
    t2;

negTrth: bool -> bool;
negTrth(t) :=
    not t;

////////// ////////// ////////// ////////// ////////// ////////// 
/* arithmetic operations (number) */

addNumb: Numb * Numb -> Numb;
addNumb(numb1, numb2) :=
    let
        numr := 
            numbToNumr(numb1) * numbToDenr(numb2) + 
            numbToDenr(numb1) * numbToNumr(numb2);
        denr := numbToDenr(numb1) * numbToDenr(numb2);
    in
        twoIntsToNumbRed(numr, denr);
        
bMnsNumb: Numb * Numb -> Numb;
bMnsNumb(numb1, numb2) :=
    addNumb(numb1, uMnsNumb(numb2));
    
uMnsNumb: Numb -> Numb;
uMnsNumb(numb) :=    
    twoIntsToNumbRed(-numbToNumr(numb), numbToDenr(numb));
    
multNumb: Numb * Numb -> Numb;
multNumb(numb1, numb2) :=
    let
        numr := numbToNumr(numb1) * numbToNumr(numb2);
        denr := numbToDenr(numb1) * numbToDenr(numb2);
    in
        twoIntsToNumbRed(numr, denr);
        
divNumb: Numb * Numb -> Numb;
divNumb(numb1, numb2) := 
    multNumb(numb1, recipr(numb2));
    
flrNumb: Numb -> int64;
flrNumb(numb) := 
    let        
        quot := numbToNumr(numb) / numbToDenr(numb);
        badCase := not numbIsInt(numb) and sgn(numb) < 0;
    in
        quot - 1 when badCase else
        quot;
        
clngNumb: Numb -> int64;
clngNumb(numb) :=
    numbToInt(numb) when numbIsInt(numb) else
    flrNumb(numb) + 1;
    
abNumb: Numb -> Numb;
abNumb(numb) :=
    twoIntsToNumbRed(Math::abs(numbToNumr(numb)), numbToDenr(numb));
    
mdNumb: int64 * int64 -> int64;
mdNumb(i1, i2) :=
    i1 mod i2;
    
expNumb: Numb * int64 -> Numb;
expNumb(numb, p) :=
    let
        numr := numbToNumr(numb); 
        denr := numbToDenr(numb);
    in
        expTwoInts(numr, denr, p);
        
expTwoInts: int64 * int64 * int64 -> Numb;
expTwoInts(numr, denr, p) :=
    let
        numr2 := Math::integerPower(numr, p);
        denr2 := Math::integerPower(denr, p);
    in
        twoIntsToNumb(numr2, denr2) when p >= 0 else
        expTwoInts(denr, numr, -p);        
