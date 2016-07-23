'''
convert an LED parsetree into a SL program
'''

########## ########## ########## ########## ########## ########## 
'''
importing
'''

from tester import *

########## ########## ########## ########## ########## ########## 
'''
unparse an LED parsetree into a string which represents a SL program

note: tree := tuple/str
'''

# unparse: list -> str
def unparse(L):
    T = listToTree(L)
    st = unparseRecur(T)
    st = importLib + st
    st = markBeginEnd(st)
    return st

# unparseRecur: tree -> str
def unparseRecur(T):
    if type(T) == str:
        return T
    if T[0] in lexemes:
        return unparseLexemes(T)
    if T[0] == 'normT':
        return unparseNorm(T[1])
    if T[0] == 'set':
        return unparseSet(T)
    if T[0] == 'nrval':
        st = applyRecur('iv', T[1:], isInLib = True)
        return st
    if T[0] == 'tup':
        return unparseTuple(T)
    if T[0] == 'tupInd':
        st = applyRecur('tuIn', T[1:], isInLib = True)
        return st
    if T[0] in quantLabels:
        return unparseQuant(T)
    if T[0] in libOps:
        return unparseLibOps(T)
    if T[0] == 'cDef':
        st = defFuncRecur(T[1], (), T[2])
        return st
    else:
        return recurStr(unparseRecur, T[1:])
        
########## ########## ########## ########## ########## ########## 
'''
quantification
'''

quantLabels = {'univ', 'exist'}
libMaxSymbolsInSet = 2

# # # class QuantInfo:
    # # # isExistential = True # or universal
    # # # independentSymbols = () # ('i1', 'i2')
    # # # dependentSymbols = () # ('d1', 'd2')
    # # # quantSet = '' # '{}'
    # # # quanPred = () # sub-tree, like: equal(i1, d2)
    # # # auxNum = 1
    
    # # # # writeMain: str
    # # # def writeMain(self):
        # # # xx
    
    # # # # funcMain: (bool ->) str
    # # # def funcMain(self, next = False):
        # # # st = self.appendAux('A', next)
        # # # return st
        
    # # # # funcPred: str
    # # # def funcPred(self):
        # # # st = self.appendAux('B')
        # # # return st
        
    # # # # funcSet: str
    # # # def funcSet(self):
        # # # st = self.appendAux('C')
        # # # return st
        
    # # # # appendAux: str (* bool) -> str
    # # # def appendAux(self, extraAppend, next = False):
        # # # num = self.auxNum
        # # # if next:
            # # # num += 1
        # # # st = 'AUX_' + str(num) + '_' + extraAppend + '_'
        # # # return st
    
########## ########## ########## ########## ########## ########## 
'''
misc functions
'''

# unionDicts: tuple(dict) -> dict
def unionDicts(ds):
    D = {}
    for d in ds:
        D.update(d)
    return D
    
########## ########## ########## ########## ########## ########## 
'''
unparse lexemes
'''

lexemesDoublyQuoted = {'numl': 'nu', 'atom': 'at'}
lexemes = unionDicts((lexemesDoublyQuoted, {'truth': 'tr'}))

# unparseLexemes: tree -> str
def unparseLexemes(T):
    lex = T[0]
    func = lexemes[lex]
    arg = T[1]
    if lex in lexemesDoublyQuoted:
        arg = addDoubleQuotes(arg)
    args = arg,
    st = applyRecur(func, args, isInLib = True)
    return st

########## ########## ########## ########## ########## ########## 
'''
unparse collections
'''

# unparseTuple: tree -> str
def unparseTuple(T):
    func = 'tu'
    terms = T[1]
    st = applyRecur(func, terms[1:], isInLib = True, isList = True)
    return st
    
# unparseSet: tree -> str
def unparseSet(T):
    func = 'se'
    if len(T) == 1: # empty set
        args = '',
    else:
        terms = T[1]
        args = terms[1:]
    st = applyRecur(func, args, isInLib = True, isList = True)
    return st

########## ########## ########## ########## ########## ########## 
'''
unparse library operations
'''

equalityOps = {'eq', 'uneq'}
relationalOps = {'less', 'greater', 'lessEq', 'greaterEq'}
arOps = {'add', 'bMns', 'uMns', 'mult', 'div', 'flr', 'clng', 'md', 'exp'}
setOps = {'setMem', 'sbset', 'unn', 'nrsec', 'diff', 'cross', 'powSet'}
boolOps = {'equiv', 'impl', 'disj', 'conj', 'neg'}
libOps = equalityOps | relationalOps | arOps | setOps | boolOps

# unparseLibOps: tree -> str
def unparseLibOps(T):
    st = applyRecur(T[0], T[1:], isInLib = True)
    return st
    
# unparseNorm: tree -> str
def unparseNorm(T):
    if T[0] == 'setT':
        func = 'card'
    else: # 'arT'
        func = 'ab'
    st = applyRecur(func, T[1:], isInLib = True)
    return st
    
########## ########## ########## ########## ########## ########## 
'''
helper functions
'''

# defFuncRecur: tree * tuple(tree) * tree -> str
def defFuncRecur(func, args, expr):
    expr = unparseRecur(expr)
    st = applyRecur(func, args) + ' := ' + expr + ';\n\n'
    return st

# applyRecur: tree * tuple(tree) -> str
def applyRecur(func, args, isInLib = False, isList = False):
    func = unparseRecur(func)
    if isInLib:
        func = prependLib(func)
    st = func
    if args != ():
        st2 = unparseRecur(args[0])
        for arg in args[1:]:
            st2 += ', ' + unparseRecur(arg)
        if isList:
            st2 = '[' + st2 + ']'
        st += '(' + st2 + ')'
    return st
    
# addDoubleQuotes: str -> str
def addDoubleQuotes(st):
    st = '"' + st + '"'
    return st
    
# recurStr: function * tuple(tree) -> str
def recurStr(func, args):
    st = ''
    for arg in args:
        st += func(arg)
    return st
    
# listToTree: list -> tree
def listToTree(L):
    if type(L) == str:
        return L
    else:
        T = L[0],
        for l in L[1:]:
            T += listToTree(l),
        return T
        
########## ########## ########## ########## ########## ########## 
'''
importing and using LED library
'''

libLoc = '../'
libName = 'libLED'
libAs = 'l::'
importLib = 'import * from "' + libLoc + libName + '.sl" as ' + libAs + '*;\n\n'

# str -> str
def prependLib(st):
    st = libAs + st
    return st
