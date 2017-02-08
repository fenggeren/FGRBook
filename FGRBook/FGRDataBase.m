//
//  FGRDataBase.m
//  FGRBook
//
//  Created by fenggeren on 2016/10/13.
//  Copyright © 2016年 fenggeren. All rights reserved.
//

#import "FGRDataBase.h"
#import <sqlite3.h>
#import <QuartzCore/QuartzCore.h>
#import "FGRNovelModel.h"
#import "FGRChapterInfoModel.h"


static const NSUInteger kMaxErrorRetryCount = 8;
static const NSTimeInterval kMinRetryTimeInterval = 2.0;
static NSString *const kDBFileName = @"novels.sqlite";
static NSString *const kDBShmFileName = @"novels.sqlite-shm";
static NSString *const kDBWalFileName = @"novels.sqlite-wal";
static NSString *const kDataDirectoryName = @"data";
static NSString *const kTrashDirectoryName = @"trash";

@interface FGRDataBase ()

@property (nonatomic, copy) NSString *path;        ///< The path of this storage.
@property (nonatomic) BOOL errorLogsEnabled;

@end

@implementation FGRDataBase
{
    dispatch_queue_t _trashQueue;
    
    NSString *_path;
    NSString *_dbPath;
    NSString *_dataPath;
    NSString *_trashPath;
    
    sqlite3 *_db;
    CFMutableDictionaryRef _dbStmtCache;
    NSTimeInterval _dbLastOpenErrorTime;
    NSUInteger _dbOpenErrorCount;
}

#pragma mark - db

- (BOOL)_dbOpen {
    if (_db) return YES;
    
    int result = sqlite3_open(_dbPath.UTF8String, &_db);
    if (result == SQLITE_OK) {
        CFDictionaryKeyCallBacks keyCallbacks = kCFCopyStringDictionaryKeyCallBacks;
        CFDictionaryValueCallBacks valueCallbacks = {0};
        _dbStmtCache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &keyCallbacks, &valueCallbacks);
        _dbLastOpenErrorTime = 0;
        _dbOpenErrorCount = 0;
        return YES;
    } else {
        _db = NULL;
        if (_dbStmtCache) CFRelease(_dbStmtCache);
        _dbStmtCache = NULL;
        _dbLastOpenErrorTime = CACurrentMediaTime();
        _dbOpenErrorCount++;
        
        if (_errorLogsEnabled) {
            NSLog(@"%s line:%d sqlite open failed (%d).", __FUNCTION__, __LINE__, result);
        }
        return NO;
    }
}


- (BOOL)_dbClose {
    if (!_db) return YES;
    
    int  result = 0;
    BOOL retry = NO;
    BOOL stmtFinalized = NO;
    
    if (_dbStmtCache) CFRelease(_dbStmtCache);
    _dbStmtCache = NULL;
    
    do {
        retry = NO;
        result = sqlite3_close(_db);
        if (result == SQLITE_BUSY || result == SQLITE_LOCKED) {
            if (!stmtFinalized) {
                stmtFinalized = YES;
                sqlite3_stmt *stmt;
                while ((stmt = sqlite3_next_stmt(_db, nil)) != 0) {
                    sqlite3_finalize(stmt);
                    retry = YES;
                }
            }
        } else if (result != SQLITE_OK) {
            if (_errorLogsEnabled) {
                NSLog(@"%s line:%d sqlite close failed (%d).", __FUNCTION__, __LINE__, result);
            }
        }
    } while (retry);
    _db = NULL;
    return YES;
}

- (BOOL)_dbCheck {
    if (!_db) {
        if (_dbOpenErrorCount < kMaxErrorRetryCount &&
            CACurrentMediaTime() - _dbLastOpenErrorTime > kMinRetryTimeInterval) {
            return [self _dbOpen] && [self _dbInitialize];
        } else {
            return NO;
        }
    }
    return YES;
}

