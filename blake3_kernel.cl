enum blake3_flags {
    CHUNK_START         = 1 << 0,
    CHUNK_END           = 1 << 1,
    PARENT              = 1 << 2,
    ROOT                = 1 << 3,
    KEYED_HASH          = 1 << 4,
    DERIVE_KEY_CONTEXT  = 1 << 5,
    DERIVE_KEY_MATERIAL = 1 << 6,
};

#define MAX_SIMD_DEGREE 1

#define MAX_SIMD_DEGREE_OR_2 (MAX_SIMD_DEGREE > 2 ? MAX_SIMD_DEGREE : 2)



#define BLAKE3_KEY_LEN 32
#define BLAKE3_OUT_LEN 32
#define BLAKE3_BLOCK_LEN 64
#define BLAKE3_CHUNK_LEN 1024
#define BLAKE3_MAX_DEPTH 54
#define BLAKE3_MAX_SIMD_DEGREE 16

__constant static const uchar MSG_SCHEDULE[7][16] = {
        {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15},
        {2, 6, 3, 10, 7, 0, 4, 13, 1, 11, 12, 5, 9, 14, 15, 8},
        {3, 4, 10, 12, 13, 2, 7, 14, 6, 5, 9, 0, 11, 15, 8, 1},
        {10, 7, 12, 9, 14, 3, 13, 15, 4, 0, 11, 2, 5, 8, 1, 6},
        {12, 13, 9, 11, 15, 10, 14, 8, 7, 2, 5, 3, 0, 1, 6, 4},
        {9, 14, 11, 5, 8, 12, 15, 1, 13, 3, 0, 10, 2, 6, 4, 7},
        {11, 15, 5, 0, 1, 9, 8, 6, 14, 10, 2, 12, 3, 4, 7, 13},
};

__constant static const uint IV[8] = {0x6A09E667U, 0xBB67AE85U, 0x3C6EF372U,
                           0xA54FF53AU, 0x510E527FU, 0x9B05688CU,
                           0x1F83D9ABU, 0x5BE0CD19U};


void round_fn(uint state[16], const uint *msg, ulong round) {
    __constant const uchar *schedule = MSG_SCHEDULE[round];
    state[0] = state[0] + state[4] + msg[schedule[0]];
    state[12] = ((state[12] ^ state[0]) >> 16) | ((state[12] ^ state[0]) << (32 - 16));
    state[8] = state[8] + state[12];
    state[4] = ((state[4] ^ state[8]) >> 12) | ((state[4] ^ state[8]) << (32 - 12));
    state[0] = state[0] + state[4] + msg[schedule[1]];
    state[12] = ((state[12] ^ state[0]) >> 8) | ((state[12] ^ state[0]) << (32 - 8));
    state[8] = state[8] + state[12];
    state[4] = ((state[4] ^ state[8]) >> 7) | ((state[4] ^ state[8]) << (32 - 7));
    state[1] = state[1] + state[5] + msg[schedule[2]];
    state[13] = ((state[13] ^ state[1]) >> 16) | ((state[13] ^ state[1]) << (32 - 16));
    state[9] = state[9] + state[13];
    state[5] = ((state[5] ^ state[9]) >> 12) | ((state[5] ^ state[9]) << (32 - 12));
    state[1] = state[1] + state[5] + msg[schedule[3]];
    state[13] = ((state[13] ^ state[1]) >> 8) | ((state[13] ^ state[1]) << (32 - 8));
    state[9] = state[9] + state[13];
    state[5] = ((state[5] ^ state[9]) >> 7) | ((state[5] ^ state[9]) << (32 - 7));
    state[2] = state[2] + state[6] + msg[schedule[4]];
    state[14] = ((state[14] ^ state[2]) >> 16) | ((state[14] ^ state[2]) << (32 - 16));
    state[10] = state[10] + state[14];
    state[6] = ((state[6] ^ state[10]) >> 12) | ((state[6] ^ state[10]) << (32 - 12));
    state[2] = state[2] + state[6] + msg[schedule[5]];
    state[14] = ((state[14] ^ state[2]) >> 8) | ((state[14] ^ state[2]) << (32 - 8));
    state[10] = state[10] + state[14];
    state[6] = ((state[6] ^ state[10]) >> 7) | ((state[6] ^ state[10]) << (32 - 7));
    state[3] = state[3] + state[7] + msg[schedule[6]];
    state[15] = ((state[15] ^ state[3]) >> 16) | ((state[15] ^ state[3]) << (32 - 16));
    state[11] = state[11] + state[15];
    state[7] = ((state[7] ^ state[11]) >> 12) | ((state[7] ^ state[11]) << (32 - 12));
    state[3] = state[3] + state[7] + msg[schedule[7]];
    state[15] = ((state[15] ^ state[3]) >> 8) | ((state[15] ^ state[3]) << (32 - 8));
    state[11] = state[11] + state[15];
    state[7] = ((state[7] ^ state[11]) >> 7) | ((state[7] ^ state[11]) << (32 - 7));
    state[0] = state[0] + state[5] + msg[schedule[8]];
    state[15] = ((state[15] ^ state[0]) >> 16) | ((state[15] ^ state[0]) << (32 - 16));
    state[10] = state[10] + state[15];
    state[5] = ((state[5] ^ state[10]) >> 12) | ((state[5] ^ state[10]) << (32 - 12));
    state[0] = state[0] + state[5] + msg[schedule[9]];
    state[15] = ((state[15] ^ state[0]) >> 8) | ((state[15] ^ state[0]) << (32 - 8));
    state[10] = state[10] + state[15];
    state[5] = ((state[5] ^ state[10]) >> 7) | ((state[5] ^ state[10]) << (32 - 7));
    state[1] = state[1] + state[6] + msg[schedule[10]];
    state[12] = ((state[12] ^ state[1]) >> 16) | ((state[12] ^ state[1]) << (32 - 16));
    state[11] = state[11] + state[12];
    state[6] = ((state[6] ^ state[11]) >> 12) | ((state[6] ^ state[11]) << (32 - 12));
    state[1] = state[1] + state[6] + msg[schedule[11]];
    state[12] = ((state[12] ^ state[1]) >> 8) | ((state[12] ^ state[1]) << (32 - 8));
    state[11] = state[11] + state[12];
    state[6] = ((state[6] ^ state[11]) >> 7) | ((state[6] ^ state[11]) << (32 - 7));
    state[2] = state[2] + state[7] + msg[schedule[12]];
    state[13] = ((state[13] ^ state[2]) >> 16) | ((state[13] ^ state[2]) << (32 - 16));
    state[8] = state[8] + state[13];
    state[7] = ((state[7] ^ state[8]) >> 12) | ((state[7] ^ state[8]) << (32 - 12));
    state[2] = state[2] + state[7] + msg[schedule[13]];
    state[13] = ((state[13] ^ state[2]) >> 8) | ((state[13] ^ state[2]) << (32 - 8));
    state[8] = state[8] + state[13];
    state[7] = ((state[7] ^ state[8]) >> 7) | ((state[7] ^ state[8]) << (32 - 7));
    state[3] = state[3] + state[4] + msg[schedule[14]];
    state[14] = ((state[14] ^ state[3]) >> 16) | ((state[14] ^ state[3]) << (32 - 16));
    state[9] = state[9] + state[14];
    state[4] = ((state[4] ^ state[9]) >> 12) | ((state[4] ^ state[9]) << (32 - 12));
    state[3] = state[3] + state[4] + msg[schedule[15]];
    state[14] = ((state[14] ^ state[3]) >> 8) | ((state[14] ^ state[3]) << (32 - 8));
    state[9] = state[9] + state[14];
    state[4] = ((state[4] ^ state[9]) >> 7) | ((state[4] ^ state[9]) << (32 - 7));
}

