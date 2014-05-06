//
//  TrieTree.h
//  Quill
//
//  Created by Shintaro Morikawa on 2013/11/14.
//  Copyright (c) 2013年 Shintaro Morikawa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "trie.h"

typedef struct _TrieNode TrieNode;

struct _TrieNode {
	TrieValue data;
	unsigned int use_count;
	TrieNode *next[256];
    TrieNode *parent;   //added
    unsigned int depth; //added
};

struct _Trie {
	TrieNode *root_node;
};

@interface TrieTree : NSObject

@property (strong, nonatomic) NSMutableArray *snippets;

+ (TrieTree *)sharedTrieTree;
- (BOOL)addSnippetWithKey:(NSString *)key andValue:(NSString *)val;
- (BOOL)removeSnippetWithKey:(NSString *)key;
- (TrieNode *)stateTransit:(unichar)character;
- (BOOL)updateSnippetKeyFrom:(NSString *)key_from To:(NSString *)key_to;

@end
