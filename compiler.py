import time
import struct
import regex as re
import numpy as np
from copy import deepcopy

STATUS = ''
code_ids = []
label_cnt = 0
line_n = 0
reserved_words = []


def get_label(prefix='L'):
    global label_cnt
    label_cnt += 1
    return prefix + str(label_cnt)


# -------------------------------------------- Print Color --------------------------------------------- #

def _wrap_colour(colour, *args, **kwargs):
    for a in args:
        print(colour + '{}'.format(a) + '\033[0m', **kwargs, end='')
    if kwargs.get('end'):
        print(end=kwargs['end'])
    else:
        print()


def debug(*args, **kwargs): print('!!!!!!!!!!!!!', *args, **kwargs)
def print_red(*args, **kwargs): _wrap_colour('\033[31m', *args, **kwargs)
def print_green(*args, **kwargs): _wrap_colour('\033[32m', *args, **kwargs)
def print_blue(*args, **kwargs): _wrap_colour('\033[34m', *args, **kwargs)


# --------------------------------------------- Data Type ---------------------------------------------- #

class DataType:
    def __init__(self, name, children=None, prefix=None, size=None):
        self.name = name
        self.children = {} if children is None else children
        self.n_children = max(1, len(self.children))
        self.prefix = prefix
        self.in_asm = prefix is not None
        self.size = size

    def __eq__(self, other):
        return self.name == other.name

    def compute_bytes(self):
        if self.size is None:
            bytes = 0
            for k, d in self.children.items():
                if self.children[k].size is None:
                    self.children[k].compute_bytes()
                self.children[k].offset = bytes
                bytes += self.children[k].size
            self.size = bytes

    def get_offset(self, child: list):
        if len(child) == 0:
            return 0
        if self.children.get(child[0]) is None:
            print_red(f'datatype {self.name} has no attribute {child[0]}, line {line_n}')
            raise
        return self.children[child[0]].offset + self.children[child[0]].dtype.get_offset(child[1:])

    def get_child(self, child: list):
        if self.children.get(child[0]) is None:
            # return None
            print_red(f'datatype {self.name} has no attribute {child[0]}, line {line_n}')
            raise
        if len(child) == 1:
            return self.children[child[0]]
        return self.children[child[0]].dtype.get_child(child[1:])


def get_dtype(s):
    cnt = 0
    v = ''
    vs = []
    for c in s:
        if c == '[':
            cnt += 1
        elif c == ']':
            cnt -= 1
        elif c == '.':
            vs.append(v)
            v = ''
        elif cnt == 0 and c not in ' \t':
            v += c
    if v:
        vs.append(v)

    # debug(s, vs, [curr_func.vars][vs[0]].dtype.children)
    vs[0] = replace_reserved_words(vs[0])

    if len(vs) == 1:
        return curr_vars()[vs[0]].dtype
    else:
        return curr_vars()[vs[0]].dtype.get_child(vs[1:]).dtype


dataType = {
    'int':      DataType('int', size=4, prefix='ii'),
    'float':    DataType('float', size=4, prefix='ff'),
}

# dataType['vec3f'] = DataType('vec3f', {'x': dataType['float'], 'y': dataType['float'], 'z': dataType['float']}, prefix='v3f')


# ----------------------------------------------- Codes ------------------------------------------------ #
code_priority = [['class'], ['function'], ['if-else', 'loop']]


def add_code(x, tar, indent=False):
    tar.append('\t' + x if indent else x)


def add_codes(x, tar, indent=False):
    for line in x:
        add_code(line, tar, indent)


class CodeStack:
    class CodeBlock:
        def __init__(self, label):
            self.label = label
            self.codes = []

    def __init__(self, log=False):
        self.stack = []
        self.line_codes = []
        self.log = log
        self.segment = 'import'
        self.reset()

    def reset(self):
        self.segment = 'import'
        self.line_codes = []
        self.stack = [self.CodeBlock('global')]

    @property
    def top(self):
        return self.stack[-1]

    def push(self, label):
        self.stack.append(self.CodeBlock(label))

    def pop(self):
        self.stack.pop()

    def cat(self):
        add_codes(self.stack[-1].codes, self.stack[-2].codes, indent=self.stack[-1].label != 'class')
        self.stack = self.stack[:-1]

    def add_line(self, line):
        self.line_codes.append(line)
        self.stack[-1].codes.append(line)

    def log_line_codes(self, line, proc):
        sp = match_all(reg_get('sp', r'\s*') + r'\S+.*', line)['sp']
        print_blue(sp, '    ', proc, ' -> ')
        for i, code in enumerate(self.line_codes):
            print_green(sp, '        ', code)
        self.line_codes = []


code_stack = CodeStack()


# ---------------------------------------------- Operator ---------------------------------------------- #
opLevel = [('.', '['), ('!',), ('*', '/', '%'), ('+', '-'), ('<<', '>>'), ('>', '<', '>=', '<='), ('==', '!='), ('&&',), ('||',)]
boolOpLevel = [1, 5, 6, 7, 8]
andOpLevel = 7
orOpLevel = 8
biOpLevel = [5, 6]
biOp = ['>', '<', '>=', '<=', '==', '!=']
uniOp = ['!']

invOp = {
    '==': '!=',
    '!=': '==',
    '<': '>=',
    '>': '<=',
    '<=': '>',
    '>=': '<',
}

floatOpMap = {
    r'>': 'ja',
    r'<': 'jb',
    r'>=': 'jnb',
    r'<=': 'jna',
}

opMap = {
    r'[': 'ofs',
    r'.': 'get',
    r'<<': 'shl',
    r'>>': 'shr',
    r'>=': 'jnl',
    r'<=': 'jng',
    r'==': 'je',
    r'!=': 'jne',
    r'&&': 'and',
    r'||': 'or',
    r'>': 'jg',
    r'<': 'jl',
    r'!': 'not',
    r'+': 'add',
    r'-': 'sub',
    r'*': 'mul',
    r'/': 'div',
    r'%': 'mod'
}


# ------------------------------------------ String operating ----------------------------------------- #
def reg_get(x, s):
    if x is None:
        return s
    else:
        return r'(?P<' + x + '>' + s + r')'


def reg_ss(x): return r'\s*' + x + r'\s*'


# reg_n = r'\w+((\.\w+)\b(?!\s*\())*'
reg_n = r'\w+'
reg_of = r'\[([^\[\]]|(?R))*\]'


def reg_p(x): return '(' + x + ')'
def reg_lp(x): return reg_ss(r'\(') + x + reg_ss(r'\)')
def reg_ofs(x='ofs'): return reg_get(x, reg_ss(reg_of))
def reg_int(x='int'): return reg_get(x, reg_ss(r'(\+|-)?\d+'))
def reg_float(x='float'): return reg_ss(reg_get(x, r'(\+|-)?(\d+\.\d*|\d*\.\d+)'))
def reg_func(n='f_n', x='f_v'): return reg_ss(reg_get(n, r'(\w+((\.\w+)\b(?!\s*\())*)?')) + reg_rlp(x)
def reg_rlp(x='p'): return reg_p(reg_get(x, reg_lp(r'([^()]|(?R))*')))
def reg_mtn(x): return reg_get(x, r'(\s*\w+\s*\w+\s*,)*(\s*\w+\s*\w+\s*)?')


op_reg = r'^$()*+?.[{|/'


def reg_get_nv(x):
    nvs = re.findall(r'(?:\+|-)?\d+|(?:\w+\.)*\w+', x)
    return nvs if nvs is not None else []


def reg_unit():
    return reg_p('|'.join([reg_float(None), reg_int(None), reg_rlp(None), reg_func(None, None), reg_ss(reg_n), reg_ofs(None)]))


def reg_op():
    reg_ops = []
    for k in opMap.keys():
        s = k
        for c in op_reg:
            s = s.replace(c, '\\' + c)
        reg_ops.append(s)
    return reg_p('|'.join(reg_ops))


def reg_get_unit():
    return reg_p('|'.join([reg_float(), reg_int(), reg_rlp(), reg_func(), reg_ss(reg_get('v', reg_n)), reg_ofs()]))


