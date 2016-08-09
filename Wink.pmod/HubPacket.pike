
/*

[0..3]    4 bytes : MurmurHash3_32 of bytes 4..19
[4..7]    4 bytes : Version
[8..11]   4 bytes : Command
[12..15]  4 bytes : Message length - 24
[16..19]  4 bytes : Nonce
[20..23]  4 bytes : MurmurHash3_32 of bytes 24 - 24 + message length
