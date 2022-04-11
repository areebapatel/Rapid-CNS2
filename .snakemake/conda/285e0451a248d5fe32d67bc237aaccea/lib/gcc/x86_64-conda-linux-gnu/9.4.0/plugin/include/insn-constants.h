/* Generated automatically by the program `genconstants'
   from the machine description file `md'.  */

#ifndef GCC_INSN_CONSTANTS_H
#define GCC_INSN_CONSTANTS_H

#define SI_REG 4
#define XMM13_REG 49
#define PPERM_SIGN 0xc0
#define XMM9_REG 45
#define XMM10_REG 46
#define XMM17_REG 53
#define COM_FALSE_P 3
#define R13_REG 41
#define XMM6_REG 26
#define FPSR_REG 18
#define XMM18_REG 54
#define R10_REG 38
#define XMM3_REG 23
#define ST5_REG 13
#define MM6_REG 34
#define AX_REG 0
#define XMM0_REG 20
#define DI_REG 5
#define MM3_REG 31
#define MASK7_REG 75
#define ROUND_SAE 8
#define ROUND_NEAREST_INT 0
#define PPERM_ZERO 0x80
#define R8_REG 36
#define MM0_REG 28
#define CX_REG 2
#define MASK4_REG 72
#define XMM27_REG 63
#define COM_FALSE_S 2
#define R9_REG 37
#define MASK1_REG 69
#define XMM24_REG 60
#define XMM15_REG 51
#define NO_ROUND 4
#define XMM30_REG 66
#define PPERM_SRC1 0x00
#define PPERM_SRC2 0x10
#define XMM12_REG 48
#define R15_REG 43
#define ROUND_NO_EXC 0x8
#define PCOM_FALSE 0
#define R12_REG 40
#define XMM5_REG 25
#define ST7_REG 15
#define MASK2_REG 70
#define PPERM_REVERSE 0x40
#define BP_REG 6
#define XMM2_REG 22
#define PCOM_TRUE 1
#define ST4_REG 12
#define MM5_REG 33
#define ROUND_TRUNC 0x3
#define XMM21_REG 57
#define PPERM_SRC 0x00
#define ST1_REG 9
#define MM2_REG 30
#define MASK6_REG 74
#define XMM8_REG 44
#define MASK3_REG 71
#define XMM26_REG 62
#define ROUND_MXCSR 0x4
#define PPERM_ONES 0xa0
#define ROUND_ZERO 3
#define FIRST_PSEUDO_REG 76
#define ROUND_FLOOR 0x1
#define PPERM_INV_SIGN 0xe0
#define XMM23_REG 59
#define ROUND_NEG_INF 1
#define XMM14_REG 50
#define BX_REG 3
#define XMM20_REG 56
#define XMM11_REG 47
#define FRAME_REG 19
#define PPERM_INVERT 0x20
#define PPERM_REV_INV 0x60
#define R14_REG 42
#define XMM7_REG 27
#define ROUND_CEIL 0x2
#define COM_TRUE_P 5
#define COM_TRUE_S 4
#define R11_REG 39
#define XMM4_REG 24
#define ST6_REG 14
#define MM7_REG 35
#define SP_REG 7
#define ST2_REG 10
#define ARGP_REG 16
#define MASK0_REG 68
#define XMM1_REG 21
#define XMM29_REG 65
#define ST3_REG 11
#define MM4_REG 32
#define ST0_REG 8
#define MM1_REG 29
#define MASK5_REG 73
#define ROUND_POS_INF 2
#define XMM28_REG 64
#define XMM19_REG 55
#define XMM25_REG 61
#define DX_REG 1
#define XMM16_REG 52
#define XMM31_REG 67
#define FLAGS_REG 17
#define XMM22_REG 58

