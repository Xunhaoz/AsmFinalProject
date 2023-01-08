.DATA
const WIDTH = 480; 480
const HEIGHT = 360; 360
int color_buffer[HEIGHT][WIDTH]
float deep_buffer[HEIGHT][WIDTH]
int charLevel[64]
int buffer[200000]

.CODE
def build_char_level():
    charLevel[00] = 32
    charLevel[01] = 46
    charLevel[02] = 39
    charLevel[03] = 45
    charLevel[04] = 44
    charLevel[05] = 58
    charLevel[06] = 95
    charLevel[07] = 34
    charLevel[08] = 59
    charLevel[09] = 60
    charLevel[10] = 62
    charLevel[11] = 47
    charLevel[12] = 92
    charLevel[13] = 33
    charLevel[14] = 43
    charLevel[15] = 42
    charLevel[16] = 61
    charLevel[17] = 94
    charLevel[18] = 76
    charLevel[19] = 74
    charLevel[20] = 63
    charLevel[21] = 84
    charLevel[22] = 89
    charLevel[23] = 40
    charLevel[24] = 41
    charLevel[25] = 55
    charLevel[26] = 67
    charLevel[27] = 70
    charLevel[28] = 50
    charLevel[29] = 49
    charLevel[30] = 73
    charLevel[31] = 51
    charLevel[32] = 53
    charLevel[33] = 90
    charLevel[34] = 91
    charLevel[35] = 93
    charLevel[36] = 83
    charLevel[37] = 86
    charLevel[38] = 69
    charLevel[39] = 65
    charLevel[40] = 88
    charLevel[41] = 80
    charLevel[42] = 71
    charLevel[43] = 79
    charLevel[44] = 85
    charLevel[45] = 52
    charLevel[46] = 75
    charLevel[47] = 37
    charLevel[48] = 78
    charLevel[49] = 72
    charLevel[50] = 87
    charLevel[51] = 35
    charLevel[52] = 48
    charLevel[53] = 77
    charLevel[54] = 36
    charLevel[55] = 68
    charLevel[56] = 82
    charLevel[57] = 57
    charLevel[58] = 81
    charLevel[59] = 54
    charLevel[60] = 66
    charLevel[61] = 64
    charLevel[62] = 56
    charLevel[63] = 38
endf

push_render_buffer Macro c, p
    mov eax, p
    mov ebx, c
    mov BYTE PTR buffer[eax], bl
    inc p
ENDM

def display():
    int p = 0
	for i in range(HEIGHT):
	    for j in range(WIDTH):
            int color = color_buffer[i][j]
            int char = charLevel[color]
            push_render_buffer char, p
            ; push_render_buffer char, p
        endl
        push_render_buffer 10, p
    endl
    push_render_buffer 0, p

    ; call Clrscr
    mov edx, OFFSET buffer
    call WriteString
endf

def clear_buffer():
    for i in range(HEIGHT):
        for j in range(WIDTH):
            color_buffer[i][j] = 0
            deep_buffer[i][j] = INF
        endl
    endl
endf

; def fxaa():
;     for i in range(1, Height - 1):
;         for j in range(1, WIDTH - 1):
;             float luma_m = color_buffer[i][j]
;             float luma_s = color_buffer[i+1][j]
;             float luma_n = color_buffer[i-1][j]
;             float luma_e = color_buffer[i][j+1]
;             float luma_w = color_buffer[i][j-1]
; 
;             float luma_se = (luma_m + luma_s + luma_e + color_buffer[i+1][j+1]) / 4
;             float luma_ne = (luma_m + luma_n + luma_e + color_buffer[i-1][j+1]) / 4
;             float luma_sw = (luma_m + luma_s + luma_w + color_buffer[i+1][j-1]) / 4
;             float luma_nw = (luma_m + luma_n + luma_w + color_buffer[i-1][j-1]) / 4
; 
;             float max_luma = max5f(luma_m, luma_se, luma_ne, luma_sw, luma_nw)
;             float min_luma = min5f(luma_m, luma_se, luma_ne, luma_sw, luma_nw)
; 
;             if max_luma - min_luma < :
;                 
; 
;             endif
;         endl
;     endl
; endf