void compress_pre(uint state[16], const uint cv[8],
                         const uchar block[BLAKE3_BLOCK_LEN],
                         uchar block_len, ulong counter, uchar flags) {
    uint block_words[16];
    const uchar *p = (const uchar *) (block + 4 * 0);
    block_words[0] = ((uint) (p[0]) << 0) | ((uint) (p[1]) << 8) |
                     ((uint) (p[2]) << 16) | ((uint) (p[3]) << 24);
    const uchar *p1 = (const uchar *) (block + 4 * 1);
    block_words[1] = ((uint) (p1[0]) << 0) | ((uint) (p1[1]) << 8) |
                     ((uint) (p1[2]) << 16) | ((uint) (p1[3]) << 24);
    const uchar *p2 = (const uchar *) (block + 4 * 2);
    block_words[2] = ((uint) (p2[0]) << 0) | ((uint) (p2[1]) << 8) |
                     ((uint) (p2[2]) << 16) | ((uint) (p2[3]) << 24);
    const uchar *p3 = (const uchar *) (block + 4 * 3);
    block_words[3] = ((uint) (p3[0]) << 0) | ((uint) (p3[1]) << 8) |
                     ((uint) (p3[2]) << 16) | ((uint) (p3[3]) << 24);
    const uchar *p4 = (const uchar *) (block + 4 * 4);
    block_words[4] = ((uint) (p4[0]) << 0) | ((uint) (p4[1]) << 8) |
                     ((uint) (p4[2]) << 16) | ((uint) (p4[3]) << 24);
    const uchar *p5 = (const uchar *) (block + 4 * 5);
    block_words[5] = ((uint) (p5[0]) << 0) | ((uint) (p5[1]) << 8) |
                     ((uint) (p5[2]) << 16) | ((uint) (p5[3]) << 24);
    const uchar *p6 = (const uchar *) (block + 4 * 6);
    block_words[6] = ((uint) (p6[0]) << 0) | ((uint) (p6[1]) << 8) |
                     ((uint) (p6[2]) << 16) | ((uint) (p6[3]) << 24);
    const uchar *p7 = (const uchar *) (block + 4 * 7);
    block_words[7] = ((uint) (p7[0]) << 0) | ((uint) (p7[1]) << 8) |
                     ((uint) (p7[2]) << 16) | ((uint) (p7[3]) << 24);
    const uchar *p8 = (const uchar *) (block + 4 * 8);
    block_words[8] = ((uint) (p8[0]) << 0) | ((uint) (p8[1]) << 8) |
                     ((uint) (p8[2]) << 16) | ((uint) (p8[3]) << 24);
    const uchar *p9 = (const uchar *) (block + 4 * 9);
    block_words[9] = ((uint) (p9[0]) << 0) | ((uint) (p9[1]) << 8) |
                     ((uint) (p9[2]) << 16) | ((uint) (p9[3]) << 24);
    const uchar *p10 = (const uchar *) (block + 4 * 10);
    block_words[10] = ((uint) (p10[0]) << 0) | ((uint) (p10[1]) << 8) |
                      ((uint) (p10[2]) << 16) | ((uint) (p10[3]) << 24);
    const uchar *p11 = (const uchar *) (block + 4 * 11);
    block_words[11] = ((uint) (p11[0]) << 0) | ((uint) (p11[1]) << 8) |
                      ((uint) (p11[2]) << 16) | ((uint) (p11[3]) << 24);
    const uchar *p12 = (const uchar *) (block + 4 * 12);
    block_words[12] = ((uint) (p12[0]) << 0) | ((uint) (p12[1]) << 8) |
                      ((uint) (p12[2]) << 16) | ((uint) (p12[3]) << 24);
    const uchar *p13 = (const uchar *) (block + 4 * 13);
    block_words[13] = ((uint) (p13[0]) << 0) | ((uint) (p13[1]) << 8) |
                      ((uint) (p13[2]) << 16) | ((uint) (p13[3]) << 24);
    const uchar *p14 = (const uchar *) (block + 4 * 14);
    block_words[14] = ((uint) (p14[0]) << 0) | ((uint) (p14[1]) << 8) |
                      ((uint) (p14[2]) << 16) | ((uint) (p14[3]) << 24);
    const uchar *p15 = (const uchar *) (block + 4 * 15);
    block_words[15] = ((uint) (p15[0]) << 0) | ((uint) (p15[1]) << 8) |
                      ((uint) (p15[2]) << 16) | ((uint) (p15[3]) << 24);

    state[0] = cv[0];
    state[1] = cv[1];
    state[2] = cv[2];
    state[3] = cv[3];
    state[4] = cv[4];
    state[5] = cv[5];
    state[6] = cv[6];
    state[7] = cv[7];
    state[8] = IV[0];
    state[9] = IV[1];
    state[10] = IV[2];
    state[11] = IV[3];
    state[12] = (uint) counter;
    state[13] = (uint) (counter >> 32);
    state[14] = (uint)block_len;
    state[15] = (uint)flags;

    round_fn(state, (const uint *) &block_words[0], 0);
    round_fn(state, &block_words[0], 1);
    round_fn(state, &block_words[0], 2);
    round_fn(state, &block_words[0], 3);
    round_fn(state, &block_words[0], 4);
    round_fn(state, &block_words[0], 5);
    round_fn(state, &block_words[0], 6);
}

void blake3_compress_in_place(uint cv[8],
                                       const uchar block[BLAKE3_BLOCK_LEN],
                                       uchar block_len, ulong counter,
                                       uchar flags) {
    uint state[16];
    compress_pre(state, cv, block, block_len, counter, flags);
    cv[0] = state[0] ^ state[8];
    cv[1] = state[1] ^ state[9];
    cv[2] = state[2] ^ state[10];
    cv[3] = state[3] ^ state[11];
    cv[4] = state[4] ^ state[12];
    cv[5] = state[5] ^ state[13];
    cv[6] = state[6] ^ state[14];
    cv[7] = state[7] ^ state[15];
}