enum unspec {
  UNSPEC_GOT = 0,
  UNSPEC_GOTOFF = 1,
  UNSPEC_GOTPCREL = 2,
  UNSPEC_GOTTPOFF = 3,
  UNSPEC_TPOFF = 4,
  UNSPEC_NTPOFF = 5,
  UNSPEC_DTPOFF = 6,
  UNSPEC_GOTNTPOFF = 7,
  UNSPEC_INDNTPOFF = 8,
  UNSPEC_PLTOFF = 9,
  UNSPEC_MACHOPIC_OFFSET = 10,
  UNSPEC_PCREL = 11,
  UNSPEC_SIZEOF = 12,
  UNSPEC_STACK_ALLOC = 13,
  UNSPEC_SET_GOT = 14,
  UNSPEC_SET_RIP = 15,
  UNSPEC_SET_GOT_OFFSET = 16,
  UNSPEC_MEMORY_BLOCKAGE = 17,
  UNSPEC_PROBE_STACK = 18,
  UNSPEC_TP = 19,
  UNSPEC_TLS_GD = 20,
  UNSPEC_TLS_LD_BASE = 21,
  UNSPEC_TLSDESC = 22,
  UNSPEC_TLS_IE_SUN = 23,
  UNSPEC_SCAS = 24,
  UNSPEC_FNSTSW = 25,
  UNSPEC_SAHF = 26,
  UNSPEC_NOTRAP = 27,
  UNSPEC_PARITY = 28,
  UNSPEC_FSTCW = 29,
  UNSPEC_REP = 30,
  UNSPEC_LD_MPIC = 31,
  UNSPEC_TRUNC_NOOP = 32,
  UNSPEC_DIV_ALREADY_SPLIT = 33,
  UNSPEC_PAUSE = 34,
  UNSPEC_LEA_ADDR = 35,
  UNSPEC_XBEGIN_ABORT = 36,
  UNSPEC_STOS = 37,
  UNSPEC_PEEPSIB = 38,
  UNSPEC_INSN_FALSE_DEP = 39,
  UNSPEC_SBB = 40,
  UNSPEC_FIX_NOTRUNC = 41,
  UNSPEC_MASKMOV = 42,
  UNSPEC_MOVMSK = 43,
  UNSPEC_RCP = 44,
  UNSPEC_RSQRT = 45,
  UNSPEC_PSADBW = 46,
  UNSPEC_COPYSIGN = 47,
  UNSPEC_XORSIGN = 48,
  UNSPEC_IEEE_MIN = 49,
  UNSPEC_IEEE_MAX = 50,
  UNSPEC_SIN = 51,
  UNSPEC_COS = 52,
  UNSPEC_FPATAN = 53,
  UNSPEC_FYL2X = 54,
  UNSPEC_FYL2XP1 = 55,
  UNSPEC_FRNDINT = 56,
  UNSPEC_FIST = 57,
  UNSPEC_F2XM1 = 58,
  UNSPEC_TAN = 59,
  UNSPEC_FXAM = 60,
  UNSPEC_FRNDINT_FLOOR = 61,
  UNSPEC_FRNDINT_CEIL = 62,
  UNSPEC_FRNDINT_TRUNC = 63,
  UNSPEC_FIST_FLOOR = 64,
  UNSPEC_FIST_CEIL = 65,
  UNSPEC_SINCOS_COS = 66,
  UNSPEC_SINCOS_SIN = 67,
  UNSPEC_XTRACT_FRACT = 68,
  UNSPEC_XTRACT_EXP = 69,
  UNSPEC_FSCALE_FRACT = 70,
  UNSPEC_FSCALE_EXP = 71,
  UNSPEC_FPREM_F = 72,
  UNSPEC_FPREM_U = 73,
  UNSPEC_FPREM1_F = 74,
  UNSPEC_FPREM1_U = 75,
  UNSPEC_C2_FLAG = 76,
  UNSPEC_FXAM_MEM = 77,
  UNSPEC_SP_SET = 78,
  UNSPEC_SP_TEST = 79,
  UNSPEC_ROUND = 80,
  UNSPEC_CRC32 = 81,
  UNSPEC_LZCNT = 82,
  UNSPEC_TZCNT = 83,
  UNSPEC_BEXTR = 84,
  UNSPEC_PDEP = 85,
  UNSPEC_PEXT = 86,
  UNSPEC_INTERRUPT_RETURN = 87,
  UNSPEC_MOVDIRI = 88,
  UNSPEC_MOVDIR64B = 89,
  UNSPEC_MOVNTQ = 90,
  UNSPEC_PFRCP = 91,
  UNSPEC_PFRCPIT1 = 92,
  UNSPEC_PFRCPIT2 = 93,
  UNSPEC_PFRSQRT = 94,
  UNSPEC_PFRSQIT1 = 95,
  UNSPEC_MOVNT = 96,
  UNSPEC_MOVDI_TO_SSE = 97,
  UNSPEC_LDDQU = 98,
  UNSPEC_PSHUFB = 99,
  UNSPEC_PSIGN = 100,
  UNSPEC_PALIGNR = 101,
  UNSPEC_EXTRQI = 102,
  UNSPEC_EXTRQ = 103,
  UNSPEC_INSERTQI = 104,
  UNSPEC_INSERTQ = 105,
  UNSPEC_BLENDV = 106,
  UNSPEC_INSERTPS = 107,
  UNSPEC_DP = 108,
  UNSPEC_MOVNTDQA = 109,
  UNSPEC_MPSADBW = 110,
  UNSPEC_PHMINPOSUW = 111,
  UNSPEC_PTEST = 112,
  UNSPEC_PCMPESTR = 113,
  UNSPEC_PCMPISTR = 114,
  UNSPEC_FMADDSUB = 115,
  UNSPEC_XOP_UNSIGNED_CMP = 116,
  UNSPEC_XOP_TRUEFALSE = 117,
  UNSPEC_XOP_PERMUTE = 118,
  UNSPEC_FRCZ = 119,
  UNSPEC_AESENC = 120,
  UNSPEC_AESENCLAST = 121,
  UNSPEC_AESDEC = 122,
  UNSPEC_AESDECLAST = 123,
  UNSPEC_AESIMC = 124,
  UNSPEC_AESKEYGENASSIST = 125,
  UNSPEC_PCLMUL = 126,
  UNSPEC_PCMP = 127,
  UNSPEC_VPERMIL = 128,
  UNSPEC_VPERMIL2 = 129,
  UNSPEC_VPERMIL2F128 = 130,
  UNSPEC_CAST = 131,
  UNSPEC_VTESTP = 132,
  UNSPEC_VCVTPH2PS = 133,
  UNSPEC_VCVTPS2PH = 134,
  UNSPEC_VPERMVAR = 135,
  UNSPEC_VPERMTI = 136,
  UNSPEC_GATHER = 137,
  UNSPEC_VSIBADDR = 138,
  UNSPEC_VPERMT2 = 139,
  UNSPEC_UNSIGNED_FIX_NOTRUNC = 140,
  UNSPEC_UNSIGNED_PCMP = 141,
  UNSPEC_TESTM = 142,
  UNSPEC_TESTNM = 143,
  UNSPEC_SCATTER = 144,
  UNSPEC_RCP14 = 145,
  UNSPEC_RSQRT14 = 146,
  UNSPEC_FIXUPIMM = 147,
  UNSPEC_SCALEF = 148,
  UNSPEC_VTERNLOG = 149,
  UNSPEC_GETEXP = 150,
  UNSPEC_GETMANT = 151,
  UNSPEC_ALIGN = 152,
  UNSPEC_CONFLICT = 153,
  UNSPEC_COMPRESS = 154,
  UNSPEC_COMPRESS_STORE = 155,
  UNSPEC_EXPAND = 156,
  UNSPEC_MASKED_EQ = 157,
  UNSPEC_MASKED_GT = 158,
  UNSPEC_MASKOP = 159,
  UNSPEC_KORTEST = 160,
  UNSPEC_KTEST = 161,
  UNSPEC_EMBEDDED_ROUNDING = 162,
  UNSPEC_GATHER_PREFETCH = 163,
  UNSPEC_SCATTER_PREFETCH = 164,
  UNSPEC_EXP2 = 165,
  UNSPEC_RCP28 = 166,
  UNSPEC_RSQRT28 = 167,
  UNSPEC_SHA1MSG1 = 168,
  UNSPEC_SHA1MSG2 = 169,
  UNSPEC_SHA1NEXTE = 170,
  UNSPEC_SHA1RNDS4 = 171,
  UNSPEC_SHA256MSG1 = 172,
  UNSPEC_SHA256MSG2 = 173,
  UNSPEC_SHA256RNDS2 = 174,
  UNSPEC_DBPSADBW = 175,
  UNSPEC_PMADDUBSW512 = 176,
  UNSPEC_PMADDWD512 = 177,
  UNSPEC_PSHUFHW = 178,
  UNSPEC_PSHUFLW = 179,
  UNSPEC_CVTINT2MASK = 180,
  UNSPEC_REDUCE = 181,
  UNSPEC_FPCLASS = 182,
  UNSPEC_RANGE = 183,
  UNSPEC_VPMADD52LUQ = 184,
  UNSPEC_VPMADD52HUQ = 185,
  UNSPEC_VPMULTISHIFT = 186,
  UNSPEC_VP4FMADD = 187,
  UNSPEC_VP4FNMADD = 188,
  UNSPEC_VP4DPWSSD = 189,
  UNSPEC_VP4DPWSSDS = 190,
  UNSPEC_GF2P8AFFINEINV = 191,
  UNSPEC_GF2P8AFFINE = 192,
  UNSPEC_GF2P8MUL = 193,
  UNSPEC_VPSHLD = 194,
  UNSPEC_VPSHRD = 195,
  UNSPEC_VPSHRDV = 196,
  UNSPEC_VPSHLDV = 197,
  UNSPEC_VPMADDUBSWACCD = 198,
  UNSPEC_VPMADDUBSWACCSSD = 199,
  UNSPEC_VPMADDWDACCD = 200,
  UNSPEC_VPMADDWDACCSSD = 201,
  UNSPEC_VAESDEC = 202,
  UNSPEC_VAESDECLAST = 203,
  UNSPEC_VAESENC = 204,
  UNSPEC_VAESENCLAST = 205,
  UNSPEC_VPCLMULQDQ = 206,
  UNSPEC_VPSHUFBIT = 207,
  UNSPEC_LFENCE = 208,
  UNSPEC_SFENCE = 209,
  UNSPEC_MFENCE = 210,
  UNSPEC_FILD_ATOMIC = 211,
  UNSPEC_FIST_ATOMIC = 212,
  UNSPEC_LDX_ATOMIC = 213,
  UNSPEC_STX_ATOMIC = 214,
  UNSPEC_LDA = 215,
  UNSPEC_STA = 216
};
#define NUM_UNSPEC_VALUES 217
extern const char *const unspec_strings[];

