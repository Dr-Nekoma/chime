#import <Foundation/Foundation.h>

#include "Headers/Utilities.h"

bool findInEnumerator(NSEnumerator* enumerator, id key){
    bool found = false;
    for(NSString* key in enumerator){
        if([key isEqualToString:key]){
            found = true;
            break;
        }
    }
    return found;
}

uint32_t from64To32(uint64_t value){
    return 0xFFFFFFFF & value;
}

uint32_t packWord(OPCODE* opcodes){
    uint32_t word = 0;
    for(int i = 0; i < 6; i++){
        word = word << 5;
        word |= opcodes[i];
    }
    word = word << 2;
    return word;
}