void blake3_compress_xof(const uint cv[8],
                                  const uchar block[BLAKE3_BLOCK_LEN],
                                  uchar block_len, ulong counter,
                                  uchar flags, uchar out[64]) {
    uint state[16];
    compress_pre(state, cv, block, block_len, counter, flags);

    uchar *p = (uchar *) &out[0 * 4];
    p[0] = (uchar) ((state[0] ^ state[8]) >> 0);
    p[1] = (uchar) ((state[0] ^ state[8]) >> 8);
    p[2] = (uchar) ((state[0] ^ state[8]) >> 16);
    p[3] = (uchar) ((state[0] ^ state[8]) >> 24);
    uchar *p1 = (uchar *) &out[1 * 4];
    p1[0] = (uchar) ((state[1] ^ state[9]) >> 0);
    p1[1] = (uchar) ((state[1] ^ state[9]) >> 8);
    p1[2] = (uchar) ((state[1] ^ state[9]) >> 16);
    p1[3] = (uchar) ((state[1] ^ state[9]) >> 24);
    uchar *p2 = (uchar *) &out[2 * 4];
    p2[0] = (uchar) ((state[2] ^ state[10]) >> 0);
    p2[1] = (uchar) ((state[2] ^ state[10]) >> 8);
    p2[2] = (uchar) ((state[2] ^ state[10]) >> 16);
    p2[3] = (uchar) ((state[2] ^ state[10]) >> 24);
    uchar *p3 = (uchar *) &out[3 * 4];
    p3[0] = (uchar) ((state[3] ^ state[11]) >> 0);
    p3[1] = (uchar) ((state[3] ^ state[11]) >> 8);
    p3[2] = (uchar) ((state[3] ^ state[11]) >> 16);
    p3[3] = (uchar) ((state[3] ^ state[11]) >> 24);
    uchar *p4 = (uchar *) &out[4 * 4];
    p4[0] = (uchar) ((state[4] ^ state[12]) >> 0);
    p4[1] = (uchar) ((state[4] ^ state[12]) >> 8);
    p4[2] = (uchar) ((state[4] ^ state[12]) >> 16);
    p4[3] = (uchar) ((state[4] ^ state[12]) >> 24);
    uchar *p5 = (uchar *) &out[5 * 4];
    p5[0] = (uchar) ((state[5] ^ state[13]) >> 0);
    p5[1] = (uchar) ((state[5] ^ state[13]) >> 8);
    p5[2] = (uchar) ((state[5] ^ state[13]) >> 16);
    p5[3] = (uchar) ((state[5] ^ state[13]) >> 24);
    uchar *p6 = (uchar *) &out[6 * 4];
    p6[0] = (uchar) ((state[6] ^ state[14]) >> 0);
    p6[1] = (uchar) ((state[6] ^ state[14]) >> 8);
    p6[2] = (uchar) ((state[6] ^ state[14]) >> 16);
    p6[3] = (uchar) ((state[6] ^ state[14]) >> 24);
    uchar *p7 = (uchar *) &out[7 * 4];
    p7[0] = (uchar) ((state[7] ^ state[15]) >> 0);
    p7[1] = (uchar) ((state[7] ^ state[15]) >> 8);
    p7[2] = (uchar) ((state[7] ^ state[15]) >> 16);
    p7[3] = (uchar) ((state[7] ^ state[15]) >> 24);
    uchar *p8 = (uchar *) &out[8 * 4];
    p8[0] = (uchar) ((state[8] ^ cv[0]) >> 0);
    p8[1] = (uchar) ((state[8] ^ cv[0]) >> 8);
    p8[2] = (uchar) ((state[8] ^ cv[0]) >> 16);
    p8[3] = (uchar) ((state[8] ^ cv[0]) >> 24);
    uchar *p9 = (uchar *) &out[9 * 4];
    p9[0] = (uchar) ((state[9] ^ cv[1]) >> 0);
    p9[1] = (uchar) ((state[9] ^ cv[1]) >> 8);
    p9[2] = (uchar) ((state[9] ^ cv[1]) >> 16);
    p9[3] = (uchar) ((state[9] ^ cv[1]) >> 24);
    uchar *p10 = (uchar *) &out[10 * 4];
    p10[0] = (uchar) ((state[10] ^ cv[2]) >> 0);
    p10[1] = (uchar) ((state[10] ^ cv[2]) >> 8);
    p10[2] = (uchar) ((state[10] ^ cv[2]) >> 16);
    p10[3] = (uchar) ((state[10] ^ cv[2]) >> 24);
    uchar *p11 = (uchar *) &out[11 * 4];
    p11[0] = (uchar) ((state[11] ^ cv[3]) >> 0);
    p11[1] = (uchar) ((state[11] ^ cv[3]) >> 8);
    p11[2] = (uchar) ((state[11] ^ cv[3]) >> 16);
    p11[3] = (uchar) ((state[11] ^ cv[3]) >> 24);
    uchar *p12 = (uchar *) &out[12 * 4];
    p12[0] = (uchar) ((state[12] ^ cv[4]) >> 0);
    p12[1] = (uchar) ((state[12] ^ cv[4]) >> 8);
    p12[2] = (uchar) ((state[12] ^ cv[4]) >> 16);
    p12[3] = (uchar) ((state[12] ^ cv[4]) >> 24);
    uchar *p13 = (uchar *) &out[13 * 4];
    p13[0] = (uchar) ((state[13] ^ cv[5]) >> 0);
    p13[1] = (uchar) ((state[13] ^ cv[5]) >> 8);
    p13[2] = (uchar) ((state[13] ^ cv[5]) >> 16);
    p13[3] = (uchar) ((state[13] ^ cv[5]) >> 24);
    uchar *p14 = (uchar *) &out[14 * 4];
    p14[0] = (uchar) ((state[14] ^ cv[6]) >> 0);
    p14[1] = (uchar) ((state[14] ^ cv[6]) >> 8);
    p14[2] = (uchar) ((state[14] ^ cv[6]) >> 16);
    p14[3] = (uchar) ((state[14] ^ cv[6]) >> 24);
    uchar *p15 = (uchar *) &out[15 * 4];
    p15[0] = (uchar) ((state[15] ^ cv[7]) >> 0);
    p15[1] = (uchar) ((state[15] ^ cv[7]) >> 8);
    p15[2] = (uchar) ((state[15] ^ cv[7]) >> 16);
    p15[3] = (uchar) ((state[15] ^ cv[7]) >> 24);
}

void blake3_hash_many(const uchar *const *inputs, ulong num_inputs,
                               ulong blocks, const uint key[8],
                               ulong counter, bool increment_counter,
                               uchar flags, uchar flags_start,
                               uchar flags_end, uchar *out) {
    while (num_inputs > 0) {
        uchar *input = inputs[0];
        ulong blocks1 = blocks;
        uint cv[8];
        for (ulong i = 0; i < BLAKE3_KEY_LEN; ++i) {
            cv[i] = key[i];
        }
        uchar blockFlags = flags | flags_start;
        while (blocks1 > 0) {
            if (blocks1 == 1) {
                blockFlags |= flags_end;
            }
            blake3_compress_in_place(cv, input, BLAKE3_BLOCK_LEN, counter,
                                     blockFlags);
            input = &input[BLAKE3_BLOCK_LEN];
            blocks1 -= 1;
            blockFlags = flags;
        }
        for (ulong i1 = 0; i1 < 32; ++i1) {
            out[i1] = cv[i1];
        }
        if (increment_counter) {
            counter += 1;
        }
        inputs += 1;
        num_inputs -= 1;
        out = &out[BLAKE3_OUT_LEN];
    }
}

typedef struct {
    uint cv[8];
    ulong chunk_counter;
    uchar buf[BLAKE3_BLOCK_LEN];
    uchar buf_len;
    uchar blocks_compressed;
    uchar flags;
} blake3_chunk_state;

typedef struct {
    uint key[8];
    blake3_chunk_state chunk;
    uchar cv_stack_len;
    uchar cv_stack[(BLAKE3_MAX_DEPTH + 1) * BLAKE3_OUT_LEN];
} blake3_hasher;

typedef struct {
    uint input_cv[8];
    ulong counter;
    uchar block[BLAKE3_BLOCK_LEN];
    uchar block_len;
    uchar flags;
} output_t;

void blake3_hasher_update(blake3_hasher *self, __global const void *input, ulong input_len);
void blake3_hasher_finalize(const blake3_hasher *self, __global uchar *out, ulong out_len);
void blake3_hasher_finalize_seek(const blake3_hasher *self, ulong seek, __global uchar *out, ulong out_len);