def str_get_units_sep_by_comma(s):
    cnt0, cnt1 = 0, 0
    vs = []
    p = 0
    for i, c in enumerate(s):
        if c == '(':
            cnt0 += 1
        elif c == ')':
            cnt0 -= 1
        elif c == '[':
            cnt1 += 1
        elif c == ']':
            cnt1 -= 1
        if cnt0 < 0 or cnt1 < 0:
            raise
        elif cnt0 == 0 and cnt1 == 0 and c == ',':
            vs.append(str_remove_front_back_blank(s[p:i]))
            p = i+1
    if cnt0 == 0 and cnt1 == 0 and p < len(s):
        vs.append(str_remove_front_back_blank(s[p:]))
    return vs


def replace_reserved_words(s):
    if s.lower() in reserved_words:
        s += '__'
    return s


def reg_get_unit_info(s):
    reg_dict = match_all(reg_get_unit(), s)
    if reg_dict['int']:
        return 'int', reg_dict['int']
    elif reg_dict['float']:
        return 'float', reg_dict['float']
    elif reg_dict['f_n']:
        reg_dict_ = match_all(r'[^()]*\((?P<f_v>.*)\)[^()]*', reg_dict['f_v'])
        return 'func', (reg_dict['f_n'], reg_dict_['f_v'])
    elif reg_dict['p']:
        reg_dict_p = match_all(r'[^()]*\((?P<p>.*)\)[^()]*', reg_dict['p'])
        return 'p', reg_dict_p['p']
    elif reg_dict['v']:
        return 'v', reg_dict['v']
    elif reg_dict['ofs']:
        return 'ofs', reg_dict['ofs']
    else:
        raise


def str_remove_front_blank(s):
    p = 0
    while p < len(s) and s[p] in " \t\n":
        p += 1
    return s[p:]


def str_remove_back_blank(s):
    p = len(s)
    while p > 0 and s[p-1] in " \t\n":
        p -= 1
    return s[:p]


def str_remove_front_back_blank(s):
    return str_remove_front_blank(str_remove_back_blank(s))


def float2bits(s):
    s = struct.pack('>f', float(s))
    return str(struct.unpack('>i', s)[0])


def floatbits2int(s):
    s = struct.pack('>i', int(s))
    return str(int(struct.unpack('>f', s)[0]))


def match_all(r, s):
    reg = re.match(r, s)
    mat = reg and reg.group() == s
    if not mat:
        return None

    reg_dict = reg.groupdict()
    for k, v in reg_dict.items():
        if v is None:
            reg_dict[k] = ''
    return reg_dict


def match_first(r, s):
    reg = re.match(r'\s*' + r + r'( +.+)?', s)
    return False if reg is None else reg.group() == s


def find_all(r, s):
    reg = re.findall('((' + r + '))', s)
    reg = [r[0] for r in reg]
    return reg


def func_attribute_to_register():
    esp_of = 0
    esp_ofs = [1e30]
    lines = deepcopy(code_stack.top.codes)
    code_stack.stack[-1].codes = []

    for line in lines:
        reg_dict = match_all(r'\s*call\s+(?P<fn>\w+)\s*', line)
        if reg_dict:
            code_stack.add_line(line)
            f = func_dict.get(reg_dict['fn'])
            if f and len(f.in_v) + len(f.out_v):
                if esp_ofs[-1]:
                    code_stack.add_line(f'sub esp, {esp_ofs[-1]}')
                esp_of = esp_ofs.pop()
            continue

        ns = [n for n in re.finditer(r'(?P<fn>\w+)\.(?P<vn>\w+)', line)]
        ns = list(filter(lambda n: n['fn'] in func_dict.keys(), ns))

        for n in reversed(ns):
            ofs = func_dict[n['fn']].vars[n['vn']].offset
            if ofs + esp_ofs[-1] >= esp_of:
                if esp_of:
                    code_stack.add_line(f'add esp, {esp_of}')
                esp_ofs.append(esp_of)
            esp_of = ofs + esp_ofs[-1]
            line = line[:n.start()] + f'[esp{ofs}]' + line[n.end():]

        code_stack.add_line(line)


def class_attribute_to_register():
    lines = deepcopy(code_stack.top.codes)
    code_stack.stack[-1].codes = []
    esi = None
    edi = None

    for line in lines:
        _ns = [n for n in re.finditer(r'(?P<vn>\w+)(?P<suffix>(\.\w+)+)?(\[(?P<ofs>[^\]]+)\])?', line)]
        _ns = list(filter(lambda n: n['suffix'] or n['ofs'], _ns))

        ns = []
        # for n in _ns:
        #     debug(n['vn'], n['suffix'], n['ofs'])
        for n in _ns:
            if curr_vars()[n['vn']].is_ptr or n['suffix'] or (n['ofs'] and not str.isdigit(n['ofs'])):
                ns.append(n)

        if len(ns) > 2:
            print_red(line)
            raise

        if len(ns) > 0:
            reg_dict = ns[0].groupdict()
            v1n = reg_dict['vn']
            v1 = curr_vars()[v1n]
            v1ofs = v1.dtype.get_offset(reg_dict['suffix'].split('.')[1:]) if reg_dict['suffix'] else "0"
            v1ofn = reg_dict['ofs'].split('+') if reg_dict['ofs'] else []

            if len(ns) == 2:
                reg_dict = ns[1].groupdict()
                v2n = reg_dict['vn']
                v2 = curr_vars()[v2n]
                v2ofs = v2.dtype.get_offset(reg_dict['suffix'].split('.')[1:]) if reg_dict['suffix'] else "0"
                v2ofn = reg_dict['ofs'].split('+') if reg_dict['ofs'] else []
            else:
                v2n = None

            if v2n is None or v1n == v2n:
                if v1n == edi:
                    reg1 = reg2 = 'edi'
                else:
                    reg1 = reg2 = 'esi'
            else:
                if v1n == edi or v2n == esi:
                    reg1 = 'edi'
                    reg2 = 'esi'
                else:
                    reg1 = 'esi'
                    reg2 = 'edi'

            if (v1n != esi and reg1 == 'esi') or (v1n != edi and reg1 == 'edi'):
                code_stack.add_line(f"{'mov' if v1.is_ptr else 'lea'} {reg1}, {v1n}")
                for v in v1ofn:
                    code_stack.add_line(f'add {reg1}, {v}')
            if v2n and v1n != v2n and ((v2n != esi and reg2 == 'esi') or (v2n != edi and reg2 == 'edi')):
                code_stack.add_line(f"{'mov' if v2.is_ptr else 'lea'} {reg2}, {v2n}")
                for v in v2ofn:
                    code_stack.add_line(f'add {reg2}, {v}')
            if v2n:
                line = line[:ns[1].start()] + f'[{reg2}+{v2ofs}]' + line[ns[1].end():]
            line = line[:ns[0].start()] + f'[{reg1}+{v1ofs}]' + line[ns[0].end():]

            if reg1 == 'esi':
                esi = v1n if v1ofn is None else None
            elif reg1 == 'edi':
                edi = v1n if v1ofn is None else None

            if reg2 == 'esi' and v2n:
                esi = v2n if v2ofn is None else None
            elif reg2 == 'edi' and v2n:
                edi = v2n if v2ofn is None else None

        code_stack.add_line(line)

    return


# --------------------------------------------- Expression --------------------------------------------- #


class RegisterManager:
    def __init__(self):
        self.extra_regs = {}
        self.used_regs = set()
        self.stack = []
        self.build()

    def build(self):
        for i in dataType.keys():
            self.extra_regs[i] = set()

    def get_reg(self, dtype_name):
        for i in self.extra_regs[dtype_name]:
            if i not in self.used_regs:
                self.used_regs.add(i)
                return i

        for i in range(1, int(1e9)):
            reg = f'reg_{dtype_name}_{i}'
            if reg not in self.used_regs:
                self.used_regs.add(reg)
                if reg not in curr_vars().keys():
                    def_var(reg, dtype_name)
                return get_var(reg)

    @staticmethod
    def is_reg(s):
        return s[:4] == 'reg_'

    def save(self):
        self.stack.append(deepcopy((self.extra_regs, self.used_regs)))

    def restore(self):
        self.extra_regs, self.used_regs = self.stack.pop()

    def remove(self, *regs):
        for reg in regs:
            if reg.name in self.used_regs:
                self.used_regs.remove(reg.name)


rm = RegisterManager()


