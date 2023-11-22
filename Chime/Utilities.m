//
//  Utilities.m
//  Chime
//
//  Created by Marcos Magueta on 21/11/23.
//

#import <Foundation/Foundation.h>


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