- (BOOL)_dbInitialize {
    NSString *sql = @"create table if not exists novels (url text, name text, imgURL text, author text, type text, updateDate text, briefIntroduction text, curIndex integer, chapterAmount integer, isUpdate integer, curChapterPageIndex integer, key text primary key);";
    return [self _dbExecute:sql];
}

- (BOOL)_dbCreateNovelChaptersFile:(NSString *)file
{
    NSString *sql = [NSString stringWithFormat:@"create table if not exists '%@' (url text, name text, content text, curIndex integer, key text primary key);", file]; 
    return [self _dbExecute:sql];
}

- (BOOL)_isExistWithFile:(NSString *)file
{
    if (file == nil || file.length == 0) {
        return NO;
    }

    NSString *sql = @"select count(*) from sqlite_master where type='table' and name=?1;";
    sqlite3_stmt *fileExistStmt = [self _dbPrepareStmt:sql];
    
    int result = sqlite3_bind_text(fileExistStmt, 1, file.UTF8String, -1, NULL);
    if (result != SQLITE_OK) {
        if (_errorLogsEnabled) NSLog(@"%s line:%d sqlite insert error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        return NO;
    }
    if (sqlite3_step(fileExistStmt) == SQLITE_ROW) {
        return sqlite3_column_int(fileExistStmt, 0) == 1;
    }
    return NO;
}

- (void)_dbCheckpoint {
    if (![self _dbCheck]) return;
    // Cause a checkpoint to occur, merge `sqlite-wal` file to `sqlite` file.
    sqlite3_wal_checkpoint(_db, NULL);
}

- (BOOL)_dbExecute:(NSString *)sql {
    if (sql.length == 0) return NO;
    if (![self _dbCheck]) return NO;
    
    char *error = NULL;
    int result = sqlite3_exec(_db, sql.UTF8String, NULL, NULL, &error);
    if (error) {
        if (_errorLogsEnabled) NSLog(@"%s line:%d sqlite exec error (%d): %s", __FUNCTION__, __LINE__, result, error);
        sqlite3_free(error);
    }
    
    return result == SQLITE_OK;
}


- (sqlite3_stmt *)_dbPrepareStmt:(NSString *)sql {
    if (![self _dbCheck] || sql.length == 0 || !_dbStmtCache) return NULL;
    sqlite3_stmt *stmt = (sqlite3_stmt *)CFDictionaryGetValue(_dbStmtCache, (__bridge const void *)(sql));
    if (!stmt) {
        int result = sqlite3_prepare_v2(_db, sql.UTF8String, -1, &stmt, NULL);
        if (result != SQLITE_OK) {
            if (_errorLogsEnabled) NSLog(@"%s line:%d sqlite stmt prepare error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
            return NULL;
        }
        CFDictionarySetValue(_dbStmtCache, (__bridge const void *)(sql), stmt);
    } else {
        sqlite3_reset(stmt);
    }
    return stmt;
}

- (NSString *)_dbJoinedKeys:(NSArray *)keys {
    NSMutableString *string = [NSMutableString new];
    for (NSUInteger i = 0,max = keys.count; i < max; i++) {
        [string appendString:@"?"];
        if (i + 1 != max) {
            [string appendString:@","];
        }
    }
    return string;
}

- (void)_dbBindJoinedKeys:(NSArray *)keys stmt:(sqlite3_stmt *)stmt fromIndex:(int)index{
    for (int i = 0, max = (int)keys.count; i < max; i++) {
        NSString *key = keys[i];
        sqlite3_bind_text(stmt, index + i, key.UTF8String, -1, NULL);
    }
}



- (BOOL)insertNovel:(FGRNovelModel *)novel
{
    NSString *sql = @"insert or replace into novels (key, url , name , imgURL , author , type , updateDate , briefIntroduction , curIndex, chapterAmount, isUpdate, curChapterPageIndex ) values (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10, ?11, ?12);";
    sqlite3_stmt *stmt = [self _dbPrepareStmt:sql];
    if(!stmt) return NO;
    
    sqlite3_bind_text(stmt, 1, novel.url.UTF8String, -1, NULL);
    sqlite3_bind_text(stmt, 2, novel.url.UTF8String, -1, NULL);
    sqlite3_bind_text(stmt, 3, novel.name.UTF8String, -1, NULL);
    sqlite3_bind_text(stmt, 4, novel.imgURL.UTF8String, -1, NULL);
    sqlite3_bind_text(stmt, 5, novel.author.UTF8String, -1, NULL);
    sqlite3_bind_text(stmt, 6, novel.type.UTF8String, -1, NULL);
    sqlite3_bind_text(stmt, 7, novel.updateDate.UTF8String, -1, NULL);
    sqlite3_bind_text(stmt, 8, novel.briefIntroduction.UTF8String, -1, NULL);
    sqlite3_bind_int(stmt, 9, (int)novel.curIndex);
    sqlite3_bind_int(stmt, 10, (int)novel.chapterAmount);
    sqlite3_bind_int(stmt, 11, novel.isUpdate);
    sqlite3_bind_int(stmt, 12, (int)novel.curChapterPageIndex);
    int result = sqlite3_step(stmt);
    if (result != SQLITE_DONE) {
        if (_errorLogsEnabled) NSLog(@"%s line:%d sqlite insert error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        return NO;
    }
    return YES;
}


- (BOOL)insertChapter:(FGRChapterInfoModel *)chapter forFile:(NSString *)file
{
    if (![self _isExistWithFile:file]) {
        [self _dbCreateNovelChaptersFile:file];
    }
    NSString *sql = [NSString stringWithFormat:@"insert or replace into '%@' (key, url , name , content) values (?1, ?2, ?3, ?4);", file];
    sqlite3_stmt *stmt = [self _dbPrepareStmt:sql];
    if(!stmt) return NO;
    
    sqlite3_bind_text(stmt, 1, chapter.url.UTF8String, -1, NULL);
    sqlite3_bind_text(stmt, 2, chapter.url.UTF8String, -1, NULL);
    sqlite3_bind_text(stmt, 3, chapter.name.UTF8String, -1, NULL);
    sqlite3_bind_text(stmt, 4, chapter.content.UTF8String, -1, NULL);
    
    int result = sqlite3_step(stmt);
    if (result != SQLITE_DONE) {
        if (_errorLogsEnabled) NSLog(@"%s line:%d sqlite insert error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        return NO;
    }
    return YES;
}

- (BOOL)removeNovelWithKeys:(NSArray<NSString *> *)keys
{
    if (![self _dbCheck]) return NO;
    NSString *sql =  [NSString stringWithFormat:@"delete from novels where key in (%@);", [self _dbJoinedKeys:keys]];
    sqlite3_stmt *stmt = NULL;
    int result = sqlite3_prepare_v2(_db, sql.UTF8String, -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        if (_errorLogsEnabled) NSLog(@"%s line:%d sqlite stmt prepare error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        return NO;
    }
    
    [self _dbBindJoinedKeys:keys stmt:stmt fromIndex:1];
    result = sqlite3_step(stmt);
    sqlite3_finalize(stmt);
    if (result == SQLITE_ERROR) {
        if (_errorLogsEnabled) NSLog(@"%s line:%d sqlite delete error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        return NO;
    }
    
    for (NSString * key in keys) {
        [self _fileDeleteWithName:key];
    }
    
    return YES;
}

- (BOOL)deleteTable:(NSString *)tableName
{
    if (![self _dbCheck]) return NO;
    NSString *sql =  [NSString stringWithFormat:@"DROP TABLE %@;", tableName];
    sqlite3_stmt *stmt = NULL;
    int result = sqlite3_prepare_v2(_db, sql.UTF8String, -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        if (_errorLogsEnabled) NSLog(@"%s line:%d sqlite stmt prepare error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        return NO;
    }
    
    result = sqlite3_step(stmt);
    sqlite3_finalize(stmt);
    if (result == SQLITE_ERROR) {
        if (_errorLogsEnabled) NSLog(@"%s line:%d sqlite delete error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        return NO;
    }
    
    [self _fileDeleteWithName:tableName];
    return YES;
}

#pragma mark Novel

- (FGRNovelModel *)_dbGetNovelFromStmt:(sqlite3_stmt *)stmt
{
    int i = 0;
    char *key = (char *)sqlite3_column_text(stmt, i++);
    char *url = (char *)sqlite3_column_text(stmt, i++);
    char *name = (char *)sqlite3_column_text(stmt, i++);
    char *imgURL = (char *)sqlite3_column_text(stmt, i++);
    char *author = (char *)sqlite3_column_text(stmt, i++);
    char *type = (char *)sqlite3_column_text(stmt, i++);
    char *updateDate = (char *)sqlite3_column_text(stmt, i++);
    char *briefIntroduction = (char *)sqlite3_column_text(stmt, i++);
    int curIndex = sqlite3_column_int(stmt, i++);
    int chapterAmount = sqlite3_column_int(stmt, i++);
    int isUpdate = sqlite3_column_int(stmt, i++);
    int curChapterPageIndex = sqlite3_column_int(stmt, i++);
    
    FGRNovelModel *novel = [[FGRNovelModel alloc] init];
    novel.url = [self _stringWithChar:url];
    novel.name = [self _stringWithChar:name];
    novel.imgURL = [self _stringWithChar:imgURL];
    novel.author = [self _stringWithChar:author];
    novel.type = [self _stringWithChar:type];
    novel.updateDate = [self _stringWithChar:updateDate];
    novel.briefIntroduction = [self _stringWithChar:briefIntroduction];
    novel.curIndex = curIndex;
    novel.chapterAmount = chapterAmount;
    novel.update = isUpdate;
    novel.curChapterPageIndex = curChapterPageIndex;
    return novel;
}



- (FGRNovelModel *)novelWithKey:(NSString *)key
{
    NSString *sql = @"select key, url , name , imgURL , author , type , updateDate , briefIntroduction , curIndex, chapterAmount, isUpdate, curChapterPageIndex from novels where key = ?1;";
    sqlite3_stmt *stmt = [self _dbPrepareStmt:sql];
    if (!stmt) return nil;
    sqlite3_bind_text(stmt, 1, key.UTF8String, -1, NULL);
    
    FGRNovelModel *novel = nil;
    int result = sqlite3_step(stmt);
    if (result == SQLITE_ROW) {
        novel = [self _dbGetNovelFromStmt:stmt];
    } else {
        if (result != SQLITE_DONE) {
            if (_errorLogsEnabled) NSLog(@"%s line:%d sqlite query error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        }
    }
 
    return novel;
}



- (NSArray<FGRNovelModel *> *)novelsWithKeys:(NSArray<NSString *> *)keys
{
    if (![self _dbCheck]) return nil;
    NSString *sql = [NSString stringWithFormat:@"select key, url , name , imgURL , author , type , updateDate , briefIntroduction , curIndex, chapterAmount, isUpdate, curChapterPageIndex, from novels where key in (%@);", [self _dbJoinedKeys:keys]];
    
    sqlite3_stmt *stmt = NULL;
    int result = sqlite3_prepare_v2(_db, sql.UTF8String, -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        if (_errorLogsEnabled) NSLog(@"%s line:%d sqlite stmt prepare error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        return nil;
    }
    
    [self _dbBindJoinedKeys:keys stmt:stmt fromIndex:1];
    NSMutableArray *items = [NSMutableArray new];
    do {
        result = sqlite3_step(stmt);
        if (result == SQLITE_ROW) {
            FGRNovelModel *item = [self _dbGetNovelFromStmt:stmt];
            if (item) [items addObject:item];
        } else if (result == SQLITE_DONE) {
            break;
        } else {
            if (_errorLogsEnabled) NSLog(@"%s line:%d sqlite query error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
            items = nil;
            break;
        }
    } while (1);
    sqlite3_finalize(stmt);
    return items;
}


#pragma mark Chapter
- (FGRChapterInfoModel *)_dbGetChapterFromStmt:(sqlite3_stmt *)stmt
{
    int i = 0;
    char *key = (char *)sqlite3_column_text(stmt, i++);
    char *url = (char *)sqlite3_column_text(stmt, i++);
    char *name = (char *)sqlite3_column_text(stmt, i++);
    char *content = (char *)sqlite3_column_text(stmt, i++);
    
    FGRChapterInfoModel *chapter = [[FGRChapterInfoModel alloc] initWithName:[self _stringWithChar:name] andURL:[self _stringWithChar:url] andContent:[self _stringWithChar:content]];
    return chapter;
}

- (FGRChapterInfoModel *)chapterWithKey:(NSString *)key fromFile:(NSString *)file
{
    if (![self _isExistWithFile:file]) {
        return nil;
    }
    NSString *sql = [NSString stringWithFormat:@"select key, url , name , content, curIndex from '%@' where key = ?1;", file];
    sqlite3_stmt *stmt = [self _dbPrepareStmt:sql];
    if (!stmt) return nil;
    sqlite3_bind_text(stmt, 1, key.UTF8String, -1, NULL);
    
    FGRChapterInfoModel *chapter = nil;
    int result = sqlite3_step(stmt);
    if (result == SQLITE_ROW) {
        chapter = [self _dbGetChapterFromStmt:stmt];
    } else {
        if (result != SQLITE_DONE) {
            if (_errorLogsEnabled) NSLog(@"%s line:%d sqlite query error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        }
    }
    return chapter;
}

- (BOOL)novelHasExistsWithKey:(NSString *)key
{
    NSString *sql = @"select count(*) from novels where key = ?1;";
    sqlite3_stmt *stmt = [self _dbPrepareStmt:sql];
    if (!stmt) return nil;
    sqlite3_bind_text(stmt, 1, key.UTF8String, -1, NULL);
    int result = sqlite3_step(stmt);
    if (result == SQLITE_ROW) {
        int count = sqlite3_column_int(stmt, 0);
        if (count > 0) {
            return YES;
        }
    } else {
        if (result != SQLITE_DONE) {
            if (_errorLogsEnabled) NSLog(@"%s line:%d sqlite query error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        }
    }
    return NO;
}

- (NSString *)chapterContentWithKey:(NSString *)key fromFile:(NSString *)file
{
    if (![self _isExistWithFile:file]) {
        return nil;
    }
    NSString *sql = [NSString stringWithFormat:@"select content from '%@' where key = ?1;", file];
    sqlite3_stmt *stmt = [self _dbPrepareStmt:sql];
    if (!stmt) return nil;
    sqlite3_bind_text(stmt, 1, key.UTF8String, -1, NULL);
    int result = sqlite3_step(stmt);
    if (result == SQLITE_ROW) {
        char *content = (char *)sqlite3_column_text(stmt, 0);
        return [self _stringWithChar:content];
    } else {
        if (result != SQLITE_DONE) {
            if (_errorLogsEnabled) NSLog(@"%s line:%d sqlite query error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        }
    }
    return nil;
}

- (NSString *)_stringWithChar:(char *)cr
{
    return cr == NULL ? nil : [NSString stringWithUTF8String:cr];
}

- (NSArray<FGRChapterInfoModel *> *)allChaptersFromFile:(NSString *)file
{
    if (![self _isExistWithFile:file]) {
        return nil;
    }
    if (![self _dbCheck]) return nil;
    NSString *sql = [NSString stringWithFormat:@"select key, url , name , content from '%@';",file];
    
    sqlite3_stmt *stmt = NULL;
    int result = sqlite3_prepare_v2(_db, sql.UTF8String, -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        if (_errorLogsEnabled) NSLog(@"%s line:%d sqlite stmt prepare error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        return nil;
    }
    
    NSMutableArray *items = [NSMutableArray new];
    do {
        result = sqlite3_step(stmt);
        if (result == SQLITE_ROW) {
            FGRChapterInfoModel *item = [self _dbGetChapterFromStmt:stmt];
            if (item) [items addObject:item];
        } else if (result == SQLITE_DONE) {
            break;
        } else {
            if (_errorLogsEnabled) NSLog(@"%s line:%d sqlite query error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
            items = nil;
            break;
        }
    } while (1);
    sqlite3_finalize(stmt);
    return items;
}


- (NSArray<FGRChapterInfoModel *> *)chaptersWithKeys:(NSArray<NSString *> *)keys fromFile:(NSString *)file
{
    if (![self _isExistWithFile:file]) {
        return nil;
    }
    if (![self _dbCheck]) return nil;
    NSString *sql = [NSString stringWithFormat:@"select key, url , name , content from %@ where key in (%@);",file, [self _dbJoinedKeys:keys]];
    
    sqlite3_stmt *stmt = NULL;
    int result = sqlite3_prepare_v2(_db, sql.UTF8String, -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        if (_errorLogsEnabled) NSLog(@"%s line:%d sqlite stmt prepare error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        return nil;
    }
    
    [self _dbBindJoinedKeys:keys stmt:stmt fromIndex:1];
    NSMutableArray *items = [NSMutableArray new];
    do {
        result = sqlite3_step(stmt);
        if (result == SQLITE_ROW) {
            FGRChapterInfoModel *item = [self _dbGetChapterFromStmt:stmt];
            if (item) [items addObject:item];
        } else if (result == SQLITE_DONE) {
            break;
        } else {
            if (_errorLogsEnabled) NSLog(@"%s line:%d sqlite query error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
            items = nil;
            break;
        }
    } while (1);
    sqlite3_finalize(stmt);
    return items;
}

#pragma mark - 

- (BOOL)_fileDeleteWithName:(NSString *)filename {
    NSString *path = [_dataPath stringByAppendingPathComponent:filename];
    return [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
}


#pragma mark --

- (instancetype)initWithPath:(NSString *)path
{
    
    self = [super init];
    _path = path.copy;
    _dataPath = [path stringByAppendingPathComponent:kDataDirectoryName];
    _trashPath = [path stringByAppendingPathComponent:kTrashDirectoryName];
    _trashQueue = dispatch_queue_create("com.ibireme.cache.disk.trash", DISPATCH_QUEUE_SERIAL);
    _dbPath = [path stringByAppendingPathComponent:kDBFileName];
    _errorLogsEnabled = YES;
    
    NSError *error = nil;
    if (![[NSFileManager defaultManager] createDirectoryAtPath:path
                                   withIntermediateDirectories:YES
                                                    attributes:nil
                                                         error:&error] ||
        ![[NSFileManager defaultManager] createDirectoryAtPath:[path stringByAppendingPathComponent:kDataDirectoryName]
                                   withIntermediateDirectories:YES
                                                    attributes:nil
                                                         error:&error] ||
        ![[NSFileManager defaultManager] createDirectoryAtPath:[path stringByAppendingPathComponent:kTrashDirectoryName]
                                   withIntermediateDirectories:YES
                                                    attributes:nil
                                                         error:&error]) {
            NSLog(@"YYKVStorage init error:%@", error);
            return nil;
        }
    
    if (![self _dbOpen] || ![self _dbInitialize]) {
        // db file may broken...
        [self _dbClose];
        if (![self _dbOpen] || ![self _dbInitialize]) {
            [self _dbClose];
            NSLog(@"YYKVStorage init error: fail to open sqlite db.");
            return nil;
        }
    }
    return self;
}


- (void)dealloc {
    [self _dbClose]; 
}

@end