def preprocess_unit_and_op(s):
    _xs, _ops = [], []
    while True:
        while True:
            while s[0] in ' \t\n':
                s = s[1:]
            r_uni_op = re.match(reg_op(), s)
            uni_op = r_uni_op.group() if r_uni_op else None
            if r_uni_op and uni_op == s[:len(uni_op)] and uni_op in uniOp:
                _ops.append(r_uni_op.group())
                s = s[len(uni_op):]
            else:
                break

        r_x = re.match(reg_unit(), s)
        x = r_x.group() if r_x else None
        if r_x is None or x != s[:len(x)]:
            print_red(f'syntax error, line {line_n}')
            print_red(s)
            raise
        _xs.append(x)
        s = s[len(x):]

        if len(s) == 0:
            break
        r_op = re.match(reg_op(), s)
        op = r_op.group() if r_op else None
        if r_op is None or op != s[:len(op)]:
            print_red(f'syntax error, line {line_n}')
            print_red(s)
            raise
        _ops.append(op)
        s = s[len(op) if op != '[' else len(op) - 1:]

    op_lev = -1
    op_levs = []

    for op in _ops:
        for n, opl in enumerate(opLevel):
            if op in opl:
                op_levs.append(n)
                op_lev = max(op_lev, n)
                break

    return _xs, _ops, op_lev, op_levs


def postprocess_unit_and_op(_xs, _ops, op_lev, op_levs):
    xs, ops = [], []

    if len(_xs) == 1:
        xs = _xs
        ops = _ops
    else:
        # i = 0
        # while i < len(_ops):
        #     xs.append(_xs[i])
        #     ops.append(_ops[i])
        #     if _ops[i] == '[':
        #         xs.append('')
        #         while i < len(_ops) and _ops[i] == '[':
        #             debug('asdfasdfasdfasdf')
        #             xs[-1] += _xs[i+1]
        #             i += 1
        #         ops.append(_ops[i])
        #
        #     i += 1
        #     if i == len(_ops):
        #         xs.append(_xs[i])
        #
        # debug(_xs, _ops, xs, ops)
        #
        # _xs, _ops, xs, ops = xs, ops, [], []

        i = j = 0
        while i < len(_ops):
            if op_levs[i] < op_lev:
                x = '('
                while i < len(_ops) and op_levs[i] < op_lev:
                    if _ops[i] not in uniOp:
                        x += _xs[j]
                        j += 1
                    if _ops[i] != '[':
                        x += _ops[i]
                    i += 1
                x += _xs[j] + ')'
                xs.append(x)
                j += 1
            else:
                xs.append(_xs[j])
                j += 1

            if i < len(_ops):
                ops.append(_ops[i])
                i += 1
                if i >= len(_ops):
                    xs.append(_xs[j])

    return xs, ops


def process_logic_and_label(op_lev, _logic, cd_label):
    if op_lev == andOpLevel:
        logic = 'and'
        if cd_label[0] is None or _logic == 'or':
            cd_label[0] = get_label()
    elif op_lev == orOpLevel:
        logic = 'or'
        if cd_label[1] is None or _logic == 'and' or _logic is None:
            cd_label[1] = get_label()
        if cd_label[0] is None:
            cd_label[0] = get_label()
    elif op_lev in biOpLevel:
        if _logic is None:
            logic = 'and'
            if cd_label[0] is None:
                cd_label[0] = get_label()
        else:
            logic = _logic
    else:
        logic = None
        cd_label = [None, None]

    return logic, cd_label


def sep_exp(s, dtype_name, cd_label, _logic, log=False):

    _xs, _ops, op_lev, op_levs = preprocess_unit_and_op(s)
    if dtype_name == 'bool' and op_lev not in biOpLevel:
        _xs, _ops, op_lev, op_levs = preprocess_unit_and_op(f'({s}) == 1')

    logic, cd_label = process_logic_and_label(op_lev, _logic, cd_label)
    xs, ops = postprocess_unit_and_op(_xs, _ops, op_lev, op_levs)

    dtype_name = 'int' if dtype_name in ['bool', 'if'] or op_lev in boolOpLevel else dtype_name

    if log:
        print('_ops', _ops)
        print('ops', ops, '   op_lev:', op_lev, '   op_levs:', op_levs)
        print('_xs:', _xs, '\nxs:', xs)
        print('cd_label', cd_label)

    return dtype_name, xs, ops, op_lev, logic, cd_label


def convert_type(x, target_dtype_name):
    if x.dtype.name == 'int' and target_dtype_name == 'float':
        if x.imm:
            return Var(float2bits(x.name), 'float', imm=True)
        else:
            reg = rm.get_reg(target_dtype_name)
            code_stack.add_line(f'ifmov {reg.name}, {x.name}')
            rm.remove(x)
            return reg
    elif x.dtype.name == 'float' and target_dtype_name == 'int':
        if x.imm:
            return Var(floatbits2int(x.name), 'int', imm=True)
        else:
            reg = rm.get_reg(target_dtype_name)
            code_stack.add_line(f'fimov {reg.name}, {x.name}')
            rm.remove(x)
            return reg
    else:
        return x


def build_exp(s, target_dtype_name, _logic=None, dest=None, cd_label=None, log=True):
    if dest:
        debug(dest)
    is_bool = target_dtype_name in ['bool', 'if']
    is_if = target_dtype_name == 'if'

    cd_label = [None, None] if cd_label is None else cd_label
    _cd_label = deepcopy(cd_label)

    # if match_all(r'(' + reg_unit() + reg_op() + r')*(' + reg_unit() + r')?', s) is None:
    #     print_red(line)
    #     raise

    if log:
        print('')
        print('s:', s)

    target_dtype_name, xs, ops, op_lev, logic, cd_label = sep_exp(s, target_dtype_name, cd_label, _logic, log)
    logic_root = is_if or (op_lev in boolOpLevel and _logic is None)

    def add_ofs():
        nonlocal reg_s, ofs
        if ofs:
            digits, exps = [], []
            for of in ofs:
                if of.imm:
                    digits.append(of.name)
                else:
                    exps.append(of.name)
            if int(np.sum(digits)):
                exps = [str(int(np.sum(digits)))] + exps
            if exps:
                reg_s += '[' + '+'.join(exps) + ']'

    x, reg, reg_s, of, ofs = None, None, '', '', []


    for i in range(0, len(xs)):
        if op_lev == 0:
            etype, content = reg_get_unit_info(xs[i])
            if etype != 'ofs' and of:
                ofs.append(get_var(reg_s).get_offset(of, rm))
                of = ''

            if etype == 'p':
                add_ofs()
                reg_s = build_exp(content, None, _logic=logic, cd_label=cd_label, log=log).name
            elif etype == 'func':
                add_ofs()
                f_n, f_v = content
                f_n = reg_s + '.' + f_n if reg_s else f_n
                reg_s = _func_call(f_n, f_v, 'None')[0]
            elif etype == 'v':
                if i == 0:
                    reg_s = replace_reserved_words(content)
                else:
                    reg_s += '.' + content
            elif etype == 'ofs':
                of += content
            else:
                print_red(s)
                raise

            if i == len(xs) - 1:
                if of:
                    ofs.append(get_var(reg_s).get_offset(of, rm))
                add_ofs()
                reg = Var(reg_s, get_dtype(reg_s).name, is_ptr=False, virtual=True)

        else:
            etype, content = reg_get_unit_info(xs[i])
            if etype == 'v':
                v = get_var(content)
                if v.val:
                    etype = v.dtype.name
                    content = str(v.val)

            if etype == 'int':
                x = Var(str(content), 'int', imm=True)
            elif etype == 'float':
                x = Var(float2bits(content), 'float', imm=True)
            elif etype == 'func':
                f_n, f_v = content
                f_out = dest.name if dest and dest.dtype.name == target_dtype_name else 'None'
                x = get_var(_func_call(f_n, f_v, f_out)[0])
            elif etype == 'v':
                x = get_var(content)
            elif etype == 'p':
                x = build_exp(content, None, _logic=logic, cd_label=cd_label, log=log)
            else:
                print_red(f'compiler error, line {line_n}')
                print_red(s)
                raise

            if log and i > 0:
                print(f'x{i}:', x, 'op:', ops[i - 1])

            if len(xs) == 1:
                for op in ops:
                    if op not in uniOp:
                        print_red(s)
                        raise
                    reg = rm.get_reg('int')
                    code_stack.add_line(f'{x.prefix}{opMap[op]} {x}, {reg}')
                    x = reg
                reg = x
            elif op_lev not in [andOpLevel, orOpLevel]:
                if i == 0:
                    reg = x
                else:
                    op = ops[i - 1]
                    _reg = reg
                    if reg.dtype.in_asm:
                        if not x.dtype.in_asm:
                            raise
                        if reg.dtype.name != x.dtype.name:
                            if reg.dtype.name == 'int':
                                _reg = convert_type(_reg, 'float')
                            else:
                                x = convert_type(x, 'float')
                    if op in biOp:
                        code_stack.add_line(f'{reg.dtype.prefix}cmp {reg}, {x}')
                        if _logic == 'or':
                            oper = opMap[op] if reg.dtype.name != 'float' else floatOpMap[op]
                            code_stack.add_line(oper + f' {cd_label[1]}')
                        else:
                            oper = opMap[invOp[op]] if reg.dtype.name != 'float' else floatOpMap[invOp[op]]
                            code_stack.add_line(oper + f' {cd_label[0]}')
                    else:
                        if reg.dtype.in_asm:
                            rm.remove(reg, x)
                            reg = rm.get_reg(x.dtype.name)
                            code_stack.add_line(f'{x.dtype.prefix}{opMap[op]} {_reg}, {x}, {reg}')
                        else:
                            rm.remove(reg, x)
                            reg = get_var(_func_call(f'{_reg}.{opMap[op]}', x.name, 'None')[0])

    if op_lev == orOpLevel:
        if _logic != 'or':
            code_stack.add_line(f'jmp {cd_label[0]}')
        if cd_label[1] != _cd_label[1]:
            code_stack.add_line(f'{cd_label[1]}:')

    if logic_root and not is_if:
        reg = rm.get_reg('int')
        end_label = get_label()
        code_stack.add_line(f'mov {reg}, 1')
        code_stack.add_line(f'jmp {end_label}')
        code_stack.add_line(f'{cd_label[0]}:')
        code_stack.add_line(f'mov {reg}, 0')
        code_stack.add_line(f'{end_label}:')

    if is_if and reg:
        rm.remove(reg)

    if reg:
        reg = convert_type(reg, target_dtype_name)

    if log:
        print('s:', s, 're:', reg if not is_if else cd_label[0])
        print('')

    return reg if not is_if else cd_label[0]