static ulong blake3_compress_subtree_wide(__global const uchar *input, ulong input_len, const uint key[8], ulong chunk_counter, uchar flags, uchar *out) {
    if (input_len <= 1 * BLAKE3_CHUNK_LEN) {
        ulong result;
        __global const uchar *chunksArray[MAX_SIMD_DEGREE];
        ulong inputPosition = 0;
        ulong chunksArrayLen = 0;
        while (input_len - inputPosition >= BLAKE3_CHUNK_LEN) {
            chunksArray[chunksArrayLen] = &input[inputPosition];
            inputPosition += BLAKE3_CHUNK_LEN;
            chunksArrayLen += 1;
        }

        blake3_hash_many(chunksArray, chunksArrayLen,
                         BLAKE3_CHUNK_LEN / BLAKE3_BLOCK_LEN, key, chunk_counter,
                         true, flags, CHUNK_START, CHUNK_END, out);
        if (input_len > inputPosition) {
            ulong counter = chunk_counter + (ulong) chunksArrayLen;
            blake3_chunk_state chunkState;
            for (ulong i = 0; i < BLAKE3_KEY_LEN; ++i) {
                (&chunkState)->cv[i] = key[i];
            }
            (&chunkState)->chunk_counter = 0;
            for (ulong i1 = 0; i1 < BLAKE3_BLOCK_LEN; ++i1) {
                (&chunkState)->buf[i1] = 0;
            }
            (&chunkState)->buf_len = 0;
            (&chunkState)->blocks_compressed = 0;
            (&chunkState)->flags = flags;
            chunkState.chunk_counter = counter;
            __global uchar *input11 = &input[inputPosition];
            ulong inputLen1 = input_len - inputPosition;
            if ((&chunkState)->buf_len > 0) {
                ulong take1 = BLAKE3_BLOCK_LEN - ((ulong) (&chunkState)->buf_len);
                if (take1 > inputLen1) {
                    take1 = inputLen1;
                }
                uchar *dest = (&chunkState)->buf + ((ulong) (&chunkState)->buf_len);
                for (ulong i12 = 0; i12 < take1; ++i12) {
                    dest[i12] = input11[i12];
                }
                (&chunkState)->buf_len += (uchar) take1;
                ulong take = take1;
                input11 += take;
                inputLen1 -= take;
                if (inputLen1 > 0) {
                    uchar result1;
                    if ((&chunkState)->blocks_compressed == 0) {
                        result1 = CHUNK_START;
                    } else {
                        result1 = 0;
                    }
                    blake3_compress_in_place(
                            (&chunkState)->cv, (&chunkState)->buf, BLAKE3_BLOCK_LEN, (&chunkState)->chunk_counter,
                            (&chunkState)->flags | result1);
                    (&chunkState)->blocks_compressed += 1;
                    (&chunkState)->buf_len = 0;
                    for (ulong i3 = 0; i3 < BLAKE3_BLOCK_LEN; ++i3) {
                        (&chunkState)->buf[i3] = 0;
                    }
                }
            }

            while (inputLen1 > BLAKE3_BLOCK_LEN) {
                uchar result1;
                if ((&chunkState)->blocks_compressed == 0) {
                    result1 = CHUNK_START;
                } else {
                    result1 = 0;
                }
                blake3_compress_in_place((&chunkState)->cv, input11, BLAKE3_BLOCK_LEN,
                                         (&chunkState)->chunk_counter,
                                         (&chunkState)->flags | result1);
                (&chunkState)->blocks_compressed += 1;
                input11 += BLAKE3_BLOCK_LEN;
                inputLen1 -= BLAKE3_BLOCK_LEN;
            }

            ulong take2 = BLAKE3_BLOCK_LEN - ((ulong) (&chunkState)->buf_len);
            if (take2 > inputLen1) {
                take2 = inputLen1;
            }
            uchar *dest1 = (&chunkState)->buf + ((ulong) (&chunkState)->buf_len);
            for (ulong i21 = 0; i21 < take2; ++i21) {
                dest1[i21] = input11[i21];
            }
            (&chunkState)->buf_len += (uchar) take2;
            ulong take = take2;
            input11 += take;
            inputLen1 -= take;
            uchar result2;
            if ((&chunkState)->blocks_compressed == 0) {
                result2 = CHUNK_START;
            } else {
                result2 = 0;
            }
            uchar blockFlags =
                    (&chunkState)->flags | result2 | CHUNK_END;
            output_t ret;
            for (ulong i4 = 0; i4 < 32; ++i4) {
                ret.input_cv[i4] = (&chunkState)->cv[i4];
            }
            for (ulong i13 = 0; i13 < BLAKE3_BLOCK_LEN; ++i13) {
                ret.block[i13] = (&chunkState)->buf[i13];
            }
            ret.block_len = (&chunkState)->buf_len;
            ret.counter = (&chunkState)->chunk_counter;
            ret.flags = blockFlags;
            output_t output = ret;
            uint cvWords[8];
            for (ulong i2 = 0; i2 < 32; ++i2) {
                cvWords[i2] = (&output)->input_cv[i2];
            }
            blake3_compress_in_place(cvWords, (&output)->block, (&output)->block_len,
                                     (&output)->counter, (&output)->flags);
            for (ulong i11 = 0; i11 < 32; ++i11) {
                (&out[chunksArrayLen * BLAKE3_OUT_LEN])[i11] = cvWords[i11];
            }
            result = chunksArrayLen + 1;
        } else {
            result = chunksArrayLen;
        }
        return result;
    }

    ulong fullChunks = (input_len - 1) / BLAKE3_CHUNK_LEN;
    ulong x1 = fullChunks | 1;
    uint c = 0;
    if (x1 & 0xffffffff00000000LU) {
        x1 >>= 32;
        c += 32;
    }
    if (x1 & 0x00000000ffff0000LU) {
        x1 >>= 16;
        c += 16;
    }
    if (x1 & 0x000000000000ff00LU) {
        x1 >>= 8;
        c += 8;
    }
    if (x1 & 0x00000000000000f0LU) {
        x1 >>= 4;
        c += 4;
    }
    if (x1 & 0x000000000000000cLU) {
        x1 >>= 2;
        c += 2;
    }
    if (x1 & 0x0000000000000002LU) { c += 1; }
    ulong left_input_len = (1LU << c) * BLAKE3_CHUNK_LEN;
    ulong right_input_len = input_len - left_input_len;
    __global const uchar *right_input = &input[left_input_len];
    ulong right_chunk_counter =
            chunk_counter + (ulong)(left_input_len / BLAKE3_CHUNK_LEN);

    uchar cv_array[2 * MAX_SIMD_DEGREE_OR_2 * BLAKE3_OUT_LEN];
    ulong degree = 1;
    if (left_input_len > BLAKE3_CHUNK_LEN && degree == 1) {
        degree = 2;
    }
    uchar *right_cvs = &cv_array[degree * BLAKE3_OUT_LEN];

    ulong left_n = blake3_compress_subtree_wide(input, left_input_len, key,
                                                 chunk_counter, flags, cv_array);
    ulong right_n = blake3_compress_subtree_wide(
            right_input, right_input_len, key, right_chunk_counter, flags, right_cvs);

    if (left_n == 1) {
        for (ulong i = 0; i < 2 * BLAKE3_OUT_LEN; ++i) {
            out[i] = cv_array[i];
        }
        return 2;
    }

    ulong num_chaining_values = left_n + right_n;
    ulong result3;
#if defined(BLAKE3_TESTING)
    assert(2 <= num_chaining_values);
      assert(num_chaining_values <= 2 * MAX_SIMD_DEGREE_OR_2);
#endif

    const uchar *parentsArray[MAX_SIMD_DEGREE_OR_2];
    ulong parentsArrayLen = 0;
    while (num_chaining_values - (2 * parentsArrayLen) >= 2) {
        parentsArray[parentsArrayLen] =
                &cv_array[2 * parentsArrayLen * BLAKE3_OUT_LEN];
        parentsArrayLen += 1;
    }

    blake3_hash_many(parentsArray, parentsArrayLen, 1, key,
                     0,
                     false, flags | PARENT,
                     0,
                     0,
                     out);

    if (num_chaining_values > 2 * parentsArrayLen) {
        for (ulong i5 = 0; i5 < BLAKE3_OUT_LEN; ++i5) {
            (&out[parentsArrayLen * BLAKE3_OUT_LEN])[i5] = (&cv_array[2 * parentsArrayLen *
                                                                      BLAKE3_OUT_LEN])[i5];
        }
        result3 = parentsArrayLen + 1;
    } else {
        result3 = parentsArrayLen;
    }
    return result3;
}

void blake3_hasher_init(blake3_hasher *self) {
    for (ulong i = 0; i < BLAKE3_KEY_LEN; ++i) {
        self->key[i] = IV[i];
    }
    for (ulong i1 = 0; i1 < BLAKE3_KEY_LEN; ++i1) {
        (&self->chunk)->cv[i1] = IV[i1];
    }
    (&self->chunk)->chunk_counter = 0;
    for (ulong i1 = 0; i1 < BLAKE3_BLOCK_LEN; ++i1) {
        (&self->chunk)->buf[i1] = 0;
    }
    (&self->chunk)->buf_len = 0;
    (&self->chunk)->blocks_compressed = 0;
    (&self->chunk)->flags = 0;
    self->cv_stack_len = 0;
}

