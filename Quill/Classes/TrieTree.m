//
//  TrieTree.m
//  Quill
//
//  Created by Shintaro Morikawa on 2013/11/14.
//  Copyright (c) 2013年 Shintaro Morikawa. All rights reserved.
//

#import "TrieTree.h"

#define SNIPPET_FILE_PATH @"Contents/Resources/snippets.plist"

@interface TrieTree () {
    NSString *snippetFilePath_;
    NSMutableArray *snippets_;
    Trie *trie_;
    TrieNode *currentNode_;
}
@end

@implementation TrieTree

@synthesize snippets = snippets_;

static TrieTree *trieTree = nil;

+ (TrieTree *)sharedTrieTree {
	@synchronized(self) {
		if (trieTree == nil) {
			trieTree = [[self alloc] init];
		}
	}
	return trieTree;
}

- (id)init
{
    self = [super init];
    if (self) {
        NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
        snippetFilePath_ = [bundlePath stringByAppendingPathComponent:SNIPPET_FILE_PATH];
        
        //load Snippets from file
        snippets_ = [[NSMutableArray alloc] initWithContentsOfFile:snippetFilePath_];
        if (snippets_==NULL) {
            snippets_ = [[NSMutableArray alloc] init];
        }
        
        //Create Trie-tree from snippets dictionary
        [self createTrie];
    }
    return self;
}

- (void)createTrie {
    if (trie_!=NULL) {
        trie_free(trie_);
    }
    trie_ = trie_new();
    for (NSArray *snippet in snippets_) {
        [self insertNodeWithKey:snippet[0] andValue:snippet[1]];
    }
    currentNode_ = trie_->root_node;
}

- (BOOL)addSnippetWithKey:(NSString *)key andValue:(NSString *)val {
    BOOL result_write = NO, result_remove = NO, result_insert = NO;
    for (NSArray *pair in snippets_) {
        NSUInteger index = [snippets_ indexOfObject:pair];
        if ([pair[0] isEqualToString:key]) {
            [snippets_ replaceObjectAtIndex:[snippets_ indexOfObject:pair] withObject:@[key, val]];
            result_write = [self writeSnippetsToFile];
            result_insert = [self insertNodeWithKey:snippets_[index][0] andValue:snippets_[index][1]];
            return result_write && result_remove && result_insert;
        }
    }
    
    //when key does not exist
    result_insert = [self insertNodeWithKey:key andValue:val];
    
    [snippets_ addObject:@[key, val]];
    result_write = [self writeSnippetsToFile];
    
    return result_insert && result_write;
}

- (BOOL)removeSnippetWithKey:(NSString *)key {
    BOOL result_remove_from_trie = [self removeNodeWithKey:key];
    
    BOOL result_remove_from_array = NO;
    NSArray *snippetShoudBeRemoved = nil;
    for (NSArray *snippet in snippets_) {
        if ([snippet[0] isEqualToString:key]) {
            snippetShoudBeRemoved = snippet;
            break;
        }
    }
    if (snippetShoudBeRemoved) {
        [snippets_ removeObject:snippetShoudBeRemoved];
        result_remove_from_array = YES;
    }
    
    BOOL result_write = [self writeSnippetsToFile];
    
    return result_remove_from_trie && result_remove_from_array && result_write;
}

- (BOOL)updateSnippetKeyFrom:(NSString *)key_from To:(NSString *)key_to {
    BOOL result_write = NO, result_remove = NO, result_insert = NO;
    NSString *val;
    for (NSArray *pair in snippets_) {
        if ([pair[0] isEqualToString:key_from]) {
            val = [NSString stringWithString:pair[1]];
            [snippets_ replaceObjectAtIndex:[snippets_ indexOfObject:pair] withObject:@[key_to, val]];
            result_write = [self writeSnippetsToFile];
            
            result_insert = [self insertNodeWithKey:key_to andValue:val];
            
            return result_write && result_remove && result_insert;
        }
    }
    return NO;
}

- (BOOL)insertNodeWithKey:(NSString *)key andValue:(NSString *)val{
    char *c_key = (char *)[key UTF8String];
    char *c_val = (char *)[val UTF8String];
    BOOL result_insert = (BOOL)trie_insert(trie_, c_key, c_val);
    
    currentNode_ = trie_->root_node;
    
    return result_insert;
}

- (BOOL)removeNodeWithKey:(NSString *)key {
    char *c_key = (char *)[key UTF8String];
    BOOL result_remove = (BOOL)trie_remove(trie_, c_key);
    
    currentNode_ = trie_->root_node;
    
    return result_remove;
}

- (BOOL)writeSnippetsToFile {
    BOOL result = [snippets_ writeToFile:snippetFilePath_ atomically:YES];
    return result;
}

- (TrieNode *)stateTransit:(unichar)character {
    if (currentNode_==NULL) {
        return NULL;
    }
    
    TrieNode *accept;
    if (character==NSDeleteCharacter) {
        if (currentNode_!=trie_->root_node) {
            currentNode_ = currentNode_->parent;
        }
        accept = NULL;
    } else {
        TrieNode *next_node = currentNode_->next[character];
        if (next_node == NULL) {
            //next node does not exist
            if (trie_->root_node->next[character]) {
                currentNode_ = trie_->root_node->next[character];
            } else {
                currentNode_ = trie_->root_node;
            }
            accept = NULL;
        } else if (next_node->data == TRIE_NULL) {
            //next node exists
            currentNode_ = next_node;
            accept = NULL;
        } else {
            //accept state
            currentNode_ = trie_->root_node;
            accept = next_node;
        }
    }
    [self displayChildren:currentNode_];
    return accept;
}

//for debug
- (void)displayChildren:(TrieNode *)parent{
    TrieNode *next;
    for (int i=0; i<256; i++) {
        next = parent->next[i];
        if (next!=NULL) {
            if (next->data!=NULL) {
                printf("[%c] ",i);
            } else {
                printf("%c ",i);
            }
        }
    }
    printf("\n");
}

@end