# ---------------------------------------------- Utils ---------------------------------------------- #
def build_and_transfer(source, dest, transfer_type='auto', log=False):

    def str_sd(s):
        r = []
        if isinstance(s, str):
            return s
        else:
            for x in s:
                r.append(x if isinstance(x, str) else x.name)
            return r

    if log:
        print('s:', str_sd(source), end='\t')
        print('d:', str_sd(dest))

    if source is None or dest is None:
        return

    if isinstance(dest, str):
        dest = str_get_units_sep_by_comma(dest)
    if isinstance(source, str):
        source = str_get_units_sep_by_comma(source)
        if len(dest) > 1 and len(source) == 1:
            reg_dict = match_all(reg_ss(reg_get('fn', '[^\(]+')) + reg_ss(reg_lp(reg_get('fv', '.+'))), source[0])
            _func_call(reg_dict['fn'], reg_dict['fv'], ', '.join(dest))
            return

    rm.save()

    for s, d in zip(source, dest):
        if isinstance(s, str) and s in ['None']:
            continue

        rm.save()
        dtype = get_dtype(d) if isinstance(d, str) else d.dtype
        dv = build_exp(d, dtype.name) if isinstance(d, str) else d
        dest = dv if dv.name in global_vars.keys() else None
        sv = build_exp(s, dtype.name, dest=dest) if isinstance(s, str) else s

        if sv.name == dv.name:
            continue

        len_ = int(dtype.size / 4)

        if dv.is_ptr:
            if transfer_type == 'auto':
                if sv.is_ptr:
                    code_stack.add_line(f'iimov {dv}, {sv}')
                else:
                    code_stack.add_line(f'plea {dv}, {sv}')
            elif transfer_type == 'value':
                if sv.is_ptr:
                    code_stack.add_line(f'ppmov {dv}, {sv}, {len_}')
                else:
                    code_stack.add_line(f'vpmov {dv}, {sv}, {len_}')
            else:
                print_red(sv)
                raise
        else:
            if sv.is_ptr:
                code_stack.add_line(f'pvmov {dv}, {sv}, {len_}')
            else:
                code_stack.add_line(f'vvmov {dv}, {sv}, {len_}')

        rm.restore()
        if rm.is_reg(sv.name) and dv.is_ptr:
            rm.used_regs.add(sv.name)

    rm.restore()


# ---------------------------------------------- Variable ---------------------------------------------- #
global_vars = {}


class Var:
    def __init__(self, name, dtype, is_ptr=None, imm=False, val=None, virtual=False):
        self.name = name
        self.dtype_name = dtype
        self.is_ptr = is_ptr
        self.imm = imm
        self.val = val
        self.virtual = virtual
        self.shape = []
        p = self.name.find('[')
        # debug('Var', self.name, i, self.name[:i], self.name[i:])
        if p != -1 and not virtual:
            self.get_offset(self.name[p:], build=True)
            self.name = self.name[:p]
        self.offset = None
        if self.is_ptr is None:
            if dtype:
                self.is_ptr = not self.dtype.in_asm

    @property
    def dtype(self):
        return dataType.get(self.dtype_name, None)

    @property
    def len(self):
        return int(np.prod(self.shape))

    @property
    def bytes(self):
        return int(self.size / 4)

    @property
    def size(self):
        return self.dtype.size * self.len if not self.is_ptr else 4

    def __eq__(self, other):
        return self.name == other.name and self.dtype_name == other.dtype_name

    def __str__(self):
        return self.name

    def get_offset(self, s, rm=None, build=False):
        if rm is None:
            rm = RegisterManager()
        i = 0
        exp = ''

        while True:
            s = str_remove_front_blank(s)
            if s == '':
                break
            reg_dict = re.match(reg_of, s)
            if reg_dict is None:
                print_red(s)
                raise
            x = reg_dict.group()[1:-1]
            if build:
                v = get_var(x)
                self.shape.append(v.val if v else int(x))
            else:
                if exp != '':
                    exp += '+'
                exp += f'({x}) * {int(np.prod(self.shape[i + 1:])) * self.dtype.size}'

            s = s[len(x) + 2:]
            i += 1

        if not build:
            return build_exp(exp, 'int', rm)


def curr_vars():
    vars = deepcopy(global_vars)
    vars.update(curr_func.vars)
    return vars


def is_ptr(s):
    v = get_var(s)
    # if v is not None and not v.dtype.in_asm and not v.is_ptr:
    #     debug('is_ptr:', s, v.dtype.in_asm, v.is_ptr)
    #     print_red(line)
    #     raise
    return not (v is None or not v.is_ptr)


def get_len(s):
    v = get_var(s)
    if v is None:
        return 4
    else:
        return int(v.size / 4)


def get_var(s):
    s = s
    if isinstance(s, str):
        if re.match(reg_int() + '|' + reg_float(), s) is not None:
            return None
        name_list = s.split('.')
    else:
        name_list = s
    r_name = replace_reserved_words(name_list[0])

    for i in range(len(name_list)):
        p = name_list[i].find('[')
        if p >= 0:
            name_list[i] = name_list[i][:p]

    if r_name in curr_vars().keys():
        r_var = curr_vars()[r_name]
        return r_var.dtype.get_child(name_list[1:]) if len(name_list) > 1 else r_var
    elif r_name in func_dict.keys():
        r_var = func_dict[r_name].vars[name_list[1]]
        return r_var.dtype.get_child(name_list[2:]) if len(name_list) > 2 else r_var
    else:
        return None
        # print_red(f'undefined variable "{r_name}", line {line_n}')
        # print_red(line)
        # raise


