#define O(X) (X&0xffffffff)
#define ROT32(x, y) (O(x << y) | O(x >> O(32 - y))) // avoid effort
int murmur3_32(string(1..1) key, int seed) {
	int c1 = 0xcc9e2d51;
	int c2 = 0x1b873593;
	int r1 = 15;
	int r2 = 13;
	int m = 5;
	int n = 0xe6546b64;

	int hash = seed;
        int len = sizeof(key);
	int nblocks = len / 4;
	int i;
	int k;
	for (i = 0; i < nblocks; i++) {
		sscanf(key, "%*" + (i*4) + "c%-4c", k);

		k = O(k) * c1;
		k = ROT32(O(k), r1);
		k = O(k) * c2;

		hash = O(hash) ^ O(k);
		hash = O(O(ROT32(O(hash), r2)) * m) + n;
                hash = O(hash);
	}

	int tail = nblocks * 4;
	int k1 = 0;

	switch (len & 3) {
	case 3:
		k1 ^= (0xffffffff & (key[tail+2] << 16));
	case 2:
		k1 = (k1 ^ (0xffffffff & (key[tail+1] << 8)) & 0xffffffff);
	case 1:

		k1 ^= O(key[tail]);

		k1 = O(k1) * c1;
		k1 = O(ROT32(O(k1), r1));
		k1 = O(k1) * c2;
		hash ^= O(k1);
                hash = O(hash);
  }

	hash ^= len;

	hash = O(hash) ^ O(O(hash) >> 16);
	hash = O(hash) * 0x85ebca6b;
	hash = O(hash) ^ O(O(hash) >> 13);
	hash = O(hash) * 0xc2b2ae35;
	hash = O(hash) ^ O(O(hash) >> 16);

	return O(hash);
}