void blake3_hasher_init_keyed(blake3_hasher *self, const uchar key[BLAKE3_KEY_LEN]) {
    uint key_wordsasdfsaf[8];
    const uchar *p = (const uchar *) &key[0 * 4];
    key_wordsasdfsaf[0] = ((uint) (p[0]) << 0) | ((uint) (p[1]) << 8) |
                   ((uint) (p[2]) << 16) | ((uint) (p[3]) << 24);
    const uchar *p1 = (const uchar *) &key[1 * 4];
    key_wordsasdfsaf[1] = ((uint) (p1[0]) << 0) | ((uint) (p1[1]) << 8) |
                   ((uint) (p1[2]) << 16) | ((uint) (p1[3]) << 24);
    const uchar *p2 = (const uchar *) &key[2 * 4];
    key_wordsasdfsaf[2] = ((uint) (p2[0]) << 0) | ((uint) (p2[1]) << 8) |
                   ((uint) (p2[2]) << 16) | ((uint) (p2[3]) << 24);
    const uchar *p3 = (const uchar *) &key[3 * 4];
    key_wordsasdfsaf[3] = ((uint) (p3[0]) << 0) | ((uint) (p3[1]) << 8) |
                   ((uint) (p3[2]) << 16) | ((uint) (p3[3]) << 24);
    const uchar *p4 = (const uchar *) &key[4 * 4];
    key_wordsasdfsaf[4] = ((uint) (p4[0]) << 0) | ((uint) (p4[1]) << 8) |
                   ((uint) (p4[2]) << 16) | ((uint) (p4[3]) << 24);
    const uchar *p5 = (const uchar *) &key[5 * 4];
    key_wordsasdfsaf[5] = ((uint) (p5[0]) << 0) | ((uint) (p5[1]) << 8) |
                   ((uint) (p5[2]) << 16) | ((uint) (p5[3]) << 24);
    const uchar *p6 = (const uchar *) &key[6 * 4];
    key_wordsasdfsaf[6] = ((uint) (p6[0]) << 0) | ((uint) (p6[1]) << 8) |
                   ((uint) (p6[2]) << 16) | ((uint) (p6[3]) << 24);
    const uchar *p7 = (const uchar *) &key[7 * 4];
    key_wordsasdfsaf[7] = ((uint) (p7[0]) << 0) | ((uint) (p7[1]) << 8) |
                   ((uint) (p7[2]) << 16) | ((uint) (p7[3]) << 24);
    for (ulong i = 0; i < BLAKE3_KEY_LEN; ++i) {
        self->key[i] = key_wordsasdfsaf[i];
    }
    for (ulong i1 = 0; i1 < BLAKE3_KEY_LEN; ++i1) {
        (&self->chunk)->cv[i1] = key_wordsasdfsaf[i1];
    }
    (&self->chunk)->chunk_counter = 0;
    for (ulong i1 = 0; i1 < BLAKE3_BLOCK_LEN; ++i1) {
        (&self->chunk)->buf[i1] = 0;
    }
    (&self->chunk)->buf_len = 0;
    (&self->chunk)->blocks_compressed = 0;
    (&self->chunk)->flags = KEYED_HASH;
    self->cv_stack_len = 0;
}