def def_global_var(line):
    if STATUS == 'GET_VARS_AND_BUILD_EXP':
        reg_dict = match_all(r'\s*((?P<type>\w+)\s+)(?P<lv>\w[^=]*)(\s*=(?P<rv>.+))?', line)
        if reg_dict is None:
            return False
        else:
            dtype_name = reg_dict.get('type')
            lv = str_remove_front_back_blank(reg_dict['lv'])
            rv = str_remove_front_back_blank(reg_dict['rv'])

            if dtype_name == 'const':
                if not rv:
                    print_red('const must has initial value')
                    print_red(line)
                    raise
                lv = replace_reserved_words(lv)
                code_stack.add_line(f'{lv} EQU {rv}')
                global_vars[lv] = Var(lv, 'int', val=int(rv))
                return True

            v = def_var(lv, dtype_name)
            global_vars[v.name] = v

            if dtype_name == 'int' and rv:
                code_stack.add_line(f'{v.name} DWORD {rv}')
            elif dtype_name == 'float' and rv:
                code_stack.add_line(f'{v.name} DWORD {float2bits(float(rv))}')
            else:
                if v.bytes == 1:
                    code_stack.add_line(f'{v.name} DWORD ?')
                else:
                    code_stack.add_line(f'{v.name} DWORD {v.bytes} DUP(?)')
            return True


def def_var(name, dtype_name):
    v = Var(replace_reserved_words(name), dtype_name, is_ptr=False)

    if v.dtype is None:
        print_red(f'unsupported dtype {dtype_name}, line {line_n}')
        raise
    else:
        if v.name in curr_vars().keys():
            print_red(f'redefined variable "{name}", line {line_n}')
            raise
        else:
            curr_func.vars[v.name] = v

    return v


def def_and_assign_var(line, log=False):
    global curr_func, curr_class

    reg_dict = match_all(r'\s*((?P<type>\w+)\s+)?(?P<lv>\w[^=]*)(=(?P<rv>.+))?', line)

    if reg_dict is None:
        return False
    else:
        dtype_name = reg_dict.get('type')
        lv = str_remove_front_back_blank(reg_dict['lv'])
        rv = str_remove_front_back_blank(reg_dict['rv'])

        # debug('DAV:', 'n:', dtype_name, 'lv', lv, 'rv', rv)

        if dtype_name and dtype_name not in dataType.keys():
            return False

        if not dtype_name and lv and not rv:
            return False

        # debug('DAV:', 'n:', dtype_name, 'lv:', lv, 'rv:', rv)

        if STATUS == 'GET_FUNC_AND_CLASS':
            if dtype_name and lv[:4] == 'self':
                if curr_func.name == curr_class.name + '__init':
                    child = Var(lv[5:], dtype_name, False)
                    curr_class.children[child.name] = child
                else:
                    print_red(f'syntax error, line {line_n}')
                    print_red(line)
                    raise
        elif STATUS == 'GET_VARS_AND_BUILD_EXP':
            if not curr_func.exist:
                print_red(f'variable must be inside the function, line {line_n}')
                print_red(line)
                raise

            if dtype_name and lv[:5] != 'self.':
                lv = str_get_units_sep_by_comma(lv)
                for vn in lv:
                    def_var(vn, dtype_name)

            if rv:
                build_and_transfer(rv, lv, transfer_type='value')

    if log:
        print(dtype_name, lv, rv, end='')
        print('')

    return True


# -------------------------------------------- If-elif-else -------------------------------------------- #
class If:
    def __init__(self, end_label, end_if_label):
        self.end_label = end_label
        self.end_if_label = end_if_label


if_stack = []


def if_begin(line):
    reg_dict = match_all(r'\s*(?P<label>if|elif|else)(?P<exp>.*)\s*\:\s*(?P<cmd>.+)?', line)
    if reg_dict:
        label = reg_dict['label']
        exp = reg_dict['exp']
        cmd = str_remove_front_back_blank(reg_dict['cmd'])

        if (label == 'else' and exp) or ((label == 'if' or label == 'elif') and not exp):
            print_red('syntax error', line_n)
            print_red(line)
            raise

        if STATUS == 'REFORMAT_RAW_CODES':
            if cmd:
                code_stack.add_line(f'{label} {exp}:')
                code_stack.add_line(cmd)
                code_stack.add_line('endif')
            else:
                code_stack.add_line(line)
        elif STATUS == 'GET_VARS_AND_BUILD_EXP':
            end_if_label = get_label() if label == 'if' else if_stack[-1].end_if_label

            if label == 'elif' or label == 'else':
                ife = if_stack.pop()
                code_stack.add_line(f'jmp {end_if_label}')
                code_stack.add_line(f'{ife.end_label}:')

            if label == 'if' or label == 'elif':
                end_label = build_exp(exp, target_dtype_name='if')
                if_stack.append(If(end_label, end_if_label))

            if label == 'else':
                if_stack.append(If(None, end_if_label))

        return True
    else:
        if match_first('(if|elif|else)', line) and reg_dict is None:
            print_red(f'syntax error, line {line_n}')
            print_red(line)
            raise
        return False


def if_end(line):
    if match_all(r'\s*endif\s*', line) is not None:
        ife = if_stack.pop()
        if ife.end_label:
            code_stack.add_line(f'{ife.end_label}:')
        code_stack.add_line(f'{ife.end_if_label}:')
        return True
    else:
        return False


# ------------------------------------------------ Loop ------------------------------------------------ #
class Loop:
    def __init__(self, type, it=None, itv=None, sn=None, en=None, step=None):
        self.type = type
        self.begin_label = get_label()
        self.end_label = get_label()
        self.it = it
        self.itv = itv
        self.sn = sn
        self.en = en
        self.step = step


loop_stack = []


def while_begin(line):
    reg_dict = match_all(r'\s*while(?P<exp>.*)\s*\:\s*', line)
    if reg_dict is None:
        return False
    else:
        loop = Loop('while')
        loop_stack.append(loop)
        code_stack.add_line(f'{loop.begin_label}:')

        exp = str_remove_front_back_blank(reg_dict['exp'])
        if exp != 'True':
            build_exp(exp, target_dtype_name='if', cd_label=[loop.end_label, None])
        return True


def for_begin(line):
    reg_dict = match_all(r'\s*for\s+(?P<it>\w+)\s+in\s+(?P<container>.+)\:\s*', line)
    if reg_dict is None:
        return False
    else:
        it = replace_reserved_words(reg_dict['it'])
        container = reg_dict['container']
        reg_dict = match_all(r'\s*range\s*\((?P<rvs>.+)\)\s*', container)
        if reg_dict is None:
            print_red(line)
            raise
            # con = get_var(container)
            # itv = it
            #
            # def_var(itv, con.dtype.name)
            # it = rm.get_reg('int')
            # sid, eid, gap = 0, con.len, 1
        else:
            def_var(it, 'int')
            itv = None
            rvs = str_get_units_sep_by_comma(reg_dict['rvs'])
            rvs = [build_exp(rv, 'int') for rv in rvs]
            if len(rvs) == 1:
                sid, eid, gap = 0, rvs[0], 1
            elif len(rvs) == 2:
                sid, eid, gap = rvs[0], rvs[1], 1
            elif len(rvs) == 3:
                sid, eid, gap = rvs[0], rvs[1], rvs[2]
            else:
                print_red(line)
                raise
            rm.remove(*rvs)

        loop = Loop('for', it, itv, sid, eid, gap)
        loop_stack.append(loop)

        code_stack.add_line(f'iimov {loop.it}, {loop.sn}')
        code_stack.add_line(f'{loop.begin_label}:')
        code_stack.add_line(f'iicmp {loop.it}, {loop.en}')
        code_stack.add_line(f'jnl {loop.end_label}')
        return True


def loop_end(line):
    if match_all(r'\s*endl\s*', line) is not None:
        loop = loop_stack.pop()
        if loop.type == 'for':
            code_stack.add_line(f'iiadd {loop.it}, {loop.step}, {loop.it}')
        if loop.itv is not None:
            pass
        code_stack.add_line(f'jmp {loop.begin_label}')
        code_stack.add_line(f'{loop.end_label}:')
        return True
    else:
        return False


def loop_break_continue(line):
    if match_all(r'\s*break\s*', line) is not None:
        code_stack.add_line(f'jmp {loop_stack[-1].end_label}')
        return True
    elif match_all(r'\s*continue\s*', line) is not None:
        code_stack.add_line(f'jmp {loop_stack[-1].begin_label}')
        return True
    else:
        return False