enum unspecv {
  UNSPECV_UD2 = 0,
  UNSPECV_BLOCKAGE = 1,
  UNSPECV_STACK_PROBE = 2,
  UNSPECV_PROBE_STACK_RANGE = 3,
  UNSPECV_ALIGN = 4,
  UNSPECV_PROLOGUE_USE = 5,
  UNSPECV_SPLIT_STACK_RETURN = 6,
  UNSPECV_CLD = 7,
  UNSPECV_NOPS = 8,
  UNSPECV_RDTSC = 9,
  UNSPECV_RDTSCP = 10,
  UNSPECV_RDPMC = 11,
  UNSPECV_LLWP_INTRINSIC = 12,
  UNSPECV_SLWP_INTRINSIC = 13,
  UNSPECV_LWPVAL_INTRINSIC = 14,
  UNSPECV_LWPINS_INTRINSIC = 15,
  UNSPECV_RDFSBASE = 16,
  UNSPECV_RDGSBASE = 17,
  UNSPECV_WRFSBASE = 18,
  UNSPECV_WRGSBASE = 19,
  UNSPECV_FXSAVE = 20,
  UNSPECV_FXRSTOR = 21,
  UNSPECV_FXSAVE64 = 22,
  UNSPECV_FXRSTOR64 = 23,
  UNSPECV_XSAVE = 24,
  UNSPECV_XRSTOR = 25,
  UNSPECV_XSAVE64 = 26,
  UNSPECV_XRSTOR64 = 27,
  UNSPECV_XSAVEOPT = 28,
  UNSPECV_XSAVEOPT64 = 29,
  UNSPECV_XSAVES = 30,
  UNSPECV_XRSTORS = 31,
  UNSPECV_XSAVES64 = 32,
  UNSPECV_XRSTORS64 = 33,
  UNSPECV_XSAVEC = 34,
  UNSPECV_XSAVEC64 = 35,
  UNSPECV_XGETBV = 36,
  UNSPECV_XSETBV = 37,
  UNSPECV_WBINVD = 38,
  UNSPECV_WBNOINVD = 39,
  UNSPECV_FNSTENV = 40,
  UNSPECV_FLDENV = 41,
  UNSPECV_FNSTSW = 42,
  UNSPECV_FNCLEX = 43,
  UNSPECV_RDRAND = 44,
  UNSPECV_RDSEED = 45,
  UNSPECV_XBEGIN = 46,
  UNSPECV_XEND = 47,
  UNSPECV_XABORT = 48,
  UNSPECV_XTEST = 49,
  UNSPECV_NLGR = 50,
  UNSPECV_CLWB = 51,
  UNSPECV_CLFLUSHOPT = 52,
  UNSPECV_MONITORX = 53,
  UNSPECV_MWAITX = 54,
  UNSPECV_CLZERO = 55,
  UNSPECV_PKU = 56,
  UNSPECV_RDPID = 57,
  UNSPECV_NOP_ENDBR = 58,
  UNSPECV_NOP_RDSSP = 59,
  UNSPECV_INCSSP = 60,
  UNSPECV_SAVEPREVSSP = 61,
  UNSPECV_RSTORSSP = 62,
  UNSPECV_WRSS = 63,
  UNSPECV_WRUSS = 64,
  UNSPECV_SETSSBSY = 65,
  UNSPECV_CLRSSBSY = 66,
  UNSPECV_UMWAIT = 67,
  UNSPECV_UMONITOR = 68,
  UNSPECV_TPAUSE = 69,
  UNSPECV_CLDEMOTE = 70,
  UNSPECV_SPECULATION_BARRIER = 71,
  UNSPECV_PTWRITE = 72,
  UNSPECV_EMMS = 73,
  UNSPECV_FEMMS = 74,
  UNSPECV_LDMXCSR = 75,
  UNSPECV_STMXCSR = 76,
  UNSPECV_CLFLUSH = 77,
  UNSPECV_MONITOR = 78,
  UNSPECV_MWAIT = 79,
  UNSPECV_VZEROALL = 80,
  UNSPECV_VZEROUPPER = 81,
  UNSPECV_CMPXCHG = 82,
  UNSPECV_XCHG = 83,
  UNSPECV_LOCK = 84
};
#define NUM_UNSPECV_VALUES 85
extern const char *const unspecv_strings[];

#endif /* GCC_INSN_CONSTANTS_H */