void blake3_hasher_update(blake3_hasher *self, __global const void *input,
                          ulong input_len) {
    if (input_len == 0) {
        return;
    }

    __global const uchar *input_bytes = (__global const uchar *)input;

    if ((BLAKE3_BLOCK_LEN * (ulong) (&self->chunk)->blocks_compressed) +
        ((ulong) (&self->chunk)->buf_len) > 0) {
        ulong take = BLAKE3_CHUNK_LEN - ((BLAKE3_BLOCK_LEN * (ulong) (&self->chunk)->blocks_compressed) +
                                         ((ulong) (&self->chunk)->buf_len));
        if (take > input_len) {
            take = input_len;
        }
        __global uchar *input1 = input_bytes;
        ulong inputLen = take;
        if ((&self->chunk)->buf_len > 0) {
            ulong takel = BLAKE3_BLOCK_LEN - ((ulong) (&self->chunk)->buf_len);
            if (takel > inputLen) {
                takel = inputLen;
            }
            uchar *dest = (&self->chunk)->buf + ((ulong) (&self->chunk)->buf_len);
            for (ulong i12 = 0; i12 < takel; ++i12) {
                dest[i12] = input1[i12];
            }
            (&self->chunk)->buf_len += (uchar) takel;
            ulong take1 = takel;
            input1 += take1;
            inputLen -= take1;
            if (inputLen > 0) {
                uchar result;
                if ((&self->chunk)->blocks_compressed == 0) {
                    result = CHUNK_START;
                } else {
                    result = 0;
                }
                blake3_compress_in_place(
                        (&self->chunk)->cv, (&self->chunk)->buf, BLAKE3_BLOCK_LEN, (&self->chunk)->chunk_counter,
                        (&self->chunk)->flags | result);
                (&self->chunk)->blocks_compressed += 1;
                (&self->chunk)->buf_len = 0;
                for (ulong i3 = 0; i3 < BLAKE3_BLOCK_LEN; ++i3) {
                    (&self->chunk)->buf[i3] = 0;
                }
            }
        }

        while (inputLen > BLAKE3_BLOCK_LEN) {
            uchar result;
            if ((&self->chunk)->blocks_compressed == 0) {
                result = CHUNK_START;
            } else {
                result = 0;
            }
            blake3_compress_in_place((&self->chunk)->cv, input1, BLAKE3_BLOCK_LEN,
                                     (&self->chunk)->chunk_counter,
                                     (&self->chunk)->flags | result);
            (&self->chunk)->blocks_compressed += 1;
            input1 += BLAKE3_BLOCK_LEN;
            inputLen -= BLAKE3_BLOCK_LEN;
        }

        ulong take2 = BLAKE3_BLOCK_LEN - ((ulong) (&self->chunk)->buf_len);
        if (take2 > inputLen) {
            take2 = inputLen;
        }
        uchar *dest1 = (&self->chunk)->buf + ((ulong) (&self->chunk)->buf_len);
        for (ulong i21 = 0; i21 < take2; ++i21) {
            dest1[i21] = input1[i21];
        }
        (&self->chunk)->buf_len += (uchar) take2;
        ulong take1 = take2;
        input1 += take1;
        inputLen -= take1;
        input_bytes += take;
        input_len -= take;
        if (input_len > 0) {
            uchar result1;
            if ((&self->chunk)->blocks_compressed == 0) {
                result1 = CHUNK_START;
            } else {
                result1 = 0;
            }
            uchar blockFlags =
                    (&self->chunk)->flags | result1 | CHUNK_END;
            output_t ret;
            for (ulong i3 = 0; i3 < 32; ++i3) {
                ret.input_cv[i3] = (&self->chunk)->cv[i3];
            }
            for (ulong i12 = 0; i12 < BLAKE3_BLOCK_LEN; ++i12) {
                ret.block[i12] = (&self->chunk)->buf[i12];
            }
            ret.block_len = (&self->chunk)->buf_len;
            ret.counter = (&self->chunk)->chunk_counter;
            ret.flags = blockFlags;
            output_t output = ret;
            uchar chunk_cv[32];
            uint cvWords[8];
            for (ulong i2 = 0; i2 < 32; ++i2) {
                cvWords[i2] = (&output)->input_cv[i2];
            }
            blake3_compress_in_place(cvWords, (&output)->block, (&output)->block_len,
                                     (&output)->counter, (&output)->flags);
            for (ulong i11 = 0; i11 < 32; ++i11) {
                chunk_cv[i11] = cvWords[i11];
            }
            ulong x = self->chunk.chunk_counter;
            uint count = 0;
            while (x != 0) {
                count += 1;
                x &= x - 1;
            }
            ulong postMergeStackLen = (ulong) count;
            while (self->cv_stack_len > postMergeStackLen) {
                uchar *parentNode =
                        &self->cv_stack[(self->cv_stack_len - 2) * BLAKE3_OUT_LEN];
                output_t ret1;
                for (ulong i21 = 0; i21 < 32; ++i21) {
                    ret1.input_cv[i21] = self->key[i21];
                }
                for (ulong i111 = 0; i111 < BLAKE3_BLOCK_LEN; ++i111) {
                    ret1.block[i111] = parentNode[i111];
                }
                ret1.block_len = BLAKE3_BLOCK_LEN;
                ret1.counter = 0;
                ret1.flags = self->chunk.flags | PARENT;
                output_t output1 = ret1;
                uint cvWords1[8];
                for (ulong i13 = 0; i13 < 32; ++i13) {
                    cvWords1[i13] = (&output1)->input_cv[i13];
                }
                blake3_compress_in_place(cvWords1, (&output1)->block, (&output1)->block_len,
                                         (&output1)->counter, (&output1)->flags);
                for (ulong i13 = 0; i13 < 32; ++i13) {
                    parentNode[i13] = cvWords1[i13];
                }
                self->cv_stack_len -= 1;
            }
            for (ulong i4 = 0; i4 < BLAKE3_OUT_LEN; ++i4) {
                (&self->cv_stack[self->cv_stack_len * BLAKE3_OUT_LEN])[i4] = chunk_cv[i4];
            }
            self->cv_stack_len += 1;
            for (ulong i = 0; i < BLAKE3_KEY_LEN; ++i) {
                (&self->chunk)->cv[i] = self->key[i];
            }
            (&self->chunk)->chunk_counter = self->chunk.chunk_counter + 1;
            (&self->chunk)->blocks_compressed = 0;
            for (ulong i1 = 0; i1 < BLAKE3_BLOCK_LEN; ++i1) {
                (&self->chunk)->buf[i1] = 0;
            }
            (&self->chunk)->buf_len = 0;
        } else {
            return;
        }
    }

    while (input_len > BLAKE3_CHUNK_LEN) {
        ulong x1 = input_len | 1;
        uint c = 0;
        if (x1 & 0xffffffff00000000LU) {
            x1 >>= 32;
            c += 32;
        }
        if (x1 & 0x00000000ffff0000LU) {
            x1 >>= 16;
            c += 16;
        }
        if (x1 & 0x000000000000ff00LU) {
            x1 >>= 8;
            c += 8;
        }
        if (x1 & 0x00000000000000f0LU) {
            x1 >>= 4;
            c += 4;
        }
        if (x1 & 0x000000000000000cLU) {
            x1 >>= 2;
            c += 2;
        }
        if (x1 & 0x0000000000000002LU) { c += 1; }
        ulong subtree_len = 1LU << c;
        ulong count_so_far = self->chunk.chunk_counter * BLAKE3_CHUNK_LEN;
        while ((((ulong)(subtree_len - 1)) & count_so_far) != 0) {
            subtree_len /= 2;
        }
        ulong subtree_chunks = subtree_len / BLAKE3_CHUNK_LEN;
        if (subtree_len <= BLAKE3_CHUNK_LEN) {
            blake3_chunk_state chunk_state;
            for (ulong i = 0; i < BLAKE3_KEY_LEN; ++i) {
                (&chunk_state)->cv[i] = self->key[i];
            }
            (&chunk_state)->chunk_counter = 0;
            for (ulong i1 = 0; i1 < BLAKE3_BLOCK_LEN; ++i1) {
                (&chunk_state)->buf[i1] = 0;
            }
            (&chunk_state)->buf_len = 0;
            (&chunk_state)->blocks_compressed = 0;
            (&chunk_state)->flags = self->chunk.flags;
            chunk_state.chunk_counter = self->chunk.chunk_counter;
            __global uchar *input1 = input_bytes;
            ulong inputLen = subtree_len;
            if ((&chunk_state)->buf_len > 0) {
                ulong take1 = BLAKE3_BLOCK_LEN - ((ulong) (&chunk_state)->buf_len);
                if (take1 > inputLen) {
                    take1 = inputLen;
                }
                uchar *dest = (&chunk_state)->buf + ((ulong) (&chunk_state)->buf_len);
                for (ulong i12 = 0; i12 < take1; ++i12) {
                    dest[i12] = input1[i12];
                }
                (&chunk_state)->buf_len += (uchar) take1;
                ulong take = take1;
                input1 += take;
                inputLen -= take;
                if (inputLen > 0) {
                    uchar result;
                    if ((&chunk_state)->blocks_compressed == 0) {
                        result = CHUNK_START;
                    } else {
                        result = 0;
                    }
                    blake3_compress_in_place(
                            (&chunk_state)->cv, (&chunk_state)->buf, BLAKE3_BLOCK_LEN, (&chunk_state)->chunk_counter,
                            (&chunk_state)->flags | result);
                    (&chunk_state)->blocks_compressed += 1;
                    (&chunk_state)->buf_len = 0;
                    for (ulong i3 = 0; i3 < BLAKE3_BLOCK_LEN; ++i3) {
                        (&chunk_state)->buf[i3] = 0;
                    }
                }
            }

            while (inputLen > BLAKE3_BLOCK_LEN) {
                uchar result;
                if ((&chunk_state)->blocks_compressed == 0) {
                    result = CHUNK_START;
                } else {
                    result = 0;
                }
                blake3_compress_in_place((&chunk_state)->cv, input1, BLAKE3_BLOCK_LEN,
                                         (&chunk_state)->chunk_counter,
                                         (&chunk_state)->flags | result);
                (&chunk_state)->blocks_compressed += 1;
                input1 += BLAKE3_BLOCK_LEN;
                inputLen -= BLAKE3_BLOCK_LEN;
            }

            ulong take2 = BLAKE3_BLOCK_LEN - ((ulong) (&chunk_state)->buf_len);
            if (take2 > inputLen) {
                take2 = inputLen;
            }
            uchar *dest1 = (&chunk_state)->buf + ((ulong) (&chunk_state)->buf_len);
            for (ulong i21 = 0; i21 < take2; ++i21) {
                dest1[i21] = input1[i21];
            }
            (&chunk_state)->buf_len += (uchar) take2;
            ulong take = take2;
            input1 += take;
            inputLen -= take;
            uchar result2;
            if ((&chunk_state)->blocks_compressed == 0) {
                result2 = CHUNK_START;
            } else {
                result2 = 0;
            }
            uchar blockFlags =
                    (&chunk_state)->flags | result2 | CHUNK_END;
            output_t ret;
            for (ulong i4 = 0; i4 < 32; ++i4) {
                ret.input_cv[i4] = (&chunk_state)->cv[i4];
            }
            for (ulong i13 = 0; i13 < BLAKE3_BLOCK_LEN; ++i13) {
                ret.block[i13] = (&chunk_state)->buf[i13];
            }
            ret.block_len = (&chunk_state)->buf_len;
            ret.counter = (&chunk_state)->chunk_counter;
            ret.flags = blockFlags;
            output_t output = ret;
            uchar cv[BLAKE3_OUT_LEN];
            uint cvWords[8];
            for (ulong i2 = 0; i2 < 32; ++i2) {
                cvWords[i2] = (&output)->input_cv[i2];
            }
            blake3_compress_in_place(cvWords, (&output)->block, (&output)->block_len,
                                     (&output)->counter, (&output)->flags);
            for (ulong i11 = 0; i11 < 32; ++i11) {
                cv[i11] = cvWords[i11];
            }
            ulong x = chunk_state.chunk_counter;
            uint count = 0;
            while (x != 0) {
                count += 1;
                x &= x - 1;
            }
            ulong postMergeStackLen = (ulong) count;
            while (self->cv_stack_len > postMergeStackLen) {
                uchar *parentNode =
                        &self->cv_stack[(self->cv_stack_len - 2) * BLAKE3_OUT_LEN];
                output_t ret1;
                for (ulong i22 = 0; i22 < 32; ++i22) {
                    ret1.input_cv[i22] = self->key[i22];
                }
                for (ulong i111 = 0; i111 < BLAKE3_BLOCK_LEN; ++i111) {
                    ret1.block[i111] = parentNode[i111];
                }
                ret1.block_len = BLAKE3_BLOCK_LEN;
                ret1.counter = 0;
                ret1.flags = self->chunk.flags | PARENT;
                output_t output1 = ret1;
                uint cvWords1[8];
                for (ulong i14 = 0; i14 < 32; ++i14) {
                    cvWords1[i14] = (&output1)->input_cv[i14];
                }
                blake3_compress_in_place(cvWords1, (&output1)->block, (&output1)->block_len,
                                         (&output1)->counter, (&output1)->flags);
                for (ulong i14 = 0; i14 < 32; ++i14) {
                    parentNode[i14] = cvWords1[i14];
                }
                self->cv_stack_len -= 1;
            }
            for (ulong i5 = 0; i5 < BLAKE3_OUT_LEN; ++i5) {
                (&self->cv_stack[self->cv_stack_len * BLAKE3_OUT_LEN])[i5] = cv[i5];
            }
            self->cv_stack_len += 1;
        } else {
            uchar cv_pair[2 * BLAKE3_OUT_LEN];
#if defined(BLAKE3_TESTING)
            assert(input_len > BLAKE3_CHUNK_LEN);
#endif

            uchar cvArray[MAX_SIMD_DEGREE_OR_2 * BLAKE3_OUT_LEN];
            ulong numCvs = blake3_compress_subtree_wide(input_bytes, subtree_len, self->key,
                                                        self->chunk.chunk_counter, self->chunk.flags, cvArray);

            uchar outArray[MAX_SIMD_DEGREE_OR_2 * BLAKE3_OUT_LEN / 2];
            while (numCvs > 2) {
                ulong result;
#if defined(BLAKE3_TESTING)
                assert(2 <= num_chaining_values);
                  assert(num_chaining_values <= 2 * MAX_SIMD_DEGREE_OR_2);
#endif

                const uchar *parentsArray[MAX_SIMD_DEGREE_OR_2];
                ulong parentsArrayLen = 0;
                while (numCvs - (2 * parentsArrayLen) >= 2) {
                    parentsArray[parentsArrayLen] =
                            &cvArray[2 * parentsArrayLen * BLAKE3_OUT_LEN];
                    parentsArrayLen += 1;
                }

                blake3_hash_many(parentsArray, parentsArrayLen, 1, self->key,
                                 0,
                                 false, self->chunk.flags | PARENT,
                                 0,
                                 0,
                                 outArray);

                if (numCvs > 2 * parentsArrayLen) {
                    for (ulong i1 = 0; i1 < BLAKE3_OUT_LEN; ++i1) {
                        (&outArray[parentsArrayLen * BLAKE3_OUT_LEN])[i1] = (&cvArray[2 * parentsArrayLen *
                                                                                      BLAKE3_OUT_LEN])[i1];
                    }
                    result = parentsArrayLen + 1;
                } else {
                    result = parentsArrayLen;
                }
                numCvs =
                        result;
                for (ulong i = 0; i < numCvs * BLAKE3_OUT_LEN; ++i) {
                    cvArray[i] = outArray[i];
                }
            }
            for (ulong i1 = 0; i1 < 2 * BLAKE3_OUT_LEN; ++i1) {
                cv_pair[i1] = cvArray[i1];
            }
            ulong x = self->chunk.chunk_counter;
            uint count = 0;
            while (x != 0) {
                count += 1;
                x &= x - 1;
            }
            ulong postMergeStackLen = (ulong) count;
            while (self->cv_stack_len > postMergeStackLen) {
                uchar *parentNode =
                        &self->cv_stack[(self->cv_stack_len - 2) * BLAKE3_OUT_LEN];
                output_t ret;
                for (ulong i2 = 0; i2 < 32; ++i2) {
                    ret.input_cv[i2] = self->key[i2];
                }
                for (ulong i11 = 0; i11 < BLAKE3_BLOCK_LEN; ++i11) {
                    ret.block[i11] = parentNode[i11];
                }
                ret.block_len = BLAKE3_BLOCK_LEN;
                ret.counter = 0;
                ret.flags = self->chunk.flags | PARENT;
                output_t output = ret;
                uint cvWords[8];
                for (ulong i11 = 0; i11 < 32; ++i11) {
                    cvWords[i11] = (&output)->input_cv[i11];
                }
                blake3_compress_in_place(cvWords, (&output)->block, (&output)->block_len,
                                         (&output)->counter, (&output)->flags);
                for (ulong i11 = 0; i11 < 32; ++i11) {
                    parentNode[i11] = cvWords[i11];
                }
                self->cv_stack_len -= 1;
            }
            for (ulong i2 = 0; i2 < BLAKE3_OUT_LEN; ++i2) {
                (&self->cv_stack[self->cv_stack_len * BLAKE3_OUT_LEN])[i2] = cv_pair[i2];
            }
            self->cv_stack_len += 1;
            ulong x2 = self->chunk.chunk_counter + (subtree_chunks / 2);
            uint count1 = 0;
            while (x2 != 0) {
                count1 += 1;
                x2 &= x2 - 1;
            }
            ulong postMergeStackLen1 = (ulong) count1;
            while (self->cv_stack_len > postMergeStackLen1) {
                uchar *parentNode1 =
                        &self->cv_stack[(self->cv_stack_len - 2) * BLAKE3_OUT_LEN];
                output_t ret1;
                for (ulong i21 = 0; i21 < 32; ++i21) {
                    ret1.input_cv[i21] = self->key[i21];
                }
                for (ulong i111 = 0; i111 < BLAKE3_BLOCK_LEN; ++i111) {
                    ret1.block[i111] = parentNode1[i111];
                }
                ret1.block_len = BLAKE3_BLOCK_LEN;
                ret1.counter = 0;
                ret1.flags = self->chunk.flags | PARENT;
                output_t output1 = ret1;
                uint cvWords1[8];
                for (ulong i12 = 0; i12 < 32; ++i12) {
                    cvWords1[i12] = (&output1)->input_cv[i12];
                }
                blake3_compress_in_place(cvWords1, (&output1)->block, (&output1)->block_len,
                                         (&output1)->counter, (&output1)->flags);
                for (ulong i12 = 0; i12 < 32; ++i12) {
                    parentNode1[i12] = cvWords1[i12];
                }
                self->cv_stack_len -= 1;
            }
            for (ulong i3 = 0; i3 < BLAKE3_OUT_LEN; ++i3) {
                (&self->cv_stack[self->cv_stack_len * BLAKE3_OUT_LEN])[i3] = (&cv_pair[BLAKE3_OUT_LEN])[i3];
            }
            self->cv_stack_len += 1;
        }
        self->chunk.chunk_counter += subtree_chunks;
        input_bytes += subtree_len;
        input_len -= subtree_len;
    }

    if (input_len > 0) {
        __global uchar *input1 = input_bytes;
        ulong inputLen = input_len;
        if ((&self->chunk)->buf_len > 0) {
            ulong take1 = BLAKE3_BLOCK_LEN - ((ulong) (&self->chunk)->buf_len);
            if (take1 > inputLen) {
                take1 = inputLen;
            }
            uchar *dest = (&self->chunk)->buf + ((ulong) (&self->chunk)->buf_len);
            for (ulong i1 = 0; i1 < take1; ++i1) {
                dest[i1] = input1[i1];
            }
            (&self->chunk)->buf_len += (uchar) take1;
            ulong take = take1;
            input1 += take;
            inputLen -= take;
            if (inputLen > 0) {
                uchar result;
                if ((&self->chunk)->blocks_compressed == 0) {
                    result = CHUNK_START;
                } else {
                    result = 0;
                }
                blake3_compress_in_place(
                        (&self->chunk)->cv, (&self->chunk)->buf, BLAKE3_BLOCK_LEN, (&self->chunk)->chunk_counter,
                        (&self->chunk)->flags | result);
                (&self->chunk)->blocks_compressed += 1;
                (&self->chunk)->buf_len = 0;
                for (ulong i = 0; i < BLAKE3_BLOCK_LEN; ++i) {
                    (&self->chunk)->buf[i] = 0;
                }
            }
        }

        while (inputLen > BLAKE3_BLOCK_LEN) {
            uchar result;
            if ((&self->chunk)->blocks_compressed == 0) {
                result = CHUNK_START;
            } else {
                result = 0;
            }
            blake3_compress_in_place((&self->chunk)->cv, input1, BLAKE3_BLOCK_LEN,
                                     (&self->chunk)->chunk_counter,
                                     (&self->chunk)->flags | result);
            (&self->chunk)->blocks_compressed += 1;
            input1 += BLAKE3_BLOCK_LEN;
            inputLen -= BLAKE3_BLOCK_LEN;
        }

        ulong take2 = BLAKE3_BLOCK_LEN - ((ulong) (&self->chunk)->buf_len);
        if (take2 > inputLen) {
            take2 = inputLen;
        }
        uchar *dest1 = (&self->chunk)->buf + ((ulong) (&self->chunk)->buf_len);
        for (ulong i2 = 0; i2 < take2; ++i2) {
            dest1[i2] = input1[i2];
        }
        (&self->chunk)->buf_len += (uchar) take2;
        ulong take = take2;
        input1 += take;
        inputLen -= take;
        ulong x = self->chunk.chunk_counter;
        uint count = 0;
        while (x != 0) {
            count += 1;
            x &= x - 1;
        }
        ulong postMergeStackLen = (ulong) count;
        while (self->cv_stack_len > postMergeStackLen) {
            uchar *parentNode =
                    &self->cv_stack[(self->cv_stack_len - 2) * BLAKE3_OUT_LEN];
            output_t ret;
            for (ulong i21 = 0; i21 < 32; ++i21) {
                ret.input_cv[i21] = self->key[i21];
            }
            for (ulong i11 = 0; i11 < BLAKE3_BLOCK_LEN; ++i11) {
                ret.block[i11] = parentNode[i11];
            }
            ret.block_len = BLAKE3_BLOCK_LEN;
            ret.counter = 0;
            ret.flags = self->chunk.flags | PARENT;
            output_t output = ret;
            uint cvWords[8];
            for (ulong i3 = 0; i3 < 32; ++i3) {
                cvWords[i3] = (&output)->input_cv[i3];
            }
            blake3_compress_in_place(cvWords, (&output)->block, (&output)->block_len,
                                     (&output)->counter, (&output)->flags);
            for (ulong i11 = 0; i11 < 32; ++i11) {
                parentNode[i11] = cvWords[i11];
            }
            self->cv_stack_len -= 1;
        }
    }
}