# ---------------------------------------------- Function ---------------------------------------------- #
class Func:
    def __init__(self, name, in_v, out_v, start_line, exist=True):
        self.name = name
        self.in_v = in_v
        self.out_v = out_v
        self.vars = {}
        self.start_line = start_line
        self.exist = exist
        self.offset = -8

    def new_offset(self, size):
        self.offset -= size
        return self.offset

    # def get_offset(self, x):
    #     xs = x.split('.')
    #     return self.offset + self.vars[xs[0]].dtype.get_offset(xs[1:])


curr_func = Func(None, None, None, None, False)
func_dict = {}


def get_func_name(name: str):
    if '.' in name:
        ns = name.split('.')
        if ns[0] in dataType.keys():
            return ns[0] + '__' + ns[1], None
        dtype = get_var(ns[:-1]).dtype
        name = f'{dtype.name}__{ns[-1]}'
        return name, '.'.join(ns[:-1])
    elif name in dataType.keys():
        return name + '__init', None
    else:
        return replace_reserved_words(name), None


def func_begin(line):
    global curr_func, rm

    reg_dict = match_all(r'\s*def +(?P<name>\w+)\s*(' + reg_lp(reg_mtn('in')) + r')?(\s*->\s*' + reg_lp(reg_mtn('out')) + r')?\:\s*', line)

    if match_first('def', line) and reg_dict is None:
        print_red(f'syntax error, line {line_n}')
        print_red(line)
        raise

    if reg_dict:
        rm = RegisterManager()

        if curr_func.exist:
            print_red(f'unsupported hierarchical function, line {line_n}')
            print_red(line)
            raise

        if curr_class.name:
            name = curr_class.name + '__' + reg_dict['name']
        else:
            name, _ = get_func_name(reg_dict['name'])

        if STATUS == 'GET_FUNC_AND_CLASS':
            if name in func_dict.keys():
                print_red(f'duplicated function name, line {line_n}')
                print_red(line)
                raise

            in_v = np.array(re.findall(r'\w+', reg_dict['in'])).reshape(-1, 2)
            out_v = np.array(re.findall(r'\w+', reg_dict['out']))
            in_v = [Var(replace_reserved_words(i[1]), i[0], is_ptr=not dataType[i[0]].in_asm) for i in in_v]
            out_v = [Var(replace_reserved_words('ret_' + str(i)), v, is_ptr=True) for i, v in enumerate(out_v)]
            in_out_name_s = ', '.join([v.name for v in in_v + out_v])

            if curr_class.name:
                if name.split('__')[-1] == 'init':
                    if len(out_v) > 0:
                        print_red(f'the \'init\' function cannot has output, line {line_n}')
                        print_red(line)
                        raise
                    out_v = [Var('self', curr_class.name, is_ptr=True)]
                    in_out_name_s = in_out_name_s + ', self'
                else:
                    in_v = [Var('self', curr_class.name, is_ptr=True)] + in_v
                    in_out_name_s = 'self, ' + in_out_name_s

            if name == 'main':
                if in_out_name_s:
                    print_red(f'\'main\' function cannot has params, line {line_n}')
                    print_red(line)
                    raise
                f = Func(name, in_v, out_v, line_n)
            else:
                for v in in_v + out_v:
                    if v.dtype is None:
                        print_red(f'unsupported dtype, line{line_n}')
                        print_red(line)
                        raise

                f = Func(name, in_v, out_v, line_n)
                for v in in_v:
                    f.vars[v.name] = v
                for v in out_v:
                    f.vars[v.name] = v

            func_dict[name] = curr_func = f
            code_stack.push('function')

        elif STATUS == 'COMPILE':
            curr_func = func_dict[name]
            var_strings = []
            for v in curr_func.vars.values():
                if '.' not in v.name:
                    if v.size > 4 and not v.is_ptr:
                        var_strings.append(f'{v.name}[{int(v.size/4)}]:DWORD')
                    else:
                        var_strings.append(f'{v.name}:DWORD')

            if curr_func.name == 'main':
                code_stack.add_line(f'{curr_func.name} PROC')
            else:
                code_stack.add_line(f'{curr_func.name} PROC USES esi edi')

            code_stack.push('function')

            if var_strings:
                ls, var_s = 0, []
                for v in var_strings:
                    var_s.append(v)
                    ls += len(var_s)
                    if ls > 80 or v == var_strings[-1]:
                        code_stack.add_line('local ' + ', '.join(var_s))
                        ls, var_s = 0, []

        else:
            code_stack.add_line(str_remove_front_blank(line))
            code_stack.push('function')
            curr_func = func_dict[name]

        return True
    else:
        return False


def func_end(line):
    global curr_func

    if match_all(r'\s*endf\s*', line) is not None:

        if STATUS == 'COMPILE':
            if not curr_func.exist:
                print_red(f'syntax error, line {line_n}')
                print_red(line)
                raise

            func_attribute_to_register()
            class_attribute_to_register()

            if curr_func.name == 'main':
                code_stack.add_line(f'exit')
                code_stack.cat()
                code_stack.add_line(f'main ENDP')
            else:
                code_stack.add_line(f'end_{curr_func.name}:')
                code_stack.add_line(f'ret')
                code_stack.cat()
                code_stack.add_line(f'{curr_func.name} ENDP')

            code_stack.add_line('')
            code_stack.add_line('')
        else:
            code_stack.cat()
            code_stack.add_line(str_remove_front_blank(line))

        curr_func = Func(None, None, None, None, False)
        return True

    return False


def func_return(line):
    global curr_func
    reg_dict = match_all(r'\s*return\s*(?P<vals>\S+.*)?', line)
    if reg_dict is not None:
        if not curr_func.exist:
            print_red(f'return not in function, line{line_n}')
            print_red(line)
            raise
        vals = str_get_units_sep_by_comma(reg_dict['vals'])

        if len(vals) and len(vals) != len(curr_func.out_v):
            print_red(f'expect to return {len(curr_func.out_v)} values, line {line_n}')
            print_red(line)
            raise

        if STATUS == 'GET_VARS_AND_BUILD_EXP':
            if len(vals):
                build_and_transfer(vals, curr_func.out_v, transfer_type='value')
            code_stack.add_line(f'jmp end_{curr_func.name}')
    else:
        return False

    return True


interior_function = ['len']


def _func_call(fn, in_v, out_v='', log=False):
    if not curr_func.exist:
        print_red(f'function can only execute in a function, line {line_n}')
        raise

    fn, self = (fn, None) if fn in interior_function else get_func_name(fn)

    if log:
        debug('_func_call', fn, in_v, out_v)

    if fn not in func_dict.keys() and fn not in interior_function:
        print_red(f'undefined function {fn}, line {line_n}')
        raise
    elif fn == 'main':
        print_red(f'cannot call \'main\' function, line {line_n}')
        raise
    elif fn in func_dict.keys():
        f = func_dict[fn]

    reg = None
    in_v = str_get_units_sep_by_comma(in_v)
    out_v = str_get_units_sep_by_comma(out_v)

    f_in_v, f_out_v = deepcopy(f.in_v), deepcopy(f.out_v)
    for v in f_in_v + f_out_v:
        v.name = f'{f.name}.{v.name}'

    if self is not None:
        in_v = [self] + in_v

    build_and_transfer(in_v, f_in_v)
    if out_v and out_v[0]:
        if out_v[0] == 'None':
            out_v = [rm.get_reg(f.out_v[0].dtype.name).name]

    if fn == 'len':
        code_stack.add_line(f'mov {out_v[0]}, {curr_vars()[f_in_v[0]].shape[0]}')
    else:
        build_and_transfer(out_v, f_out_v)
        code_stack.add_line(f'call {f.name}')

    return out_v


def func_call(line, log=False):
    reg_dict = match_all(reg_ss(reg_get('fn', r'[\w\[\]\.]+')) + r'\(' + reg_get('fv', '.*') + r'\)\s*', line)
    if reg_dict is not None and get_func_name(reg_dict['fn']):
        if log:
            debug('func_call', reg_dict['fn'], reg_dict['fv'])
        _func_call(reg_dict['fn'], reg_dict['fv'])
        return True
    else:
        return False


# ----------------------------------------------- Class ------------------------------------------------ #
curr_class = DataType(None)
class_func_list = ['init']


