#include <stdbool.h>

static unsigned short table[256] =
{
    0x0000, 0x6757, 0xe9f9, 0x8eae, 0xf4a5, 0x93f2, 0x1d5c, 0x7a0b,
    0xce1d, 0xa94a, 0x27e4, 0x40b3, 0x3ab8, 0x5def, 0xd341, 0xb416,
    0x9c3a, 0xfb6d, 0x75c3, 0x1294, 0x689f, 0x0fc8, 0x8166, 0xe631,
    0x5227, 0x3570, 0xbbde, 0xdc89, 0xa682, 0xc1d5, 0x4f7b, 0x282c,
    0x3874, 0x5f23, 0xd18d, 0xb6da, 0xccd1, 0xab86, 0x2528, 0x427f,
    0xf669, 0x913e, 0x1f90, 0x78c7, 0x02cc, 0x659b, 0xeb35, 0x8c62,
    0xa44e, 0xc319, 0x4db7, 0x2ae0, 0x50eb, 0x37bc, 0xb912, 0xde45,
    0x6a53, 0x0d04, 0x83aa, 0xe4fd, 0x9ef6, 0xf9a1, 0x770f, 0x1058,
    0x57bf, 0x30e8, 0xbe46, 0xd911, 0xa31a, 0xc44d, 0x4ae3, 0x2db4,
    0x99a2, 0xfef5, 0x705b, 0x170c, 0x6d07, 0x0a50, 0x84fe, 0xe3a9,
    0xcb85, 0xacd2, 0x227c, 0x452b, 0x3f20, 0x5877, 0xd6d9, 0xb18e,
    0x0598, 0x62cf, 0xec61, 0x8b36, 0xf13d, 0x966a, 0x18c4, 0x7f93,
    0x6fcb, 0x089c, 0x8632, 0xe165, 0x9b6e, 0xfc39, 0x7297, 0x15c0,
    0xa1d6, 0xc681, 0x482f, 0x2f78, 0x5573, 0x3224, 0xbc8a, 0xdbdd,
    0xf3f1, 0x94a6, 0x1a08, 0x7d5f, 0x0754, 0x6003, 0xeead, 0x89fa,
    0x3dec, 0x5abb, 0xd415, 0xb342, 0xc949, 0xae1e, 0x20b0, 0x47e7,
    0xaf7e, 0xc829, 0x4687, 0x21d0, 0x5bdb, 0x3c8c, 0xb222, 0xd575,
    0x6163, 0x0634, 0x889a, 0xefcd, 0x95c6, 0xf291, 0x7c3f, 0x1b68,
    0x3344, 0x5413, 0xdabd, 0xbdea, 0xc7e1, 0xa0b6, 0x2e18, 0x494f,
    0xfd59, 0x9a0e, 0x14a0, 0x73f7, 0x09fc, 0x6eab, 0xe005, 0x8752,
    0x970a, 0xf05d, 0x7ef3, 0x19a4, 0x63af, 0x04f8, 0x8a56, 0xed01,
    0x5917, 0x3e40, 0xb0ee, 0xd7b9, 0xadb2, 0xcae5, 0x444b, 0x231c,
    0x0b30, 0x6c67, 0xe2c9, 0x859e, 0xff95, 0x98c2, 0x166c, 0x713b,
    0xc52d, 0xa27a, 0x2cd4, 0x4b83, 0x3188, 0x56df, 0xd871, 0xbf26,
    0xf8c1, 0x9f96, 0x1138, 0x766f, 0x0c64, 0x6b33, 0xe59d, 0x82ca,
    0x36dc, 0x518b, 0xdf25, 0xb872, 0xc279, 0xa52e, 0x2b80, 0x4cd7,
    0x64fb, 0x03ac, 0x8d02, 0xea55, 0x905e, 0xf709, 0x79a7, 0x1ef0,
    0xaae6, 0xcdb1, 0x431f, 0x2448, 0x5e43, 0x3914, 0xb7ba, 0xd0ed,
    0xc0b5, 0xa7e2, 0x294c, 0x4e1b, 0x3410, 0x5347, 0xdde9, 0xbabe,
    0x0ea8, 0x69ff, 0xe751, 0x8006, 0xfa0d, 0x9d5a, 0x13f4, 0x74a3,
    0x5c8f, 0x3bd8, 0xb576, 0xd221, 0xa82a, 0xcf7d, 0x41d3, 0x2684,
    0x9292, 0xf5c5, 0x7b6b, 0x1c3c, 0x6637, 0x0160, 0x8fce, 0xe899
};

short crc14(unsigned char const *data, int length)
{
    unsigned short remainder = 0;
    unsigned char index;
    int i;

    for(i = 0; i < length; ++i)
    {
        index = remainder >> 6;
        remainder <<= 8;
        remainder |= data[i];
        remainder ^= table[index];
    }

    return remainder & 0x3fff;
}

bool crc14_check(unsigned char const *data, int length)
{
    return !crc14(data, length);
}