void blake3_hasher_finalize(const blake3_hasher *self, __global uchar *out,
                            ulong out_len) {
    blake3_hasher_finalize_seek(self, 0, out, out_len);
}

void blake3_hasher_finalize_seek(const blake3_hasher *self,  ulong seek,
                                 __global uchar *out, ulong out_len) {

    if (out_len == 0) {
        return;
    }

    if (self->cv_stack_len == 0) {
        uchar result1;
        if ((&self->chunk)->blocks_compressed == 0) {
            result1 = CHUNK_START;
        } else {
            result1 = 0;
        }
        uchar blockFlags =
                (&self->chunk)->flags | result1 | CHUNK_END;
        output_t ret;
        for (ulong i1 = 0; i1 < 32; ++i1) {
            ret.input_cv[i1] = (&self->chunk)->cv[i1];
        }
        for (ulong i1 = 0; i1 < BLAKE3_BLOCK_LEN; ++i1) {
            ret.block[i1] = (&self->chunk)->buf[i1];
        }
        ret.block_len = (&self->chunk)->buf_len;
        ret.counter = (&self->chunk)->chunk_counter;
        ret.flags = blockFlags;
        output_t output = ret;
        __global uchar *out1 = out;
        ulong outLen = out_len;
        ulong outputBlockCounter = seek / 64;
        ulong offsetWithinBlock = seek % 64;
        uchar wideBuf[64];
        while (outLen > 0) {
            blake3_compress_xof((&output)->input_cv, (&output)->block, (&output)->block_len,
                                outputBlockCounter, (&output)->flags | ROOT, wideBuf);
            ulong availableBytes = 64 - offsetWithinBlock;
            ulong memcpyLen;
            if (outLen > availableBytes) {
                memcpyLen = availableBytes;
            } else {
                memcpyLen = outLen;
            }
            for (ulong i = 0; i < memcpyLen; ++i) {
                out1[i] = (wideBuf + offsetWithinBlock)[i];
            }
            out1 += memcpyLen;
            outLen -= memcpyLen;
            outputBlockCounter += 1;
            offsetWithinBlock = 0;
        }
        return;
    }
    output_t output;
    ulong cvs_remaining;
    if ((BLAKE3_BLOCK_LEN * (ulong) (&self->chunk)->blocks_compressed) +
        ((ulong) (&self->chunk)->buf_len) > 0) {
        cvs_remaining = self->cv_stack_len;
        uchar result1;
        if ((&self->chunk)->blocks_compressed == 0) {
            result1 = CHUNK_START;
        } else {
            result1 = 0;
        }
        uchar blockFlags =
                (&self->chunk)->flags | result1 | CHUNK_END;
        output_t ret;
        for (ulong i = 0; i < 32; ++i) {
            ret.input_cv[i] = (&self->chunk)->cv[i];
        }
        for (ulong i1 = 0; i1 < BLAKE3_BLOCK_LEN; ++i1) {
            ret.block[i1] = (&self->chunk)->buf[i1];
        }
        ret.block_len = (&self->chunk)->buf_len;
        ret.counter = (&self->chunk)->chunk_counter;
        ret.flags = blockFlags;
        output = ret;
    } else {
        cvs_remaining = self->cv_stack_len - 2;
        output_t ret;
        for (ulong i = 0; i < 32; ++i) {
            ret.input_cv[i] = self->key[i];
        }
        for (ulong i1 = 0; i1 < BLAKE3_BLOCK_LEN; ++i1) {
            ret.block[i1] = (&self->cv_stack[cvs_remaining * 32])[i1];
        }
        ret.block_len = BLAKE3_BLOCK_LEN;
        ret.counter = 0;
        ret.flags = self->chunk.flags | PARENT;
        output = ret;
    }
    while (cvs_remaining > 0) {
        cvs_remaining -= 1;
        uchar parent_block[BLAKE3_BLOCK_LEN];
        for (ulong i = 0; i < 32; ++i) {
            parent_block[i] = (&self->cv_stack[cvs_remaining * 32])[i];
        }
        uint cvWords[8];
        for (ulong i1 = 0; i1 < 32; ++i1) {
            cvWords[i1] = (&output)->input_cv[i1];
        }
        blake3_compress_in_place(cvWords, (&output)->block, (&output)->block_len,
                                 (&output)->counter, (&output)->flags);
        for (ulong i1 = 0; i1 < 32; ++i1) {
            (&parent_block[32])[i1] = cvWords[i1];
        }
        output_t ret;
        for (ulong i2 = 0; i2 < 32; ++i2) {
            ret.input_cv[i2] = self->key[i2];
        }
        for (ulong i11 = 0; i11 < BLAKE3_BLOCK_LEN; ++i11) {
            ret.block[i11] = parent_block[i11];
        }
        ret.block_len = BLAKE3_BLOCK_LEN;
        ret.counter = 0;
        ret.flags = self->chunk.flags | PARENT;
        output = ret;
    }
    __global uchar *out2 = out;
    ulong outLen1 = out_len;
    ulong outputBlockCounter1 = seek / 64;
    ulong offsetWithinBlock1 = seek % 64;
    uchar wideBuf1[64];
    while (outLen1 > 0) {
        blake3_compress_xof((&output)->input_cv, (&output)->block, (&output)->block_len,
                            outputBlockCounter1, (&output)->flags | ROOT, wideBuf1);
        ulong availableBytes1 = 64 - offsetWithinBlock1;
        ulong memcpyLen1;
        if (outLen1 > availableBytes1) {
            memcpyLen1 = availableBytes1;
        } else {
            memcpyLen1 = outLen1;
        }
        for (ulong i2 = 0; i2 < memcpyLen1; ++i2) {
            out2[i2] = (wideBuf1 + offsetWithinBlock1)[i2];
        }
        out2 += memcpyLen1;
        outLen1 -= memcpyLen1;
        outputBlockCounter1 += 1;
        offsetWithinBlock1 = 0;
    }
}



__kernel void vector_blake3(__global uint* A, __global uint *C, uint size) {
    uint i = get_global_id(0);
    blake3_hasher hasher;
    blake3_hasher_init(&hasher);
    blake3_hasher_update(&hasher, A + (i * 8), size);
    blake3_hasher_finalize(&hasher, C + (i * 8), sizeof(uint) * 8);
}