def class_begin(line):
    global curr_class

    reg_dict = match_all(r'\s*class +(?P<name>\w+)\s*\:\s*', line)
    if reg_dict:
        name = reg_dict['name']
        if STATUS == 'GET_FUNC_AND_CLASS':
            if curr_func.exist:
                print_red(f'unsupported hierarchical class, line {line_n}')
                print_red(line)
                raise
            curr_class.name = name
            dataType[name] = curr_class
        elif STATUS == 'GET_VARS_AND_BUILD_EXP':
            code_stack.add_line(str_remove_front_blank(line))
        curr_class = dataType[name]
        code_stack.push('class')
        return True
    else:
        if match_first('class', line) and reg_dict is None:
            print_red(f'syntax error, line {line_n}')
            print_red(line)
            raise
        return False


def class_end(line):
    global curr_class

    if match_all(r'\s*endc\s*', line) is None:
        return False
    else:
        if STATUS == 'GET_FUNC_AND_CLASS':
            if curr_class.name + '__init' not in func_dict.keys():
                print_red(f'class \'{curr_class.name}\' does not has \'init\' function, line {line_n}')
                print_red(line)
                raise
            dataType[curr_class.name] = deepcopy(curr_class)
        elif STATUS == 'GET_VARS_AND_BUILD_EXP':
            code_stack.add_line(str_remove_front_blank(line))
        code_stack.cat()
        curr_class = DataType(None)
        return True


# ---------------------------------------------- Compile ----------------------------------------------- #
def import_file(file_name, datas=None, codes=None):
    datas = [] if datas is None else datas
    codes = [] if codes is None else codes
    code_stack.reset()
    segment = code_stack.segment
    with open(file_name, 'r') as f:
        for line in f.readlines():
            if update_segment(line):
                segment = code_stack.segment
            elif segment == 'import':
                reg_dict = re.match(r'\s*import\s+(?P<fn>\w+)\s*', line)
                if reg_dict is not None:
                    fn = reg_dict['fn']
                    import_file('src/' + fn + '.asm', datas, codes)
            elif segment == 'data':
                datas.append(line)
            elif segment == 'code':
                codes.append(line)

    return ['.data'] + datas + ['.code'] + codes


def _line_preprocess(codes):
    for i in range(len(codes)):
        if len(codes[i]) > 0:
            if codes[i][-1] == '\n':
                codes[i] = codes[i][:-1]
            q = codes[i].find(';')
            if q >= 0:
                codes[i] = codes[i][:q]
            codes[i] = str_remove_front_back_blank(codes[i])
            if not codes[i]:
                codes[i] = None

    re_codes = []

    for i in reversed(range(len(codes))):
        if i and codes[i] and codes[i-1] and codes[i-1][-1] == '\\':
            codes[i-1] = codes[i-1][:-1] + codes[i]
        else:
            re_codes.append(codes[i])

    return list(reversed(re_codes))


def update_segment(line):
    reg_dict = match_all('\.(?P<seg>\w+)\s*', line)
    if reg_dict:
        _segment = code_stack.segment

        if STATUS == 'COMPILE' and code_stack.segment == 'import':
            code_stack.add_line('include Irvine32.inc')
            code_stack.add_line('include macros/utils.mac')
            code_stack.add_line('include macros/int.mac')
            code_stack.add_line('include macros/float.mac')
            code_stack.add_line('include macros/vector.mac')

        code_stack.segment = reg_dict['seg'].lower()

        if STATUS == 'COMPILE':
            code_stack.add_line('')
            code_stack.add_line('')
        code_stack.add_line(f'.{code_stack.segment}')

        if STATUS == 'COMPILE' and code_stack.segment == 'data':
            code_stack.add_line('xax DWORD ?')
            code_stack.add_line('fcw WORD ?')
        return True
    return False


def compile_line(line, proc, log=False):
    if line is None or update_segment(line):
        return
    for p in proc.get(code_stack.segment, []):
        if p(line):
            if log:
                code_stack.log_line_codes(line, p.__name__)
            return
    code_stack.add_line(str_remove_front_blank(line))


def _reformat_raw_code(codes):
    global STATUS
    STATUS = 'REFORMAT_RAW_CODES'
    print('\n\n', '--------------------------------------- REFORMAT_RAW_CODES ----------------------------------------')

    code_stack.reset()
    proc = {'code': [if_begin]}
    for n, line in enumerate(codes):
        compile_line(line, proc)

    codes = code_stack.top.codes

    print('Codes: ')
    for code in codes:
        print(code)

    return codes


def _get_function_and_class(codes):
    global STATUS
    STATUS = 'GET_FUNC_AND_CLASS'
    print('\n\n', '--------------------------------------- GET_FUNC_AND_CLASS ----------------------------------------')

    code_stack.reset()
    proc = {'code': [func_begin, func_end, class_begin, class_end, def_and_assign_var]}
    for n, line in enumerate(codes):
        compile_line(line, proc)

    for d in dataType.values():
        d.compute_bytes()

    print('Functions:')
    for k, v in func_dict.items():
        print('', k, *[val.name for val in v.in_v], *[val.name for val in v.out_v], sep='\t')
    print('')

    print('Class:')
    for d in dataType.values():
        if not d.in_asm:
            print('\t', f'{d.name}:')
            for k, c in d.children.items():
                print('\t', k, c.dtype_name, d.children[k].offset, d.children[k].size, sep='\t\t')
    print('')

    return True


def _get_vars_and_build_exp(codes):
    global STATUS
    STATUS = 'GET_VARS_AND_BUILD_EXP'
    print('\n\n', '------------------------------------- GET_VARS_AND_BUILD_EXP --------------------------------------')

    code_stack.reset()
    proc = {'data': [def_global_var],
            'code': [if_begin, if_end, for_begin, while_begin, loop_end, loop_break_continue, func_begin, func_end, func_return,
                     class_begin, class_end, def_and_assign_var, func_call]}

    for n, line in enumerate(codes):
        compile_line(line, proc)

    for f in func_dict.values():
        for v in f.vars.values():
            v.offset = f.new_offset(v.size)
        for v in f.in_v + f.out_v:
            v.offset = f.vars[v.name].offset

    print('Functions info:')
    for k, f in func_dict.items():
        print('\t', k)
        for v in f.vars.values():
            print(f'\t\t{v.name:<10}{v.dtype.name:>10}{v.is_ptr:>10}{v.offset:>10}{v.size:>10}')
        print('')
    print('')

    codes = code_stack.top.codes

    print('Codes: ')
    for code in codes:
        print(code)

    return codes


def _compile(codes):
    global STATUS

    codes = _line_preprocess(codes)
    codes = _reformat_raw_code(codes)
    if _get_function_and_class(codes) is None:
        return []

    codes = _get_vars_and_build_exp(codes)

    if codes is None:
        return []

    STATUS = 'COMPILE'
    print('\n\n', '--------------------------------------------- COMPILE ---------------------------------------------')

    code_stack.reset()
    proc = {'code': [if_begin, if_end, def_and_assign_var, func_begin, func_end,
            class_begin, class_end, func_return]}
    for n, line in enumerate(codes):
        compile_line(line, proc)

    code_stack.add_line('END main')

    asm_codes = '\n'.join(code_stack.top.codes)
    print(asm_codes)

    return asm_codes


def compile_file():
    with open('main.asm', 'w') as f:
        codes = import_file('src/main.asm')
        asm_codes = _compile(codes)
        f.writelines(asm_codes)


# ----------------------------------------------- Test ------------------------------------------------- #

