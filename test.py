# for i in range(10):
#     print('local ', end='')
#     for j in range(10):
#         if j:
#             print(', ', end='')
#         print(f'x{i*10+j:02}:DWORD', end='')
#     print('')

# for i in range(10):
#     for j in range(10):
#         print(f'iimov eax, x{i*10+j:02}')
import numpy as np
import regex as re


def reg_get(x, s):
    if x is None:
        return s
    else:
        return r'(?P<' + x + '>' + s + r')'


def reg_ss(x): return r'\s*' + x + r'\s*'


reg_n = r'\w+((\.\w+)\b(?!\s*\())*'
reg_ofs = reg_ss(r'(\[([^\[\]]|(?R))*\])*')
reg_nv = reg_ss(r'((\+|-)?\d+|' + reg_n + ')')


def reg_p(x): return '(' + x + ')'
def reg_lp(x): return reg_ss(r'\(') + x + reg_ss(r'\)')
def reg_int(x='int'): return reg_ss(reg_get(x, r'(\+|-)?\d+'))
def reg_float(x='float'): return reg_ss(reg_get(x, r'(\+|-)?(\d+\.\d*|\d*\.\d+)'))
def reg_func(n='f_n', x='f_v'): return reg_ss(reg_get(n, r'(' + reg_n + ')?')) + reg_rlp(x)
def reg_rlp(x='p'): return reg_p(reg_get(x, reg_lp(r'([^()]|(?R))*')))
def reg_mn1(x): return reg_get(x, r'(' + reg_ss(reg_n) + r',)*(' + reg_ss(reg_n) + r'){1}')
def reg_mnv0(x): return reg_get(x, r'(' + reg_nv + r',)*(' + reg_nv + r')?')
def reg_mtn(x): return reg_get(x, r'(\s*\w+\s*\w+\s*,)*(\s*\w+\s*\w+\s*)?')


def reg_get_unit():
    return reg_p('|'.join([reg_float(), reg_int(), reg_rlp(), reg_func(), reg_ss(reg_get('v', reg_n))]))


import struct


def float2bits(s):
    s = struct.pack('>f', float(s))
    return str(struct.unpack('>i', s)[0])
