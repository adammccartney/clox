#include <stdlib.h>

#include "chunk.h"
#include "memory.h"

#define UINT8_LIM 256

void initChunk(Chunk* chunk) {
    chunk->count = 0;
    chunk->capacity = 0;
    chunk->code = NULL;
    chunk->lines = NULL;
    initValueArray(&chunk->constants);
}

void freeChunk(Chunk* chunk) {
    FREE_ARRAY(uint8_t, chunk->code, chunk->capacity);
    FREE_ARRAY(int, chunk->lines, chunk->capacity);
    freeValueArray(&chunk->constants);
    initChunk(chunk);
}

void writeChunk(Chunk* chunk, uint8_t byte, int line) {

    if (chunk->capacity < chunk->count + 1) {
        int oldCapacity = chunk->capacity;
        chunk->capacity = GROW_CAPACITY(oldCapacity);
        chunk->code = GROW_ARRAY(uint8_t, chunk->code,
                oldCapacity, chunk->capacity);
        chunk->lines = GROW_ARRAY(int, chunk->lines,
                oldCapacity, chunk->capacity);
    }

    chunk->code[chunk->count] = byte;
    chunk->lines[chunk->count] = line;
    chunk->count++;
}


int addConstant(Chunk* chunk, Value value) {
    writeValueArray(&chunk->constants, value);
    return chunk->constants.count - 1;
}

void writeConstant(Chunk* chunk, Value value, int line) {
    // call addConstant to get an index
    int index = addConstant(chunk, value);
    // check what size the index is
    if (index < UINT8_LIM)  { // is less than 256
        writeChunk(chunk, OP_CONSTANT, line);
    } else {
        writeChunk(chunk, OP_CONSTANT_LONG, line);
    }
}