def test():
    codes_1 = '''
        def main:
            int a = 3
            int b = 3
            int c = 3
            int d = 3
            int q = a != 2;  && b >= 3 || c < d || a > b
            printInt a
        endf
    '''

    codes_2 = '''
        def  f(int x) -> (int):
            int a = g(x) + h(x) * g(x)
            int b = g(x) + h(x) * g(x)
            return a
        endf
        
        def  g(int x) -> (int):
            int a = x * x
            return a
        endf
        
        def  h(int x) -> (int):
            int a = x * 3
            return a
        endf
    '''

    # test function
    codes_f1 = '''
        def  f(int x) -> (int):
            float fn = 0.1234    
            return g(g(g(x) * g(x * g(x + h(x, x)))))
        endf

        def  g(int x) -> (int):
            return x * x
        endf
        
        def h(int x, int y) -> (int):
            int b = (x + y) / x
            return b
        endf
        
        def main:
            int a = f(1)
            printInt a
            int b = g(3)
            printInt b
        endf
    '''

    codes_f2 = '''
        def  f(int x) -> (int):
            return x * x
        endf

        def main:
            int a = f(3)
            printInt a
        endf
    '''

    # test class
    codes_c1 = '''
        class Linear:
            def init(int a, int b):
                int self.a = a
                int self.b = b
            endf

            def f(int x) -> (int):
                return self.a * x + self.b
            endf
            
            def g(int x) -> (int):
                return self.f(x)
            endf

        endc
        
        def main:
            Linear x = Linear(2, 3)
            int a_ = x.f(3);
            int b_ = x.f(x.a * x.b + x.a * x.f(x.f(x.a) + 1))
            int c_ = x.f(x.f(1))
            int d_ = x.a * x.b + x.f(12) + x.f(1)
            int e_ = x.g(x.f(1))
            printInt a_; 9
            printInt b_; 91
            printInt c_; 13
            printInt d_; 38
            printInt e_; 13
        endf
    '''

    codes_c2 = '''
        class Linear:
            def init(int a, int b):
                int self.a = a
                int self.b = b
            endf

            def f(int x) -> (int):
                return self.a * x + self.b
            endf
                        
            def reset():
                self.a = 0
                self.b = 0
            endf
            
            def compare(Linear other) -> (int):
                if self.a > other.a && self.b > other.b:
                    return 1
                else:
                    return 0
                endif
            endf
        endc
        
        def f(Linear x):
            x.a = 1
        endf

        def main:
            Linear x = Linear(2, 3)
            x.a = 3
            printInt x.a
            f(x)
            printInt x.a
            x.reset()
            printInt x.a
            printInt x.b
    
            x.a = 3
            x.b = 5
            Linear y = x
            printInt y.a
            printInt y.b
        endf
    '''

    codes_c3 = '''
        class Linear:
            def init(int a, int b):
                int self.a = a
                int self.b = b
            endf

            def f(int x) -> (int):
                return self.a * x + self.b
            endf
                        
            def reset():
                self.a = 0
                self.b = 0
            endf
            
            def print():
                printInt self.a
                printInt self.b
            endf
        endc
        
        class LS:
            def init(Linear a, Linear b):
                Linear self.a = a
                Linear self.b = b
                Linear self.c = Linear(1, 3)
            endf
            
            def print():
                self.a.print()
                self.b.print()
                self.c.print()
                printEndl
            endf  
        endc

        def main:
            Linear x = Linear(2, 3)
            Linear y = Linear(12, 34)
            LS l = LS(x, y)
            l.print()
            l.a.a = 123
            l.c.b = 256
            l.print()
            l.a.reset()
            l.print()
            int a = l.c.f(2)
            printInt a
        endf
    '''

    codes_c4 = '''
            class Vec3:
                def init(float x, float y, float z):
                    float self.x = x
                    float self.y = y
                    float self.z = z
                endf
                
                def add(Vec3 other) -> (Vec3):
                    return Vec3(self.x + other.x, self.y + other.y, self.z + other.z)
                endf
                
                def sub(Vec3 other) -> (Vec3):
                    return Vec3(self.x - other.x, self.y - other.y, self.z - other.z)
                endf
                
                def dot() -> (float):
                    return self.x * self.x + self.y * self.y + self.z * self.z
                endf
                
                def print():
                    printFloat self.x
                    printFloat self.y
                    printFloat self.z
                    printEndl
                endf
                
            endc

            def main:
                Vec3 v0 = Vec3(1, 2, 3)
                v0.print()
                Vec3 v1 = Vec3(4, 5, 6)
                v1.print()
                Vec3 v2 = v0.add(v1).sub(v0)
                float x = v0.add(v1).sub(v0).z
                v2.print()
                printFloat x
            endf
        '''

    # test bool
    codes_b1 = '''
        def main:
            int a_ = 3
            int b_ = 5
            int c_ = 3
            int d_ = 5
            int q_ = a_ == 2 && b_ > 3 || c_ > d_ || a_ == b_
            printInt q_
            q_ = a_ != 2 && b_ > 3 || c_ <= d_ || a_ > b_
            printInt q_
        endf
    '''

    codes_b2 = '''
        def main:
            int a_ = 3
            int b_ = 5
            int c_ = 4
            int d_ = 5
            int q_ = !a_
            printInt q_
            q_ = !  !!! !!         !(a_ == 2 && b_ > 3 || !   (c_ < d_) || a_ == b_)
            printInt q_
            q_ = 0 && !!! 0 && !!1
            printInt q_
            ; 0 1 1
        endf
    '''

    # test if-else
    codes_i1 = '''
    def main:
            int a_ = 3
            int b_ = 5
            int c_ = 3
            int d_ = 5
            if a_ == 1
                printInt 1
            elif a_ == 2
                printInt 2
            elif a_ == 3
                printInt 3
            elif a_ == 4
                printInt 4
            else
                printInt 5
            endif
            
            if b_ == 1
                printInt 1
            elif b_ == 2
                printInt 2
            elif b_ == 3
                printInt 3
            elif b_ == 4
                printInt 4
            else
                printInt 5
            endif
        endf
    '''

    codes_a1 = '''
        def print_float(float x):
            printFloat x
        endf
    
        class C1:
            def init(int x):
                float self.x = x
                float self.v[10]
            endf
        endc
        
        class C2:
            def init:
                C1 self.c1[5]
                self.c1[0].v[0] = 0
                self.c1[0].v[1] = 1
                self.c1[0].v[2] = 2
            endf
            
            def print:
                print_float(self.c1[0].v[0])
                print_float(self.c1[0].v[1])
                print_float(self.c1[0].v[2])
                printEndl
            endf
        endc
    
        def main:
            int v[100]
            int a = v[55]
            C1 c1 = C1(1)
            v[2] = 5
            c1.v[5] = 123
            float b = c1.v[v[2]]
            printFloat b
            printEndl
            C2 c2 = C2()
            c2.c1[0].v[1] = 30
            c2.print()
        endf
    '''

    codes_l1 = '''
        def main:
            for i in range(1, 10)
                for j in range(1, 10)
                    int a = i * j
                    printInt a
                endl
                printEndl
            endl
        endf
    '''

    codes_l2 = '''
        def is_prime(int x) -> (int y):
            for i in range(2, x)
                if x % i == 0
                    return 0
                endif 
            endl
            return 1
        endf
    
        def main:
            printInt 0
            for i in range(1, 30000):
                if is_prime(i) == 1:
                    ; printInt i
                    ; printEndl
                endif
            endl
            printInt 1
        endf
    '''

    codes_float_int_convert = '''
        def ff(int a):
            printInt a
            printEndl
        endf
        
        def gg(float a):
            printFloat a
            printEndl
        endf
    
        def main:
            float a = 2.5
            ; for i in range(a):
            ;     printInt i
            ;     printEndl
            ; endl
            int b = a
            int c = a * b
            int d = a * a
            int e = 10 * 5.5
            float f = 5.5 * 10
            printEndl
            ; printFloat a ; 2.5
            ; printInt b ; 2
            ; printInt c__ ; 5
            ; printInt d ; 5
            printInt e
            printFloat f
            printEndl
            ; ff(a) ; 
            ; gg(b) ; 
        endf
    '''

    codes_while_test = '''
        def main():
            int t = 0
            while True:
                printInt t
                t = t + 1
            endl
        endf
    '''

    codes_test = '''
        def main():
            int x = 9
            if x > 8 || x < 10: x = 1
            printFloat x
        endf
    '''

    head_code = '''include Irvine32.inc
include macros/utils.mac
include macros/int.mac
include macros/float.mac
include macros/vector.mac

.data
const WIDTH = 480
const HEIGHT = 360
int canvas[480][360]

.code
'''

    codes = head_code + codes_test
    codes = codes.split('\n')
    for i in range(len(codes)):
        codes[i] += '\n'
    asm_codes = _compile(codes)

    with open(r'C:\Users\hardy\Sync\Study\組合語言\practice\Test\main.asm', 'w') as f:
        f.writelines(asm_codes)


if __name__ == '__main__':
    with open(r'masm_reserved_words', 'r') as f:
        reserved_words = f.readlines()
        reserved_words = list(map(str.lower, map(str_remove_front_back_blank, reserved_words)))
    # test()
    compile_file()
